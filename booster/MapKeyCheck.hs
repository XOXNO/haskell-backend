{-# LANGUAGE ImportQualifiedPost, OverloadedStrings, QuasiQuotes, NamedFieldPuns #-}
module Main where

import Control.Monad (forM_, unless)
import Data.Map qualified as Map
import Booster.Builtin.INT qualified as INT
import Booster.Pattern.Base
import Booster.Pattern.Match
import Booster.Syntax.ParsedKore.Internalise (symb)
import Test.Booster.Fixture

main :: IO ()
main = do
    forM_ [("Rewrite", Rewrite), ("Eval", Eval), ("Implies", Implies)] $ \(name, mode) -> do
        let matches = matchTerms mode testDefinition
            check label result = unless result (error (name <> ": " <> label))
        check "prior substitution" $ matches (app pair [i, patternMap (sub i (int 1))])
            (app pair [int 2, subject]) == success [("I",SortInt,int 2),("VALUE",kmapElementSort,value),("REST",kmapSort,rest)]
        check "map queued before binder" $ matches (app reversePair [patternMap (sub i (int 1)), i])
            (app reversePair [subject, int 2]) == success [("I",SortInt,int 2),("VALUE",kmapElementSort,value),("REST",kmapSort,rest)]
        forM_ [(2,1,1),(1,1,0),(0,1,-1),(2^200,1,2^200-1)] $ \(a,b,c) ->
            check "integer subtraction" $ matches (patternMap (sub (int a) (int b)))
                (KMap testKMapDefinition [(key (int c),value)] Nothing)
                == success [("VALUE",kmapElementSort,value),("REST",kmapSort,emptyKMap)]
        check "missing key" $ case matches (patternMap (sub (int 0) (int 1))) subject of
            MatchFailed KeyNotFound{} -> True; _ -> False
        forM_ [sub (var "X" SortInt) (int 1),sub (dv SortInt "bad") (int 1),sub (dv someSort "2") (int 1),
               app division [int 1,int 0],app subtraction [],app subtraction [int 1],app subtraction [int 1,int 2,int 3],
               app (subtraction{resultSort=someSort}) [int 2,int 1],app (subtraction{argSorts=[someSort,someSort]}) [int 2,int 1],
               SymbolApplication subtraction [SortInt] [int 2,int 1],app addition [int 0,int 1]] $ \expression ->
            check "unsupported key retained" $ case matches (patternMap expression) subject of
                MatchIndeterminate{} -> True; _ -> False
        check "normalized duplicate rejected" $ case matches
            (KMap testKMapDefinition [(key (sub (int 2) (int 1)),value),(key (int 1),value)] Nothing) subject of
            MatchFailed DuplicateKeys{} -> True; _ -> False
        check "value mismatch rejected" $ case matches
            (KMap testKMapDefinition [(key (sub (int 2) (int 1)),dv kmapElementSort "wrong")] (Just (var "REST" kmapSort))) subject of
            MatchFailed DifferentValues{} -> True; _ -> False
        putStrLn (name <> ": all map-key checks passed")
  where
    subtraction = [symb| symbol sub{}(SortInt{},SortInt{}) : SortInt{} [function{}(),total{}(),hook{}("INT.sub")] |]
    division = [symb| symbol div{}(SortInt{},SortInt{}) : SortInt{} [function{}(),hook{}("INT.tdiv")] |]
    addition = [symb| symbol add{}(SortInt{},SortInt{}) : SortInt{} [function{}(),total{}(),hook{}("INT.add")] |]
    pair = [symb| symbol pair{}(SortInt{},SortTestKMap{}) : SomeSort{} [constructor{}()] |]
    reversePair = [symb| symbol pairReverse{}(SortTestKMap{},SortInt{}) : SomeSort{} [constructor{}()] |]
    i = var "I" SortInt
    int = INT.intTerm
    sub a b = app subtraction [a,b]
    key = Injection SortInt kmapKeySort
    value = dv kmapElementSort "value"
    rest = KMap testKMapDefinition [(key (int 0),value)] Nothing
    subject = KMap testKMapDefinition [(key (int 1),value),(key (int 0),value)] Nothing
    patternMap expression = KMap testKMapDefinition [(key expression,var "VALUE" kmapElementSort)] (Just (var "REST" kmapSort))
    success assocs = MatchSuccess $ Map.fromList [(Variable{variableSort,variableName},term) | (variableName,variableSort,term) <- assocs]
