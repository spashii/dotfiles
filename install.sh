#!/bin/bash
# Set up this Mac: apps from the Brewfile, zsh, node + python, kitty, Karabiner, Touch ID sudo.
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

echo "== apps (Brewfile) =="
if command -v brew >/dev/null 2>&1; then
  brew trust --tap hashicorp/tap spashii/browserpicker  # Homebrew only loads third-party taps you trust
  brew bundle --file="$REPO/Brewfile" || echo "  ! some entries failed, see above; re-run after fixing"
else
  echo "  ! Homebrew not found: install it first (see README), then re-run"
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
link ~/.zshenv "$REPO/zsh/zshenv"
link ~/.zshrc "$REPO/zsh/zshrc"

echo "== node + python (asdf) =="
if command -v asdf >/dev/null 2>&1; then
  for l in nodejs python; do
    asdf plugin list 2>/dev/null | grep -qx "$l" || asdf plugin add "$l"
    # newest plain release: skips the free-threaded "t" builds and pre-releases
    v=$(asdf list all "$l" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)
    asdf install "$l" "$v" && asdf set --home "$l" "$v"
  done
fi

echo "== kitty =="
link ~/.config/kitty "$REPO/kitty"

echo "== karabiner (seed copy — never a symlink; Karabiner rewrites the file) =="
mkdir -p ~/.config/karabiner
[ -f ~/.config/karabiner/karabiner.json ] && echo "  exists, kept" \
  || cp "$REPO/karabiner/karabiner.json" ~/.config/karabiner/karabiner.json

echo "== touch id for sudo (sudo_local survives macOS updates) =="
if grep -q '^auth.*pam_tid.so' /etc/pam.d/sudo_local 2>/dev/null; then echo "  ok"
elif [ -t 0 ]; then
  sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null && echo "  enabled"
else echo "  ! skipped: needs your password, re-run from a local terminal"
fi

echo
echo "Done. Open a new terminal tab. Karabiner: grant Accessibility + approve the driver extension."
