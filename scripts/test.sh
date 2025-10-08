ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)  # repo root
CONTRACTS_DIR="$ROOT_DIR/golden_tests/test_contracts"  # error contracts root

for dir in "$CONTRACTS_DIR"/*/; do  # iterate over each contract
  [[ -d "$dir" ]] || continue
  CONTRACT_NAME=$(basename "$dir")
  expected_output_file="$CONTRACTS_DIR/${CONTRACT_NAME}/expected_stderr.txt"
  result_file="$CONTRACTS_DIR/${CONTRACT_NAME}/result.txt"
  cd "$dir" && nargo compile 2> "$result_file"
  diff "$expected_output_file" "$result_file" && echo "Files are identical" || echo "Files differ"
done