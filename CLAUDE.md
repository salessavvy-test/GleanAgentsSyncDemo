# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a demo repository for the [Glean Agent Sync GitHub Action](https://github.com/glean-io/agent-sync-action). It demonstrates how to manage Glean agent definitions in Git and automatically sync them to a Glean instance via GitHub Actions.

**Workflow:**
- On PRs: Creates draft preview links for agent changes
- On merge to master: Publishes agent definitions to Glean

## Project Structure

```
.glean/agents/{agent-name}/
  ├── agent-spec.json      # Agent definition (name, description, icon, schema)
  └── glean-sync.yaml      # Sync config (agent-id, commit message)

.github/actions/agent-sync-action/
  ├── action.yml           # Composite action definition
  └── scripts/
      ├── detect-changes.sh   # Detects modified agent folders
      ├── sync-agents.sh      # Builds & sends sync API requests
      └── comment-pr.sh       # Posts PR comments with preview links

.github/workflows/agent-sync.yml  # Workflow triggering the sync action
```

## Configuration

**Required GitHub Secret:**
- `GLEAN_AGENT_SYNC_TOKEN` — Glean client API token with `AGENTS` scope

**Instance Configuration:**
- Glean instance URL is hardcoded in `.github/workflows/agent-sync.yml` to `https://salessavvy-test-be.glean.com`
- To use a different instance, update the `instance-url` input in the workflow

**Agent Setup:**
- Each agent folder must contain `glean-sync.yaml` with a valid `agent-id`
- The default placeholder `"REPLACE_WITH_YOUR_AGENT_ID"` must be replaced before syncing

## Testing & Development

**Live API Calls:**
The sync script makes live API calls to the Glean instance. Ensure:
- `GLEAN_AGENT_SYNC_TOKEN` secret is set with valid credentials
- The Glean instance URL is correctly configured
- All agents have valid `agent-id` values in their `glean-sync.yaml`

**Triggering Workflows:**
- Workflow only triggers on changes to `.glean/agents/**`
- To test: modify any file in an agent folder and push or create a PR

**Dependencies:**
- Workflow requires `yq` for YAML parsing (auto-installed in CI)
- Uses `jq` for JSON processing (available in GitHub Actions runners)

## Agent Spec Format

Agent definitions follow Glean's agent spec format:
```json
{
  "rootWorkflow": {
    "name": "Agent Name",
    "description": "Agent description",
    "icon": "DEFAULT",
    "schema": {
      "steps": []
    }
  }
}
```

## Sync Behavior

**PR Events:**
- Syncs agent as draft (`isDraft: true`)
- Posts comment with preview link: `{instance-url}/agents/{agent-id}?version=draft`

**Push to Master:**
- Syncs agent as published (`isDraft: false`)
- Uses commit message or PR title as staging commit message

**Deleted Agents:**
- Deleting an agent folder is skipped with a warning
- To retire a Git-managed agent, switch it back to UI-managed mode in Glean Agent Builder first

## Error Handling

The sync script validates:
- Agent folder exists
- `glean-sync.yaml` exists and contains `agent-id`
- At least one `.json` spec file exists in the folder
- Spec file contains valid JSON

Failures are reported as GitHub Action errors and prevent workflow success.

## Recent Changes (2026-04-24)

**Agent Sync API Update:**
- Updated endpoint from `/rest/api/v1/agents/sync` to `/rest/api/v1/agents/{agent-id}/edit`
- Added `workflowSource: "GIT"` field to all sync requests
- Enabled live API calls (removed dry-run mode)

**Before first sync:**
- Ensure `GLEAN_AGENT_SYNC_TOKEN` secret has valid credentials
- Verify all agents have valid `agent-id` in their `glean-sync.yaml`
- The Glean instance must support the `/agents/{id}/edit` endpoint
