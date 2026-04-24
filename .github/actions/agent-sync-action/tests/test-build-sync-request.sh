#!/bin/bash
set -e

# Extract and source only the build_sync_request function
# (avoid sourcing the whole script which has unbound variable checks)
eval "$(sed -n '/^build_sync_request()/,/^}/p' .github/actions/agent-sync-action/scripts/sync-agents.sh)"

# Test data
SPEC_JSON='{"rootWorkflow":{"name":"Test","description":"Desc","icon":"DEFAULT","schema":{"steps":[]}}}'

# Test 1: Verify workflowSource field is present and correct
OUTPUT=$(build_sync_request "test-id" "$SPEC_JSON" "sha123" "true" "msg")

echo "$OUTPUT" | jq -e '.workflowSource == "GIT"' > /dev/null || { echo "FAIL: workflowSource missing or incorrect"; exit 1; }
echo "✓ workflowSource field correct"

# Test 2: Verify all required fields are present
echo "$OUTPUT" | jq -e '.id == "test-id"' > /dev/null || { echo "FAIL: id incorrect"; exit 1; }
echo "✓ id field correct"

echo "$OUTPUT" | jq -e '.commitSha == "sha123"' > /dev/null || { echo "FAIL: commitSha incorrect"; exit 1; }
echo "✓ commitSha field correct"

echo "$OUTPUT" | jq -e '.isDraft == true' > /dev/null || { echo "FAIL: isDraft incorrect"; exit 1; }
echo "✓ isDraft field correct"

echo "$OUTPUT" | jq -e '.name == "Test"' > /dev/null || { echo "FAIL: name incorrect"; exit 1; }
echo "✓ name field correct"

echo "$OUTPUT" | jq -e '.description == "Desc"' > /dev/null || { echo "FAIL: description incorrect"; exit 1; }
echo "✓ description field correct"

echo "$OUTPUT" | jq -e '.icon == "DEFAULT"' > /dev/null || { echo "FAIL: icon incorrect"; exit 1; }
echo "✓ icon field correct"

echo "$OUTPUT" | jq -e '.schema.steps | length == 0' > /dev/null || { echo "FAIL: schema incorrect"; exit 1; }
echo "✓ schema field correct"

# Test 3: Verify stagingOptions when message provided
echo "$OUTPUT" | jq -e '.stagingOptions.save == true' > /dev/null || { echo "FAIL: stagingOptions.save incorrect"; exit 1; }
echo "✓ stagingOptions.save field correct"

echo "$OUTPUT" | jq -e '.stagingOptions.commitMessage == "msg"' > /dev/null || { echo "FAIL: stagingOptions.commitMessage incorrect"; exit 1; }
echo "✓ stagingOptions.commitMessage field correct"

echo ""
echo "✅ All tests passed"
