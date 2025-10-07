#!/usr/bin/env bash
set -euo pipefail

# Iterate over every folder in contract-benchmarks, run `nargo info`,
# then find the single JSON file in its `target/` and run noir-inspector.

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
CONTRACTS_DIR="$ROOT_DIR/contract-benchmarks"

if [[ ! -d "$CONTRACTS_DIR" ]]; then
  echo "Directory not found: $CONTRACTS_DIR" >&2
  exit 1
fi

METRICS_TMP=$(mktemp)
trap 'rm -f "$METRICS_TMP"' EXIT

for dir in "$CONTRACTS_DIR"/*/; do
  [[ -d "$dir" ]] || continue
  A=$(basename "$dir")

  # Run nargo info inside the package directory
  if command -v nargo >/dev/null 2>&1; then
    (cd "$dir" && nargo info)
  else
    echo "Warning: nargo not found in PATH; skipping 'nargo info' for $A" >&2
  fi

  target_dir="$dir/target"
  if [[ ! -d "$target_dir" ]]; then
    echo "Target directory not found for $A: $target_dir" >&2
    continue
  fi

  shopt -s nullglob
  json_files=("$target_dir"/*.json)
  shopt -u nullglob

  if (( ${#json_files[@]} != 1 )); then
    echo "Expected exactly one JSON in $target_dir, found ${#json_files[@]}" >&2
    continue
  fi

  B=$(basename "${json_files[0]}")
  B_NO_EXT="${B%.json}"

  # Discover functions to process from inspector output

  if command -v noir-inspector >/dev/null 2>&1; then
    # Get function names with opcodes > 1 from constrained functions only
    FUNC_NAMES=$(noir-inspector info "$CONTRACTS_DIR/$A/target/$B" --json \
      | jq -c '(
          (.programs // [])
          | map(.functions // [])
          | add // []
          | map(select((.opcodes // 0) > 1) | .name)
          | unique
        )')

    # Ensure FUNC_NAMES is a JSON array; default to [] if empty
    if [[ -z "$FUNC_NAMES" || "$FUNC_NAMES" == "null" ]]; then
      FUNC_NAMES="[]"
    fi

    # For each function, extract and compute gates using bb; collect metrics
    for fn in $(echo "$FUNC_NAMES" | jq -r '.[]'); do
      node "$ROOT_DIR/extractFunctionAsNoirArtifact.js" "$CONTRACTS_DIR/$A/target/$B_NO_EXT.json" "$fn"
      if [[ -x "$HOME/.bb/bb" ]]; then
        GATES_OUTPUT=$("$HOME/.bb/bb" gates -b "$CONTRACTS_DIR/$A/target/${B_NO_EXT}-${fn}.json")
        echo "$GATES_OUTPUT" | jq -c --arg name "${A}-${fn}" '{name: $name, acir_opcodes: (.functions[0].acir_opcodes // 0), circuit_size: (.functions[0].circuit_size // 0)}' >> "$METRICS_TMP"
      else
        echo "Warning: $HOME/.bb/bb not found or not executable; skipping bb for $A/$fn" >&2
      fi
    done
  else
    echo "Error: noir-inspector not found in PATH; cannot process $A" >&2
    exit 1
  fi
done

# Build reports from collected metrics
if [[ -s "$METRICS_TMP" ]]; then
  jq -s '[.[] | { name: .name, unit: "acir_opcodes", value: (.acir_opcodes // 0) }]' "$METRICS_TMP" > "$ROOT_DIR/opcodes-report.json"
  jq -s '[.[] | { name: .name, unit: "circuit_size", value: (.circuit_size // 0) }]' "$METRICS_TMP" > "$ROOT_DIR/gates-report.json"
  echo "Wrote $ROOT_DIR/opcodes-report.json and $ROOT_DIR/gates-report.json"
else
  echo "No metrics collected; not writing reports" >&2
fi
