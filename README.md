# dotfiles

my macOS setup

- git, build tools: `xcode-select --install`
- homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- kitty, zsh, karabiner, opensuperwhisper, ollama: `git clone https://github.com/spashii/dotfiles ~/dotfiles && ~/dotfiles/install.sh`
    - after: new terminal tab, grant karabiner Accessibility, approve its driver extension
- second account, share configs + ollama/whisper models: `~/dotfiles/share.sh host`, then `~/dotfiles/share.sh join` on the other account
    - don't run ollama in both accounts at once (one server on :11434)
- `brew install --cask raycast cursor docker-desktop mos`
    - mos: MX Master scroll fix ([baty.net](https://baty.net/posts/2025/03/fixing-the-terrible-scrolling-behavior-with-logitech-mx-master-on-mac-os/))
- `brew install gh`, then `gh auth login`
- `brew install asdf`, then:
    - `asdf plugin add nodejs && asdf install nodejs latest && asdf set nodejs latest`
    - `asdf plugin add python && asdf install python latest && asdf set python latest`
- `curl -fsSL https://bun.sh/install | bash`
- `curl -fsSL https://claude.ai/install.sh | bash`
- `curl -fsSL https://chatgpt.com/codex/install.sh | sh`
- touch-id sudo: `sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local`
