module SysA where

import Common
import Prelude

import Data.Array as Array
import Data.FoldableWithIndex (traverseWithIndex_)
import Data.Map as Map
import Data.String as String
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import File (File)
import File as File
import Utilities (replaceFormatVars)

name ∷ String
name = "SysA"

question_file ∷ Int → File
question_file i = File.file $ "prompts/" <> name <> "." <> show i <> ".question.md"

answer_file ∷ Int → File
answer_file i = File.file $ "prompts/" <> name <> "." <> show i <> ".answer.md"

rules :: Array Rule
rules =
  [ Rule (a % x) x
  , Rule (b % x % y) (y % x % x)
  , Rule (c % x % y % z) (x % z % y)
  ]

expr_inputs =
  [ (c % c % (a % d) % (a % (b % (a % d) % c)))
  , (c % c % (a % d) % (a % (b % (a % d) % c))) % (c % c % (a % d) % (a % (b % (a % d) % c)))
  ]

showQuestion expr_input =
  let
    formatVars = Map.fromFoldable
      [ Tuple "lang_name" "Rofdas"
      , Tuple "expr_ex1" $ show $ a % b
      , Tuple "expr_ex2" $ show $ b % a % c
      , Tuple "expr_ex3" $ show $ c % a % a % b
      , Tuple "eval_ex1" $ showEval rules $ a % b
      , Tuple "eval_ex2" $ showEval rules $ b % a % c
      , Tuple "eval_ex3" $ showEval rules $ c % a % a % b
      , Tuple "rules" $ rules # map show # Array.intercalate "\n"
      , Tuple "expr_input" $ show expr_input
      ]
  in
    Array.intercalate "\n"
      [ """
Your current task involves the analysis a new programming language called {lang_name}.

A grammar of a programming language defines what expressions can appear in the language.
The grammar for {lang_name} is defined as follows, where `c` is any capitalized letter and `x` is any {lang_name} expression:

```
x ::= c | ( x x )
```

Some example {lang_name} expressions are:
- `{expr_ex1}`
- `{expr_ex2}`
- `{expr_ex3}`

The small-step semantics of a programming language is a system of rules that define how to simplify and evaluate an expression in that language.
A single rule is written as `i -> o`, where `i` is the input expression and `o` is the output expression.
The input and output expressions of rules can use meta-variables, which are written as `x`, `y`, or `z`, in place of expressions.

To attempt to use a rule to simplify a given expression, do the following:
1. Attempt to find a subexpression in the given expression that matches the rule's input expression.
   Note that the input expression could contain metavariables, which can be substituted for any expression in order to make the input expression exactly match the subexpression for this check.
   Note that this substitution doesn't modify the original rule.
   If there is no such subexpression, then the attempt has failed and this rule cannot be used to simplify the given expression, so do not continue to step 2.
   If there are multiple such subexpressions, you may choose any of them to proceed with in order to finish applying the rule.
2. If a substitution of metavariables was required to make the subexpression match the rule's input expression, then do that same substitution of metavariables in the rule's output expression.
   Note that this substitution doesn't modify the original rule.
3. Replace the subexpression in the given expression with the rule's output expression.
   The rule has now been sucessfully used to simplify the given expression.

We write `i -> o` to state that expression `i` simplifies to expression `o`.

To use a rule system to evaluate a given expression, do the following:
1. Try to use each rule in the semantics to simplify the given expression.
   If none of the rules can be used to simplify the given expression, then go to step 2.
   If there are multiple rules that can be used to simplify the expression, you maybe choose any one of them to proceed with in order to finish evaluating the given expression.
   Next, repeat this step with the newly-evaluated expression.
   Note that this step could be repeated many times in order to evaluate an expression.
3. The expression has now been evaluated.

We write `i => o` to state that expression `i` evalautes to expression `o`.

The following rule system defines the small-step semantics for {lang_name}:

```
{rules}
```

Some example evaluations of {lang_name} expressions are:
- {eval_ex1}
- {eval_ex2}
- {eval_ex3}

Determine what {lang_name} expression the following {lang_name} expression evaluates to:

`{expr_input}`
    """ # String.trim
          # replaceFormatVars formatVars
      ]

writeQuestionAndAnswer i expr_input = do
  File.write (question_file i) $ showQuestion expr_input
  File.write (answer_file i) (showEval rules expr_input)
  pure unit

main :: Effect Unit
main = launchAff_ do
  expr_inputs # traverseWithIndex_ \i e -> writeQuestionAndAnswer i e

--------------------------------------------------------------------------------

a :: Expr
a = Var "A"

b :: Expr
b = Var "B"

c :: Expr
c = Var "C"

d :: Expr
d = Var "D"

x :: Expr
x = MVar "x"

y :: Expr
y = MVar "y"

z :: Expr
z = MVar "z"
