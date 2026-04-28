#!/usr/bin/env bash
# Validates SKILL.md frontmatter and layout invariants.
# Exits non-zero if any skill fails.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"
fail=0

err() { printf "ERR  %s: %s\n" "$1" "$2" >&2; fail=1; }
warn() { printf "WARN %s: %s\n" "$1" "$2" >&2; }

if [[ ! -d "$SKILLS_DIR" ]]; then
    echo "no skills/ directory yet — nothing to validate"
    exit 0
fi

for skill_dir in "$SKILLS_DIR"/*/; do
    skill="$(basename "$skill_dir")"
    md="$skill_dir/SKILL.md"

    if [[ ! -f "$md" ]]; then
        err "$skill" "missing SKILL.md"
        continue
    fi

    if ! head -n 1 "$md" | grep -q '^---$'; then
        err "$skill" "SKILL.md does not start with frontmatter delimiter"
        continue
    fi

    fm="$(awk '/^---$/{n++; next} n==1{print}' "$md")"

    name="$(echo "$fm" | awk -F': *' '/^name:/{print $2; exit}')"
    desc="$(echo "$fm" | awk -F': *' '/^description:/{print $2; exit}')"

    if [[ -z "$name" ]]; then
        err "$skill" "missing name field"
    elif [[ ${#name} -gt 64 ]]; then
        err "$skill" "name too long (${#name} > 64)"
    elif [[ ! "$name" =~ ^[a-z][a-z0-9-]*$ ]]; then
        err "$skill" "name must be lowercase + hyphens (got: $name)"
    fi

    if [[ -z "$desc" ]]; then
        err "$skill" "missing description field"
    elif [[ ${#desc} -gt 1024 ]]; then
        err "$skill" "description too long (${#desc} > 1024)"
    fi

    if echo "$fm" | grep -q '^model:'; then
        err "$skill" "frontmatter contains forbidden 'model:' field"
    fi

    body_lines=$(awk '/^---$/{n++; next} n>=2' "$md" | wc -l | tr -d ' ')
    if [[ "$body_lines" -gt 500 ]]; then
        warn "$skill" "body is $body_lines lines (>500)"
    fi

    if [[ -d "$skill_dir/reference" ]]; then
        depth=$(find "$skill_dir/reference" -mindepth 2 -type d 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$depth" -gt 0 ]]; then
            err "$skill" "reference/ has nested subdirectories"
        fi
    fi

    while IFS= read -r link; do
        [[ -z "$link" ]] && continue
        case "$link" in
            http*|"#"*) continue ;;
        esac
        target="$skill_dir/$link"
        if [[ ! -e "$target" ]]; then
            err "$skill" "broken link: $link"
        fi
    done < <(grep -oE '\]\([^)]+\)' "$md" | sed 's/^](//;s/)$//' || true)

    echo "OK   $skill (name=$name, body=$body_lines lines)"
done

exit "$fail"
