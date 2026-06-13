# dotfiles

my macOS setup

- git, build tools: `xcode-select --install`
- homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- kitty, zsh, karabiner, opensuperwhisper, ollama: `git clone https://github.com/spashii/dotfiles ~/dotfiles && ~/dotfiles/install.sh`
    - after: new terminal tab, grant karabiner Accessibility, approve its driver extension
- second account, share configs + ollama/whisper models: `~/dotfiles/share.sh host`, then `~/dotfiles/share.sh join` on the other account
    - don't run ollama in both accounts at once (one server on :11434)
- mos: `brew install --cask mos` (MX Master scroll fix: [baty.net](https://baty.net/posts/2025/03/fixing-the-terrible-scrolling-behavior-with-logitech-mx-master-on-mac-os/))
- raycast: `brew install --cask raycast`
- cursor: `brew install --cask cursor`
- docker: `brew install --cask docker-desktop`
- gh: `brew install gh`, then `gh auth login`
- asdf: `brew install asdf` (node, python, bun)
- claude code: `curl -fsSL https://claude.ai/install.sh | bash`
- codex: `curl -fsSL https://chatgpt.com/codex/install.sh | sh`
- touch-id sudo: `sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local`
