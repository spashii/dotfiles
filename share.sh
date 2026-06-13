#!/bin/bash
# Share configs + model stores across two accounts on one Mac, via /Users/Shared.
#   main account:   ~/dotfiles/share.sh host
#   other account:  ~/dotfiles/share.sh join
# Idempotent; backs up anything it replaces to *.bak.<ts>.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SH=/Users/Shared
TS=$(date +%s)

link() {  # $1 = home path, $2 = shared target
  local dst="$1" src="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then echo "  ok: $dst"; return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then mv "$dst" "$dst.bak.$TS"; echo "  backed up $dst"; fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst" && echo "  linked $dst -> $src"
}

omz() {  # per-account oh-my-zsh + plugins (not shared: its updater would race)
  [ -d ~/.oh-my-zsh ] || RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  local c=~/.oh-my-zsh/custom/plugins; mkdir -p "$c"
  [ -d "$c/zsh-autosuggestions" ]     || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$c/zsh-autosuggestions"
  [ -d "$c/fast-syntax-highlighting" ] || git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting "$c/fast-syntax-highlighting"
  [ -d "$c/fzf-tab" ]                 || git clone --depth=1 https://github.com/Aloxaf/fzf-tab "$c/fzf-tab"
}

karabiner() {  # per-account COPY — never a symlink (Karabiner rewrites the file)
  mkdir -p ~/.config/karabiner
  [ -f ~/.config/karabiner/karabiner.json ] || cp "$REPO/karabiner/karabiner.json" ~/.config/karabiner/karabiner.json
}

WHISPER="$HOME/Library/Application Support/ru.starmel.OpenSuperWhisper/whisper-models"

case "${1:-}" in
host)
  echo "== host: building shared store at $SH =="
  mkdir -p "$SH/dotfiles" "$SH/models"
  chgrp staff "$SH/dotfiles" "$SH/models" 2>/dev/null
  chmod 2775 "$SH/dotfiles" "$SH/models" 2>/dev/null
  # configs: seed shared from the repo, then link this account at them
  [ -d "$SH/dotfiles/kitty" ] || cp -R "$REPO/kitty" "$SH/dotfiles/kitty"
  [ -f "$SH/dotfiles/zshrc" ] || cp "$REPO/zsh/zshrc" "$SH/dotfiles/zshrc"
  echo "kitty:"; link ~/.config/kitty "$SH/dotfiles/kitty"
  echo "zsh:";   omz; link ~/.zshrc "$SH/dotfiles/zshrc"
  echo "karabiner:"; karabiner
  # ollama models -> shared (instant rename, same volume)
  echo "ollama:"
  if [ -d ~/.ollama/models ] && [ ! -L ~/.ollama/models ]; then
    osascript -e 'quit app "Ollama"' 2>/dev/null; pkill -f "ollama serve" 2>/dev/null; sleep 1
    [ -d "$SH/models/ollama" ] || mv ~/.ollama/models "$SH/models/ollama"
    rm -rf ~/.ollama/models
  fi
  mkdir -p ~/.ollama "$SH/models/ollama"; link ~/.ollama/models "$SH/models/ollama"
  # whisper models -> shared, made group-readable (downloads 0600)
  echo "whisper:"
  if [ -d "$WHISPER" ] && [ ! -L "$WHISPER" ]; then
    osascript -e 'quit app "OpenSuperWhisper"' 2>/dev/null; sleep 1
    mkdir -p "$SH/models/whisper"; mv "$WHISPER"/*.bin "$SH/models/whisper/" 2>/dev/null
    rmdir "$WHISPER" 2>/dev/null
  fi
  mkdir -p "$SH/models/whisper"; chmod 644 "$SH/models/whisper"/*.bin 2>/dev/null
  link "$WHISPER" "$SH/models/whisper"
  echo "== host done. In the other account: ~/dotfiles/share.sh join =="
  ;;
join)
  echo "== join: linking this account to $SH =="
  echo "kitty:"; link ~/.config/kitty "$SH/dotfiles/kitty"
  echo "zsh:";   omz; link ~/.zshrc "$SH/dotfiles/zshrc"
  echo "ollama:"; mkdir -p ~/.ollama; link ~/.ollama/models "$SH/models/ollama"
  echo "whisper:"; link "$WHISPER" "$SH/models/whisper"
  echo "karabiner:"; karabiner
  echo "== join done. New terminal tab; grant Karabiner Accessibility. Don't run Ollama in both accounts at once. =="
  ;;
*)
  echo "usage: share.sh host   # main account: create shared store + link"
  echo "       share.sh join   # other account: link to the shared store"
  exit 1 ;;
esac
