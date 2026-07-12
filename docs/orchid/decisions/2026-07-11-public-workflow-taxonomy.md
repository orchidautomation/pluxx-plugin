# Public Pluxx Plugin Workflow Taxonomy

Decision: expose seven user jobs instead of one skill per CLI stage.

The public skills are guide, create, refine, maintain, verify, translate, and publish. CLI subcommands such as discovery, migration, autopilot, taxonomy refinement, behavioral testing, and proof packaging remain available as steps inside those coherent jobs.

This reduces trigger collisions and context overhead while preserving the complete CLI surface. It also creates a clear boundary: source authoring stays in this repository; generated `dist/` output is rebuilt through Pluxx.

Follow-up: update the separate `orchidautomation/pluxx` documentation and self-hosted embedded plugin after this taxonomy is accepted and merged here.
