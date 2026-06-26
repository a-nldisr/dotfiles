#!/usr/bin/env bash
set -euo pipefail

echo "Starting Hermes config setup"

HERMES_PROFILES="$HOME/.hermes/profiles"
OLLAMA_URL="http://localhost:11434/v1"
HERMES_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

config_set() {
  local profile="$1"
  local key="$2"
  local value="$3"
  hermes -p "$profile" config set "$key" "$value"
  echo "  [${profile}] ${key} = ${value}"
}

ensure_profile() {
  local profile="$1"
  if [[ ! -d "$HERMES_PROFILES/$profile" ]]; then
    echo "Creating profile: $profile"
    hermes profile create "$profile"
  else
    echo "Profile exists: $profile"
  fi
}

# ---------------------------------------------------------------------------
# Profiles
# ---------------------------------------------------------------------------

declare -A PROFILE_MODELS=(
  [architect]="qwen3.6:35b-a3b"
  [coder]="qwen3.6:35b-a3b"
  [qa]="qwen3:14b"
  [investigator]="qwen3:8b"
)

for profile in "${!PROFILE_MODELS[@]}"; do
  ensure_profile "$profile"
done

# ---------------------------------------------------------------------------
# Model config — all profiles use local Ollama
# ---------------------------------------------------------------------------

for profile in "${!PROFILE_MODELS[@]}"; do
  echo "Configuring model for: $profile"
  model="${PROFILE_MODELS[$profile]}"
  config_set "$profile" model.provider       custom
  config_set "$profile" model.base_url       "$OLLAMA_URL"
  config_set "$profile" model.default        "$model"
  config_set "$profile" model.api_key        ollama
  config_set "$profile" model.context_length 65536
done

# ---------------------------------------------------------------------------
# Architect — orchestrator role
# ---------------------------------------------------------------------------

echo "Configuring delegation for: architect"
config_set architect delegation.provider               custom
config_set architect delegation.base_url               "$OLLAMA_URL"
config_set architect delegation.max_iterations         100
config_set architect delegation.max_concurrent_children 3
config_set architect delegation.max_spawn_depth        2
config_set architect delegation.timeout                600
config_set architect delegation.subagent_auto_approve  false

# ---------------------------------------------------------------------------
# Coder — leaf delegator
# ---------------------------------------------------------------------------

echo "Configuring delegation for: coder"
config_set coder delegation.provider               custom
config_set coder delegation.base_url               "$OLLAMA_URL"
config_set coder delegation.max_spawn_depth        1
config_set coder delegation.max_concurrent_children 2

# ---------------------------------------------------------------------------
# QA — leaf delegator
# ---------------------------------------------------------------------------

echo "Configuring delegation for: qa"
config_set qa delegation.provider               custom
config_set qa delegation.base_url               "$OLLAMA_URL"
config_set qa delegation.max_spawn_depth        1
config_set qa delegation.max_concurrent_children 2

# ---------------------------------------------------------------------------
# Auxiliary (title generation) — architect profile
# ---------------------------------------------------------------------------

echo "Configuring auxiliary for architect profile"
hermes -p architect config set auxiliary.title.provider custom
hermes -p architect config set auxiliary.title.base_url "$OLLAMA_URL"
hermes -p architect config set auxiliary.title.model    "${PROFILE_MODELS[architect]}"

# ---------------------------------------------------------------------------
# Gateway systemd service — architect profile
# ---------------------------------------------------------------------------

echo "Installing gateway systemd service"
hermes -p architect gateway install
systemctl --user daemon-reload
echo "  Gateway service installed: hermes-gateway-architect"

# ---------------------------------------------------------------------------
# Execute skills-setup to link skills directories
# ---------------------------------------------------------------------------

echo "Running skills setup"
bash "$HERMES_SCRIPT_DIR/hermes-skills-setup.sh"

# ---------------------------------------------------------------------------
# Execute cron-setup to register cron jobs
# ---------------------------------------------------------------------------

echo "Running cron setup"
bash "$HERMES_SCRIPT_DIR/cron-setup.sh"
echo "  Cron jobs registered"


# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
echo "Hermes config setup complete."
echo "Ensure you setup the integration with chat tools such as Telegram or Slack."
