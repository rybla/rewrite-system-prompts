module Utilities where

import Prelude

import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe')
import Data.String as String
import Data.Tuple.Nested ((/\))
import Partial.Unsafe (unsafeCrashWith)

replaceFormatVars :: Map String String -> String -> String
replaceFormatVars m = go ""
  where
  go :: String -> String -> String
  go result s =
    let
      mb = do
        i <- s # String.indexOf (String.Pattern "}")
        case s # String.take i # String.split (String.Pattern "{") of
          [ s1, fv ] -> do
            let s2 = s # String.drop (i + 1)
            let v = m # Map.lookup fv # fromMaybe' \_ -> unsafeCrashWith $ "value for format var not given: " <> show fv
            pure $ (s1 <> v) /\ s2
          _ -> unsafeCrashWith "mismatched braces"
    in
      case mb of
        Nothing -> result <> s
        Just (result' /\ s2) -> go (result <> result') s2

