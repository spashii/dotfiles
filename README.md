# dotfiles

my macOS setup — kitty · zsh · Karabiner · OpenSuperWhisper · Ollama

- `xcode-select --install` — git + build tools
- homebrew — `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- **setup** — installs + configures kitty, zsh, Karabiner, OpenSuperWhisper, Ollama:
  `git clone https://github.com/spashii/dotfiles ~/dotfiles && ~/dotfiles/install.sh`
  then: new terminal tab · Karabiner → grant Accessibility + approve driver extension
- **second account** — share configs + Ollama/Whisper models via `/Users/Shared`:
  `~/dotfiles/share.sh host`, then `~/dotfiles/share.sh join` in the other account
  (don't run Ollama in both accounts at once — one server on `:11434`)
- mos — `brew install --cask mos` · [MX Master scroll fix](https://baty.net/posts/2025/03/fixing-the-terrible-scrolling-behavior-with-logitech-mx-master-on-mac-os/)
- raycast — `brew install --cask raycast`
- cursor — `brew install --cask cursor`
- docker — `brew install --cask docker-desktop`
- gh — `brew install gh` · `gh auth login`
- asdf — `brew install asdf` · then node / python / bun
- claude code / codex — `curl -fsSL https://claude.ai/install.sh | bash` · `curl -fsSL https://chatgpt.com/codex/install.sh | sh`
- touch-id for sudo — `sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local`

`linux-2020` branch = old vim/tmux/zsh setup.
