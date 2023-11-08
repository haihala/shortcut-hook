#!/usr/bin/env bash

msgFile=$1

# This should allow for user input
exec </dev/tty

# Entered during installation
token="PUT-SHORTCUT-API-TOKEN-HERE"

osSed() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v gsed >/dev/null; then
            echo "Please install gnu-sed"
            exit
        fi
        gsed "$@"
    else
        sed "$@"
    fi
}

echo "Commit: " $(head -n 1 $msgFile)

function hookInFile() {
    grep -q "^Shortcut: " "$msgFile"
}

if $(hookInFile); then
    echo "Message contains a shortcut link already"
    exit
fi

echo "Do you want to link that commit to shortcut story?"
echo
echo "Yes! - Enter a query to search for stories"
echo "No! - Enter an empty string"
read -e query

if [ -z "$query" ]; then # Empty string
    echo "Roger that, NOT adding link"
    exit
fi

function queryShortcut() {
    out=$(curl -s -X GET \
        -H "Content-Type: application/json" \
        -H "Shortcut-Token: $token" \
        -d '{ "detail": "slim", "page_size": 25, "query": "'"$1"'"}' \
        -L 'https://api.app.shortcut.com/api/v3/search/stories' |
        jq '.data | map ({ name, app_url })')

    if [[ $(echo $out | jq 'length') -eq "0" ]]; then
        echo "Search for \"$1\" returned nothing, can't add link"
        exit 1
    fi

    echo $out
}

search=$(queryShortcut $query)

long_arg="curl -s \
    -X GET \
    -H 'Content-Type: application/json' \
    -H 'Shortcut-Token: $token' \
    -d '{ \"detail\": \"slim\", \"page_size\": 25, \"query\": \"{q}\" }' \
    -L 'https://api.app.shortcut.com/api/v3/search/stories' \
    | jq -r '.data | .[] | .name'"

selected=$(
    echo $search |
        jq -r '.[] | .name' |
        fzf \
            --header 'Press ctrl-r to re-query shortcut with the search term' \
            --bind "ctrl-r:reload:$long_arg"
)

if [[ $? -ne 0 ]]; then
    echo "Story selection cancelled, won't add link"
    exit
fi

url=$(echo $search | jq -r '.[] | select(.name=="'"$selected"'") | .app_url')

if [[ -z "$url" ]]; then
    # Because how fzf refresh works, we need a second query for the url
    # We could instead contain the url in the fzf view, but that seems ugly
    url=$(queryShortcut $selected | jq -r '.[] | select(.name=="'"$selected"'") | .app_url')
fi

output="Shortcut: $url"

# Largely from https://stackoverflow.com/questions/30386483/command-to-insert-lines-before-first-match
# Because url contains /, use | for delimiter for the second part
if grep -q "^Change-Id: " $msgFile; then
    # Gerrit hook has ran and it expects the change-id to be
    # the last line so place the link before that

    # Substitute the first line that starts with a "Change-Id:" with a newline, output, newline and itself (&)
    osSed -i.bak "0,/^Change\-Id: .*/s|^Change\-Id: .*|\n$output\n&|" $msgFile
else
    # Substitute the first line that starts with a # with a newline, output, newline and itself (&)
    osSed -i.bak "0,/^#.*/s|^#.*|\n$output\n&|" $msgFile

    # Sometimes, there are no comments in $msgFile, in those cases just put it in the end
    if ! $(hookInFile); then
        echo >>$msgFile
        echo $output >>$msgFile
    fi
fi
