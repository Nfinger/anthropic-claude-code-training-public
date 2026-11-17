#!/usr/bin/env bash
# PreToolUse hook (Bash): before Claude runs `git push`, run the merchant
# console's tests and build. Block the push (exit 2) if either fails.
# Any other command passes straight through (exit 0).

set -u

input="$(cat)"
tmp_root="${TMPDIR:-/tmp}"
tmp_root="${tmp_root%/}"

# Pull tool_input.command out of the hook's JSON. node is already required
# by the project, so this does not depend on jq being installed.
command="$(printf '%s' "$input" | node -e '
  let s = ""
  process.stdin.on("data", (d) => (s += d))
  process.stdin.on("end", () => {
    try { process.stdout.write(JSON.parse(s).tool_input?.command ?? "") } catch {}
  })
')"

# A git push at the start of the command or after ; & | ( — with optional
# git options such as `-C dir` before the subcommand. A commit message that
# merely mentions "git push" does not match.
if ! printf '%s' "$command" | grep -Eq '(^|[;&|(])[[:space:]]*git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+push([[:space:]]|$)'; then
  exit 0
fi

project_dir="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
app_dir="$project_dir/build-battle/merchant-console"

if [ ! -d "$app_dir/node_modules" ]; then
  echo "Push blocked: $app_dir has no node_modules, so tests and build cannot run." >&2
  echo "Run: cd \"$app_dir\" && npm install" >&2
  exit 2
fi

log_dir="$tmp_root/claude-pre-push/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$log_dir"
test_log="$log_dir/test.log"
build_log="$log_dir/build.log"

failed=()

# 1. Tests
if ! (cd "$app_dir" && npm test) >"$test_log" 2>&1; then
  failed+=("npm test")
fi

# 2. Build, in a throwaway copy that shares node_modules. Building in place
#    would overwrite .next under a running `next dev` and break it.
build_dir="$(mktemp -d "$tmp_root/claude-pre-push-build.XXXXXX")"
(
  cd "$app_dir" &&
    tar --exclude=./node_modules --exclude=./.next -cf - . | tar -xf - -C "$build_dir" &&
    ln -s "$app_dir/node_modules" "$build_dir/node_modules" &&
    cd "$build_dir" && npm run build
) >"$build_log" 2>&1 || failed+=("npm run build")
rm -rf "$build_dir"

if [ ${#failed[@]} -eq 0 ]; then
  echo "pre-push: npm test and npm run build passed. Logs: $log_dir" >&2
  exit 0
fi

{
  echo "Push blocked: ${failed[*]} failed."
  for step in "${failed[@]}"; do
    case "$step" in
      "npm test") log="$test_log" ;;
      *) log="$build_log" ;;
    esac
    echo
    echo "--- $step (full output: cat \"$log\") ---"
    tail -n 25 "$log"
  done
  echo
  echo "Fix the failure, then push again."
} >&2
exit 2
