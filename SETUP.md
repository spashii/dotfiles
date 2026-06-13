# New MacOS install

## General Rules 
- if multiple accounts, only use BREW in the main account
- use ONE password manager, apple passwords
- stay as close to defaults
- screenshot is `Command + Control + Shift + 4`

## Software
- Docker Desktop: https://www.docker.com/
- Mos: https://mos.caldis.me/ 
    - Mx Master 3s fix: https://baty.net/posts/2025/03/fixing-the-terrible-scrolling-behavior-with-logitech-mx-master-on-mac-os/
- Brew: https://brew.sh/ 
- Kitty: https://sw.kovidgoyal.net/kitty/binary/ (restore good terminal zoom behavior)
    - Enable touch id sudo auth: `sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local`
- Raycast: https://www.raycast.com/ (clipboard history)
- GH CLI: `brew install gh`
    - gh auth login / switch 
- ohmyzsh: https://ohmyz.sh/#install 
    - Plugins: `fast-syntax-highlighting zsh-autosuggestions fzf-tab`
    - https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
    - https://github.com/zdharma-continuum/fast-syntax-highlighting 
    - `brew install fzf`
    - https://github.com/Aloxaf/fzf-tab?tab=readme-ov-file#install 
- Bins: `brew install asdf`
    - asdf for oh-my-zsh
    - https://github.com/asdf-vm/asdf-nodejs
    - https://github.com/asdf-community/asdf-python
    - (check v before install)
    - `asdf install nodejs 24.10.0`
    - `asdf set nodejs 24.10.0`
    - `asdf install python 3.12.12`
    - `asdf set python 3.12.12`
    - `curl -fsSL https://bun.sh/install | bash`
- Code:
    - Cursor cursor.sh 
    - `curl -fsSL https://claude.ai/install.sh | bash`
    - `curl -fsSL https://chatgpt.com/codex/install.sh | sh`
- OpenSuperWhisper: https://github.com/Starmel/OpenSuperWhisper#installation
- Karabiner-Elements: https://karabiner-elements.pqrs.org/ (`brew install --cask karabiner-elements`)
    - Approve the driver extension once: System Settings > Login Items & Extensions > Driver Extensions
    - Grant Accessibility per-account (covers Input Monitoring on 16.0+)


## Multi-account sharing (configs + models)

> Two accounts on one Mac (main + secondary). Apps are installed/available in **both** (brew is system-wide per General Rules) — only per-user **config + model data** is shared: one physical copy under `/Users/Shared`, each account points at it. Goal: never store multi-GB models twice, and never let the two setups drift.

### Shared folders (run once, from the main account)
```bash
# both accounts are in group `staff`; setgid (2xxx) so new files inherit it
sudo install -d -g staff -m 2775 /Users/Shared/dotfiles /Users/Shared/models
```
- Default `umask 022` → files one account creates are **readable** but not writable by the other. For stores both accounts download into (ollama, asdf), add `umask 002` to each `.zshrc`, or just designate one account as the installer.
- `/Users/Shared` has the sticky bit (`1777`): you can't delete each other's top-level entries — harmless here.

### Configs → symlink into each home (run in BOTH accounts)
Real files live in `/Users/Shared/dotfiles/`; each home just links to them, so an edit in one account shows up in both.
```bash
ln -sf /Users/Shared/dotfiles/kitty     ~/.config/kitty       # whole dir
ln -sf /Users/Shared/dotfiles/zshrc     ~/.zshrc
ln -sf /Users/Shared/dotfiles/karabiner ~/.config/karabiner   # DIR symlink — never the .json (see gotchas)
launchctl kickstart -k gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server 2>/dev/null
```

### Per-app gotchas
- **Kitty** — symlink the whole `~/.config/kitty/`. Live-reloads config, no per-user state. Clean, no caveats.
- **Zsh / oh-my-zsh** — share `~/.zshrc` + `custom/plugins/*` only. **Don't** share all of `~/.oh-my-zsh`: its auto-updater `git pull`s into the dir and the two accounts race on it. Install OMZ per-account (fast) or disable updates (`zstyle ':omz:update' mode disabled`). `.zcompdump` stays under each `$HOME` — fine.
- **asdf** *(optional)* — share the runtime store: `export ASDF_DATA_DIR=/Users/Shared/models/asdf` in each `.zshrc` (skips re-downloading node/python). Needs `umask 002` since both write; `.tool-versions` stays per-project. Skip if the perms hassle isn't worth it.
- **Ollama** — share **only** `~/.ollama/models` (`blobs/` + `manifests/`); the rest of `~/.ollama` is per-account (`id_ed25519` key, history, logs, cache). Blobs/manifests are written `0644`, so the other account reads them fine.
    - macOS 15+ **ignores `OLLAMA_MODELS`** set in `.zshrc`/`.zshenv`/`.zprofile` — use a **symlink** instead. If models already exist: `mv ~/.ollama/models /Users/Shared/models/ollama && ln -s /Users/Shared/models/ollama ~/.ollama/models`.
    - The server binds `:11434` — only **one** `ollama serve` can run at a time. With fast-user-switching (both accounts logged in) the second account's server won't start. Sequential use is fine.
- **OpenSuperWhisper** — **not** sandboxed (verified: no `~/Library/Containers/…`), so symlinks out of its support dir work. Models: `~/Library/Application Support/ru.starmel.OpenSuperWhisper/whisper-models/` (plain whisper.cpp `.bin` files).
    - Symlink **only** `whisper-models` — the parent dir also holds `recordings.sqlite`, your per-account recording history (keep local).
    - The downloaded `.bin` is written `0600` (owner-only) — after moving it to the shared store, `chmod 644` it or the other account can't read it.
    - `W=~/Library/Application\ Support/ru.starmel.OpenSuperWhisper/whisper-models; mkdir -p /Users/Shared/models/whisper; mv "$W"/*.bin /Users/Shared/models/whisper/ 2>/dev/null; chmod 644 /Users/Shared/models/whisper/*.bin; rmdir "$W" && ln -s /Users/Shared/models/whisper "$W"`
- **Karabiner-Elements** — symlink the **directory** `~/.config/karabiner`, **never** the `karabiner.json` file: Karabiner saves atomically (temp file + rename), which clobbers a file symlink back into a plain file and breaks the share. After relocating, restart the user server (`launchctl kickstart -k gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server`).
    - ⚠️ Karabiner **re-clamps the config to `0700`/`0600` (owner-only) on every launch/write**, so plain `chmod g+r` does NOT stick. Use an **inheriting ACL** instead (`chmod` of mode bits doesn't strip ACLs, and `file_inherit` re-applies to each rewritten `karabiner.json`):
        ```bash
        D=/Users/Shared/dotfiles/karabiner
        chmod -R +a "group:staff allow list,search,add_file,delete_child,read,write,execute,delete,append,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" "$D"
        ```
    - Config is device-keyed (`vendor_id`/`product_id`), so the same remaps apply on both accounts for the same hardware.
    - Driver extension (DriverKit VirtualHIDDevice) is approved **once, system-wide**. But **Accessibility permission is per-account** — grant it from each login session.
    - macOS 26 (Tahoe) has known driver-approval bugs ("Please grant permission for driver extension") — a reboot / re-approve usually clears it.
- **gh CLI** — auth is per-user (keychain / `~/.config/gh/hosts.yml`). Not shared by design — `gh auth login` separately in each account.


---

## Agent instructions (terminal setup)

> Everything above this line is human-written reference — don't modify it.
> For an AI agent helping with a fresh macOS setup. Don't copy-paste configs from anywhere — read these preferences and write minimal config yourself. Guiding principle (same as General Rules): **stay as close to defaults as possible**; every line in a config should be a deliberate deviation I actually want.

### Kitty — how I like it

- Tokyo Night colors (folke's `tokyonight_night`, has an official kitty extra) + JetBrainsMono Nerd Font, ~14pt (install via brew cask).
- Frosted-glass look: slightly translucent background (~0.75) with heavy blur, and a keybinding to toggle fully opaque for screenshots. Text must stay crisp.
- Clean chrome: no title bar (keep the traffic lights), a bit of window padding, powerline-style tab bar on top.
- Quiet: no audio/visual bell, no cursor blink, beam cursor.
- copy-on-select, and keep kitty's performance defaults — don't add fancy effects that cost battery.
- Mac-native `cmd` keymaps for the power features that default to ctrl+shift: scrollback in pager, last-command output, URL hints, jump between prompts, cycle layouts, reload config. Plus iTerm-style splits: `cmd+d` / `cmd+shift+d`, new split inherits current directory.

### Zsh — how I like it (optional)

- Stock ohmyzsh `.zshrc` template, changing only: theme `refined` (the Pure-style minimal prompt) and the plugins already listed in the Software section above.
- One readability fix: brighten the zsh-autosuggestions highlight color — the default is too dim against a Tokyo Night background.

If my old machine is reachable, `~/.config/kitty/` and `~/.zshrc` there are the source of truth — prefer porting those over recreating from this description.
