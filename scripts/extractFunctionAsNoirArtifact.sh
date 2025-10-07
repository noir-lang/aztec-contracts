#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/extractFunctionAsNoirArtifact.sh <contractArtifactPath> <functionName>

artifact_path=${1:-}
function_name=${2:-}

if [[ -z "${artifact_path}" || -z "${function_name}" ]]; then
  echo "Usage: scripts/extractFunctionAsNoirArtifact.sh <contractArtifactPath> <functionName>" >&2
  exit 1
fi

if [[ ! -f "${artifact_path}" ]]; then
  echo "Artifact not found: ${artifact_path}" >&2
  exit 1
fi

# Verify the function exists
if ! jq -e --arg fn "${function_name}" '.functions[] | select(.name == $fn)' "${artifact_path}" >/dev/null; then
  echo "Function ${function_name} not found in ${artifact_path}" >&2
  exit 1
fi

# Compute output path
artifact_dir=$(dirname "${artifact_path}")
artifact_base=$(basename "${artifact_path}" .json)
output_path="${artifact_dir}/${artifact_base}-${function_name}.json"

# Build Noir artifact with selected function's components
jq -r --arg fn "${function_name}" '
  . as $root
  | ($root.functions[] | select(.name == $fn)) as $f
  | {
      noir_version: $root.noir_version,
      hash: 0,
      abi: $f.abi,
      bytecode: $f.bytecode,
      debug_symbols: $f.debug_symbols,
      file_map: $root.file_map,
      names: ["main"]
    }
' "${artifact_path}" | jq '.' > "${output_path}"

echo "Writing to ${output_path}"


