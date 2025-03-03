Your current task involves the analysis a new programming language called Rofdas.

A grammar of a programming language defines what expressions can appear in the language.
The grammar for Rofdas is defined as follows, where `c` is any capitalized letter and `x` is any Rofdas expression:

```
x ::= c | ( x x )
```

Some example Rofdas expressions are:
- `( A B )`
- `( ( B A ) C )`
- `( ( ( C A ) A ) B )`

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

The following rule system defines the small-step semantics for Rofdas:

```
( A x ) -> x
( ( B x ) y ) -> ( ( y x ) x )
( ( ( C x ) y ) z ) -> ( ( x z ) y )
```

Some example evaluations of Rofdas expressions are:
- `( A B ) => B`
- `( ( B A ) C ) => ( ( C A ) A )`
- `( ( ( C A ) A ) B ) => ( B A )`

Determine what Rofdas expression the following Rofdas expression evaluates to:

`( ( ( ( C C ) ( A D ) ) ( A ( ( B ( A D ) ) C ) ) ) ( ( ( C C ) ( A D ) ) ( A ( ( B ( A D ) ) C ) ) ) )`