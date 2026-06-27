#!/usr/bin/env bash
set -euo pipefail

HERMES_PROFILES="${HOME}/.hermes/profiles"
AGENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../agents" && pwd)"

echo "Starting agent .md setup"
echo "  agents dir : ${AGENTS_DIR}"
echo "  profiles   : ${HERMES_PROFILES}"

if [[ ! -d "$AGENTS_DIR" ]]; then
  echo "ERROR: agents dir not found: ${AGENTS_DIR}" >&2
  exit 1
fi

for agent_dir in "${AGENTS_DIR}"/*/; do
  profile="$(basename "$agent_dir")"
  profile_dir="${HERMES_PROFILES}/${profile}"

  if [[ ! -d "$profile_dir" ]]; then
    echo "  [${profile}] no matching Hermes profile found, skipping"
    continue
  fi

  shopt -s nullglob
  md_files=("${agent_dir}"*.md)
  shopt -u nullglob

  if [[ ${#md_files[@]} -eq 0 ]]; then
    echo "  [${profile}] no .md files found, skipping"
    continue
  fi

  for src in "${md_files[@]}"; do
    filename="$(basename "$src")"
    dest="${profile_dir}/${filename}"

    if [[ -L "$dest" ]]; then
      current_target="$(readlink "$dest")"
      if [[ "$current_target" == "$src" ]]; then
        echo "  [${profile}] symlink already correct: ${filename}"
        continue
      fi
      echo "  [${profile}] updating symlink: ${filename} (was -> ${current_target})"
      ln -sf "$src" "$dest"
    elif [[ -f "$dest" ]]; then
      echo "  [${profile}] WARNING: ${filename} exists as a regular file, skipping (remove it manually to replace with symlink)"
    else
      echo "  [${profile}] linking: ${filename} -> ${src}"
      ln -s "$src" "$dest"
    fi
  done
done

echo "Agent .md setup complete."