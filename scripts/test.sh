ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)  # repo root
CONTRACTS_DIR="$ROOT_DIR/golden_tests/test_contracts"  # error contracts root


for dir in "$CONTRACTS_DIR"/*/; do  # iterate over each contract
  [[ -d "$dir" ]] || continue
  CONTRACT_NAME=$(basename "$dir")
  expected_output_file="$CONTRACTS_DIR/${CONTRACT_NAME}/expected_stderr.txt"
  result_file="$CONTRACTS_DIR/${CONTRACT_NAME}/result.txt"
  
  cd "$dir" && nargo compile 2> "$result_file" || true
  
  # replace /home/runner paths with local paths if running locally
  if [[ "${CI:-}" != "true" ]]; then
    RUNNER_HOME="$HOME"
    sed "s|/home/runner|$RUNNER_HOME|g" "$expected_output_file" > "$expected_output_file.temp"
    expected_for_comparison="$expected_output_file.temp"
  else
    expected_for_comparison="$expected_output_file"
  fi
  
  if diff "$expected_for_comparison" "$result_file" >/dev/null; then
    echo "$CONTRACT_NAME: Files are identical"
  else
    echo "$CONTRACT_NAME: Files differ"
    echo "Differences:"
    diff "$expected_for_comparison" "$result_file"
    # Clean up temporary file before exiting
    [[ -f "$expected_output_file.temp" ]] && rm -f "$expected_output_file.temp"
    exit 1
  fi
  
  # Clean up temporary file if created
  [[ -f "$expected_output_file.temp" ]] && rm -f "$expected_output_file.temp"
done

echo "All tests passed!"