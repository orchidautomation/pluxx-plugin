# Upstream Pluxx Follow-ups

These belong in the separate `orchidautomation/pluxx` repository and need their own issue/branch/PR lifecycle.

1. Harden `pluxx discover-mcp` redaction.
   - Pluxx `0.1.31` can retain credential-bearing URL query strings or stdio arguments in discovery output.
   - Redact those values by default and add regression coverage for remote URLs, command arguments, and JSON output.
2. Align the self-hosted plugin and docs with the accepted seven-workflow taxonomy.
   - Replace the older 17-skill public surface in upstream docs and `plugins/pluxx` after the `pluxx-plugin` `0.2.0` taxonomy is accepted.
   - Preserve the internal CLI stages as specialist behavior rather than public trigger surfaces.
