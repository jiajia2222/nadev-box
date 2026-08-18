#!/usr/bin/env bash
# Nadev Box bootstrapper. The maintained implementation is sing-box.sh.

set -eu

SCRIPT_URL='https://raw.githubusercontent.com/jiajia2222/nadev-box/main/sing-box.sh'
TEMP_FILE=$(mktemp "${TMPDIR:-/tmp}/nadev-box.XXXXXX")
trap 'rm -f "$TEMP_FILE"' EXIT

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$SCRIPT_URL" -o "$TEMP_FILE"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$TEMP_FILE" "$SCRIPT_URL"
else
  echo 'Nadev Box requires curl or wget to download the installer.' >&2
  exit 1
fi

bash "$TEMP_FILE" "$@"
