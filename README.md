# Shortcut hook

A git hook that can let you fuzzy find shortcut stories to link to the commit message

## Install the hook

Steps:

1. Install dependencies
    1. For ubuntu: `sudo apt install bash jq fzf curl sed`
    2. For mac: `brew install bash jq fzf curl gnu-sed` (Not tested)
    3. Anything else: Figure it out, I believe in you.
2. Get a shortcut API token from [here](https://app.shortcut.com/settings/account/api-tokens)
3. Run the installation script (it will prompt for token, paste it in even if you don't see any change)


Installation script can be ran with:
```bash
curl https://raw.githubusercontent.com/haihala/shortcut-hook/main/install.sh | bash
```

## Usage

After commiting, you will be prompted to add a shortcut link. Entering anything
besides "y" or "Y" will cause nothing to happen.

After that, you will be prompted to search for stories. Your search term
doesn't have to be that accurate, just something to put the desired story in
the top 25.

After that, fzf (a fuzzy finder) will let you pick one from the list of options
the search term returned.

After you select one, the link to that will be inserted to the commit message
with a "Shortcut: " -prefix

