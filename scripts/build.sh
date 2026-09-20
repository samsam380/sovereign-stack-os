#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  echo "Usage: sudo $0 <desktop|server>" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

readonly EDITION="$1"
case "$EDITION" in
  desktop|server) ;;
  *)
    usage
    exit 2
    ;;
esac

if [[ "${EUID}" -ne 0 ]]; then
  echo "The ISO build requires root for chroot and mount operations." >&2
  exit 1
fi

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly VERSION="$(tr -d '[:space:]' < "${ROOT_DIR}/VERSION")"
readonly BUILD_DIR="${ROOT_DIR}/build/${EDITION}"
readonly OUT_DIR="${ROOT_DIR}/out"
readonly FINAL_NAME="sovereign-stack-os-${VERSION}-${EDITION}-amd64.iso"

if [[ -z "${SOURCE_DATE_EPOCH:-}" ]] && command -v git >/dev/null 2>&1; then
  SOURCE_DATE_EPOCH="$(git -C "$ROOT_DIR" log -1 --format=%ct 2>/dev/null || true)"
  if [[ -n "$SOURCE_DATE_EPOCH" ]]; then
    export SOURCE_DATE_EPOCH
  fi
fi

"${ROOT_DIR}/scripts/validate.sh"
"${ROOT_DIR}/scripts/configure.sh" "$EDITION"

cd "$BUILD_DIR"
echo "Building Sovereign Stack OS ${VERSION} (${EDITION})..."
lb build 2>&1 | tee "${BUILD_DIR}/build.log"

mapfile -t BUILT_IMAGES < <(find "$BUILD_DIR" -maxdepth 1 -type f -name '*.iso' -print)
if [[ "${#BUILT_IMAGES[@]}" -ne 1 ]]; then
  echo "Expected exactly one ISO, found ${#BUILT_IMAGES[@]}." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
install -m 0644 "${BUILT_IMAGES[0]}" "${OUT_DIR}/${FINAL_NAME}"
(
  cd "$OUT_DIR"
  sha256sum "$FINAL_NAME" > "${FINAL_NAME}.sha256"
)

for manifest in binary.packages chroot.packages.install; do
  if [[ -f "${BUILD_DIR}/${manifest}" ]]; then
    install -m 0644 "${BUILD_DIR}/${manifest}" \
      "${OUT_DIR}/${FINAL_NAME%.iso}.${manifest}.txt"
  fi
done

echo "Created ${OUT_DIR}/${FINAL_NAME}"
echo "Checksum: ${OUT_DIR}/${FINAL_NAME}.sha256"
