# Borrow-double backend source snapshot

This branch preserves the additional source selected by the Komet
`test_borrow_double` proof on 2026-10-07. Its base is the published repair
commit `bc935ed495c8e1613b294d875d016b0fad469038`, based on backend version
`0.1.155` at `38afc81fc9414f1e11e609b01a43a436b613bd2d`.

The three changed source files and `booster/MapKeyCheck.hs` are exact copies of
the historical `booster-source-v6` and compact-RPC source snapshots. They retain
the erased-operand definedness checks and rollback, concrete substituted map-key
normalization, and compact JSON-RPC framing. `SHA256SUMS.borrow-double` binds
those copied bytes.

From this pinned checkout on Linux, use its existing locked flake:

```sh
sha256sum -c SHA256SUMS.borrow-double
nix build --no-write-lock-file .#kore-rpc-booster --out-link result-booster
./result-booster/bin/kore-rpc-booster --version
```

The flake builds the local `kore-rpc-types`, `kore`, and Booster sources using
GHC 9.6.5 and wraps Booster with Z3 4.13.4. Select this executable ahead of K's
bundled, unpatched Booster. The separate Komet guide pins K 7.1.337.
`deps/k_release` selects backend integration tests and is not its build-time
K compiler dependency.

The historical executable was an aarch64-darwin Nix build named
`hs-backend-booster-0.1.155-v6-compact-rpc`, SHA-256
`0eda4843ca9302027925903ee3006d3f5143b02c81e590d9af2c54709dd5e8bf`.
A Linux build will have different executable bytes and embedded revision
metadata. The original derivation-reconstruction scripts contain Darwin store
paths and are not Linux build recipes.

The standard flake disables package tests. `MapKeyCheck.hs` is the preserved
standalone fixture from the original build, not an automatically registered
Cabal test. Publishing these sources does not establish a successful Linux
build or proof replay.
