# GleanAgentsSyncDemo

Demo repository for testing the [Glean Agent Sync](https://github.com/glean-io/agent-sync-action) GitHub Action.

## Setup

1. Add repository secrets in **Settings > Secrets and variables > Actions**:
   - `GLEAN_INSTANCE_URL` — your Glean instance URL (e.g. `https://acme.glean.com`)
   - `GLEAN_API_TOKEN` — a Glean client API token with **AGENTS** scope

2. Agent specs live in `.glean/agents/`. Each subfolder is one agent containing:
   - `glean-sync.yaml` — must have an `agent-id` field
   - A `.json` spec file — the agent definition

## How it works

- **On PR**: syncs agents as draft previews and comments on the PR with preview links.
- **On merge to master**: publishes agent changes to Glean.
