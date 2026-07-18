import { definePlugin } from 'pluxx'

export default definePlugin({
  name: 'pluxx',
  version: '0.2.2',
  description: 'Guide Pluxx CLI users through creating, refining, maintaining, verifying, translating, and publishing native plugins.',
  author: {
    name: 'Orchid Automation',
    url: 'https://github.com/orchidautomation',
  },
  repository: 'https://github.com/orchidautomation/pluxx-plugin',
  license: 'MIT',
  keywords: ['mcp', 'plugins', 'claude-code', 'cursor', 'codex', 'opencode', 'pluxx'],

  brand: {
    displayName: 'Pluxx',
    shortDescription: 'One plugin workflow source. Native bundles for Claude, Cursor, Codex, and OpenCode.',
    longDescription: 'Use Pluxx through seven job-shaped workflows: choose and troubleshoot the CLI, create one maintained source from an MCP or existing plugin, refine product context and taxonomy, sync upstream changes, prove source and installed behavior, audit host translation, and publish native bundles for Claude Code, Cursor, Codex, and OpenCode.',
    category: 'Productivity',
    color: '#0F172A',
    icon: './assets/icon/pluxx-icon.svg',
    screenshots: [
      './assets/screenshots/import-workflow.svg',
      './assets/screenshots/build-install-workflow.svg',
    ],
    defaultPrompts: [
      'Use Pluxx to choose the safest workflow for this plugin project and explain the next command before changing anything.',
      'Use Pluxx to create or refine one maintained source project, then validate it across the core four.',
      'Use Pluxx to prove the installed plugin, audit host translation, and prepare a release plan without publishing until I approve.',
    ],
    websiteURL: 'https://pluxx.dev',
    privacyPolicyURL: 'https://docs.pluxx.dev/reference/privacy-policy',
    termsOfServiceURL: 'https://docs.pluxx.dev/reference/terms-of-service',
  },

  permissions: {
    allow: [
      'Read(*)',
      'Skill(pluxx-*)',
    ],
    ask: [
      'Edit(*)',
      'Bash(*)',
    ],
  },

  skills: './skills/',
  commands: './commands/',
  agents: './agents/',
  instructions: './INSTRUCTIONS.md',
  hooks: {
    sessionStart: [{
      command: 'bash "${PLUGIN_ROOT}/scripts/check-pluxx-runtime.sh"',
    }],
  },
  scripts: './scripts/',
  assets: './assets/',

  platforms: {
    codex: {
      interface: {
        capabilities: ['Interactive', 'Read', 'Write'],
      },
    },
  },

  targets: ['claude-code', 'cursor', 'codex', 'opencode'],
  outDir: './dist',
})
