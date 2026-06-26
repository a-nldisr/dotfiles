#!/usr/bin/env bash
set -euo pipefail

SKILLS_DIR="$HOME/Git/skills"
HERMES_PROFILES="$HOME/.hermes/profiles"

# Parse profile names from hermes profile list, skip header lines, strip leading symbols
profiles=$(hermes profile list 2>/dev/null | awk 'NR>2 {print $1}' | tr -d '◆ ' | grep -av '^[-─]*$' | grep -av '^$' | grep -a '^[a-zA-Z]')

for profile in $profiles; do
  [[ -z "$profile" ]] && continue

  profile_skills="$HERMES_PROFILES/$profile/skills"
  if [[ ! -d "$profile_skills" ]]; then
    echo "Skipping $profile — skills dir not found"
    continue
  fi

  for skill_dir in "$SKILLS_DIR"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill=$(basename "$skill_dir")
    target="$profile_skills/$skill"
    if [[ -L "$target" ]]; then
      echo "Already linked: $profile/$skill"
    elif [[ -d "$target" ]]; then
      echo "Skipping $profile/$skill — exists as real dir"
    else
      ln -s "$skill_dir" "$target"
      echo "Linked: $profile/$skill"
    fi
  done

  hermes -p "$profile" config set skills.external_dirs "$SKILLS_DIR"
  echo "  [$profile] skills.external_dirs = $SKILLS_DIR"
done