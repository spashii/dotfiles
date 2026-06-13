#!/bin/bash
# Set up this Mac: install + configure kitty, zsh, Karabiner, OpenSuperWhisper, Ollama.
#   git clone https://github.com/spashii/dotfiles ~/dotfiles && ~/dotfiles/install.sh
# Idempotent; backs up replaced files to *.bak.<ts>. Needs Homebrew (see README).
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS=$(date +%s)

link() {  # $1 = home path, $2 = repo source
  local dst="$1" src="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then echo "  ok: $dst"; return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then mv "$dst" "$dst.bak.$TS"; echo "  backed up $dst"; fi
  mkdir -p "$(dirname "$dst")"; ln -s "$src" "$dst"; echo "  linked $dst"
}

echo "== apps =="
if command -v brew >/dev/null 2>&1; then
  for c in kitty karabiner-elements opensuperwhisper ollama font-jetbrains-mono-nerd-font; do
    if brew list --cask "$c" >/dev/null 2>&1; then echo "  $c present"; else brew install --cask "$c"; fi
  done
else
  echo "  ! Homebrew not found — install it first (see README), then re-run"
fi

echo "== zsh (oh-my-zsh + plugins + fzf) =="
[ -d ~/.oh-my-zsh ] || RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
CUST=~/.oh-my-zsh/custom/plugins; mkdir -p "$CUST"
for s in "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions" \
         "fast-syntax-highlighting|https://github.com/zdharma-continuum/fast-syntax-highlighting" \
         "fzf-tab|https://github.com/Aloxaf/fzf-tab"; do
  n="${s%%|*}"; [ -d "$CUST/$n" ] || git clone --depth=1 "${s#*|}" "$CUST/$n"
done
command -v fzf >/dev/null 2>&1 || { command -v brew >/dev/null 2>&1 && brew install fzf; }  # fzf-tab needs it
link ~/.zshenv "$REPO/zsh/zshenv"
link ~/.zshrc "$REPO/zsh/zshrc"

echo "== kitty =="
link ~/.config/kitty "$REPO/kitty"

echo "== karabiner (seed copy — never a symlink; Karabiner rewrites the file) =="
mkdir -p ~/.config/karabiner
[ -f ~/.config/karabiner/karabiner.json ] && echo "  exists, kept" \
  || cp "$REPO/karabiner/karabiner.json" ~/.config/karabiner/karabiner.json

echo
echo "Done. Open a new terminal tab. Karabiner: grant Accessibility + approve the driver extension."
