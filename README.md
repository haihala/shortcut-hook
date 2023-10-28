# Shortcut hook

A git hook that can let you fuzzy find shortcut stories to link to the commit message

## Install the hook

Steps:

1. Install dependencies
    1. For ubuntu: `sudo apt install bash jq fzf curl sed`
    2. For mac: `brew install bash jq fzf curl gnu-sed` (Not tested)
    3. Anything else: Figure it out
2. Get a shortcut API token from [here](https://app.shortcut.com/settings/account/api-tokens)
3. Run the installation script (it will prompt for token, paste it in even if you don't see any change)


Installation script can be ran with:
```bash
curl https://raw.githubusercontent.com/haihala/shortcut-hook/main/install.sh | bash
```

## Usage

Because shortcut search works how it does, the script will first prompt for a search term.
This doesn't need to be that precise, just enough for what you want to be in the 25 top results
After that, the script will prompt you to select one of them by name. It will then add the link
to the commit message.
