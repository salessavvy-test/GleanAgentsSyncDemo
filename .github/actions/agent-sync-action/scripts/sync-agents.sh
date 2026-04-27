#!/usr/bin/env bash
set -euo pipefail

# Required env: API_TOKEN, AGENT_DIR, EVENT_NAME, COMMIT_SHA, INSTANCE_URL_BE, FOLDERS_JSON
# Optional env: DEFAULT_MESSAGE (from PR title or git commit subject)

INSTANCE_URL_BE="${INSTANCE_URL_BE%/}"
RESULTS="[]"
HAS_FAILURE=false

build_sync_request_workflow() {
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

build_sync_request_automode() {
  local agent_id="$1"
  local converter_json="$2"
  local commit_sha="$3"
  local is_draft="$4"
  local message="$5"

  echo "$converter_json" | jq -c \
    --arg id "$agent_id" \
    --arg sha "$commit_sha" \
    --argjson draft "$is_draft" \
    --arg msg "$message" \
    '. + {
      id: $id,
      commitSha: $sha,
      isDraft: $draft,
      workflowSource: "GIT"
    } + if $msg != "" then {stagingOptions: {save: true, commitMessage: $msg}} else {} end'
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONVERTER="${SCRIPT_DIR}/agent_converter.py"

while IFS= read -r FOLDER; do
  FOLDER_PATH="${AGENT_DIR}/${FOLDER}"

  if [ ! -d "$FOLDER_PATH" ]; then
    echo "::warning::Agent folder ${FOLDER_PATH} was deleted — skipping. To retire a Git-managed agent, switch it back to UI-managed mode in Agent Builder."
    RESULTS=$(echo "$RESULTS" | jq -c \
      --arg aid "$FOLDER" \
      '. + [{"agentId": $aid, "agentMode": "unknown", "mode": "deleted", "status": "skipped", "error": "folder deleted — switch to UI-managed mode to retire"}]')
    continue
  fi

  SYNC_FILE="${FOLDER_PATH}/glean-sync.yaml"
  if [ ! -f "$SYNC_FILE" ]; then
    echo "::error::Missing glean-sync.yaml in ${FOLDER_PATH} — every agent folder must contain a glean-sync.yaml with at least an agent-id field."
    RESULTS=$(echo "$RESULTS" | jq -c \
      --arg aid "$FOLDER" \
      '. + [{"agentId": $aid, "agentMode": "unknown", "mode": "unknown", "status": "error", "error": "missing glean-sync.yaml — add one with at least agent-id"}]')
    HAS_FAILURE=true
    continue
  fi

  AGENT_ID=$(yq '."agent-id" // ""' "$SYNC_FILE")
  MESSAGE=$(yq '.message // ""' "$SYNC_FILE")
  if [ -z "$MESSAGE" ]; then
    MESSAGE="${DEFAULT_MESSAGE:-}"
  fi

  if [ -z "$AGENT_ID" ]; then
    echo "::error::Missing agent-id in ${SYNC_FILE}"
    RESULTS=$(echo "$RESULTS" | jq -c \
      --arg aid "$FOLDER" \
      '. + [{"agentId": $aid, "agentMode": "unknown", "mode": "unknown", "status": "error", "error": "missing agent-id in glean-sync.yaml"}]')
    HAS_FAILURE=true
    continue
  fi

  AGENT_MODE=$(yq '.mode // ""' "$SYNC_FILE")
  if [ "$AGENT_MODE" != "workflow" ] && [ "$AGENT_MODE" != "automode" ]; then
    echo "::error::Invalid or missing 'mode' in ${SYNC_FILE} — must be 'workflow' or 'automode'. Got: '${AGENT_MODE}'"
    RESULTS=$(echo "$RESULTS" | jq -c \
      --arg aid "$FOLDER" \
      --arg agentMode "$AGENT_MODE" \
      '. + [{"agentId": $aid, "agentMode": $agentMode, "mode": "unknown", "status": "error", "error": "mode must be workflow or automode in glean-sync.yaml"}]')
    HAS_FAILURE=true
    continue
  fi

  IS_DRAFT=true
  MODE="draft_preview"
  if [ "$EVENT_NAME" != "pull_request" ]; then
    IS_DRAFT=false
    MODE="published"
  fi

  if [ "$AGENT_MODE" = "workflow" ]; then
    # Find the first .json spec file in the agent folder
    SPEC_FILE=""
    for JSON_FILE in "${FOLDER_PATH}"/*.json; do
      [ -f "$JSON_FILE" ] || continue
      SPEC_FILE="$JSON_FILE"
      break
    done

    if [ -z "$SPEC_FILE" ]; then
      echo "::error::No .json spec file found in ${FOLDER_PATH}"
      RESULTS=$(echo "$RESULTS" | jq -c \
        --arg aid "$AGENT_ID" \
        --arg agentMode "$AGENT_MODE" \
        '. + [{"agentId": $aid, "agentMode": $agentMode, "mode": "unknown", "status": "error", "error": "no .json spec file found"}]')
      HAS_FAILURE=true
      continue
    fi

    SPEC_JSON=$(cat "$SPEC_FILE")
    if ! echo "$SPEC_JSON" | jq empty 2>/dev/null; then
      echo "::error::Invalid JSON in ${SPEC_FILE}"
      RESULTS=$(echo "$RESULTS" | jq -c \
        --arg aid "$AGENT_ID" \
        --arg agentMode "$AGENT_MODE" \
        '. + [{"agentId": $aid, "agentMode": $agentMode, "mode": "unknown", "status": "error", "error": "invalid JSON in spec file"}]')
      HAS_FAILURE=true
      continue
    fi

    REQUEST_BODY=$(build_sync_request_workflow "$AGENT_ID" "$SPEC_JSON" "$COMMIT_SHA" "$IS_DRAFT" "$MESSAGE")

  elif [ "$AGENT_MODE" = "automode" ]; then
    CONVERTER_STDERR_FILE="$RUNNER_TEMP/converter-stderr-${FOLDER}.txt"
    set +e
    CONVERTER_OUTPUT=$(uv run "$CONVERTER" to-json "$FOLDER" --dir "$AGENT_DIR" 2>"$CONVERTER_STDERR_FILE")
    CONVERTER_EXIT=$?
    set -e

    if [ $CONVERTER_EXIT -ne 0 ]; then
      CONVERTER_ERR=$(cat "$CONVERTER_STDERR_FILE" 2>/dev/null || echo "unknown converter error")
      echo "::error::Converter failed for ${FOLDER} — ${CONVERTER_ERR}"
      RESULTS=$(echo "$RESULTS" | jq -c \
        --arg aid "$AGENT_ID" \
        --arg agentMode "$AGENT_MODE" \
        --arg mode "$MODE" \
        --arg err "Converter failed: $CONVERTER_ERR" \
        '. + [{"agentId": $aid, "agentMode": $agentMode, "mode": $mode, "status": "error", "error": $err}]')
      HAS_FAILURE=true
      continue
    fi

    if ! echo "$CONVERTER_OUTPUT" | jq empty 2>/dev/null; then
      echo "::error::Converter produced invalid JSON for ${FOLDER} — check spec.yaml and instructions.md"
      RESULTS=$(echo "$RESULTS" | jq -c \
        --arg aid "$AGENT_ID" \
        --arg agentMode "$AGENT_MODE" \
        --arg mode "$MODE" \
        '. + [{"agentId": $aid, "agentMode": $agentMode, "mode": $mode, "status": "error", "error": "converter produced invalid JSON"}]')
      HAS_FAILURE=true
      continue
    fi

    SPEC_YAML_ID=$(yq '.id // ""' "${FOLDER_PATH}/spec.yaml" 2>/dev/null || echo "")
    if [ -n "$SPEC_YAML_ID" ] && [ "$SPEC_YAML_ID" != "$AGENT_ID" ]; then
      echo "::error::Agent ID mismatch in ${FOLDER} — glean-sync.yaml has '${AGENT_ID}' but spec.yaml has '${SPEC_YAML_ID}'. These must match."
      RESULTS=$(echo "$RESULTS" | jq -c \
        --arg aid "$AGENT_ID" \
        --arg agentMode "$AGENT_MODE" \
        --arg mode "$MODE" \
        --arg err "Agent ID mismatch: glean-sync.yaml='$AGENT_ID' spec.yaml='$SPEC_YAML_ID'" \
        '. + [{"agentId": $aid, "agentMode": $agentMode, "mode": $mode, "status": "error", "error": $err}]')
      HAS_FAILURE=true
      continue
    fi

    REQUEST_BODY=$(build_sync_request_automode "$AGENT_ID" "$CONVERTER_OUTPUT" "$COMMIT_SHA" "$IS_DRAFT" "$MESSAGE")
  fi

  echo "Agent: $AGENT_ID (folder: $FOLDER)"
  echo "  Mode: $MODE | AgentMode: $AGENT_MODE | Message: $MESSAGE"
  echo "  Request body:"
  echo "$REQUEST_BODY" | jq .

  # Endpoint for live sync
  HTTP_CODE=$(curl -s -o "$RUNNER_TEMP/sync-response-${FOLDER}.json" -w '%{http_code}' \
    -X POST "${INSTANCE_URL_BE}/rest/api/v1/agents/${AGENT_ID}/edit" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_BODY")

  if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
    echo "  Synced successfully (HTTP $HTTP_CODE)"
    RESULTS=$(echo "$RESULTS" | jq -c \
      --arg aid "$AGENT_ID" \
      --arg agentMode "$AGENT_MODE" \
      --arg mode "$MODE" \
      --arg msg "$MESSAGE" \
      '. + [{"agentId": $aid, "agentMode": $agentMode, "mode": $mode, "message": $msg, "status": "success"}]')
  else
    RESP_BODY=$(cat "$RUNNER_TEMP/sync-response-${FOLDER}.json" 2>/dev/null || echo "no response body")
    echo "::error::Failed to sync agent $AGENT_ID (HTTP $HTTP_CODE): $RESP_BODY"
    RESULTS=$(echo "$RESULTS" | jq -c \
      --arg aid "$AGENT_ID" \
      --arg agentMode "$AGENT_MODE" \
      --arg mode "$MODE" \
      --arg err "HTTP $HTTP_CODE" \
      '. + [{"agentId": $aid, "agentMode": $agentMode, "mode": $mode, "status": "error", "error": $err}]')
    HAS_FAILURE=true
  fi
done < <(echo "$FOLDERS_JSON" | jq -r '.[]')

echo "$RESULTS" > "$RUNNER_TEMP/agent-sync-results.json"
echo "synced-agents=$RESULTS" >> "$GITHUB_OUTPUT"

if [ "$HAS_FAILURE" = "true" ]; then
  echo "::error::One or more agents failed to sync"
  exit 1
fi
