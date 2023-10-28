#!/bin/env bash

msgFile=$1

if grep -q "^Shortcut: " "$msgFile"; then
    echo "Message contains a shortcut link already"
    exit
fi

# This should allow for user input
exec < /dev/tty

token="PUT-SHORTCUT-API-TOKEN-HERE"

read -p "Link to shortcut story (y/N)?" linkWanted

if [[ "${linkWanted,,}" != "y" ]]; then
    echo "Won't add link"
    exit
fi

echo "Search for stories"
read query

search=$(curl -X GET \
    -H "Content-Type: application/json" \
    -H "Shortcut-Token: $token" \
    -d '{ "detail": "slim", "page_size": 25, "query": "'$query'" }' \
    -L "https://api.app.shortcut.com/api/v3/search/stories" \
    | jq '.data | map ({ name, app_url })')

selected=$(echo $search | jq '.[] | .name' | fzf)
if [[ $? -ne 0 ]]; then
    echo "Story search cancelled, won't add link"
    exit
fi

url=$(echo $search | jq -r ".[] | select(.name==$selected) | .app_url")
output="Shortcut: $url"
# Substitute the first line that starts with a # with a newline, output, newline and itself (&)
# Largely from https://stackoverflow.com/questions/30386483/command-to-insert-lines-before-first-match
# Because url contains /, use | for delimiter for the second part
sed -i "0,/^#.*/s|^#.*|\n$output\n&|" $msgFile
