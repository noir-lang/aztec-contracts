ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)  # repo root
CONTRACTS_DIR="$ROOT_DIR/test_contracts"  # error contracts root


for dir in "$CONTRACTS_DIR"/*/; do  # iterate over each contract
  [[ -d "$dir" ]] || continue
  CONTRACT_NAME=$(basename "$dir")
  expected_output_file="$CONTRACTS_DIR/${CONTRACT_NAME}/expected_stderr.txt"
  result_file="$CONTRACTS_DIR/${CONTRACT_NAME}/result.txt"
  
  cd "$dir" && nargo compile 2> "$result_file" || true
  
  # Remove $HOME and /home/runner paths from result file to avoid environment dependency.
  GLOBAL_HOME = "/home/runner"
  sed -i "" "s@${HOME}@@g" "$result_file"
  sed -i "" "s@${GLOBAL_HOME}@@g" "$result_file"
  
  if diff "$expected_output_file" "$result_file"; then
    echo "$CONTRACT_NAME: Files are identical"
  else
    echo "$CONTRACT_NAME: Files differ"
    exit 1
  fi

done

echo "All tests passed!"