#!/usr/bin/env bash

POLICIES_FILE="/usr/share/librewolf/distribution/policies.json"

# Is Google blocked? (This happens when LibreWolf is updated)
GOOGLE_BLOCKED=$(jq '.policies.SearchEngines.Remove | map(select(. == "Google")) | length > 0' $POLICIES_FILE)

# Nothing to do here
if [[ "$GOOGLE_BLOCKED" == "false" ]]; then
    exit 0
fi

# Definition of the Google SearchEngine
SEARCH_ENGINE="{
          \"Description\": \"Google\",
          \"IconURL\": \"https://www.google.com/favicon.ico\",
          \"Method\": \"GET\",
          \"Name\": \"Google\",
          \"URLTemplate\": \"https://www.google.com/search?q={searchTerms}\"
        }"

# Remove blockage, inject search engine and set it as default
UPDATE=$(jq ".policies.Extensions.Uninstall |= map(select(. != \"google@search.mozilla.org\")) |
         .policies.SearchEngines.Remove |= map(select(. != \"Google\")) |
         .policies.SearchEngines.Default = \"Google\" |
         .policies.SearchEngines.Add += [$SEARCH_ENGINE]" \
         $POLICIES_FILE)

# Back up the config file
sudo cp $POLICIES_FILE $POLICIES_FILE.$(date +%Y%m%d%H%M%S)

# Write the new config
echo $UPDATE | jq . | sudo tee $POLICIES_FILE > /dev/null

# Clean up back ups
ls -t ${POLICIES_FILE}.* | tail -n +3 | while read file; do
    sudo rm -- $file
done
