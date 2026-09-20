# Building Sovereign Stack OS

## Recommended: isolated Debian 13 builder

Requirements:

- an x86-64 Linux host
- Docker or Podman
- at least 25 GB free disk space for Desktop, or 15 GB for Server
- at least 4 GB RAM for Desktop builds
- network access to Debian mirrors

Build the tool image:

```bash
docker build -t sovereign-stack-builder -f builder/Dockerfile .
```

Build one edition:

```bash
docker run --rm --privileged \
  -v "$PWD:/workspace" \
  sovereign-stack-builder desktop
```

Use `server` instead of `desktop` for the server image. `--privileged` is required because live-build creates chroots and mounts pseudo-filesystems. Run this only with the repository and builder image you have inspected.

## Native Debian 13 build

Install the host tools:

```bash
sudo apt update
sudo apt install live-build debootstrap xorriso squashfs-tools \
  isolinux syslinux-common grub-pc-bin grub-efi-amd64-bin \
  mtools dosfstools rsync ca-certificates
```

Validate and build:

```bash
./scripts/validate.sh
sudo ./scripts/build.sh desktop
```

The build script generates:

```text
out/sovereign-stack-os-<version>-desktop-amd64.iso
out/sovereign-stack-os-<version>-desktop-amd64.iso.sha256
```

## Mirror override

Use a trusted Debian mirror closer to the builder when necessary:

```bash
sudo DEBIAN_MIRROR=https://deb.debian.org/debian \
  DEBIAN_SECURITY_MIRROR=https://security.debian.org/debian-security \
  ./scripts/build.sh server
```

Only HTTPS mirrors are accepted by the project scripts. Repository metadata is still authenticated by APT signatures.

## Clean generated state

```bash
./scripts/clean.sh desktop
./scripts/clean.sh server
./scripts/clean.sh all
```

The cleaner refuses paths outside this repository's `build/` and `out/` directories.

## Reproducibility note

The scripts set `SOURCE_DATE_EPOCH` from the checked-out Git commit when possible and keep all project configuration in source control. That is necessary but not sufficient for byte-identical ISOs: changing Debian mirror snapshots or upstream packages can change output. Snapshot pinning and independent rebuild comparison are roadmap items.
