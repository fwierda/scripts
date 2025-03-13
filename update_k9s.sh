#!/usr/bin/env bash
set -eo pipefail

echo "Checking for new K9S version"

PKG_NAME="k9s_linux_amd64.deb"

INSTALLED=$(dpkg -s k9s | grep -e "^Version:" | cut -d : -f2 | tr -d "[:space:]")

RELEASES=$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/derailed/k9s/releases?per_page=1)

AVAILABLE=$(echo $RELEASES | jq -r ".[0].name" | tr -d "v")

if [[ "$INSTALLED" == "$AVAILABLE" ]]; then
    echo "Latest version already installed. All done."
    exit 0
fi

LOWEST=$(echo -e "$INSTALLED\n$AVAILABLE" | sort -V | head -n 1)

if [[ "$LOWEST" == "$AVAILABLE" ]]; then
    echo "Installed version is higher than latest. Exiting."
    exit 255
fi

URI=$(echo $RELEASES | jq -r ".[0].assets | \
    map(select(.name | test(\".?_amd64.deb\"))) \
    | .[0].browser_download_url")

echo "Found new release $AVAILABLE"

curl -sLo /tmp/$PKG_NAME $URI

sudo dpkg -i /tmp/$PKG_NAME

rm /tmp/$PKG_NAME
