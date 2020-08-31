---
title: Error messages and extensible unions in Elm
cover-image: error-svgrepo-com.svg
author: Rimu Shuang
attribution: 'SVG Repo. 
<a href="https://www.svgrepo.com/svg/13658/error">Error SVG Vector</a>. Unknown year. CC-0 Public Domain License (NOT a CC-BY 4.0 License).'
subhead: 'An exploration of how to have good error messages for extensible
unions'
tags: elm
date: 2020-08-30T23:31:00-0500
---

This post is a collection of thoughts around error messages and extensible
unions in Elm. It will occasionally make reference to this [Elm Discourse
thread](https://discourse.elm-lang.org/t/idea-extensible-union-types-and-benefits-they-bring-for-real-world-elm-code/6118)
where Elm's creator Evan Czaplicki mentioned [some
worries](https://discourse.elm-lang.org/t/idea-extensible-union-types-and-benefits-they-bring-for-real-world-elm-code/6118/38) he had around how
extensible unions would impact the quality of Elm's error messages.

It is built off of [my first
post](https://shuangrimu.com/posts/elm-extensible-unions.html) on extensible
unions in Elm as well as its formalization
[here](https://shuangrimu.com/posts/formalizing-extensible-unions.html).

In particular, Evan mentions that even with type annotations error messages in
code that makes heavy use of extensible unions can have [pretty bad
consequences](https://discourse.elm-lang.org/t/idea-extensible-union-types-and-benefits-they-bring-for-real-world-elm-code/6118/38)
for error messages.

While this is true for the way that Elm currently implements error reporting, I
don't think this is intrinsically true of extensible unions. In fact, I think
that the set of tradeoffs Elm has chosen around extensible records and those
same tradeoffs applied to extensible unions allow for us to have specific error
messages localized to a single offending line even in the case of completely
unannotated code, let alone code with annotations!

The rest of this post talks about how to do that. The actual algorithm is quite
straightforward, but it requires quite a bit of set up to motivate and explain
why it works.

My current iteration of the algorithm is somewhat slow and clunky, if
straightforward, and I think it can be improved significantly, but I'm putting
it out there to show the quality of error messages we can potentially have and
to show that the tension between extensible error messages is not an intrinsic
one, but an extrinsic one specific to the implementation of an error reporting
system.

One big thing to note is that what I propose in this post is independently
useful for Elm, even outside of extensible unions. I'll couch a lot of this
reply in the language of extensible unions since that's what we're talking
about, but everything I say here pertains only to row types, and so pertains to
Elm's records as well. N.B. row types are the types that underlie both record
types and extensible union types, the set of types and type tags (i.e. field
names in records and variant tag names for extensible unions) within the
brackets. As shown earlier
[here](https://shuangrimu.com/static/extensible-types-leijen.pdf), ultimately
the typing judgments for both records and extensible unions are the exact same.

This is going to be another doozy of a post so I'm going to lay out the overall
structure of my post here.

+ [The current situation in Elm WRT error messages and records](#the-current-situation): We already
  have some of the problems Evan talks about with records, but that's not a call
  for defeatism (the argument isn't extensible unions aren't worse than extensible
  records so we should embrace them), it means that all the stuff I'm going to
  talk about is valuable to Elm today, even outside of extensible unions!
+ [Why is it hard to create good error messages for row-polymorphic
  code](#why-is-it-hard): A
  refresher for the thread for why good error messages are hard to produce for
  polymorphic code.
+ [What does Elm do differently with row types](#what-does-elm-do): Elm's approach to row types,
  reflected in this proposal for extensible unions, has various restrictions
  compared to the full power of row types.
+ [A strategy for providing excellent error messages even in heavily
  row-polymorphic code](#a-strategy): Elm's restrictions on row types let us create error
  messages that are localized to the exact line and sub-expression that went
  wrong, even in highly polymorphic and complex expressions and without type
  annotations.
+ [What this means for extensible unions](#what-this-means): With these error reporting
  facilities in place there is no need to warn users away from using extensible
  unions. Users can use them freely without worrying that they're shooting
  themselves in the foot.

## <a id="the-current-situation">The current situation in Elm with respect to error messages and records</a>

I would summarize the problem Evan is talking about (I'll let him comment in the
Discourse thread if he thinks this is a bad summary) is that the error messages
given in row-polymorphic code tend to be

1. Not local: the compiler throws up its hands and says the entire expression is
   wrong instead of pointing to a specific line/sub-expression
2. Impossible to give the reader useful information on how to fix the
   expression: if you don't even know where the error is you can only offer
   vague platitudes to the programmer to try to help.

In fact, Elm already faces these problems with records.

Let's start with an exaggerated example that is illustrative. People generally
don't write code like this, but it can show up in larger expressions with a lot
of folds and maps.

```
h : { field0 : Int, field1 : Int } -> Int
h  = (\a b -> b)
    (\r0 -> r0.field0 + 1)
    (\r1 -> r1.field2 + 1)
```
Ideally we'd like the Elm compiler to mark `field2` as the offending portion of
this code, but unfortunately the best it can do is just mark the entire block.
```
Something is off with the body of the `h` definition:

4|>h  = (\a b -> b)
5|>    (\r0 -> r0.field0 + 1)
6|>    (\r1 -> r1.field2 + 1)

The body is:

    { a | field0 : Int, field1 : Int, field2 : number } -> number

But the type annotation on `h` says it should be:

    { field0 : Int, field1 : Int } -> Int

Hint: Seems like a record field typo. Maybe field2 should be field0?
```
Post-hoc the Elm compiler helpfully attempts a string comparison to detect that
maybe there's a field typo, but it doesn't give me the exact line that went
wrong and so the compiler can't be sure, it's really just guessing based off the
string comparison (a similar string guessing strategy would also work for
extensible unions of course).

Now let's focus on more prosaic environments.  Right now in Elm if I create a
record and mistype a field I don't get a localized error message, I only get an
error message for the entire expression.  Again, post-hoc the Elm compiler
attempts a string comparison, but that's the best it can do.
```
type alias MyRecord =
    { a : Int
    , b : Int
    , c : Int
    }

record : MyRecord
record =
    { a = 0
    , b = 0
    , cc = 0
    }
```
yields
```
Something is off with the body of the `record` definition:

 9|>    { a = 0
10|>    , b = 0
11|>    , cc = 0
12|>    }

The body is a record of type:

    { a : number, b : number1, cc : number2 }

But the type annotation on `record` says it should be:

    MyRecord

Hint: Seems like a record field typo. Maybe cc should be c?
```

We're saved by a post-hoc string comparison that detects `cc` (a strategy which
of course could be used for extensible unions), but this is a pretty fragile
strategy, that could easily break down for more complex expressions.
Indeed, as Evan points out with his case example, this would be bad for records
of hundreds of lines.

Something like the following would be better; it's localized to exactly the line
that went wrong, which is helpful in long record definitions!
```
Something is off with the body of the `record` definition:

11|     , cc = 0
          ^^^^^^

This field is

    cc

But the type annotation on this record only has these fields

    { a : number, b : number1, c : number2 }

Hint: Seems like a record field typo. Maybe cc should be c?
```
It may be puzzling that this doesn't already happen in Elm, but I'll get to why
in the next section.

In fact, for a lot of cases, we don't need to hypothesize about what error
messages would look like for extensible unions.  Keeping in mind that the typing
rules for extensible unions are the exact same as for extensible records, we can
just use extensible records to get a rough idea of what the error messages look
like. Now we can't implement some of our base functions, but that's okay, we're
mainly looking for type errors anyways.

```
import Debug

-- At a type level, basically equivalent to
-- case0 : b -> a + @Case0 b
-- case0 x = @Case0 x
case0Tag : b -> { a | case0 : b }
case0Tag = Debug.todo "Not actually implementable currently"
```

Indeed, we can bang out almost exactly Evan's scenario with the wood chuck and
fox sentence and see what happens with Elm's current case statement in the
presence of annotations. It's long so I've included it in an Ellie rather than
include the code inline here. [https://ellie-app.com/9QgYLvwbMbka1](https://ellie-app.com/9QgYLvwbMbka1). The thing to
notice here is that the error messages refer to the exact line that went wrong
rather than the entire expression!

So all is not hopeless with extensible unions and error messages in Elm
currently.

Nonetheless Evan is right that extensible union case match statement I've
presented them with Leijen's formalism will result in a similar error message to
what's going on with record creation. This is because at their heart both of
these are relying on nested applications of polymorphic functions and nesting
plus polymorphism can often destroy the locality of error messages.

Which brings me to...

## <a id="why-is-it-hard">Why is it hard to create good error messages for row-polymorphic code</a>

Let's review why polymorphic code is hard to create good error messages for. 

There are two criteria that make it possible for a language feature to have good
error messages:

1. A canonical "source of error": if something goes wrong we should ideally be
   able to point at one place, or a select few places, that "caused" everything
   to go wrong.
2. Agreement between the canonical source and the programmer's intuition: this
   canonical source of error should match the programmer's idea of what causes
   the error, or at the very least the programmer should be able to immediately
   say "ah yes, I see why the compiler thinks that's happening."

In highly polymorphic code, we often lose the first condition and therefore lose
the second as well. To see why, let's look at some examples.

I'm going to use the same trick as in the previous section for ginnying up some
extensible union tags to play with.

```
import Debug

case0Tag : b -> { a | case0 : b }
case0Tag = Debug.todo ""

case1Tag : b -> { a | case1 : b }
case1Tag = Debug.todo ""

-- Another extensible union tag representing what happens when we have typos
casa1Tag : b -> { a | casa1 : b }
casa1Tag = Debug.todo ""
```

Let's look at the curious case of `if ... then ... else`.

```
import Debug

case0Tag : b -> { a | case0 : b }
case0Tag = Debug.todo ""

-- This is a typo
casa1Tag : b -> { a | casa1 : b }
casa1Tag = Debug.todo ""

x : { case0 : Int, case1 : Int }
x = if True 
    then case0Tag 0
    else casa1Tag 1

ifThen : Bool -> a -> a -> a
ifThen bool thenCase elseCase = if bool then thenCase else elseCase

y : { case0 : Int, case1 : Int }
y = ifThen True
    (case0Tag 0)
    (casa1Tag 1)
```

The error message for `if ... then ... else` is pretty much spot-on. It's
localized exactly to what line went wrong.

```
Something is off with the 2nd branch of this `if` expression:

15|     else casa1Tag 1
             ^^^^^^^^^^
This `casa1Tag` call produces:

    { a | casa1 : number, case0 : Int, case1 : Int }

But the type annotation on `x` says it should be:

    { case0 : Int, case1 : Int }

Hint: Seems like a record field typo. Maybe casa1 should be case1?
```

Leaving aside the weird fact that these records are actually impossible to
create (since we're using them as stand-ins for extensible unions), we get the
exact line and exact sub-expression that went wrong.

However, `ifThen`, which seems like something that should be exactly the same at
the type level fails with a worse error message.

```
Something is off with the body of the `y` definition:

21|>y = ifThen True
22|>    (case0Tag 0)
23|>    (casa1Tag 1)

This `ifThen` call produces:

    { a | casa1 : number, case0 : number1, case1 : Int }

But the type annotation on `y` says it should be:

    { case0 : Int, case1 : Int }

Hint: Seems like a record field typo. Maybe casa1 should be case1?
```

This has lost the locality of the previous error message. Instead of referring
to a specific sub-expression, the typechecker can only tell us something is
wrong with the entire expression. Again, not a big deal with only three lines,
but way more annoying with an expression spanning dozens if not hundreds of
lines.

So what went wrong? Well it boils down to three things:

1. Nested expressions
2. Polymorphism at each level of nesting
3. No type annotation at each level of nesting

Elm's built-in `if ... then ... else ... ` is a single expression taking three
arguments. On the other hand, due to currying, a call to `ifThen` with three
arguments is actually a series of nested expressions with each level partially
applying another argument to the function returned by the previous level of
nesting.

```
-- What y looks like after translating the currying
y = (((ifThen True) (case0Tag 0)) (casa1Tag 1))
```

Moreover, each level of nesting results in a polymorphic value since `ifThen
True` is polymorphic as are `case0Tag 0` and `casa1Tag 1`.

It may seem at first glance that `casa1Tag 1` is "obviously responsible" for the
error, but because all these values are polymorphic, it's possible that any of
these values should be changed. Maybe `ifThen`'s polymorphism actually removes
fields from its input, so maybe the problem is actually that `ifThen` isn't
removing the fields it should be and should actually be removing the `casa1`
field!

Even more problematically maybe `case0Tag 0` is supposed to cause `ifThen` to
specialize with a type signature that then removes the `casa1` field so actually
the problem is that `case0Tag 0` is the wrong type!

Now if we had the ability to annotate the type of every sub-expression then we
could "tell" the compiler exactly which subexpression is wrong, but it's
very cumbersome to do so and is a poor developer experience (it would involve
pulling out every subexpression into a `let` and annotating each `let`).

Fundamentally we're running into the issue that in fully row-polymorphic code,
it's possible for each subexpression to either add or subtract a row label to
the overall type signature, so it's impossible to single out any subexpression
as the canonical source of an error. Sure maybe subexpression `x` introduced a
given row label that's causing problem , but maybe the actual problem is that
another subexpression `y` is supposed to remove that label and it isn't doing
it's job!

Indeed, in heavily polymorphic expressions, it may be the case that literally
every part of the expression is a candidate for the source of the error. Hence
we entirely lose canonicity of a single source of error and the best the
compiler can do is something to the effect of "well the error could be literally
any subexpression in this expression. Good luck!"

Since the compiler is aware of `if ... then ... else`'s hard-coded behavior and
because there's no nesting, there's no similar concern and there is in fact a
single canonical source of error: the branch that disagrees with the type
annotation is in the wrong.

Indeed this nesting and polymorphism is what makes [my presentation of the case
statement](https://shuangrimu.com/static/extensible-types-leijen.pdf) hard to generate good error messages for. This is also what makes the
creation of a record currently in Elm have a non-local error message. Both
cases, similar to function currying, ultimately desugar to a series of nested
subexpressions, each of involves a call to a polymorphic function, none of which
have a user-supplied annotation except at the top level.

Yet Elm's row polymorphism is quite a bit more controlled than the all-out row
polymorphism of, say [Leijen's
paper](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/scopedlabels.pdf).

That means when it comes to row types, we can leverage Elm's restrictions on row
polymorphism's functionality to get better error messages.

## <a id="what-does-elm-do">What does Elm do differently with row types</a>

I mentioned earlier that in fully row-polymorphic code it's possible for a given
subexpression to either add or subtract a row label.

This is not true in Elm, because Elm does not allow for the subtraction of rows,
but only addition.

This is true in two senses. The first sense (which is also true for Leijen's
more general proposal) is that while unifying types, if we are trying to unify
some row type `A` with another row type `B`, if the unification is successful
and generates a new type `C`, `C`'s rows must be the union of the rows of `A`
and `B`. That is `C` will never have fewer rows than either `A` or `B`.

In the second sense, Elm does not allow for code to dynamically add or subtract
rows from a polymorphic row type (technically Elm doesn't allow that even for
concrete row types, but you can always emulate the same thing by recreating the
row type from scratch for concrete row types). So in particular a row cannot
cannot be added to a incoming polymorphic row type inside a function.

In fact in Elm's treatment of row types there's actually an even stronger
phenomenon: functions almost always have "asymmetric" polymorphic row types.
That is if a function has a row-polymorphic input type, then it must have a
row-monomorphic output type. Otherwise if a function has a row-polymorphic
output type, then it must have a row-monomorphic input type. 

There are only three exceptions to this rule, not changing the shape of the input
to a function (i.e. the identity function or a record update), ignoring the
input to a function (i.e. the constant function), and abusing equality
(unrestricted equality breaks a lot of things in Elm and unfortunately it's no
exception here; however, hope looms on the horizon since unrestricted equality
is on the chopping block).

```
-- The three exceptions
-- Identity function
f : a or @Tag0 b -> a or @Tag0 b
f x = x
-- Record update
f : { a | Tag a }

-- Constant function
g : a or @Tag0 b -> c or @Tag0 Int
g _ = @Tag0 0

-- Equality :(
h : a or @Tag0 b -> a or @Tag0 b -> b or @Tag0 Int
h x y = if x == y then @Tag0 0 else @Tag0 1
```

The crucial thing to note here is that none of these exceptions can be construed
as "ah I meant to subtract a single row from this incoming value".  Hence, while
it is possible to write a type signature that looks like it's polymorphically
"subtracting a row," i.e. something like the following, it cannot ever have been
the writer's intention to actually subtract a row.

```
-- You can't actually implement f, except by essentially ignoring its input
f : a or @Tag0 Int or @Tag1 Int -> a or @Tag1 Int
f _ = @Tag1 1 -- The only real implementation of f
```

In other words errors involving row types arise by adding too many rows, which
means we have an answer as to what the canonical source of a row type error is:
the place that introduced that row!

This is the fulcrum by which the next section's approach works.

## <a id="a-strategy">A strategy for providing excellent error messages even in heavily row-polymorphic code</a>

Again, the big takeaway from the previous section is the following:

For row-polymorphic code, rows can only ever be added not subtracted during the
process of unification. It cannot ever have been the programmer's intention to
subtract a row.

When looking at a type error caused by a difference between an expected and
actual row type, we're going to focus only one specific case: the actual type is
polymorphic and the actual type has rows which do not exist in the expected type.

The reason we want to focus on the case where the actual type is polymorphic is
because a concrete type should be handled perfectly fine by Elm's current
error-reporting mechanism (since there's nothing special about row types being
used without polymorphism).

The reason we're focusing only on the actual type having more fields than the
expected type is that if the expected type has rows which do not exist in the
expected type, there is no localization possible (and that's okay!).

For example, in the following case, there is no specific line to point to, we
just generally saw that the user needs to add a field.

```
-- No specific line "went wrong" we can only report that you need to add a field
-- somewhere in this expression
record : { a : Int, b : Int, c: Int }
record =
    { a = 0
    , c = 0
    }
```

This leads us to a single principle.

__If you keep deleting rows from the row types that contribute to the final type
of the expression, eventually that expression must type check.__

This simple principle lets us deduce what the canonical error source for
row-polymorphic code must have been. Since row labels can only ever have been
added, not subtracted, the source of an error must have been the place that
introduced the row label. So if we just keep subtracting we'll eventually find
it!

Let's return to our first example with `ifThen`.

```
y : { case0 : Int, case1 : Int }
y = ifThen True
    (case0Tag 0)
    (casa1Tag 1)
```

Applying this reasoning we see that `casa1Tag` is our canonical source of our
error. Since we can only add fields with new code, that means the error must be
in the code that added `casa1`, which we can verify by deleting occurences of
the row type `casa1` until everything type checks again.

Because a user can never write code that "subtracts" a row, this hopefully also
agrees nicely with programmer's intuitions of "what went wrong."

Indeed we can capture our reasoning in a very straightforward algorithm.  Assume
we have a type error between two row types `A` and `B` for a given expression
`E`, at least one of which is polymorphic, take the row type that has two 

Because inference has already run, we know the type of every subexpression with
`E`.

Because of this behavior we know two things:

1. The type error must've been caused by a value or function symbol adding a row
   which shouldn't be there; it cannot have been caused by a value or function
   symbol failing to subtract a row
2. This row must appear in the type signature of a value or function symbol
   outside the expression, i.e. before running unification on the expression

Without loss of generality, assume that row to be `A`.

1. Choose one row `r0 : T` in `A` which does not exist in `B`.
2. Collect every symbol, including duplicates, in the expression whose type
   contains `r0 : T` (we can do this because by the time we have a type error
   for `E` we already know the type of every symbol within it), call this
   collection `C`. Ignore all unannotated `let` variables.
3. For each element in `C` do the following: remove `r0 : T` and re-run unification on
   `E`. If `r0 : T` no longer appears in our type error stop. If our type error
   does not change keep this modified type signature for this element in `C`. If
   we get a new type error drop the element from `C`. By our reasoning earlier
   we know this step must terminate with a non-empty `C`. On termination, remove
   any elements we haven't yet gotten to.
4. For each element remaining in `C` add back `r0 : T` and re-run unification.
   If this causes the type error to re-surface keep this element in `C`,
   otherwise remove this element.

Every element in `C` is a source of `r0 : T` and can be marked as such in the
error message.

We re-run these steps for every row that exists in `A` which does not exist in
`B`.

The dropping of elements in step 3 occurs because we can have irrelevant symbols
that are "swallowed" by functions and don't contribute to the final 

We then report the elements contained in each `C`.

This results in nice, localized error messages.

Here's a hypothetical example that demonstrates one run of the algorithm:

```
f x = case x of
    @A a -> a + 1
    @B b -> b + 2
    @C c -> c + 3

value =
    let
        x0 = @A 0
        x1 = @BB 5
        x2 = identity x1
        x3 = if False then x0 else x2
        -- Our algorithm succesfully ignores this
        x4 = @BB 10
        x5 = (\_ -> 2) x4
    in
        x5 + (f x3)
       
```
would result in an error message looking like
```
The 1st argument to `f` is not what I expect:

22|         x5 + (f x3)

`f` can only handle these cases in its first argument

    @A Int, @B Int, @C Int

but `x3` requires its caller to handle these additional cases

    @BB Int

This is because of this expression, which requires its caller to at least 
handle `@BB Int`:

15|     x1 = @BB 5
             ^^^^^
Hint: This seems like a typo, maybe `@BB` should be `@B`?
```

Let's run through the algorithm sketched out above to see how we can precisely
identiy `@BB 5` as the source of the error.

First, unification results in `x3` having a type `@BB Int` which `f` does not
support. Then we collect all our symbols for `C`, which are the following:
```
@A, 0, @BB (@BB 5), 5, identity, True, @BB (@BB 10), 10, 2, f, +
```
We then narrow down to the symbols whose types contain `@BB Int`.
```
@BB (@BB 5), @BB (@BB 10)
```
We remove `@BB Int` from `@BB`'s signature so now we just have a fully
row-polymorphic type variable. This causes unification to pass. So we keep `@BB
(@BB 5)` in `C`. Because unification has now passed we drop `@BB (@BB 10)`. Now
we verify again by adding `@BB Int` back to `@BB (@BB 5)` and we have a type
error again. That means we've finished and have identified the source of the
problem.

At the beginning of all this I said that this strategy would apply for Elm
records as well and indeed we can provide some hypothetical examples of what
that might look like.

```
Something is off with the body of the `h` definition:

4|>h  = ...

The body has the type:

    { a | field0 : Int, field1 : Int, field2 : number } -> number

But the type annotation on `h` says it should be:

    { field0 : Int, field1 : Int } -> Int

This discrepancy is caused by the following code

6|>    (\r1 -> r1.field2 + 1)
                  ^^^^^^
which has the type

    { field0 : Int, field1 : Int, field2 : number } -> number

and is causing `h`'s entire body to have an additional `field2` field.

Hint: Seems like a record field typo. Maybe field2 should be field1?
```
and in the case of record creation we get the following. We have to special-case
record creation expressions since as we said earlier that we usually only run
this algorithm when either the expected or actual type is polymorphic, but the
algorithm still works and record creation already has special-cased error
reporting behavior.
```
Something is off with the body of the `record` definition:

 9|>    { a = 0
 ...     ...
12|>    }

The body is a record of type:

    { a : number, b : number1, cc : number2 }

But the type annotation on `record` says it should be:

    MyRecord

This is caused by the following code

11|>    , cc = 0
          ^^

which is causing the entire body to have an additional `cc` field.

Hint: Seems like a record field typo. Maybe cc should be c?
```

(Note I think that `MyRecord` could probably be expanded to have an even better
type message, but that's a discussion for another day...)

I don't know about you, but I think those error messages look nicer!

## <a id="what-this-means">What this means for extensible unions</a>

Hopefully this post outlines a strategy for good error messages for row types in
Elm today. The algorithm is slow, but I think there's room for improvement
(it seems like there's some potential for caching), and moreover only needs to
run on expressions which we wish to provide more in-depth error reporting for,
and does not need to run during normal typechecking.

What I meant to show is that, given Elm's current position on row types, there
is, generally speaking, almost no *intrinsic* tension between row types and good
error messages. There are "only" implementation difficulties (which should not
be dismissed out of hand but are out of scope for this particular post).

As far as I know there is only one place where arguably error messages suffer,
which is across different top-level expressions.

That is if we have as a top-level definition `y = f x` and `x` does not match
the type required by `f` the best error message we can give is that `x` is a
different type than `f` and show the two types.

In theory the algorithm I've outlined here could inline top-level expressions
and work across expression lines. However, that would greatly increase the
potential for "knock-on" effects. That is a programmer could look at the error
report, make the suggested change in an expression far away, which would then
kick off another series of errors.

Hence I've limited the scope of the algorithm to only run within the context of
a single top-level expression.  In my estimation that seems like a rather small
price to pay for extensible unions, especially because it is immediately cleared
up by top-level type annotations (which can be suggested in the error message,
i.e. the exact symbol that needs a type annotation can be mentioned).

On the flip side, I think that extensible unions play a large part in making code
generate *better* error messages, in a way that's somewhat reminiscent of an
XY-problem.

If we think back to the problem of gigantic case statements and how to generate
good error messages in those cases, there is an unspoken question to probe which
is __why exactly do users create gigantic case statements__?

One possible answer is that there is no reasonable way to refactor these large
case statements without introducing new architectural patterns (e.g. OutMsg).
The very first refactoring tool that beginners learn, which is to pull out a
chunk of code and give it a name, fails here, because there's no straightforward
way of doing so. You have to bite the bullet and write the entire case
statement.

By providing an avenue for reducing the size of these case statements, we can
let the first refactoring tool a beginner learns have even wider power than what
currently exists in Elm.
