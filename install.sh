#!/usr/bin/env bash
#
# lidawake installer — one command, no clone, no manual chmod.
#
#   curl -fsSL https://raw.githubusercontent.com/Vasiniks/lidawake/main/install.sh | bash
#
# Downloads the lidawake CLI and drops it on your PATH. macOS only.
#
set -euo pipefail

REPO="Vasiniks/lidawake"
BRANCH="main"
SRC_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/lidawake"
DEST_DIR="/usr/local/bin"
DEST="${DEST_DIR}/lidawake"

say()  { printf '%s\n' "$*"; }
die()  { printf 'install: %s\n' "$*" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || die "lidawake is macOS-only."
command -v curl >/dev/null 2>&1 || die "curl is required but not found."

say "Downloading lidawake…"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
curl -fsSL "$SRC_URL" -o "$tmp" || die "download failed from $SRC_URL"

# Sanity-check we actually got the script, not a 404 page.
head -1 "$tmp" | grep -q '^#!/usr/bin/env bash' \
  || die "downloaded file doesn't look like lidawake — aborting."

chmod +x "$tmp"

say "Installing to ${DEST}…"
if [[ -w "$DEST_DIR" ]] || { [[ ! -e "$DEST_DIR" ]] && [[ -w "$(dirname "$DEST_DIR")" ]]; }; then
  mkdir -p "$DEST_DIR"
  mv "$tmp" "$DEST"
else
  say "(needs your admin password to write to ${DEST_DIR})"
  sudo mkdir -p "$DEST_DIR"
  sudo mv "$tmp" "$DEST"
fi
trap - EXIT

say ""
say "✓ Installed. Get started:"
say "    lidawake on 90     # keep awake, lid closed, auto-revert after 90 min"
say "    lidawake status    # check state"
say "    lidawake off       # back to normal"
