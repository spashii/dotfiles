# dotfiles

My macOS config — kitty, zsh (oh-my-zsh), Karabiner-Elements.

## Setup on a fresh Mac

```bash
git clone https://github.com/spashii/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

Then open a new terminal tab. That's it.

`install.sh` is safe to re-run — it backs up anything it replaces, symlinks kitty + zsh,
installs oh-my-zsh and its plugins, and seeds the Karabiner config. It prints what it does
and what to finish by hand (e.g. grant Karabiner Accessibility).

First install Homebrew (<https://brew.sh>), then:
`brew install --cask kitty karabiner-elements` · `brew install fzf` · a JetBrainsMono Nerd Font.

## More

- Full new-Mac playbook (every app, multi-account model sharing, all the gotchas): [SETUP.md](SETUP.md)
- The old vim/tmux/zsh setup (2020) is on the [`linux-2020`](../../tree/linux-2020) branch.
