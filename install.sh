#!/usr/bin/env bash
#
# lidawake installer — no sudo, no clone.
#
#   curl -fsSL https://raw.githubusercontent.com/Vasiniks/lidawake/main/install.sh | bash
#
# Installs lidawake into ~/.local/bin (owned by you), so no admin password is
# needed to install. macOS only asks for a password later, when you actually run
# `lidawake on`, because pmset needs it to change the lid-sleep policy.
#
set -euo pipefail

REPO="https://raw.githubusercontent.com/Vasiniks/lidawake/main"
INSTALL_DIR="$HOME/.local/bin"
INSTALL_PATH="$INSTALL_DIR/lidawake"

die() { printf 'install: %s\n' "$*" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || die "lidawake is macOS-only."
command -v curl >/dev/null 2>&1 || die "curl is required but not found."

echo "Installing lidawake…"

mkdir -p "$INSTALL_DIR"

# Download to a temp file first so a failed/partial download can't leave a
# broken binary on your PATH.
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
curl -fL "$REPO/lidawake" -o "$tmp" || die "download failed from $REPO/lidawake"

# Make sure we got the real script, not a 404 / HTML error page.
head -1 "$tmp" | grep -q '^#!/usr/bin/env bash' \
  || die "downloaded file doesn't look like lidawake — aborting."

chmod +x "$tmp"
mv "$tmp" "$INSTALL_PATH"
trap - EXIT

# Add ~/.local/bin to PATH in the right shell config, if it isn't already there.
case "$(basename "${SHELL:-}")" in
  zsh)  SHELL_CONFIG="$HOME/.zshrc" ;;
  bash) SHELL_CONFIG="$HOME/.bashrc" ;;
  *)    SHELL_CONFIG="$HOME/.profile" ;;
esac

added_path=false
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  if ! grep -q '.local/bin' "$SHELL_CONFIG" 2>/dev/null; then
    printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$SHELL_CONFIG"
    added_path=true
  fi
fi

echo ""
echo "✓ lidawake installed to $INSTALL_PATH"
echo ""
if $added_path; then
  echo "Added ~/.local/bin to your PATH. Restart Terminal, or run:"
  echo "  source $SHELL_CONFIG"
  echo ""
fi
echo "Then:"
echo "  lidawake on 90     # keep awake, lid closed, auto-revert after 90 min"
echo "  lidawake status    # check state"
echo "  lidawake off       # back to normal"
