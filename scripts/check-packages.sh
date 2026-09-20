#!/usr/bin/env bash
set -Eeuo pipefail

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v apt-cache >/dev/null 2>&1; then
  echo "apt-cache is required to check Debian package availability." >&2
  exit 1
fi

if ! compgen -G '/var/lib/apt/lists/*_Packages*' >/dev/null; then
  echo "APT package metadata is missing; run 'sudo apt update' first." >&2
  exit 1
fi

mapfile -t PACKAGES < <(
  awk '!/^[[:space:]]*(#|$)/ {print $1}' +    profiles/*/config/package-lists/*.list.chroot |
    sort -u
)

missing=()
for package in "${PACKAGES[@]}"; do
  if ! apt-cache show --no-all-versions "$package" >/dev/null 2>&1; then
    missing+=("$package")
  fi
done

if (( ${#missing[@]} > 0 )); then
  printf 'Packages unavailable from configured APT repositories:\n' >&2
  printf '  %s\n' "${missing[@]}" >&2
  exit 1
fi

echo "Confirmed ${#PACKAGES[@]} requested packages in configured APT repositories."
