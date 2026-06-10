#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${1:-}" ]]; then
  echo "Usage: new-env <name>"
  exit 1
fi

name="$1"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_dir="$DOTFILES_DIR/environments/$name"

if [[ -d "$env_dir" ]]; then
  echo "ERROR: environments/$name already exists"
  exit 1
fi

mkdir -p "$env_dir"

cat > "$env_dir/.envrc" << 'EOF'
use flake ".#default" --impure
EOF

direnv allow "$env_dir"

echo "Created environments/$name"
echo "  → add environments/$name/flake.nix"
echo "  → cd environments/$name to activate"
