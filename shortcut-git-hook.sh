#!/bin/env bash

token="PUT-SHORTCUT-API-TOKEN-HERE"

echo "Link to shortcut story (y/N)?"
read linkWanted

if [[ "${linkWanted,,}" != "y" ]]; then
    echo "Won't link"
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
    echo "Story search cancelled"
    exit mandateLinks
fi

url=$(echo $search | jq -r ".[] | select(.name==$selected) | .app_url")
output="Shortcut: $url"
echo $output
