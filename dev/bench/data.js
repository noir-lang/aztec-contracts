window.BENCHMARK_DATA = {
  "lastUpdate": 1759752078387,
  "repoUrl": "https://github.com/noir-lang/aztec-contracts",
  "entries": {
    "ACIR Opcodes": [
      {
        "commit": {
          "author": {
            "name": "noir-lang",
            "username": "noir-lang"
          },
          "committer": {
            "name": "noir-lang",
            "username": "noir-lang"
          },
          "id": "283d3ba176cf6683188c11d8602c9cd3b2c8ee1f",
          "message": "benchmark",
          "timestamp": "2025-10-06T09:03:04Z",
          "url": "https://github.com/noir-lang/aztec-contracts/pull/1/commits/283d3ba176cf6683188c11d8602c9cd3b2c8ee1f"
        },
        "date": 1759751907849,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "EcdsaKAccount::entrypoint",
            "value": 4127,
            "unit": "acir_opcodes"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "name": "noir-lang",
            "username": "noir-lang"
          },
          "committer": {
            "name": "noir-lang",
            "username": "noir-lang"
          },
          "id": "a31e697854df5f044669ffae6f61b7dd51034aa1",
          "message": "benchmark",
          "timestamp": "2025-10-06T09:03:04Z",
          "url": "https://github.com/noir-lang/aztec-contracts/pull/1/commits/a31e697854df5f044669ffae6f61b7dd51034aa1"
        },
        "date": 1759752077877,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "EcdsaKAccount::constructor",
            "value": 6343,
            "unit": "acir_opcodes"
          },
          {
            "name": "EcdsaKAccount::entrypoint",
            "value": 4127,
            "unit": "acir_opcodes"
          },
          {
            "name": "EcdsaKAccount::process_message",
            "value": 1,
            "unit": "acir_opcodes"
          },
          {
            "name": "EcdsaKAccount::sync_private_state",
            "value": 1,
            "unit": "acir_opcodes"
          },
          {
            "name": "EcdsaKAccount::verify_private_authwit",
            "value": 2222,
            "unit": "acir_opcodes"
          }
        ]
      }
    ]
  }
}