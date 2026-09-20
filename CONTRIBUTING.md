# Contributing

Keep changes reviewable and preserve the small-derivative model.

1. Run `./scripts/validate.sh` before committing.
2. Do not add third-party repositories, binary blobs, remote scripts, or telemetry without an explicit design proposal.
3. Pin or document every new trust root.
4. Put shared changes in `profiles/common`; keep edition-specific changes in `profiles/desktop` or `profiles/server`.
5. Update the architecture or threat-model documentation when a change alters the trust boundary.

Package additions should explain their purpose, upstream source, maintenance status, license, and effect on the ISO size or attack surface.
