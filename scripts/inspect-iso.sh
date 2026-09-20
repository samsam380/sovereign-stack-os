#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <path-to-iso>" >&2
  exit 2
fi

readonly ISO_PATH="$(realpath "$1")"
[[ -f "$ISO_PATH" ]] || { echo "ISO not found: ${ISO_PATH}" >&2; exit 1; }

if ! command -v xorriso >/dev/null 2>&1; then
  echo "xorriso is required to inspect an ISO." >&2
  exit 1
fi

readonly CHECKSUM_FILE="${ISO_PATH}.sha256"
if [[ -f "$CHECKSUM_FILE" ]]; then
  (cd "$(dirname "$ISO_PATH")" && sha256sum --check "$(basename "$CHECKSUM_FILE")")
else
  echo "No adjacent checksum file found; calculated SHA-256:"
  sha256sum "$ISO_PATH"
fi

xorriso -indev "$ISO_PATH" -pvd_info
xorriso -indev "$ISO_PATH" -find /live/filesystem.squashfs -print
xorriso -indev "$ISO_PATH" -find /boot -maxdepth 3 -type f -print
