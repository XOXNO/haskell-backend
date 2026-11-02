# Borrow-double Booster v6 / compact RPC sources

This branch starts at `bc935ed495c8e1613b294d875d016b0fad469038` and preserves
the extra source selected by the native Komet `test_borrow_double` proof from
2026-10-07. The Booster package matches the complete 1,013-file
`booster-source-v6` snapshot. Its changes are exactly:

| File | SHA-256 |
|---|---|
| `booster/library/Booster/Pattern/ApplyEquations.hs` | `3907dc29f8e3b0ca0e9caa1218204dc02c65ef40b4202491f063fcc41f260877` |
| `booster/library/Booster/Pattern/Match.hs` | `633f001160d664c35eba45c0a1dcf9e92115a05f9779098782a865bbe931b7ad` |
| `booster/MapKeyCheck.hs` | `38f73eb9c0fab4af3a8300f265e6edd9d287316f01c2fb5de3c38e70cf86c8be` |

The compact-RPC change lives in this repository's separate `kore-rpc-types`
package at `kore-rpc-types/src/Kore/JsonRpc/Server.hs`, SHA-256
`e2007b88090c4a63ff4c034c0e120a93251fc0157c7d125492dac598951cb4a7`.
Every file of the selected `kore` package already matches the base commit.

`nix/booster-v6-compact-rpc.nix` is a byte-for-byte copy of the original
`compact-rpc/build.nix`, SHA-256
`5906beb302c7ce966ab282d15207fc228f51f85b86bb64a5f8ebccd422930753`.
It records the original aarch64-darwin build procedure. It retains historical
relative references to derivation JSONs and copied source directories, which
are not part of this publication. It is provenance, not a standalone build
entry point in this checkout.

Linux builds use the same committed source through the existing locked flake:

```sh
nix build --no-write-lock-file .#kore-rpc-booster --out-link result-booster
./result-booster/bin/kore-rpc-booster --version
nix develop --no-write-lock-file --command z3 --version
```

The flake builds local `kore-rpc-types`, `kore`, and Booster packages with GHC
9.6.5 and wraps the executable with Z3 4.13.4. It disables package tests;
`MapKeyCheck.hs` remains the original standalone fixture, not a registered
Cabal test. Select this executable ahead of K's bundled unpatched Booster.

Historical output was `hs-backend-booster-0.1.155-v6-compact-rpc`, backend
version `0.1.155`, executable SHA-256
`0eda4843ca9302027925903ee3006d3f5143b02c81e590d9af2c54709dd5e8bf`.
Linux builds will have different executable bytes and embedded Git revision
metadata. No Mac binary or Nix store output is included here. Linux compilation
and fresh proof replay have not been established by source publication.
