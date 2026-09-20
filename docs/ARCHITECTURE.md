# Architecture

## Derivative model

Sovereign Stack OS is intentionally a thin Debian derivative. Debian remains upstream for the kernel, bootloader, installer components, security updates, and almost all user-space packages. Sovereign Stack maintains only configuration, branding, package selections, helper tools, and—later—a small signed package repository.

This keeps the security-maintenance obligation realistic for a small project. A new kernel fork or a complete rebuild of Debian's archive would add risk without creating meaningful sovereignty at this stage.

## Build flow

```text
Debian 13 repositories
        |
        v
live-build base configuration
        |
        +---- common overlay
        |       branding, AppArmor tools, updates, audit helpers
        |
        +---- desktop overlay
        |       KDE Plasma 6, Calamares, desktop defaults
        |
        `---- server overlay
                console tools, OpenSSH, fail2ban, server defaults
                        |
                        v
              hybrid BIOS/UEFI ISO + SHA-256
```

`scripts/configure.sh` generates a clean live-build working tree and then merges the common and edition-specific overlays. `scripts/build.sh` invokes live-build and copies only final artifacts into `out/`.

## Update model

Development images consume signed Debian Stable and Debian Security repositories directly. There is no Sovereign Stack binary repository in version `0.1.0-dev`.

A future Sovereign Stack repository will carry only project-owned packages such as branding, configuration migrations, and first-party applications. It must use an offline root key and a separate, rotatable online release key before being enabled by default.

## Edition relationship

Desktop and Server are profiles, not unrelated distributions. Both use:

- Debian 13 Trixie
- `amd64` in the initial release
- systemd
- Debian's kernel and firmware selection
- AppArmor tooling
- unattended security-update configuration
- the same OS identity and diagnostic commands

The Desktop profile adds KDE Plasma and a graphical installer. The Server profile deliberately rejects graphical desktop and Calamares packages during repository validation.

## Installation

The Desktop live environment includes Calamares using Debian's maintained settings as the initial installer foundation. Its launcher is renamed for Sovereign Stack OS, while deeper installer branding remains a tracked pre-1.0 task.

The Server image includes the text-mode Debian Installer and a console live environment. This avoids pulling a graphical stack into servers merely to provide an installer.

## Hardware scope

Version 0.1 targets 64-bit x86 PCs (`amd64`) with BIOS or UEFI firmware. ARM64 and hardware-specific images should be added only after automated builds and physical test machines exist for them.
