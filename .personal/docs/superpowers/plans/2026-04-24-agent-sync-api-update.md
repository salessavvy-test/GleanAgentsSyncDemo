# Agent Sync API Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update sync-agents.sh to use the correct Glean Agent Sync API endpoint and add workflowSource field

**Architecture:** Modify the bash script's build_sync_request function to add a hardcoded workflowSource field, update the curl endpoint to use agent-specific URLs, and enable live API calls

**Tech Stack:** Bash, jq, curl, GitHub Actions

---

### Task 1: Add workflowSource Field to Request Body

**Files:**
- Modify: `.github/actions/agent-sync-action/scripts/sync-agents.sh:11-32`

- [ ] **Step 1: Create test data for validation**

Create a temporary test file to validate the build_sync_request output:

```bash
cat > /tmp/test-agent-spec.json <<'EOF'
{
  "rootWorkflow": {
    "name": "Test Agent",
    "description": "Test Description",
    "icon": "DEFAULT",
    "schema": {
      "steps": []
    }
  }
}
EOF
```

- [ ] **Step 2: Test current build_sync_request output**

Extract and test the current function to verify baseline behavior:

```bash
cd /Users/ramjee.ganti/Documents/work/fde/GleanAgentsSyncDemo
source <(sed -n '/^build_sync_request()/,/^}/p' .github/actions/agent-sync-action/scripts/sync-agents.sh)
SPEC_JSON=$(cat /tmp/test-agent-spec.json)
build_sync_request "test-agent-123" "$SPEC_JSON" "abc123" "true" "test commit" | jq .
```

Expected output should contain: `id`, `commitSha`, `isDraft`, `name`, `description`, `icon`, `schema`

**Expected output should NOT contain:** `workflowSource`

- [ ] **Step 3: Add workflowSource field to build_sync_request**

Update the jq command in the build_sync_request function (lines 18-31):

```bash
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
```

The only change is adding line 26: `workflowSource: "GIT",`

- [ ] **Step 4: Verify workflowSource field is present**

Reload the function and test again:

```bash
source <(sed -n '/^build_sync_request()/,/^}/p' .github/actions/agent-sync-action/scripts/sync-agents.sh)
SPEC_JSON=$(cat /tmp/test-agent-spec.json)
OUTPUT=$(build_sync_request "test-agent-123" "$SPEC_JSON" "abc123" "true" "test commit")
echo "$OUTPUT" | jq .
echo "$OUTPUT" | jq -e '.workflowSource == "GIT"' && echo "✓ workflowSource field verified"
```

Expected: JSON output now includes `"workflowSource": "GIT"` and the verification command prints "✓ workflowSource field verified"

- [ ] **Step 5: Commit workflowSource field change**

```bash
git add .github/actions/agent-sync-action/scripts/sync-agents.sh
git commit -m "feat: add workflowSource field to agent sync request

Add hardcoded workflowSource: GIT field to indicate agent definitions
originate from Git-managed sources.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 2: Update API Endpoint to Agent-Specific URL

**Files:**
- Modify: `.github/actions/agent-sync-action/scripts/sync-agents.sh:112-117`

- [ ] **Step 1: Update curl endpoint from /agents/sync to /agents/{id}/edit**

Replace lines 112-117 with the updated curl command:

```bash
  # Uncommented and updated endpoint for live sync
  HTTP_CODE=$(curl -s -o "$RUNNER_TEMP/sync-response-${FOLDER}.json" -w '%{http_code}' \
    -X POST "${INSTANCE_URL}/rest/api/v1/agents/${AGENT_ID}/edit" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_BODY")
```

Key changes:
- Line 113: Changed endpoint from `/rest/api/v1/agents/sync` to `/rest/api/v1/agents/${AGENT_ID}/edit`
- Removed line 117: `HTTP_CODE=200` (dry-run stub)
- Uncommented the curl command (previously lines 112-116 were commented)

- [ ] **Step 2: Verify script syntax is valid**

Run shellcheck to catch any syntax errors:

```bash
shellcheck .github/actions/agent-sync-action/scripts/sync-agents.sh
```

Expected: No errors (or only warnings that don't affect functionality)

- [ ] **Step 3: Verify the curl command would use correct URL format**

Add temporary debug output before the curl command to inspect the constructed URL:

```bash
# Add this line temporarily before the curl command (around line 111)
echo "DEBUG: Would POST to ${INSTANCE_URL}/rest/api/v1/agents/${AGENT_ID}/edit"
```

Then run a dry-test with environment variables:

```bash
export INSTANCE_URL="https://salessavvy-test-be.glean.com"
export AGENT_ID="test-agent-123"
echo "DEBUG: Would POST to ${INSTANCE_URL}/rest/api/v1/agents/${AGENT_ID}/edit"
```

Expected output: `DEBUG: Would POST to https://salessavvy-test-be.glean.com/rest/api/v1/agents/test-agent-123/edit`

Remove the debug line after verification.

- [ ] **Step 4: Commit endpoint change**

```bash
git add .github/actions/agent-sync-action/scripts/sync-agents.sh
git commit -m "feat: update API endpoint to agent-specific edit URL

Change from /agents/sync to /agents/{agent-id}/edit endpoint.
Enable live API calls by uncommenting curl and removing dry-run stub.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 3: Validation and Documentation

**Files:**
- Read: `.github/actions/agent-sync-action/scripts/sync-agents.sh:1-145`
- Read: `.glean/agents/sample-agent/glean-sync.yaml`

- [ ] **Step 1: Verify script runs without errors in dry-run mode**

Set up test environment variables and run the script with minimal config:

```bash
export API_TOKEN="dummy-token-for-testing"
export AGENT_DIR=".glean/agents"
export EVENT_NAME="pull_request"
export COMMIT_SHA="test-sha-123"
export INSTANCE_URL="https://test.glean.com"
export FOLDERS_JSON='["sample-agent"]'
export DEFAULT_MESSAGE="Test sync"
export RUNNER_TEMP="/tmp"
export GITHUB_OUTPUT="/tmp/test-github-output.txt"

# Run script (will fail on actual API call, but that's expected)
bash .github/actions/agent-sync-action/scripts/sync-agents.sh 2>&1 | head -20
```

Expected: Script processes the agent folder, builds the request body correctly, shows the JSON with workflowSource field, and attempts the curl call (which will fail without valid credentials - that's fine)

- [ ] **Step 2: Verify request body contains all required fields**

Check that the debug output from the script shows the complete request structure:

```bash
# The script echoes "Request body:" followed by the JSON
# Verify the output includes:
# - id
# - commitSha
# - isDraft
# - workflowSource: "GIT"
# - name
# - description
# - icon
# - schema
```

Visual inspection of the output from Step 1.

- [ ] **Step 3: Update CLAUDE.md with deployment notes**

Add a note about the API changes to CLAUDE.md:

```bash
cat >> CLAUDE.md <<'EOF'

## Recent Changes (2026-04-24)

**Agent Sync API Update:**
- Updated endpoint from `/rest/api/v1/agents/sync` to `/rest/api/v1/agents/{agent-id}/edit`
- Added `workflowSource: "GIT"` field to all sync requests
- Enabled live API calls (removed dry-run mode)

**Before first sync:**
- Ensure `GLEAN_AGENT_SYNC_TOKEN` secret has valid credentials
- Verify all agents have valid `agent-id` in their `glean-sync.yaml`
- The Glean instance must support the `/agents/{id}/edit` endpoint
EOF
```

- [ ] **Step 4: Commit documentation update**

```bash
git add CLAUDE.md
git commit -m "docs: add agent sync API update notes to CLAUDE.md

Document the endpoint change and workflowSource field addition.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

### Task 4: Clean Up Test Artifacts

**Files:**
- Delete: `/tmp/test-agent-spec.json`
- Delete: `/tmp/test-github-output.txt`

- [ ] **Step 1: Remove temporary test files**

```bash
rm -f /tmp/test-agent-spec.json /tmp/test-github-output.txt
```

- [ ] **Step 2: Verify final script state**

Read the final script to confirm all changes are in place:

```bash
# Check build_sync_request includes workflowSource
grep -A 20 "^build_sync_request()" .github/actions/agent-sync-action/scripts/sync-agents.sh | grep "workflowSource"

# Check endpoint uses agent-specific URL
grep -n "rest/api/v1/agents/\${AGENT_ID}/edit" .github/actions/agent-sync-action/scripts/sync-agents.sh

# Verify dry-run stub is removed
grep -n "HTTP_CODE=200" .github/actions/agent-sync-action/scripts/sync-agents.sh || echo "✓ Dry-run stub removed"
```

Expected:
- First command shows: `workflowSource: "GIT",`
- Second command shows line number with the new endpoint
- Third command shows "✓ Dry-run stub removed"

- [ ] **Step 3: Review all commits**

```bash
git log --oneline -4
```

Expected: Shows 4 commits (design doc, workflowSource field, endpoint update, documentation)

---

## Pre-Deployment Checklist

Before running this in production:

1. **Verify Glean instance supports `/agents/{id}/edit` endpoint** - Test with curl manually or check API documentation
2. **Set `GLEAN_AGENT_SYNC_TOKEN` secret** - Must have `AGENTS` scope permissions
3. **Validate agent-id values** - Check all `.glean/agents/*/glean-sync.yaml` files have valid agent IDs (not placeholder)
4. **Test on PR first** - Create a test PR with agent changes to verify draft preview mode works
5. **Monitor first merge** - Watch workflow logs when first merged to master to ensure publish mode works

## Rollback Plan

If the changes cause issues:

```bash
# Revert to previous version
git revert HEAD~3..HEAD
git push origin master
```

This will revert the three implementation commits while preserving the design doc commit.
