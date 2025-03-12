#!/usr/bin/env bash
if [[ $# < 1 ]]; then
    read -a USERS -p "Lookup which user(s)? "
else
    USERS=( "$@" )
fi

for user in ${USERS[@]}; do
    UINFO=$(grep -e "^${user}:.*" /etc/passwd) \
        && echo "User ${user}'s default shell is "$(echo $UINFO | cut -d ":" -f7 ) \
        || echo "User ${user} not found."
done
