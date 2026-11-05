#!/usr/bin/env bash
set -euo pipefail
# Link the shared skills repo into the global skills dir and into every
# Hermes profile's skills dir, and register it as an external skills source
# per profile. Idempotent.

SKILLS_DIR="$HOME/Git/skills"
HERMES_SKILLS="$HOME/.hermes/skills"

# Profiles that exist in HERMES_HOME.
PROFILES=(architect coder qa investigator)

# --- global ~/.hermes/skills --------------------------------------------------
mkdir -p "$HERMES_SKILLS"
for skill_dir in "$SKILLS_DIR"/*/; do
  [[ -d "$skill_dir" ]] || continue
  skill=$(basename "$skill_dir")
  target="$HERMES_SKILLS/$skill"
  if [[ -L "$target" ]]; then
    echo "Already linked: $skill -> $(readlink "$target")"
  elif [[ -d "$target" ]]; then
    echo "Skipping $skill — exists as real dir"
  else
    ln -s "$skill_dir" "$target"
    echo "Linked: $skill -> $skill_dir"
  fi
done

# --- per-profile skills dirs ----------------------------------------------------
for profile in "${PROFILES[@]}"; do
  profile_skills="$HOME/.hermes/profiles/$profile/skills"
  mkdir -p "$profile_skills"

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
      echo "Linked: $profile/$skill -> $skill_dir"
    fi
  done

  hermes -p "$profile" config set skills.external_dirs "$SKILLS_DIR"
  echo "  [$profile] skills.external_dirs = $SKILLS_DIR"
done
