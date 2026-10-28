# dotfiles

my macOS setup

- git, build tools: `xcode-select --install`
- homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- everything else: `git clone https://github.com/spashii/dotfiles ~/dotfiles && ~/dotfiles/install.sh`
    - apps and CLIs from `Brewfile`, zsh, node + python via asdf, kitty, karabiner, touch-id sudo
    - run it from a local terminal: karabiner, windows-app and touch-id ask for your password
    - Xcode comes from the App Store: sign in there first or it is skipped
    - `~/.zshenv` is linked so asdf shims are available in non-interactive zsh shells too
- after: new terminal tab, then `~/dotfiles/signin.sh` walks through every sign-in and permission
    - mos: MX Master scroll fix ([baty.net](https://baty.net/posts/2025/03/fixing-the-terrible-scrolling-behavior-with-logitech-mx-master-on-mac-os/))
- by hand: DaVinci Resolve from blackmagicdesign.com (not in Homebrew)
- second account, share configs + ollama/whisper models: `~/dotfiles/share.sh host`, then `~/dotfiles/share.sh join` on the other account
    - don't run ollama in both accounts at once (one server on :11434)
