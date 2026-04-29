# GitHub Actions GITHUB_OUTPUT multiline form (name<<DELIMITER … DELIMITER).
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#multiline-strings
github_output_heredoc() {
  local name="$1"
  local value="$2"
  local delim="GHSYNCACTION_EOF_7a3f9c2e1d8b4a6053f2e1c0d9b8a7f6"
  {
    printf '%s<<%s\n' "$name" "$delim"
    printf '%s\n' "$value"
    printf '%s\n' "$delim"
  } >> "$GITHUB_OUTPUT"
}
