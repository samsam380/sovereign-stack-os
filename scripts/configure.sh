#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  echo "Usage: $0 <desktop|server>" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

readonly EDITION="$1"
case "$EDITION" in
  desktop)
    INSTALLER_GUI=true
    ISO_VOLUME="SSOS_DESKTOP"
    LIVE_HOSTNAME="sovereign-stack"
    BOOT_PARAMETERS="boot=live components quiet splash username=sovereign hostname=${LIVE_HOSTNAME} locales=en_US.UTF-8 keyboard-layouts=us"
    ;;
  server)
    INSTALLER_GUI=false
    ISO_VOLUME="SSOS_SERVER"
    LIVE_HOSTNAME="sovereign-server"
    BOOT_PARAMETERS="boot=live components username=sovereign hostname=${LIVE_HOSTNAME} locales=en_US.UTF-8 keyboard-layouts=us console=tty0 console=ttyS0,115200n8"
    ;;
  *)
    usage
    exit 2
    ;;
esac

if ! command -v lb >/dev/null 2>&1; then
  echo "live-build is required (missing command: lb)." >&2
  exit 1
fi

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly VERSION="$(tr -d '[:space:]' < "${ROOT_DIR}/VERSION")"
readonly BUILD_ROOT="${ROOT_DIR}/build"
readonly TARGET_DIR="${BUILD_ROOT}/${EDITION}"
readonly DEBIAN_MIRROR="${DEBIAN_MIRROR:-https://deb.debian.org/debian}"
readonly DEBIAN_SECURITY_MIRROR="${DEBIAN_SECURITY_MIRROR:-https://security.debian.org/debian-security}"

for mirror in "$DEBIAN_MIRROR" "$DEBIAN_SECURITY_MIRROR"; do
  if [[ ! "$mirror" =~ ^https:// ]]; then
    echo "Refusing non-HTTPS mirror: ${mirror}" >&2
    exit 1
  fi
done

mkdir -p "$BUILD_ROOT" "$TARGET_DIR"

readonly EXPECTED_TARGET="$(realpath -m "${BUILD_ROOT}/${EDITION}")"
readonly RESOLVED_TARGET="$(realpath -m "$TARGET_DIR")"
if [[ "$RESOLVED_TARGET" != "$EXPECTED_TARGET" || "$RESOLVED_TARGET" == "/" ]]; then
  echo "Unsafe build path: ${RESOLVED_TARGET}" >&2
  exit 1
fi

cd "$TARGET_DIR"
if [[ -d config ]]; then
  lb clean --purge >/dev/null 2>&1 || true
  rm -rf -- "${TARGET_DIR}/config"
fi

lb config \
  --mode debian \
  --distribution trixie \
  --parent-distribution trixie \
  --distribution-chroot trixie \
  --distribution-binary trixie \
  --architecture amd64 \
  --linux-flavours amd64 \
  --archive-areas "main contrib non-free-firmware" \
  --parent-archive-areas "main contrib non-free-firmware" \
  --binary-image iso-hybrid \
  --bootloaders "syslinux grub-efi" \
  --system live \
  --initramfs live-boot \
  --initsystem systemd \
  --debian-installer live \
  --debian-installer-distribution trixie \
  --parent-debian-installer-distribution trixie \
  --debian-installer-gui "$INSTALLER_GUI" \
  --firmware-binary true \
  --firmware-chroot true \
  --uefi-secure-boot auto \
  --apt-recommends true \
  --apt-secure true \
  --apt-source-archives false \
  --apt-indices true \
  --backports false \
  --security true \
  --updates true \
  --checksums sha256 \
  --chroot-filesystem squashfs \
  --chroot-squashfs-compression-type xz \
  --cache true \
  --cache-packages true \
  --cache-stages bootstrap \
  --memtest none \
  --source false \
  --mirror-bootstrap "$DEBIAN_MIRROR" \
  --mirror-chroot "$DEBIAN_MIRROR" \
  --mirror-binary "$DEBIAN_MIRROR" \
  --mirror-chroot-security "$DEBIAN_SECURITY_MIRROR" \
  --mirror-binary-security "$DEBIAN_SECURITY_MIRROR" \
  --mirror-debian-installer "$DEBIAN_MIRROR" \
  --image-name "sovereign-stack-os-${VERSION}-${EDITION}-amd64" \
  --iso-application "Sovereign Stack OS ${EDITION^}" \
  --iso-publisher "Sovereign Stack OS Project" \
  --iso-preparer "live-build from source-controlled configuration" \
  --iso-volume "$ISO_VOLUME" \
  --bootappend-live "$BOOT_PARAMETERS"

cp -a "${ROOT_DIR}/profiles/common/config/." "${TARGET_DIR}/config/"
cp -a "${ROOT_DIR}/profiles/${EDITION}/config/." "${TARGET_DIR}/config/"

echo "Configured Sovereign Stack OS ${VERSION} (${EDITION}, amd64) in ${TARGET_DIR}"
