import { definePlugin } from 'pluxx'

export default definePlugin({
  name: 'pluxx',
  version: '0.1.1',
  description: 'Build and maintain one plugin workflow source, then ship native bundles to Claude, Cursor, Codex, and OpenCode.',
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
    longDescription: 'Use Pluxx to import MCPs or migrate existing plugins into one maintained source project, prepare richer context, refine taxonomy and instructions, review host translation quality, run behavioral proof, then build, verify, install, and publish native plugin bundles for Claude, Cursor, Codex, and OpenCode.',
    category: 'Productivity',
    color: '#0F172A',
    icon: './assets/icon/pluxx-icon.svg',
    screenshots: [
      './assets/screenshots/import-workflow.svg',
      './assets/screenshots/build-install-workflow.svg',
    ],
    defaultPrompts: [
      'Use Pluxx to import or migrate this plugin into one maintained source project and validate the first pass.',
      'Use Pluxx to translate this scaffold across the core four, then call out preserve, translate, degrade, and drop decisions.',
      'Use Pluxx to run behavioral proof, package install links and screenshots, then publish the release assets.',
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
