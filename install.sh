#!/usr/bin/env bash

set -euo pipefail

# This should fail if not in a git repo
destination=$(git rev-parse --git-dir)/hooks/shortcut-git-hook.sh
hookDir=$(dirname $destination)
mkdir -p $hookDir

read -s -p "Give shortcut api token: " token

echo
echo "Testing token"

curl -s -X GET \
    --fail \
    -H "Content-Type: application/json" \
    -H "Shortcut-Token: $token" \
    -L "https://api.app.shortcut.com/api/v3/categories" ||
    (echo "Invalid token" && exit 1)

echo
echo "Token works"

curl -Lo $destination https://raw.githubusercontent.com/haihala/shortcut-hook/main/shortcut-git-hook.sh
chmod +x $destination

# OSX sed is funny, use gnu-sed if available (listed as dependency)
sed -i.bak "s/PUT-SHORTCUT-API-TOKEN-HERE/$token/g" $destination

# This is done this way so that the existing gerrit hook is not bothered
launch="exec $destination \$1"

msgFile=$hookDir/commit-msg
touch $msgFile
chmod +x $msgFile

if grep -q "$launch" "$msgFile"; then
    echo "Updated script and token"
    echo "Hook already stared from commit-msg not adding it again"
else
    echo $launch >>"$msgFile"
    echo "Hook installed"
fi
