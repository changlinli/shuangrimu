---
title: Different encodings of ADTs
cover-image: Prokudin-Gorskii-25_scale.jpg
author: Rimu Shuang
attribution: 'Public Domain. Shot by Sergey Prokudin-Gorsky. 1910. Originally
from http://en.wikipedia.org/wiki/File:Prokudin-Gorskii-25.jpg.'
subhead: Encoding Algebraic Datatypes with Functions Part 1
cover-image: Prokudin-Gorskii-25_scale.jpg
tags: haskell
date: 2018-04-02T01:39:00-0500
---

Today we'll look at different ways of representing algebraic datatypes. In
particular we're going to be answering the question "What would algebraic
datatypes look like if you didn't have them built into a language?"

This entire post is a literate Haskell file so if you'd like to load the code
simply append a `.md` to the URL and load the resulting file into GHCi.

> {-# LANGUAGE RankNTypes, GADTs #-}
> import Data.Char (ord)

Let's begin with the standard way of defining an ADT, that is with a
straightforward `data` declaration.  Here's an example of a very basic sum
type.  We'll call this `Color0` to allow us to go through multiple iterations.

> data Color0 = Red | Green | Blue

Here's an example of a very basic product type.

> data Identifier0 = Identifier0 Char Int

We can combine product and sum types together.

> data ComplexIdentifier0 = TrivialIdentifier | MultiIdentifier Char Int

We can also define ADTs recursively, as in the unary natural numbers.

> data NaturalNum0 = Zero | Successor NaturalNum0

And finally the usual definition for a linked list is an example that makes use
of all three features.

> data List0 a = Nil | Cons a (List0 a)

What we'll note here is that fundamentally the only thing you can do with an
ADT is to pattern match on it; everything reduces to a pattern match. For
example, if we wanted to convert a `Color0` to an integer, we could the following.

> doSomething0 :: Color0 -> Int
> doSomething0 color = 
>   case color of
>     Red -> 1
>     Green -> 2
>     Blue -> 3


Or to put it more pithily: your data is entirely determined by the actions you
can perform on it and vice versa.

The crucial insight of encoding an ADT as a function is that higher-order
functions can encode pattern matching. Just pass the code that you would put on
the right-hand side of a match statement as a parameter into the higher-order
function and then have the higher-order function decide which one to pick.

We can use this insight to derive alternative ways of encoding pattern matching.

For example, if we accept that pattern matching on the three tags `Red`,
`Green`, and `Blue` is the essence of `Color0` then what is the essence of
`Red`? Simply the pattern match that always returns the code behind the `Red`
tag. An analogous situation holds for `Green` and `Blue`.

> type Color1 = forall a. a -> a -> a -> a
> -- Color1 is simply a function that takes in three pieces of code to run
> -- corresponding to each branch of your match statement
>
> red :: Color1
> -- red :: a -> a -> a -> a
> red redMatch greenMatch blueMatch = redMatch 
>
> green :: Color1
> -- green :: a -> a -> a -> a
> green redMatch greenMatch blueMatch = greenMatch
>
> blue :: Color1
> -- blue :: a -> a -> a -> a
> blue redMatch greenMatch blueMatch = blueMatch

We can then rewrite `doSomething0`, now by directly passing in each branch of
our pattern match into `Color1`.

> doSomething1 :: Color1 -> Int
> doSomething1 color = color 1 2 3

And indeed we can convert losslessly between `Color0` and `Color1` which
indicates they are just two representations of the same underlying thing!

> color0ToColor1 :: Color0 -> Color1
> color0ToColor1 color =
>   case color of
>     Red -> red
>     Green -> green
>     Blue -> blue
>
> color1ToColor0 :: Color1 -> Color0
> color1ToColor0 color = color Red Green Blue

From `color1ToColor0` we can see how to actually use our function-encoded ADTs.
**Any code you would put on the right-hand branch of a match statement, you
just pass it to the appropriate argument in the function**. Because every usage
of a normal ADT bottoms out at a match statement, everywhere we use a normal
ADT, we can also use these function-encoded ADTs.

Product types make this a bit more interesting. Let's investigate `Identifier0`
and how it would look in a pattern matching statement.

> convertIdentifer0ToInt :: Identifier0 -> Int
> convertIdentifer0ToInt identifier =
>   case identifier of 
>     Identifier0 char int -> (ord char) + int

If we look at the right-hand side of the `->`, there is one big difference from
our previous pattern matches with `Color0`: we have access to a `char` and
`int` argument. So we can think now of the right-hand side as a function taking
`char` and `int` as arguments.

By analogy to `Color1`, this leads us to this definition of `Identifier1`.

> type Identifier1 = forall a. (Char -> Int -> a) -> a

This then results in

> convertIdentifier1ToInt :: Identifier1 -> Int
> convertIdentifier1ToInt identifier = identifier (\char int -> (ord char) + int)

where we could create an actual `Identifier1` in the following way:

> anIdentifier1 :: Identifier1
> anIdentifier1 charAndIntFunction = charAndIntFunction 'a' 1

compared to `Identifier0`

> anIdentifier0 :: Identifier0
> anIdentifier0 = Identifier0 'a' 1

Finally we can again convert losslessly between the two.

> identifier0ToIdentifier1 :: Identifier0 -> Identifier1
> identifier0ToIdentifier1 identifier0 =
>   case identifier0 of
>     Identifier0 char int -> 
>       let identifier1 :: (Char -> Int -> a) -> a
>           identifier1 f = f char int 
>         in 
>       identifier1
>
> identifier1ToIdentifier0 :: Identifier1 -> Identifier0
> identifier1ToIdentifier0 identifier1 = 
>   -- We'll make the lambda really obvious here when we could just write
>   -- Identifier0
>   identifier1 (\char int -> Identifier0 char int)

This again demonstrates that really these are just two representations of the
same thing. And again by looking at `identifier1ToIdentifier0` we can see that
the way to use our function-encoded ADTs is to just pass the right-hand side of
a match statement in as an argument.

Alright so now that we've displayed how you might represent a product or sum
type independently, we can put them together by presenting an alternative way
of encoding `ComplexIdentifier0`.

> type ComplexIdentifier1 =
>   -- We'll write out forall a. a -> (Char -> Int -> a) -> a on separate lines
>   forall a. a                  -- Analogous to the right-hand side of pattern matching on TrivialIdentifier
>   ->        (Char -> Int -> a) -- Analogous to the right-hand side of pattern matching on MultiIdentifier
>   ->        a

And then we can look at how we might create values of type `ComplexIdentifier1`
and compare them with `ComplexIdentifier0`.

> trivialIdentifier0 :: ComplexIdentifier0
> trivialIdentifier0 = TrivialIdentifier
>
> trivialIdentifier1 :: ComplexIdentifier1
> trivialIdentifier1 = (\a charIntFunction -> a)
>
> arbitraryMultiIdentifier0 :: ComplexIdentifier0
> arbitraryMultiIdentifier0 = MultiIdentifier 'a' 1
>
> arbitraryMultiIdentifier1 :: ComplexIdentifier1
> arbitraryMultiIdentifier1 = (\a charIntFunction -> charIntFunction 'a' 1)

And again we can prove to ourselves we can losslessly convert between the two.

> complexIdentifier0ToComplexIdentifier1 :: ComplexIdentifier0 -> ComplexIdentifier1
> complexIdentifier0ToComplexIdentifier1 identifier0 =
>   case identifier0 of
>     TrivialIdentifier -> (\a charIntFunction -> a)
>     MultiIdentifier char int -> (\a charIntFunction -> charIntFunction char int)
>
> complexIdentifier1ToComplexIdentifier0 :: ComplexIdentifier1 -> ComplexIdentifier0
> complexIdentifier1ToComplexIdentifier0 identifier1 = identifier1 TrivialIdentifier MultiIdentifier

Finally we get to recursive ADTs. This is where things get interesting because
we have a couple different choices of what to do.

The most straightforward thing we could do is preserve the recursion in
`NaturalNum0` and just move it to the type level, but we have to be a bit 
careful about how we do that because Haskell doesn't support infinite types,
which is what we get with careless recursion.

< -- Doesn't work
< -- Error: Cycle in type synonym declarations
< type NaturalNum1 = forall a. a -> NaturalNum1 -> a

Instead if we guard it behind a `newtype`, we don't get infinite expansion of
our type and have only one level of recursion.

> newtype NaturalNum1 = NaturalNum1 { unNaturalNum1 :: forall a. a -> (NaturalNum1 -> a) -> a }

If we look at how we create numbers with `NaturalNum0`, we can do an analogous thing with `NaturalNum1`.

> zero0 :: NaturalNum0
> zero0 = Zero
>
> one0 :: NaturalNum0
> one0 = Successor Zero
>
> two0 :: NaturalNum0
> two0 = Successor (Successor Zero)
>
> zero1 :: NaturalNum1
> zero1 = NaturalNum1 (\zero successor -> zero)
>
> one1 :: NaturalNum1
> one1 = NaturalNum1 (\zero successor -> 
>   successor (NaturalNum1 (\zero' successor' -> zero')))
>
> two1 :: NaturalNum1
> two1 = NaturalNum1 (\zero successor -> 
>   successor (NaturalNum1 (\zero' successor' -> 
>     successor' (NaturalNum1 (\zero'' successor'' -> zero'')))))

Let's go over what just happened in a bit more detail. If we think back to the
mantra that a datatype is entirely determined by what you would do with the
pattern match

Let's see another example here, this time with an explicit pattern match.

> naturalNum0ToInt :: NaturalNum0 -> Int
> naturalNum0ToInt n =
>   case n of
>     Zero -> 0
>     Successor m -> naturalNum0ToInt m + 1

> naturalNum1ToInt :: NaturalNum1 -> Int
> naturalNum1ToInt n = (unNaturalNum1 n) 0 (\m -> naturalNum1ToInt m + 1)

> naturalNum0ToInt' :: NaturalNum0 -> Int
> naturalNum0ToInt' n =
>   case n of
>     Zero -> 0
>     Successor Zero -> 1
>     Successor (Successor m) -> naturalNum0ToInt m + 2
>     -- To make the translation into NaturalNum1 easier, it is useful to note
>     -- that the above is equivalent to another round of matching i.e.
>     -- Successor x -> 
>     --   case x of
>     --     Zero -> 1
>     --     Successor m -> naturalNum0ToInt m + 2

> naturalNum1ToInt' :: NaturalNum1 -> Int
> naturalNum1ToInt' n = (unNaturalNum1 n) 0 (\x -> (unNaturalNum1 x) 1 (\m -> naturalNum1ToInt' m + 2))

But what if we could remove this recursion? There is a general trick here we
can use where we can use fixed points to encode recursion and leave ourselves
with a non-recursive definition. But that's getting a bit ahead of ourselves
here.

First let's talk about fixed points. A fixed point of a function `f` is a value
`x` such that `f x = x`.

For example, `0` is a fixed point of the absolute value function (the function
that leaves positive numbers unchanged and multiplies negative numbers by
`-1`).

Note that not every function has a fixed point, for example `f x = x + 1` does
not.

Note also that there can be more than one fixed point. For example `f x = x`
has a fixed point for every possible value of `x`.

It would be convenient if we could have a higher order function
`findFixedPoint` that could find a fixed point of a function automatically
(if it exists). Unfortunately, this is in general impossible due to the Halting
Problem. This may not be obvious, but in the interests of not making this post
even longer, I'll just ask you to take this on faith for now if it's not
apparent to you why this is the case.

Nonetheless, we can make an approximate version of this in Haskell that looks
like the following.

> findFixedPoint :: (a -> a) -> a
> findFixedPoint f = f (findFixedPoint f)

Note that this follows the definition of a fixed point quite closely: the value
returned by `findFixedPoint` is equal to `f` applied to that value. We're kind
of cheating here by using recursion in `findFixedPoint`, but this is the only
place we'll use recursion. The famous Y combinator is one implementation of
`findFixedPoint` that uses self-application (i.e. `use f = f f`) instead of
recursion, but we'll use this more straightforward implementation that
suffices for our purposes.

Unfortunately, on the face of things, `findFixedPoint` is rather limited in
what it can do.

< -- This hangs and never returns
< cantFindFixedPointOfAbsoluteValue = findFixedPoint abs

On the other hand, `findFixedPoint` is able to find the following fixed point.

> always0 :: Int -> Int
> always0 _ = 0

Running `findFixedPoint always0` in GHCi will yield `0`. So it appears that
`findFixedPoint` can only find blindingly obvious fixed points. Indeed, because
of the way lazy function evaluation works in Haskell, `findFixedPoint` will
only *not* hang on functions that do not inspect their argument at all.

However, `findFixedPoint` redeems itself when it is applied to higher-order
functions. In particular note that the equalty `f x = x` can easily be flipped
around to become an expansion rule `x = f x`. Let's file that away in the back
of our minds and turn our attention back to recursion.

Here's the usual presentation of the factorial function, the hello world of
recursion.

> factorial :: Integer -> Integer
> factorial 0 = 1
> factorial n = n * factorial (n - 1)

Let's make one little adjustment to it to get rid of the recursion.

> factorialNonRecursive :: (Integer -> Integer) -> Integer -> Integer
> factorialNonRecursive _ 0 = 1
> factorialNonRecursive f n = n * f (n - 1)

We've factored out our recursive step into a separate function `f` that
`factorialNonRecursive` takes so that we now have a higher order function,
which we can think of as having the signature `factorialNonRecursive :: F -> F`
where `type F = (Integer -> Integer)`.

This is now in a form where it makes sense to ask if `factorialNonRecursive`
has a fixed point. But first it's worth taking a step back to understand what
the fixed point of `factorialNonRecursive` would look like. It would be a
function `fixedPoint` where `factorialNonRecursive fixedPoint = fixedPoint`,
assuming a notion of function equality. Let's turn that equality around and use
it as a technique for expanding definitions. That equality means we should be
able to replace every occurrence of `fixedPoint` in `factorialNonRecursive
fixedPoint` by `factorialNonRecursive fixedPoint`.

Let's see how that would work.

```haskell
-- Well this part doesn't change because the argument is ignored
factorialNonRecursive _ 0 = 1
-- This does change though
factorialNonRecursive fixedPoint n = n * (factorialNonRecursive fixedPoint) (n - 1)
```

Well well well, we've recovered recursion! We can expand out the
`(factorialNonRecursive fixedPoint)` part indefinitely.

Let's walk through a mental evaluation of our hypothetical `fixedPoint` function.

`fixedPoint 0`  is equal to `factorialNonRecursive fixedPoint 0`, but by the
definition of `factorialNonRecursive` this is just `1`.

Okay what about the definition of `fixedPoint 2`? Well we take
`factorialNonRecursive fixedPoint 2 = 2 * ((factorialNonRecursive fixedPoint)
1) = 2 * (factorialNonRecursive fixedPoint 1)`. We can substitute again to
yield `factorialNonRecursive fixedPoint 2 = 2 * (1 * (factorialNonRecursive
fixedPoint 0))` and finally one more substitution yields `factorialNonRecursive
fixedPoint 2 = 2 * (1 * 1)`.

So it looks like the fixed point of `factorialNonRecursive` is exactly the
recursive function `factorial`! An astute reader may notice that I haven't
justified the use of "the" here. A priori there's no reason to believe that
there is only one fixed point, but I'll again ask the reader to take on faith
that there is a single fixed point in the interest of keeping this post
manageable in length.

So if we had a function to find fixed points, we could apply it to
`factorialNonRecursive` and get our usual factorial function out of it. Luckily
we do have `findFixedPoint` and in this case it happens to actually work and
actually find a fixed point because `factorialNonRecursive` ignores its first
argument in one case.

> factorial' :: Integer -> Integer
> factorial' = findFixedPoint factorialNonRecursive

A little bit of experimentation with GHCi will reveal that indeed `factorial'`
behaves as you would hope and that e.g. `factorial' 5` yields `120`.

Whew, that was a bit of a detour, but it's worth recapping the trick we've
demonstrated here; we've taken a recursive definition and transformed into a
non-recursive definition where we recover the recursive definition by finding
the fixed point of the non-recursive definition.

Now we're going to take this same trick and apply it at the type level.

Thinking back to our example of `NaturalNum0`, let's define a new `NaturalNum2`
that factors out the recursion into a separate parameter.

> data NaturalNum2 a = Zero2 | Successor2 a

What would a fixed point of `NaturalNum2` be? Well it would be a type that,
when passed to `NaturalNum2` results in the "same" type. Now equality of types
is a little trickier than equality of values to reason about, but we'll return
to the theme we defined at the outset of this post: two types are equal if they
have equivalent pattern matching behavior.

Let's look at some type level functions that have more straightforward fixed
points. First the type level equivalent of `identity`.

> data Identity a = Identity a

No matter what type you pass in as `a`, the pattern match always looks the
exact same; a single case of `Identity` that then delegates to the underlying
pattern match of `a`, which is effectively the same thing as just directly
pattern matching on `a`. Hence every type is a fixed point of `Identity`.

Now let's look at the type-level equivalent of `always0`

> data AlwaysTheSame a = TheSame ()

`()` is a fixed point of `AlwaysTheSame` because pattern matching on `TheSame
()` is really just the same as only pattern matching on `()`. On the other
hand, something like `Color0` is not a fixed point of `AlwaysTheSame`, because
the three cases of `Color0` have been flattened into a single case `TheSame ()`.

Now it turns out we can't really define something like `abs` at the type level
due to our limited vocabulary with ADTs. However, we can define the same
`findFixedPoint` function we had at the type level. We have to create a
`FixedPoint` data constructor because Haskell doesn't support infinite types,
but otherwise it looks the same.

> data FindFixedPoint f = FixedPoint (f (FindFixedPoint f))

Just like how `findFixedPoint factorialNonRecursive` is the same thing as
`factorial`, can we show that `FindFixedPoint NaturalNum2` is the same thing as
`NaturalNum0`?

Let's first compare `NaturalNum0` with `NaturalNum2`.  The pattern match in the
`Zero` and `Zero2` case is the exact same. However, pattern matching on
`Successor` gives you back a new `NaturalNum` whereas `Successor2` gives you
back an `a`.

Now what happens in the case of `FindFixedPoint NaturalNum2`? Well we either
get back a `FixedPoint Zero2`, which, from the perspective of pattern matching,
is the same thing as just a normal `Zero` or we get back a `FixedPoint
(Successor2 m)` where `m` is another `FindFixedPoint NaturalNum2`, which
equivalent to `Successor m` yielding another `NaturalNum0`.

Another example of this equivalence is looking again at another implementation
of `naturalNum0ToInt`.

> naturalNum2ToInt :: FindFixedPoint NaturalNum2 -> Int
> naturalNum2ToInt n =
>   case n of
>     FixedPoint Zero2 -> 0
>     FixedPoint (Successor2 m) -> naturalNum2ToInt m + 1

This looks pretty much the same, just with some extra `FixedPoint`s sprinkled
around.

So we've demonstrated we can use fixed points to remove the recursion in
`NaturalNum0` with `NaturalNum2`.

What about the recursion at the type level we see with `NaturalNum1`?

> type NaturalNum3 = forall a. a -> (a -> a) -> a

> zero3 :: NaturalNum3
> zero3 = \z _ -> z

> one3 :: NaturalNum3
> one3 = \z s -> s z

> two3 :: NaturalNum3
> two3 = \z s -> s (s z)

> successor3 :: NaturalNum3 -> NaturalNum3
> successor3 n = \z s -> s (n z s)

> naturalNum3ToInt :: NaturalNum3 -> Int
> naturalNum3ToInt f = f 0 (+ 1)

> naturalNum1ToNaturalNum3 :: NaturalNum1 -> NaturalNum3
> naturalNum1ToNaturalNum3 (NaturalNum1 n) = n (\z s -> z) (\m -> \z s -> s (naturalNum1ToNaturalNum3 m z s))

> successor1 :: NaturalNum1 -> NaturalNum1
> successor1 f = NaturalNum1 (\_ s -> s f)

> naturalNum3ToNaturalNum1 :: NaturalNum3 -> NaturalNum1
> naturalNum3ToNaturalNum1 f = f (NaturalNum1 (\z _ -> z)) successor1

> twoInt :: Int
> twoInt = naturalNum1ToInt (naturalNum3ToNaturalNum1 two3)

> twoInt' :: Int
> twoInt' = naturalNum3ToInt (naturalNum1ToNaturalNum3 two1)

> fixedPoint :: NaturalNum2 (FindFixedPoint NaturalNum2) -> FindFixedPoint NaturalNum2
> fixedPoint n = FixedPoint n

> fixedPointInverse :: FindFixedPoint NaturalNum2 -> NaturalNum2 (FindFixedPoint NaturalNum2)
> fixedPointInverse (FixedPoint n) = n

> newtype Nat = Nat { unNat :: forall a. a -> (a -> a) -> a }
> data NatF a = NatF (forall x. x -> (a -> x) -> x)

> fixedPoint' :: FindFixedPoint NatF -> NaturalNum1
> fixedPoint' (FixedPoint (NatF n)) = NaturalNum1 (\z s -> n z (\y -> s (fixedPoint' y)))

> fixedPoint'' :: FindFixedPoint NatF -> NatF (FindFixedPoint NatF)
> fixedPoint'' (FixedPoint n) = n

> fixedPoint''' :: NatF Nat -> Nat
> fixedPoint''' (NatF n) = Nat (\z s -> n z (\y -> _))

> ifZero :: NaturalNum3 -> Bool
> ifZero n = n True (\_ -> False)

> ifOne :: NaturalNum0 -> Bool
> ifOne n = case n of
>     Zero -> False
>     Successor m -> case m of
>         Zero -> True
>         Successor _ -> False

> naturalNum0ToNaturalNum3 :: NaturalNum0 -> NaturalNum3
> naturalNum0ToNaturalNum3 Zero = \z s -> z
> naturalNum0ToNaturalNum3 (Successor n) = \z s -> s (naturalNum0ToNaturalNum3 n z s)

> naturalNum3ToNaturalNum0 :: NaturalNum3 -> NaturalNum0
> naturalNum3ToNaturalNum0 f = f Zero Successor

> naturalNum0RoundTrip :: NaturalNum0 -> NaturalNum0 
> naturalNum0RoundTrip n = naturalNum3ToNaturalNum0 (naturalNum0ToNaturalNum3 n)
