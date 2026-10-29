#!/bin/bash
# Before a wipe: list what is on this Mac but not in the Brewfile, so nothing
# installed by hand is lost. Add what you want to keep to the Brewfile; the rest goes.
#   ~/dotfiles/drift.sh
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
eval "$(/opt/homebrew/bin/brew shellenv bash)"

echo "== Homebrew installs missing from the Brewfile =="
# keep only the "Would uninstall" lists; the cache cleanup lines are noise here
brew bundle cleanup --file="$REPO/Brewfile" 2>/dev/null \
  | awk '/^Would uninstall/{on=1; next} /^Would /{on=0} on && NF{print "  " $0}' | grep . || echo "  none"

echo
echo "== apps in /Applications that Homebrew and the App Store did not install =="
# every .app a cask names, plus "pkg:<id>" for casks that use an installer package
managed=$( { brew info --cask --installed --json=v2 2>/dev/null | /usr/bin/python3 -c '
import json, re, sys
for c in json.loads(sys.stdin.read(), strict=False)["casks"]:
    text = json.dumps(c["artifacts"])
    for app in set(re.findall(r"([^/\"]+\.app)\b", text)): print(app)
    def ids(x):
        if isinstance(x, dict):
            for k, v in x.items():
                if k == "pkgutil": yield from ([v] if isinstance(v, str) else v)
                else: yield from ids(v)
        elif isinstance(x, list):
            for v in x: yield from ids(v)
    for p in set(ids(c["artifacts"])): print("pkg:" + p)'
  mas list 2>/dev/null | sed -E 's/^[0-9]+ +(.*) +\(.*$/\1.app/; s/ +\.app$/.app/'; } )
# apps those installer packages put in /Applications
for p in $(sed -n 's/^pkg://p' <<<"$managed"); do
  managed+=$'\n'$(pkgutil --files "$p" 2>/dev/null | sed -nE 's#^(Applications/)?([^/]+\.app)$#\2#p')
done
found=0
for app in /Applications/*.app; do
  n=$(basename "$app")
  case "$n" in Safari.app) continue ;; esac
  grep -qxF "$n" <<<"$managed" || { echo "  $n"; found=1; }
done
[ $found = 1 ] || echo "  none"
