#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# PAW Skill Suites — Install Script
# Syncs skill-suites/src/ → ~/.claude/skills/
#
# Usage:
#   ./install.sh           # install all suites
#   ./install.sh marketing # install one suite only
#   ./install.sh --dry-run # preview what would be copied
# ─────────────────────────────────────────────────────────────────────────────

set -e

SRC_DIR="$(cd "$(dirname "$0")/src" && pwd)"
DEST_DIR="$HOME/.claude/skills"
DRY_RUN=false
SUITE_FILTER=""

# ── Args ──────────────────────────────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
    --*) echo "Unknown flag: $arg"; exit 1 ;;
    *) SUITE_FILTER="$arg" ;;
  esac
done

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo "PAW Skill Suites — Install"
echo "  Source : $SRC_DIR"
echo "  Dest   : $DEST_DIR"
echo "  Mode   : $([ "$DRY_RUN" = true ] && echo 'DRY RUN' || echo 'LIVE')"
[ -n "$SUITE_FILTER" ] && echo "  Suite  : $SUITE_FILTER"
echo ""

mkdir -p "$DEST_DIR"

# ── Install ───────────────────────────────────────────────────────────────────
installed=0
skipped=0

for suite_dir in "$SRC_DIR"/*/; do
  suite=$(basename "$suite_dir")

  # Filter to a specific suite if requested
  if [ -n "$SUITE_FILTER" ] && [ "$suite" != "$SUITE_FILTER" ]; then
    continue
  fi

  for skill_dir in "$suite_dir"*/; do
    [ -d "$skill_dir" ] || continue
    [ -f "$skill_dir/SKILL.md" ] || continue

    skill=$(basename "$skill_dir")
    dest="$DEST_DIR/$skill"

    if [ "$DRY_RUN" = true ]; then
      echo "  → $skill"
      ((installed++)) || true
      continue
    fi

    # Copy skill dir, overwriting existing
    rm -rf "$dest"
    cp -r "$skill_dir" "$dest"
    echo "  ✓ $skill"
    ((installed++)) || true
  done
done

# ── Report ────────────────────────────────────────────────────────────────────
echo ""
if [ "$DRY_RUN" = true ]; then
  echo "Dry run — $installed skill(s) would be installed to $DEST_DIR"
else
  echo "$installed skill(s) installed to $DEST_DIR"
  echo ""
  echo "Restart Claude Code to pick up changes."
fi
echo ""
