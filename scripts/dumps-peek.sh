#!/usr/bin/env sh
# Inspect or search session dumps for the current project folder:
#   ~/.config/opencode/dumps/<current-folder-name>/
#
# Usage:
#   sh dumps-peek.sh              # Human-readable grouped summary for $PWD
#   sh dumps-peek.sh --index      # Structured snapshot used by OpenCode /dump & /peek
#   sh dumps-peek.sh -f | --fzf   # Interactive fuzzy browser with preview (if fzf installed)
#   sh dumps-peek.sh --all        # List all projects that have saved dumps
#   sh dumps-peek.sh <query>      # Filter notes for $PWD by path, frontmatter, or body

set -eu

DUMPS_BASE="${OPENCODE_DUMPS_DIR:-$HOME/.config/opencode/dumps}"
PROJECT="$(basename "$PWD")"
DUMP_ROOT="$DUMPS_BASE/$PROJECT"
TODAY="$(date +%Y-%m-%d)"

extract_meta() {
  awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { exit }
    in_fm && /^title:[[:space:]]*/ {
      sub(/^title:[[:space:]]*/, "")
      gsub(/^["'\'']|["'\'']$/, "")
      title = $0
    }
    in_fm && /^updated:[[:space:]]*/ {
      sub(/^updated:[[:space:]]*/, "")
      gsub(/^["'\'']|["'\'']$/, "")
      updated = $0
    }
    in_fm && /^summary:[[:space:]]*/ {
      sub(/^summary:[[:space:]]*/, "")
      gsub(/^["'\'']|["'\'']$/, "")
      summary = $0
    }
    END {
      desc = (summary != "" ? summary : (title != "" ? title : "(no summary)"))
      if (updated != "") {
        printf "[%s] — %s\n", updated, desc
      } else {
        printf "— %s\n", desc
      }
    }
  ' "$1"
}

MODE="${1:-human}"

case "$MODE" in
  --index)
    echo "PROJECT: $PROJECT"
    echo "DUMP_ROOT: $DUMP_ROOT"
    echo "TODAY: $TODAY"
    echo "EXISTING_DOMAINS:"
    if [ -d "$DUMP_ROOT" ]; then
      domains="$(find "$DUMP_ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | sort)"
      if [ -n "$domains" ]; then
        printf "%s\n" "$domains" | while IFS= read -r dir; do
          echo "- $(basename "$dir")"
        done
      else
        echo "- (none yet)"
      fi
    else
      echo "- (none yet)"
    fi

    echo "EXISTING_NOTES:"
    if [ -d "$DUMP_ROOT" ]; then
      notes="$(find "$DUMP_ROOT" -type f -name '*.md' ! -path '*/.*' | sort)"
      if [ -n "$notes" ]; then
        printf "%s\n" "$notes" | while IFS= read -r file; do
          rel="${file#"$DUMP_ROOT"/}"
          echo "- $rel $(extract_meta "$file")"
        done
      else
        echo "- (none yet)"
      fi
    else
      echo "- (none yet)"
    fi
    ;;

  -a|--all)
    if [ ! -d "$DUMPS_BASE" ]; then
      echo "No dumps directory yet at $DUMPS_BASE"
      exit 0
    fi
    echo "Saved project dumps in $DUMPS_BASE:"
    find "$DUMPS_BASE" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | sort | while IFS= read -r proj; do
      count="$(find "$proj" -type f -name '*.md' ! -path '*/.*' | wc -l | tr -d ' ')"
      echo "  $(basename "$proj") ($count notes)"
    done
    ;;

  -f|--fzf)
    if [ ! -d "$DUMP_ROOT" ]; then
      echo "No dumps yet for '$PROJECT' ($DUMP_ROOT)"
      exit 0
    fi
    if ! command -v fzf >/dev/null 2>&1; then
      echo "fzf not found; showing index instead:" >&2
      exec sh "$0"
    fi
    PREVIEW_CMD='cat {}'
    if command -v bat >/dev/null 2>&1; then
      PREVIEW_CMD='bat --style=numbers --color=always {}'
    fi
    cd "$DUMP_ROOT"
    selected="$(
      find . -type f -name '*.md' ! -path '*/.*' \
        | sed 's|^\./||' \
        | sort \
        | fzf --prompt="$PROJECT dumps > " --preview="$PREVIEW_CMD" --preview-window=right:65%:wrap
    )" || exit 0
    [ -n "$selected" ] && cat "$DUMP_ROOT/$selected"
    ;;

  -h|--help)
    sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
    ;;

  human)
    echo "Project dumps for '$PROJECT' ($DUMP_ROOT):"
    if [ ! -d "$DUMP_ROOT" ]; then
      echo "  (none yet — run /dump in opencode2 to save findings)"
      exit 0
    fi
    notes="$(find "$DUMP_ROOT" -type f -name '*.md' ! -path '*/.*' | sort)"
    if [ -z "$notes" ]; then
      echo "  (none yet — run /dump in opencode2 to save findings)"
      exit 0
    fi
    current_domain=""
    printf "%s\n" "$notes" | while IFS= read -r file; do
      rel="${file#"$DUMP_ROOT"/}"
      domain="$(dirname "$rel")"
      name="$(basename "$rel")"
      if [ "$domain" != "$current_domain" ]; then
        echo ""
        echo "  [$domain]"
        current_domain="$domain"
      fi
      echo "    $name $(extract_meta "$file")"
    done
    ;;

  *)
    # Treat all arguments as a case-insensitive search query across path & content
    QUERY="$*"
    if [ ! -d "$DUMP_ROOT" ]; then
      echo "No dumps yet for '$PROJECT' ($DUMP_ROOT)"
      exit 0
    fi
    echo "Matches for '$QUERY' in $DUMP_ROOT:"
    found=0
    for file in $(find "$DUMP_ROOT" -type f -name '*.md' ! -path '*/.*' | sort); do
      rel="${file#"$DUMP_ROOT"/}"
      if printf "%s\n" "$rel" | grep -iq -- "$QUERY" || grep -iq -- "$QUERY" "$file"; then
        found=1
        echo "  - $rel $(extract_meta "$file")"
      fi
    done
    [ "$found" -eq 0 ] && echo "  (no matching notes)"
    exit 0
    ;;
esac
