## Test Contracts - Error Cases

This directory contains test contracts that test common compilation errors that were hard to understand in Aztec contracts. These tests are based on the `private_token_contract` example, with modifications to trigger specific error scenarios.

### Test Cases

#### 1. `private_token_contract_storage_macro` - Missing `#[storage]` Attribute

**Modification**: Removed the `#[storage]` attribute from the `Storage` struct.

**Original Code**:
```rust
#[storage]
struct Storage<Context> {
    balances: Map<AztecAddress, EasyPrivateUint<Context>, Context>,
}
```

**Modified Code**:
```rust
struct Storage<Context> {
    balances: Map<AztecAddress, EasyPrivateUint<Context>, Context>,
}
```


#### 2. `private_token_contract_struct_as_arg` - Invalid Function Parameter Type

**Modification**: Added and empty `Arbitrary` struct. Changed the `mint` function parameter from `u64` to a custom `Arbitrary` struct.

**Original Code**:
```rust
fn mint(amount: u64, owner: AztecAddress) {
    let balances = storage.balances;
    balances.at(owner).add(amount, owner);
}
```

**Modified Code**:
```rust
pub struct Arbitrary {}

fn mint(amount: Arbitrary, owner: AztecAddress) {
    //let balances = storage.balances;
    //balances.at(owner).add(amount, owner);
}
```

**Expected Errors**:
- `No matching impl found for Arbitrary: Serialize<N = _>` - The custom struct doesn't implement the `Serialize` trait required for function parameters
- `Type annotation needed` - Generic type inference fails due to the serialization error

**Purpose**: The reason we see this error is function arguments need to be serialized. We need to define Serialize/Deserialize trait implementation for the new struct,

#### 3. `private_token_contract_utility_macro` - Missing `#[utility]` Attribute

**Modification**: Removed the `#[utility]` attribute from the `get_balance` function.

**Original Code**:
```rust
#[utility]
unconstrained fn get_balance(owner: AztecAddress) -> Field {
    storage.balances.at(owner).get_value()
}
```

**Modified Code**:
```rust
unconstrained fn get_balance(owner: AztecAddress) -> Field {
    storage.balances.at(owner).get_value()
}
```

**Expected Errors**:
- `Function get_balance must be marked as either #[private], #[public], #[utility], #[contract_library_method], or #[test]` 

### Running the Tests

These test contracts are designed to fail compilation and capture the error output. 
To run the tests:

```bash
./scripts/test.sh
```

The script will:
1. Compile each test contract (expecting failures)
2. Capture the error output
3. Compare against expected error messages
4. Report whether the error messages match expectations

