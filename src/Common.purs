module Common where

import Prelude

import Data.Array as Array
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe, fromMaybe')
import Data.String as String
import Data.Traversable (sequence)
import Data.Tuple (Tuple(..))
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class.Console as Console
import Partial.Unsafe (unsafeCrashWith)

data Rule = Rule Expr Expr

instance Show Rule where
  show (Rule i o) = show i <> " -> " <> show o

data Expr = MVar String | Var String | App Expr Expr

infixl 1 App as %

instance Show Expr where
  show (MVar s) = s
  show (Var s) = s
  show (e1 % e2) = "( " <> show e1 <> " " <> show e2 <> " )"

evaluate :: Array Rule -> Expr -> Array Expr /\ Expr
evaluate rules e = fixpoint [ e ] (simplify rules) e

fixpoint :: Array Expr -> (Expr -> Maybe Expr) -> Expr -> Array Expr /\ Expr
fixpoint history f e = case f e of
  Nothing -> (history `Array.snoc` e) /\ e
  Just e' -> fixpoint (history `Array.snoc` e) f e'

simplify :: Array Rule -> Expr -> Maybe Expr
simplify rules e | Just e' <- applyRules rules e = Just e'
simplify rules (e1 % e2) | Just e1' <- simplify rules e1 = Just (e1' % e2)
simplify rules (e1 % e2) | Just e2' <- simplify rules e2 = Just (e1 % e2')
simplify _ _ = Nothing

applyRules :: Array Rule -> Expr -> Maybe Expr
applyRules rules e = Array.findMap (_ `applyRule` e) rules

applyRule :: Rule -> Expr -> Maybe Expr
applyRule (Rule i o) e = matchExpr i e <#> (_ `applySub` o)

type Sub = Map String Expr

matchExpr :: Expr -> Expr -> Maybe Sub
matchExpr (MVar x) e = Just $ Map.fromFoldable [ x /\ e ]
matchExpr e (MVar x) = Just $ Map.fromFoldable [ x /\ e ]
matchExpr (Var x) (Var y) | x == y = Just Map.empty
matchExpr (e % f) (g % h) | Just m <- matchExpr e g, Just n <- matchExpr f h = mergeSub m n
matchExpr _ _ = Nothing

mergeSub :: Sub -> Sub -> Maybe Sub
mergeSub s t = Map.unionWith conflict (s # map pure) (t # map pure) # sequence
  where
  conflict me mf = me >>= \e -> mf >>= \f -> do
    matchExpr e f <#> (_ `applySub` e)

applySub :: Sub -> Expr -> Expr
applySub s e@(MVar x) = s # Map.lookup x # fromMaybe e
applySub _ e@(Var _) = e
applySub s (e % f) = applySub s e % applySub s f

showEval rules e = "`" <> show e <> " => " <> show e' <> "`"
  where
  _ /\ e' = evaluate rules e