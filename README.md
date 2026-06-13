# dotfiles

My macOS setup — kitty · zsh (oh-my-zsh) · Karabiner-Elements. Open this when setting up a Mac.

## New Mac

```bash
xcode-select --install     # git + build tools
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install --cask kitty karabiner-elements
brew install fzf
# install a JetBrainsMono Nerd Font

git clone https://github.com/spashii/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` symlinks kitty + zsh, installs oh-my-zsh + plugins, and seeds the Karabiner config. Re-runnable; backs up anything it replaces.

By hand after: open a new terminal tab · Karabiner → grant Accessibility + approve the driver extension.

## Second account (share configs + models)

One Mac, two accounts — share configs and the big model stores instead of duplicating them:

```bash
~/dotfiles/share.sh host    # main account: set up the shared store under /Users/Shared
~/dotfiles/share.sh join    # other account: link to it (also installs oh-my-zsh)
```

| Shared (one copy, both accounts) | Per-account |
|---|---|
| kitty, zsh, Ollama models, Whisper models | Karabiner (it rewrites its own file — can't be shared) |

Don't run Ollama in both accounts at once (single server on `:11434`).

## Gotchas

- **Karabiner** config is *copied*, never symlinked — it overwrites symlinks on save.
- **Ollama** ignores `OLLAMA_MODELS` on macOS 15+; we symlink `~/.ollama/models` to the shared store instead.
- **Whisper** model downloads as `0600`; sharing makes it group-readable.

## Branches

- `linux-2020` — the old vim/tmux/zsh setup.
