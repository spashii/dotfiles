#!/bin/bash
# Walk through every sign-in and permission a fresh Mac needs, one at a time.
#   ~/dotfiles/signin.sh   (after install.sh; run it from a local terminal)
# Safe to re-run: command line tools that are already signed in are skipped.
eval "$(/opt/homebrew/bin/brew shellenv bash)"
SKIPPED=()
PANE="x-apple.systempreferences:com.apple.preference.security"

wait_done() {  # $1 = step name
  local a; read -r -p "  Enter when done, s to skip: " a
  [ "$a" = s ] && SKIPPED+=("$1")
}

cli() {  # $1 = name, $2 = check command, $3 = sign-in command
  echo; echo "== $1 =="
  if eval "$2" >/dev/null 2>&1; then echo "  already signed in"; return; fi
  local a; read -r -p "  Enter to sign in, s to skip: " a
  if [ "$a" = s ]; then SKIPPED+=("$1"); return; fi
  eval "$3" || SKIPPED+=("$1 (failed)")
}

app() {  # $1 = name, $2 = app to open, $3 = what to do there
  echo; echo "== $1 =="; echo "  $3"
  local a; read -r -p "  Enter to open, s to skip: " a
  if [ "$a" = s ]; then SKIPPED+=("$1"); return; fi
  open -a "$2"; wait_done "$1"
}

perm() {  # $1 = name, $2 = settings pane, $3 = what to switch on
  echo; echo "== $1 =="; echo "  $3"
  open "$2"; wait_done "$1"
}

app "1Password" "1Password" "Sign in first: the passwords for everything below are in here."
echo; echo "== 1Password in Firefox =="; echo "  Add the extension, then sign in to it."
open -a Firefox "https://addons.mozilla.org/firefox/addon/1password-x-password-manager/"; wait_done "1Password in Firefox"

cli "GitHub" "gh auth status" "gh auth login --web --hostname github.com --git-protocol https && gh auth setup-git"
cli "Google Cloud" "gcloud auth print-access-token" "gcloud auth login"
cli "Claude Code" "claude auth status" "claude auth login"
cli "Codex" "codex login status" "codex login"
cli "DigitalOcean" "doctl account get" "doctl auth init"

app "Slack" "Slack" "Sign in to each workspace."
app "Notion" "Notion" "Sign in."
app "Claude" "Claude" "Sign in."
app "T3 Code" "T3 Code (Nightly)" "Connect to the Linux box."
app "Brave" "Brave Browser" "Sign in to Google in the Default profile."
app "Raycast" "Raycast" "Follow its setup, allow what it asks for."
app "Karabiner" "Karabiner-Elements" "Allow the driver extension and Input Monitoring when it asks."
app "OpenSuperWhisper" "OpenSuperWhisper" "Allow the microphone and Accessibility when it asks."
app "Mos" "Mos" "Allow Accessibility when it asks."

perm "Accessibility check" "$PANE?Privacy_Accessibility" "Make sure Raycast, Karabiner, Mos and OpenSuperWhisper are on."
perm "Input Monitoring check" "$PANE?Privacy_ListenEvent" "Make sure the two Karabiner entries are on."

echo
if [ ${#SKIPPED[@]} -eq 0 ]; then echo "All signed in."
else echo "Skipped, re-run to finish:"; printf '  - %s\n' "${SKIPPED[@]}"
fi
