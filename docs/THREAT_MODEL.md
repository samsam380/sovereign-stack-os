# Threat model

## Goals

Sovereign Stack OS aims to reduce avoidable dependency, hidden behavior, and single-vendor control while retaining a maintainable security-update path.

It is designed to help against:

- opaque project-specific telemetry
- accidental exposure from unnecessary listening services
- preventable persistence after ordinary user-level compromise
- unsigned or unexplained project configuration changes
- dependence on a mandatory cloud account
- loss of availability caused by an unmaintainable one-person package fork

## Explicit non-goals

The OS does not by itself defeat:

- malicious CPU, firmware, storage firmware, or peripheral hardware
- a fully compromised Debian archive or signing infrastructure
- physical access to an unlocked computer
- malicious applications deliberately installed by the administrator
- browser fingerprinting, traffic analysis, or a hostile network provider
- theft of secrets copied into cloud services or untrusted applications
- coercion or operational-security mistakes

## Trust roots

The initial trust roots are:

1. the hardware and firmware used to boot the machine;
2. Debian archive signing keys and Debian's security process;
3. the source and build environment used for this repository;
4. upstream software included by Debian;
5. the administrator's key management and update decisions.

The project should make these dependencies visible rather than claiming that they do not exist.

## Defaults and tradeoffs

- Non-free firmware is permitted for practical hardware compatibility, but proprietary applications are not added by default.
- The firewall helper requires an explicit profile selection, avoiding silent SSH lockout on a new server.
- Server password authentication is initially available for installation and recovery; key-only SSH is recommended after keys are confirmed.
- Automatic security updates are enabled, but automatic reboot is disabled to preserve operator control.
- Third-party package repositories and Flatpak remotes are not silently enrolled.

## Future work

Before 1.0, the project should add signed release manifests, SBOM generation, an offline root signing procedure, measured build provenance, independent rebuilds, installer tests, and a documented key-compromise recovery process.
