let
  load = file: builtins.head (builtins.attrValues (builtins.fromJSON (builtins.readFile file)));
  rebuild = d: name: rewrite: extra:
    let
      context = builtins.mapAttrs (_: v: { outputs = v.outputs; }) d.inputDrvs
        // builtins.listToAttrs (map (p: { name = p; value = { path = true; }; }) d.inputSrcs);
      restore = value: builtins.appendContext (rewrite value) context;
    in builtins.derivation (
      builtins.mapAttrs (_: restore) (builtins.removeAttrs d.env [ "out" "doc" "outputs" "__structuredAttrs" ])
      // {
        inherit name;
        inherit (d) system;
        builder = restore d.builder;
        args = map restore d.args;
        outputs = builtins.attrNames d.outputs;
      } // extra
    );
  originalRpc = load ../native-json-profile/rpc-types-derivation.json;
  rpc = rebuild originalRpc "kore-rpc-types-0.1.155-compact-rpc" (x: x) {
    src = ./rpc-types-source;
  };
  originalKore = load ../../backend-lazy-metadata/kore-derivation.json;
  kore = rebuild originalKore "kore-0.1.155-lazy-metadata-compact-rpc"
    (builtins.replaceStrings [ originalRpc.outputs.out.path ] [ "${rpc.out}" ]) {
      src = ../../backend-lazy-metadata/kore-source;
    };
  originalBooster = load ../../backend-lazy-metadata/booster-derivation.json;
  booster = rebuild originalBooster "hs-backend-booster-0.1.155-v6-compact-rpc"
    (builtins.replaceStrings
      [ originalRpc.outputs.out.path originalKore.outputs.out.path ]
      [ "${rpc.out}" "${kore.out}" ]) {
      src = ../../node16-fix-20261006/booster-source-v6;
      postBuild = ''
        ./Setup register --inplace
        ghc -XImportQualifiedPost -XNamedFieldPuns -XOverloadedStrings -XOverloadedRecordDot -XDuplicateRecordFields -package-db "$packageConfDir" -package-db dist/package.conf.inplace -package hs-backend-booster -iunit-tests MapKeyCheck.hs -o map-key-check
        ./map-key-check
      '';
    };
in { inherit rpc kore booster; }
