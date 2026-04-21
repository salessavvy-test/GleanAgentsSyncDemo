#!/usr/bin/env bash
set -euo pipefail

# Required env: AGENT_DIR, EVENT_NAME, PR_BASE_SHA, PUSH_BEFORE_SHA
# Optional env: PR_TITLE

if [ "$EVENT_NAME" = "pull_request" ]; then
  BASE_SHA="$PR_BASE_SHA"
elif [ "$EVENT_NAME" = "push" ]; then
  BASE_SHA="$PUSH_BEFORE_SHA"
else
  echo "::error::Unsupported event: $EVENT_NAME. Expected pull_request or push."
  exit 1
fi

if [ "$BASE_SHA" = "0000000000000000000000000000000000000000" ]; then
  BASE_SHA="4b825dc642cb6eb9a060e54bf8d69288fbee4904"  # git empty-tree SHA
fi

CHANGED_FILES=$(git diff --name-only --diff-filter=ACMRD "$BASE_SHA" HEAD -- "$AGENT_DIR/")
if [ -z "$CHANGED_FILES" ]; then
  echo "No agent spec folders changed — nothing to sync."
  echo "folders=[]" >> "$GITHUB_OUTPUT"
  exit 0
fi

ESCAPED_DIR=$(printf '%s' "$AGENT_DIR" | sed 's/[.[\(*^$]/\\&/g')
FOLDERS=$(echo "$CHANGED_FILES" \
  | sed "s|^${ESCAPED_DIR}/||" \
  | cut -d'/' -f1 \
  | sort -u \
  | jq -R -s -c 'split("\n") | map(select(length > 0))')

ACTUAL_SHA=$(git rev-parse HEAD)
echo "folders=$FOLDERS" >> "$GITHUB_OUTPUT"
echo "event=$EVENT_NAME" >> "$GITHUB_OUTPUT"
echo "commit_sha=$ACTUAL_SHA" >> "$GITHUB_OUTPUT"

# Derive a default commit message from PR title or git commit subject
if [ "$EVENT_NAME" = "pull_request" ] && [ -n "${PR_TITLE:-}" ]; then
  echo "default_message=${PR_TITLE}" >> "$GITHUB_OUTPUT"
else
  DEFAULT_MSG=$(git log -1 --format='%s' "$ACTUAL_SHA")
  echo "default_message=${DEFAULT_MSG}" >> "$GITHUB_OUTPUT"
fi

echo "Changed agent folders: $FOLDERS"
