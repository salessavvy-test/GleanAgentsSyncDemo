# Glean Agent Sync API Update Design

**Date:** 2026-04-24  
**Status:** Approved

## Overview

Update the `sync-agents.sh` script to use the correct Glean Agent Sync API endpoint and request format based on the actual API specification.

## Current State

The script currently uses:
- **Endpoint:** `POST {instance-url}/rest/api/v1/agents/sync`
- **Request body:** Contains `id`, `commitSha`, `isDraft`, `name`, `description`, `icon`, `schema`, and optional `stagingOptions`
- **Status:** Dry-run mode with curl command commented out (lines 112-116)

## Required Changes

### 1. API Endpoint Update

**Current:**
```bash
POST ${INSTANCE_URL}/rest/api/v1/agents/sync
```

**New:**
```bash
POST ${INSTANCE_URL}/rest/api/v1/agents/${AGENT_ID}/edit
```

The endpoint changes from a generic `/sync` to an agent-specific `/agents/{agent-id}/edit` pattern. The `{agent-id}` is dynamically substituted for each agent being processed.

### 2. Request Body Modification

Add `workflowSource: "GIT"` field to the request body to indicate the agent definition originates from Git.

**Updated build_sync_request function output:**
```json
{
  "id": "<agent-id>",
  "commitSha": "<sha>",
  "isDraft": true/false,
  "workflowSource": "GIT",
  "name": "...",
  "description": "...",
  "icon": "...",
  "schema": {...},
  "stagingOptions": {...}  // optional
}
```

The `workflowSource` field is hardcoded to `"GIT"` as all agents synced via this action originate from Git-managed definitions.

### 3. Enable Live API Calls

Remove dry-run mode by:
- Uncommenting the curl command (lines 112-116)
- Removing the stub `HTTP_CODE=200` assignment (line 117)

## Implementation Details

### Modified build_sync_request Function

Update the jq command in `build_sync_request()` to include `workflowSource: "GIT"`:

```bash
build_sync_request() {
  local agent_id="$1"
  local spec_json="$2"
  local commit_sha="$3"
  local is_draft="$4"
  local message="$5"

  echo "$spec_json" | jq -c \
    --arg id "$agent_id" \
    --arg sha "$commit_sha" \
    --argjson draft "$is_draft" \
    --arg msg "$message" \
    '{
      id: $id,
      commitSha: $sha,
      isDraft: $draft,
      workflowSource: "GIT",
      name: .rootWorkflow.name,
      description: .rootWorkflow.description,
      icon: .rootWorkflow.icon,
      schema: .rootWorkflow.schema
    } + if $msg != "" then {stagingOptions: {save: true, commitMessage: $msg}} else {} end'
}
```

### Updated Curl Command

Replace lines 112-117 with:

```bash
HTTP_CODE=$(curl -s -o "$RUNNER_TEMP/sync-response-${FOLDER}.json" -w '%{http_code}' \
  -X POST "${INSTANCE_URL}/rest/api/v1/agents/${AGENT_ID}/edit" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$REQUEST_BODY")
```

Key changes:
- URL path: `/rest/api/v1/agents/${AGENT_ID}/edit` (agent-specific)
- Removed dry-run stub

## Error Handling

No changes to error handling logic. The script continues to:
- Check HTTP status codes (200-299 = success)
- Capture response body to `$RUNNER_TEMP/sync-response-${FOLDER}.json`
- Log errors via `::error::` annotations
- Aggregate results in JSON format
- Exit with status 1 if any agent fails

## Testing Considerations

Before deploying:
1. Verify `GLEAN_AGENT_SYNC_TOKEN` secret is configured with valid credentials
2. Test with a single agent in draft mode (PR workflow)
3. Verify draft preview link generation in PR comments
4. Test publish mode (merge to master)
5. Confirm error handling with invalid agent-id or malformed spec

## Backward Compatibility

This is a breaking change - the old `/agents/sync` endpoint will no longer be called. Ensure:
- The Glean instance supports the `/agents/{agent-id}/edit` endpoint
- All agent folders have valid `agent-id` values in `glean-sync.yaml`

## Files Modified

- `.github/actions/agent-sync-action/scripts/sync-agents.sh`
  - Line 11-32: `build_sync_request()` function
  - Line 112-117: curl command and dry-run stub
