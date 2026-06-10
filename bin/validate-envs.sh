#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/environments"
errors=0

for env_dir in "$ENVIRONMENTS_DIR"/*/; do
  env_name=$(basename "$env_dir")

  if [[ ! -f "$env_dir/.envrc" ]]; then
    echo "Scaffolding missing .envrc for environments/$env_name"
    cat > "$env_dir/.envrc" << 'EOF'
use flake ".#default" --impure
EOF
    git add "$env_dir/.envrc"
  fi

  if [[ ! -f "$env_dir/flake.nix" ]]; then
    echo "ERROR: environments/$env_name is missing flake.nix"
    (( errors++ )) || true
  fi
done

if [[ $errors -gt 0 ]]; then
  echo ""
  echo "Found $errors environment(s) missing flake.nix — commit blocked."
  exit 1
fi

echo "All environments valid."
