#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/build-fates-report.sh [input_json]
# - input_json: Path to noir-inspector style JSON. Defaults to scripts/output.json
#
# Emits to stdout a JSON array like:
# [ { "name": "<package_name>", "unit": "acir_opcodes", "value": <count> }, ... ]

INPUT_JSON=${1:-./output.json}

if [[ ! -f "$INPUT_JSON" ]]; then
  echo "Input file not found: $INPUT_JSON" >&2
  exit 1
fi


jq -c '
  .programs
  | map(. as $p | ($p.functions // []) | map({
      name: ($p.package_name),
      unit: "acir_opcodes",
      value: (.opcodes // 0)
    }))
  | add // []
' "$INPUT_JSON" > opcodes.json


