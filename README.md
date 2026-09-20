# Sovereign Stack OS

Sovereign Stack OS is a transparent, local-first Debian 13 (Trixie) derivative. It is designed to provide one auditable foundation for personal computers, development workstations, Bitcoin tooling, and small self-hosted servers.

> **Status:** `0.1.0-dev` — build-system preview. Do not install it on a machine containing irreplaceable data. Test in a virtual machine and then on spare hardware.

## Editions

Yes—this project produces both a graphical edition and a server-only edition from the same trusted base.

| Edition | Interface | Installer | Intended use |
| --- | --- | --- | --- |
| **Desktop** | KDE Plasma 6 | Calamares plus Debian Installer | Daily PC, development, local apps, Bitcoin tools |
| **Server** | Console only; no desktop packages | Text-mode Debian Installer | Nodes, Git hosting, containers, storage, home services |

Both editions use Debian Stable repositories, Debian security updates, the Linux kernel supplied by Debian, and the same Sovereign Stack baseline. They differ only in their package and configuration overlays.

## Design principles

- **Small derivative:** reuse Debian packages rather than maintaining an unnecessary fork of the kernel or the Debian archive.
- **Auditable:** build instructions and configuration are ordinary text files committed to Git.
- **Local-first:** no Sovereign Stack account, cloud dependency, or distribution-specific telemetry service.
- **Secure defaults without lock-in:** AppArmor, unattended security updates, encryption tooling, and firewall tooling are included; users retain control.
- **Two roles, one base:** Desktop and Server remain closely aligned so applications and operational knowledge transfer cleanly between them.
- **Migration-friendly:** no GitHub-specific component is required to build the OS; this repository can move to Forgejo later.

## Quick start

The most consistent build path uses the supplied Debian 13 builder container:

```bash
docker build -t sovereign-stack-builder -f builder/Dockerfile .
docker run --rm --privileged \
  -v "$PWD:/workspace" \
  sovereign-stack-builder desktop
```

Replace `desktop` with `server` for the console-only image. Finished ISOs and SHA-256 files appear in `out/`.

To build directly on Debian 13:

```bash
sudo apt update
sudo apt install live-build debootstrap xorriso squashfs-tools \
  isolinux syslinux-common grub-pc-bin grub-efi-amd64-bin \
  mtools dosfstools rsync ca-certificates
sudo ./scripts/build.sh desktop
```

See [docs/BUILD.md](docs/BUILD.md) for the complete procedure and [docs/TESTING.md](docs/TESTING.md) before installing on physical hardware.

## Repository layout

```text
profiles/common/     shared packages and configuration
profiles/desktop/    KDE Plasma and graphical installer overlay
profiles/server/     console and SSH-server overlay
scripts/             configure, build, inspect, and test commands
builder/             clean Debian 13 build environment
docs/                architecture, threat model, testing, and roadmap
.github/workflows/   validation and manually triggered ISO builds
```

## Security boundary

Sovereign Stack OS improves visibility and control; it does not make hardware, firmware, Debian, or installed applications automatically trustworthy. SHA-256 checksums detect accidental changes but are not proof of authorship. Signed releases and a separately controlled package-signing infrastructure are planned before a public 1.0 release.

## Upstream and trademarks

Sovereign Stack OS is independently produced and is not affiliated with or endorsed by the Debian Project. Debian is a registered trademark owned by Software in the Public Interest, Inc. KDE and Linux may be trademarks of their respective owners.

The project configuration is released under the MIT License. Packages included in generated images retain their own upstream licenses.
