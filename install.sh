#!/bin/env bash

set -euo pipefail

# This should fail if not in a git repo
destination=`git rev-parse --git-dir`/hooks/shortcut-git-hook.sh
hookDir=$(dirname $destination)
mkdir -p $hookDir

read -s -p "Give shortcut api token: " token

# Just some request to test the token works. This should fail if the token was invalid
curl -X GET \
  -H "Content-Type: application/json" \
  -H "Shortcut-Token: $token" \
  -L "https://api.app.shortcut.com/api/v3/categories"

curl -Lo $destination https://raw.githubusercontent.com/haihala/shortcut-hook/main/shortcut-git-hook.sh
chmod +x $destination
sed -i "s/PUT-SHORTCUT-API-TOKEN-HERE/$token/g" $destination

# This is done this way so that the existing gerrit hook is not bothered
echo "exec $destination \$1" >> "$hookDir/commit-msg"
chmod +x $hookDir/commit-msg

echo "Hook installed"
