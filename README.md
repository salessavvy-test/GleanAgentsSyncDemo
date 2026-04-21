# GleanAgentsSyncDemo

Test repo for the [Glean Agent Sync](https://github.com/glean-io/agent-sync-action) GitHub Action.

## Setup

1. Add repo secret in **Settings > Secrets and variables > Actions**:
   - `GLEAN_AGENT_SYNC_TOKEN` — a Glean client API token with `AGENTS` scope

   Instance URL is hardcoded to `https://salessavvy-test-be.glean.com`.

2. Update `.glean/agents/my-test-agent/glean-sync.yaml` with a real `agent-id`.

3. Edit the agent spec JSON and push — the workflow triggers on changes to `.glean/agents/**`.

## How it works

- **On PR**: syncs a draft preview and comments on the PR with a preview link.
- **On merge to master**: publishes the agent definition to Glean.
