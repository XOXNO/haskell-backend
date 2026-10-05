# Komet backend repairs

This branch preserves two reviewed local repairs on the backend revision used by
the Soroban SDK 28 Komet proof runtime:
`38afc81fc9414f1e11e609b01a43a436b613bd2d`.

## SMT model metadata

The reverse metadata map in `Kore.Rewrite.SMT.Translate.backTranslateWith`
uses lazy construction and mapping. An unused duplicate SMT name no longer
raises an exception while decoding a different, uniquely named application.
Demanding an ambiguous symbol still raises the existing error; the patch never
selects an arbitrary symbol. Assertions, solver queries and the separate state
inversions are unchanged.

Recorded compiled replay reproduced the old `smt_seq_nil` exception and returned
typed SAT with the replacement. The old transcript's 7,461 lines were an exact
prefix of the replacement transcript. Unique integer decoding and SAT/UNSAT
controls also passed.

## Erased matched operands

Booster's schematic rule check cannot see partial terms later substituted for
variables. After a successful match, the new guard refuses to erase operands
unless their syntax establishes definedness. It recursively admits ordinary
element variables, valid domain values, injections and total symbols.

The narrow `INT.emod` exception requires an exactly parsed concrete nonzero
integer divisor and recursively defined numerator. Zero spellings use the
existing integer parser. Collections, conjunctions and other partial terms are
conservatively refused.

Recorded validation passed 16 ML/CTerm partiality controls. Undefined division,
nested partial numerators and unknown modulo divisors retained their partial
terms; zero substitution reached Bottom, while defined witnesses remained
nonempty. Nonzero constant divisors and `0`, `-0`, `00` controls passed.

## Validation and boundaries

The two published source files are byte-identical to the reviewed candidates:

| File | SHA-256 |
|---|---|
| `kore/src/Kore/Rewrite/SMT/Translate.hs` | `348000af747c00a470e021e5186d715d290c07fc687287bbde751e223b7d2ccd` |
| `booster/library/Booster/Pattern/ApplyEquations.hs` | `98f36d9fa4ce689b1c5cb944dc15a371f506e7e86ac403b7f2a3a2eb43444791` |

Publication review rechecked 925 metadata-integration pins and six corrected
guard-control pins; all matched. A standalone containers-demand control passed
again. These source/evidence checks do not replace compilation or execution of
the checkout's full test suite.

The repository test command is:

```sh
stack test kore:kore-test hs-backend-booster:unit-tests
```

It was not rerun during publication. The earlier compiled runtime checks used
frozen Nix builds and Komet definitions. They are historical integration evidence,
not a portable test suite packaged by this branch.

Guard acceptance is scoped to ordinary CLI element variables and valid tokens,
with the existing trusted symbol attributes. Raw RPC set-variable representation,
malformed tokens, pre-equation Boolean builtins and LLVM simplification remain
outside that acceptance. The patch does not establish general backend soundness.

This is a draft compatibility change. No borrow-index or full-pool theorem is
claimed. Existing proof runtimes and graphs were not changed by publication.
