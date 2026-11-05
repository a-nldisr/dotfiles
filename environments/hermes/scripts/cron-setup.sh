#!/usr/bin/env bash
set -euo pipefail

echo "Registering Hermes cron jobs"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------

DEFAULT_SCHEDULE="5m"
DEFAULT_WORKDIR="$HOME/Git"
DEFAULT_DELIVER="local"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

register_cron() {
  local name="$1"
  local prompt="$2"
  local schedule="${3:-$DEFAULT_SCHEDULE}"
  local workdir="${4:-$DEFAULT_WORKDIR}"
  local deliver="${5:-$DEFAULT_DELIVER}"
  local full_prompt="Working directory: $workdir. $prompt"

  if hermes cron list 2>/dev/null | grep -q "$name"; then
    echo "  Already registered: $name"
  else
    hermes cron create "$schedule" \
      --name "$name" \
      --skill "$name" \
      --workdir "$workdir" \
      --deliver "$deliver" \
      "$full_prompt"
    echo "  Registered: $name"
  fi
}

# ---------------------------------------------------------------------------
# Jobs
# ---------------------------------------------------------------------------

register_specloop() {
  local prompt="Scan the working directory for project folders containing spec.md
but no done.md and no working.lock. For each eligible project, write a
working.lock file and spawn the architect agent in the background to work
through the spec. Skip locked or completed projects. Check for stale locks
older than 30 minutes and remove them."

  register_cron "spec-loop" "$prompt"
}

finish() {
  echo ""
  hermes cron list
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

main() {
  register_specloop
  finish
}

main