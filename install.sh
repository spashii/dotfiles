#!/bin/bash
# Bootstrap dotfiles on a fresh macOS install (single account).
#   git clone https://github.com/spashii/dotfiles ~/dotfiles && ~/dotfiles/install.sh
# Idempotent: re-running is safe. Existing files are backed up to <file>.bak.<ts>.
set -e
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS=$(date +%s)
echo "Installing dotfiles from $REPO"

link() {  # $1 = source in repo, $2 = destination in home
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then echo "  ok: $dst"; return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then mv "$dst" "$dst.bak.$TS"; echo "  backed up $dst -> $dst.bak.$TS"; fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"; echo "  linked $dst -> $src"
}

echo "== kitty =="
link "$REPO/kitty" "$HOME/.config/kitty"

echo "== zsh (oh-my-zsh + plugins are per-account; we keep our own .zshrc) =="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
CUST="$HOME/.oh-my-zsh/custom/plugins"; mkdir -p "$CUST"
for spec in \
  "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions" \
  "fast-syntax-highlighting|https://github.com/zdharma-continuum/fast-syntax-highlighting" \
  "fzf-tab|https://github.com/Aloxaf/fzf-tab"; do
  name="${spec%%|*}"; url="${spec#*|}"
  if [ -d "$CUST/$name" ]; then echo "  plugin $name present"; else git clone --depth=1 "$url" "$CUST/$name"; fi
done
link "$REPO/zsh/zshrc" "$HOME/.zshrc"

echo "== karabiner (SEED COPY — not symlinked: Karabiner rewrites the file in place) =="
mkdir -p "$HOME/.config/karabiner"
if [ -f "$HOME/.config/karabiner/karabiner.json" ]; then
  echo "  karabiner.json exists — left as-is (delete it first to re-seed from repo)"
else
  cp "$REPO/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
  echo "  seeded karabiner.json"
fi

echo
echo "Done. Open a new terminal tab to load zsh."
echo "Karabiner: grant Accessibility, and its swaps are device-keyed (edit VID/PID in karabiner.json for new hardware)."
