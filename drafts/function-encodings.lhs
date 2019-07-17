---
title: Encoding ADTs with Functions
cover-image: Prokudin-Gorskii-25_scale.jpg
author: Rimu Shuang
attribution: 'Public Domain. Shot by Sergey Prokudin-Gorsky. 1910. Originally
from http://en.wikipedia.org/wiki/File:Prokudin-Gorskii-25.jpg.'
subhead: 
tags: haskell
date: 2018-04-02T01:39:00-0500
---

Today we'll look at different ways of representing algebraic datatypes.

> {-# LANGUAGE RankNTypes, GADTs #-}
> import Data.Char (ord)

The easiest way is with a straightforward `data` declaration.
Here's an example of a very basic sum type.
We'll call this `Color0` to allow us to go through multiple iterations.

> data Color0 = Red | Green | Blue

Here's an example of a very basic product type.

> data Identifier0 = Identifier0 Char Int

We can of course combine product and sum types together.

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
>       let myFunction :: (Char -> Int -> a) -> a
>           myFunction f = f char int 
>         in 
>       myFunction
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

Boehm-Berarducci Encoding
=========================

Our next step is going to be a bit more complicated.

Our new encoding is going to to be non-recursive.
But first, let's return to our ordinary ADT definition.

> data NaturalNum0F x = ZeroF | SuccessorF x
>
> data T where
>   K :: NaturalNum0F T -> T
>
> instance Functor NaturalNum0F where
>   fmap f ZeroF = ZeroF
>   fmap f (SuccessorF x) = SuccessorF (f x)
>
> newtype Fix f = Fix {unFix :: f (Fix f)}
>
> type Algebra f c = f c -> c
>
> naturalNum0FToInt :: Algebra NaturalNum0F Int
> naturalNum0FToInt ZeroF = 0
> naturalNum0FToInt (SuccessorF x) = x + 1
>
> type NaturalNum0' = Fix NaturalNum0F
>
> naturalNum0FToNaturalNum :: Algebra NaturalNum0F NaturalNum0
> naturalNum0FToNaturalNum ZeroF = Zero
> naturalNum0FToNaturalNum (SuccessorF x) = Successor x
>
> zeroF :: NaturalNum0'
> zeroF = Fix ZeroF
>
> oneF :: NaturalNum0'
> oneF = Fix (SuccessorF (Fix ZeroF))
>
> cata :: Functor f => Algebra f a -> Fix f -> a
> cata algebra fixedF = algebra . fmap (cata algebra) . unFix $ fixedF
>
> newtype NaturalNum1F x = NaturalNum1F { unNaturalNum1F :: forall a. a -> (x -> a) -> a}
>
> zero5 :: Fix NaturalNum1F
> zero5 = Fix (NaturalNum1F (\zero successor -> zero))

We can see the equivalence between `NaturalNum1F` in two steps, one between
`NaturalNum1F` and `NaturalNum0F` and one between `NaturalNum0F` and
`NaturalNum0`.

> newtype NaturalNum2 = NaturalNum2 { unNaturalNum2 :: forall a. a -> (a -> a) -> a }

> zero2 :: NaturalNum2
> zero2 = NaturalNum2 (\zero _ -> zero)
>
> one2 :: NaturalNum2
> one2 = NaturalNum2 (\zero successor -> successor zero)

> two2 :: NaturalNum2
> two2 = NaturalNum2 (\zero successor -> successor (successor zero))

> naturalNum2ToInt :: NaturalNum2 -> Int
> naturalNum2ToInt n = (unNaturalNum2 n) 0 (+ 1)

> naturalNum2ToNaturalNum0 :: NaturalNum2 -> NaturalNum0
> naturalNum2ToNaturalNum0 naturalNum2 = (unNaturalNum2 naturalNum2) Zero Successor

> naturalNum0ToNaturalNum2 :: NaturalNum0 -> NaturalNum2
> naturalNum0ToNaturalNum2 naturalNum0 =
>   case naturalNum0 of
>     Zero -> NaturalNum2 (\zero successor -> zero)
>     Successor n -> NaturalNum2 (\zero successor -> (unNaturalNum2 $ naturalNum0ToNaturalNum2 n) zero successor)
