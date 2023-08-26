---
title: A Language Agnostic Introduction to Dependent Types
cover-image: Shibanpo-bridge.svg
author: Rimu Shuang
attribution: 'Roulex 45. <a href="https://commons.wikimedia.org/wiki/File:Shibanpo-bridge.svg">Élévation du pont de Shibapo</a> May 7th, 2010. CC-BY-SA 3.0 License (NOT a CC-BY 4.0 License).'
subhead: 'An explanation of dependent types that assumes only basic familiarity
with any statically typed programming language'
tags: Miscellaneous
date: 2021-08-15T19:27:26-0800
---

__EDIT (2021-10-05): Tom Smeding has kindly pointed out several errors in a few
of my examples. In particular I did not include additional `IsSanitized(s)` and
`Sanitized(s)` arguments to `Some` and `None` in `checkIfStringIsSafe`. I also
did not actually end up using the `recursiveEquality` value in
`addingZeroOnRightDoesNothing`. Those errors have now been fixed. Many thanks to
Tom! I have separately also added an additional simple example of proving a
contradiction and elaborated somewhat on my string sanitization example.__

"Dependent types" seem to be one of those things a lot of programmers have heard
about, but don't really know much about it. Discussion forums talk about how you
can prove things with dependent types and how they're so so awesome for program
correctness, but the discussions often are very confused with people talking
past each other. Unfortunately most introductions to dependent types seem to
assume a deep familiarity with functional programming or to assume a certain
amount of familiarity with programming language theory.

I personally think dependent types are a fantastic feature I would like to
see many more programming languages implement, rather than the paltry few that
currently exist, but I also am quite skeptical of how dependent types are often
used today in the few languages that do implement them and would like to suggest
new ways of using them. However, I will not be talking about the latter in this
post and will mainly be focusing on describing dependent types as they are found
today.

Here I present an introduction to dependent types that is hopefully accessible
for anyone who has worked with a statically typed language before that has some
sort of a switch or case matching sort of functionality. I'll go over some of
the basics of how to use dependent types to prove things. This will be very
heavy on pseudocode examples and very light on theory. Once you have an
intuition for how the examples work, I believe you will be better equipped to
understand other more theoretical introductions to dependent types.

Because this is targetted at people who have no experience with dependent types
the pace will be slow and potentially have some repetition.

To those who are familiar with dependent types, it is worth mentioning that this
introduction focuses heavily on dependent pattern matching as its primary method
of interaction with the typechecker rather than eliminators. While the latter is
theoretically cleaner, the former is often more familiar to software developers
unfamiliar with CS and logic theory. It is also the most common presentation
among existing dependently-typed languages.

As mentioned, this post will present common uses of dependent types
uncritically. This does not represent a personal endorsement of some of the
patterns I'll be presenting here. In a follow-up post I will detail what common
patterns in dependently-typed programming I believe to entail the wrong set of
trade-offs when it comes to production code in most businesses. In particular I
believe that a proof-heavy way of using dependent types is usually not
the best way to leverage dependent types and that this is even more aggravated
when the proofs are integrated into the data structure (such as the common
example of length-indexed vectors and type-safe append).

However, that will all come later. For now I'll be presenting aspects of
dependent types as they exist "in the wild" mostly divorced of my own thoughts
about them.

This post is long and is structured into several parts:

1. [Introduction to our pseudo-code](#introduction) : Our pseudo-code will consist of three
   main concepts: type constructors, pattern matching, and functions. Dependent
   types derive their power from a special type of types called `Type` that
   allows for more flexible type constructors and additional information passed to
   the type checker while pattern matching.
2. [Using the Type type](#type-type): Dependent types let you work with types just the
   same as you would any other value. This lets you recreate stuff like generics
   without any built-in support for them. Note that in the interests of
   accessibility we will not be addressing the issue of "type-in-type" (i.e.
   what is the type of `Type`?).
3. [Creating dependent types](#dependent-types): We can use this increased flexibility to create
   dependent types: types that depend on runtime values.
4. [Using pattern matching to narrow down runtime values](#pattern-matching): Our static
   typechecker needs to be able to statically narrow down runtime values to
   actually work. To do that we will use pattern matching.
5. [Determining when types are equal](#determining-equality): A large part of
   typechecking dependently typed code is proving two things are equal.
6. [Using type equality to prove runtime properties about our code: Boolean edition](#proving-boolean): Using the mechanisms that dependent types give us we go over some examples about how to prove properties of code using booleans.
7. [Using type equality to prove runtime properties about our code: NaturalNumber edition](#proving-natural-num): We do the same thing but now with natural numbers.
8. [Dependent types in data structures](#dependent-data-structures): We create
   data structures that intertwine dependent types with their underlying data.
9. [Using dependent types as a way of tagging data](#data-tagging): We use
   dependent types in a very lightweight manner to just tag data with
   properties.
10. [Why do dependently typed languages tend to be pure functional languages?](#why-functional): We close out by talking about why dependently typed languages tend to be pure functional languages.

## <a id="introduction">Introduction to our pseudo-code</a>

We will be working with some pseudocode inspired by Typescript, Java, Kotlin,
and Scala. Note that none of these languages have full-blown dependent types of
the sort I'll be presenting here although Typescript and Scala have some small
fragments.

The pseudocode looks something like this:

```
// This is a comment

/*
 * This is a block comment
 */

/*
 * This is how we create a new type
 *
 * Type constructors are the atomic "building blocks" of our programs. Most
 * non-function expressions ultimately evaluates to one of these constructors of
 * some type.
 *
 * We can create the usual primitive types this way, such as `Boolean`. We'll
 * show some other examples later as well.
 */
type Boolean constructors {
    // The ": Boolean" may look redundant right now, but it will come in handy
    // later when we have more complicated constructors
    True: Boolean
    False: Boolean
}

function not(x: Boolean): Boolean = {
    // This is an example of pattern matching
    case x of {
        True => False
        False => True
    }
}

// The last line of an expression is the return value of the entire expression
function notNot(x: Boolean): Boolean = {
    val oneNot = not(x)
    // This last line is the return value
    not(oneNot)
}

// Here's how we declare variables
// Once assigned they're immutable, we'll take more later about why this is
// important
val thisIsFalse = not(True)

type Shape constructors {
    Rectangle(isSquare: Boolean): Shape
    Circle: Shape
    Triangle(isEquilateral: Boolean): Shape
}

val square: Shape = Rectangle(True)

function isPointy(shape: Shape): Boolean = {
    case shape of {
        // We can bind new variables in pattern matches although in this case
        // it's unused
        Rectangle(unused) => True
        Circle => False
        Triangle(alsoUnused) => True
    }
}
// isPointy(Circle) is False
// isPointy(Triangle(True)) is True
// isPointy(Triangle(False)) is also True

function isRegularPolygon(shape: Shape): Boolean = {
    case shape of {
        // Another example of variable binding in pattern matches
        Rectangle(isThisASquare) => isThisASquare
        Circle => True
        Triangle(areWeEquilateral) => areWeEquilateral
    }
}
// isRegularPolygon(Rectangle(False)) is False
// isRegularPoylgon(Triangle(True)) is True
```

So far so good. This is a pretty bog-standard cross of languages such as Java,
Kotlin, Scala, Javascript, etc. It turns out that all the tools we have here are
actually enough to do basic programming. You can't interact with the outside
world since we haven't provided any primitives to do so (such as printing to
your console). However it turns out just with pattern matching and the ability
to create types with custom constructors, we can do all the logical bits of
computing you'd normally do (e.g. arithmetic, business logic, etc.).

We can build up data with the custom constructors we've defined, then pattern
matching lets us break down the custom types we create and conditionally
dispatch logic on them.

Here's some fancier type examples. We can have recursive types such as the
following.

```
type NaturalNumber constructors {
    Zero: NaturalNumber
    Successor(x: NaturalNumber): NaturalNumber
}

val zero: NaturalNumber = Zero

val one: NaturalNumber = Successor(Zero)

val two: NaturalNumber = Successor(Successor(Zero))

// We have recursion in functions as well!
function add(x: NaturalNumber, y: NaturalNumber): NaturalNumber = {
    case x of {
        Zero => y
        Successor(prev) => Successor(add(prev, y))
    }
}

// We can also recurse on both arguments
// True if x is greater than y, False otherwise
function greaterThan(x: NaturalNumber, y: NaturalNumber): Boolean = {
    case x of {
        Zero => False
        Successor(prevX) => case y of {
            Zero => True
            Successor(prevY) => greaterThan(prevX, prevY)
        }
    }
}
```

## <a id="type-type">Using the Type type</a>

We can also have the equivalent of generics in other languages, however we're
going to do this in a little different manner.

Here's the first semi-exotic thing that you might not have seen in other
statically typed languages. We have a special "type of types" called `Type`.
Any expression that is a `Type` can be used in a type signature.

This means that we don't have separate generic arguments to a type denoted by
angle or square brackets such as `List<Int>` or `List[Int]` that you might find
in other languages. We just use the same round parentheses as usual. This is a
little wordier than the usual treatment of generics, but that's because I'm
intentionally showing you all the machinery and not hiding things behind various
inference mechanisms.

```
// This is similar to an Option<T>, Option[T], or Maybe t type you might find in
// other languages
// Notice that `t: Type` is just a normal argument like any other!
type Option(t: Type) constructors {
    // Because x is a Type it can be used in the type signature of value
    Some(x: Type, value: x): Option(x)
    None(x: Type): Option(x)
}

// The Some(Boolean, ...) is explicitly passing the Boolean argument where this
// is often inferred in other languages with generics, e.g. Some<Boolean>(...)
// or Some[Boolean](...) which could be written as Some(...)
val someBoolean: Option(Boolean) = Some(Boolean, True)

val noBooleanFound: Option(Boolean) = None(Boolean)

type List(t: Type) constructors {
    Nil(x: Type): List(x)
    Cons(x: Type, element: x, rest: List(x)): List(x)
}

val listOfThreeElements: List(Boolean) = 
    Cons(Boolean, True, Cons(Boolean, False, Cons(Boolean, True, Nil(Boolean))))
```

Now that we have the ability to create a `Type` explicitly, we can create
`Type`s using all sorts of expression. Indeed, the ability for expressions to
evaluate to `Type`s themselves creates a lot of interesting other possibilities.

```
// We get type synonyms for free
// Note that choosing to capitalize the first letter of this function is just a
// convention for expressions that return a Type. There's no special mechanism
// here other than simple naming
function SynonymForBoolean(): Type = Boolean

// Remember, anything that evaluates to something of type Type can be used in a
// type signature and SynonymForBoolean returns a value of type Type!
val someBool: SomeSynonymForBoolean() = True
```

## <a id="dependent-types">Creating dependent types</a>

But an explicit `Type` by itself isn't a dependent type quite yet. Here's our
first true dependent type, that is a `Type` that depends on a runtime value.

```
// Again note that capitalizing the first letter of this function is just
// convention, nothing more
// Notice that unlike List which took an argument of type Type, here we have an
// argument boolean which is the normal runtime type Boolean
function ShapeOrNumber(boolean: Boolean): Type = {
    case boolean of {
        True => NaturalNumber
        False => Shape
    }
}

val circle: ShapeOrNumber(False) = Circle

val anotherZero: ShapeOrNumber(True) = Zero
```

Whew that's kind of trippy isn't it? You see runtime values in the form of
literals in a type signature! But of course the question arises, yeah this is
all and well when we have type constructor literals such as False or True, but
what happens when you don't have a literal?

## <a id="pattern-matching">Using pattern matching to narrow down runtime values</a>

Let's take a look at perhaps the simplest "hail Mary" approach where we just try
to stick in an abstract variable and see what happens.

```
function useAtRuntime(boolean: Boolean): NaturalNumber = {
    // Does this type check?
    // The answer is no, we'll go into a bit more later, but basically the
    // compiler can't evaluate abstract variables so it can't figure out what
    // type ShapeOrNumber(boolean) evaluates to, which is just as well since
    // this can't possibly work if boolean is False
    val thisDoesntCompile: ShapeOrNumber(boolean) = one
    thisDoesntCompile
}
```

So there's no magic here that can make this work. At a first glance this seems
to severely cripple dependent types. After all the majority of runtime values
are *not* going to be literals. And in fact we are pretty screwed if we have
arbitrary runtime values.  But we have a way of narrowing down what the value of
a runtime value can be so that it's not arbitrary anymore: pattern matching!

Every pattern match gives the compiler additional information about the runtime
value of a variable in that branch. Then in the branches of your pattern match
you can recover literals that you pass to `ShapeOrNumber`.

```
function useAtRuntimeTryAgain(boolean: Boolean): NaturalNumber = {
    case boolean of {
        True => {
            // The typechecker now knows in this branch boolean is True
            //
            // Notice that we're reusing boolean here! In a lot of statically
            // typed FP languages such as Haskell, ML, Elm, etc. the best you
            // could do is do ShapeOrNumber(True), where we are forced to repeat
            // the True even though we know that boolean can only be True.
            // In a dependently typed language we get this for free.
            //
            // Because the typechecker now knows that boolean is True it can
            // proceed to evaluate ShapeOrNumber to get NaturalNumber.
            val result: ShapeOrNumber(boolean) = one
            result
        }
        False => 
            // In this branch the typechecker now knows that boolean is False
            // We aren't doing anything with this information but we could've
            // used it to create something like `val someValue: ShapeOrNumber(boolean) = Circle`
            zero
    }
}

// useAtRuntimeTryAgain(True) is Zero
// useAtRuntimeTryAgain(False) is Successor(Zero)
```

This is important! Pattern matching in a dependently typed language can be
thought of as a more powerful form of flow typing that you might see in
languages such as Kotlin or Typescript. That is pattern matching introduces
additional information about various equalities among different values and
types that occur in that branch.

This bears repeating: **pattern matching is the fundamental tool that we use to
tell the compiler more information about which types are equal to each other.**
This makes dependent pattern matching a more powerful tool than in a
non-dependently-typed setting.

## <a id="determining-equality">Determining when types are equal</a>

But to understand this in more detail, we have to understand the phrase "what
type are equal to each other" in more detail. All languages with static type
systems have an implicit idea of what type equality is. For example any static
type checker would reject the following expression because it knows for certain
the `Boolean` and `Shape` are not equal.
```
// Type error
// Circle is type Shape and the compiler knows Shape != Boolean
val thisDoesntWork : Boolean = Circle
```

On the other hand, all statically typed languages have the ability to realize
trivial type equalities.
```
// Luckily our type checker knows that True is of type Boolean and Boolean =
// Boolean so therefore the types for thisDoesWork and True match!
val thisDoesWork : Boolean = True
```

Certain other statically typed languages might allow for very basic computations
on top of types, such as calculating type equality after resolving various type
synonyms, and somewhat more rarely statically typed languages might also allow
for non-trivial type-level computations before calculating type equality.

Dependent types extend this and allow for runtime functions to be used in
computations before calculating type equality. How exactly does this happen?
Well the forms of computation that exist in our language so far are
function application and function evaluation and the only non-trivial bit of
that is pattern matching. So the typechecker must have some way of evaluating
functions. However, we don't always have all the information at compile time to
fully evaluate a function (e.g. a number may be provided as user input). So
instead the typechecker will often only partially evaluate a function.

In particular, if a function appears in a signature, when type checking the
compiler will try to evaluate a function until it reaches an abstract variable
in a pattern match.

Then it will check whether what it has after this evaluation is syntactically
equal or not. If they are syntactically equal then the compiler concludes the
two types are equal. Otherwise the compiler declares it doesn't know whether
they are equal or not. Note that this is not the same as the compiler declaring
that two types are not equal! Due to stuff like the halting problem the compiler
cannot always prove types are equal and sometimes just throws its hands up and
says it doesn't know. It is then up to the programmer to prove that they are
equal.

Don't worry if you didn't quite get that, we'll get to some examples that will
illustrate the idea further. The main idea here is that the typechecker tries to
evaluate functions unti it hits an abstract variable, then it compares for
syntactic equality, and then it comes to one of the following conclusions:

1. Sees that the types are syntactically equal
2. Sees that the types are syntactically different, but that there were
   functions that could not be further evaluated and therefore it doesn't know
   whether the types were equal
3. Sees that the types are syntactically different, but notices that all
   functions have been completely evaluated, and therefore it knows the types
   must be different.

Let's go over some standalone examples of how the typechecker might try to
compare two types for equality.

+ Comparing `Boolean` with `Int`: The typechecker notices that the types are
  syntactically different and that there are no functions in these types.
  Therefore it knows these types are different.
+ Comparing `Shape` with `ShapeOrNumber(False)`: The typechecker evaluates
  `ShapeOrNumber(False)`. It gets to `case boolean of `, which it can further
  evaluate because boolean is set to `False` via the `False` literal whose value
  is known at compile-time. It therefore realizes that `Shape` is equal to
  `ShapeOrNumber(False)`.
+ Comparing `Shape` with `ShapeOrNumber(True)`: The typechecker evaluates
  `ShapeOrNumber(True)`. It gets to `case boolean of `, which it can further
  evaluate because boolean is set to `True` via the `True` literal whose value
  is known at compile-time. It therefore realizes that `Shape` is *not* equal to
  `ShapeOrNumber(True)` because it has evaluated `ShapeOrNumber(True)` to
  `NaturalNumber`.
+ Comparing `Shape` with `ShapeOrNumber(someUnknownValue)`: The typechecker attempts to
  evaluate `ShapeOrNumber(someUnknownValue)`, but it gets stuck on the case
  check `case boolean of` in `ShapeOrNumber` because this time `boolean` is an
  abstract variable whose value is set to `someUnknownValue` which is also an
  abstract value. Therefore it can't access the actual pattern match after 
  `case boolean of` and stops evaluation. Without full evaluation it cannot
  conclude whether `ShapeOrNumber(someUnknownValue)` is equal to `Shape`.
+ Comparing `Shape` with `ShapeOrNumber(someUnknownValue)` where we are in the
  `False` branch of a pattern match somewhere that looks like

        case someUnknownValue of {
            case True => ...

            case False => ... // Where we are
        }

  : The typechecker now knows that `someUnknownValue` is `False` and can evaluate
  `ShapeOrNumber(someUnknownValue)` completely, which alllows it to realize that
  `ShapeOrNumber(someUnknownValue)` and `Shape` are equal.
+ Comparing `ShapeOrNumber(someUnknownValue)` with
  `ShapeOrNumber(someUnknownValue)`: Even though the typechecker cannot evaluate
  either type fully, it sees that they are syntactically identical and therefore
  concludes that they are equal.

## <a id="proving-boolean">Using type equality to prove runtime properties about our code: Boolean edition</a>

So that's a brief look at type equality. Let's see how we can make of use of
that more explictly in our code. First let's return to our very first type
declaration of `Boolean`.

```
type Boolean constructors {
    // The ": Boolean" may look redundant right now, but it will come in handy
    // later when we have more complicated constructors
    True: Boolean
    False: Boolean
}
```

At the time we noted that the `: Boolean` looks redundant and up until now it
really has been kind of redundant. All of our types could've been written
without it and it could've (in theory) been inferred by the compiler. However,
now let's make use of the fact that our constructors have explicit return types.

```
type IsEqual(t: Type, x: t, y: t) constructors {
    // Refl is short for reflexive. As we start to use IsEqual more, you may
    // start to see how usages of Refl are equivalent to the reflexivity
    // property of equality
    Refl(t: Type, x: t): IsEqual(t, x, x)
}
```

The crucial point to see here is that the return value of `Refl` is a
constrained version of `IsEqual` rather than a completely unconstrained
`IsEqual(t, x, y)`.

By having a single value `x` in the argument to `Refl` duplicated in the return
type of `IsEqual`, we constrain `IsEqual`'s `x` and `y` arguments to be equal to
each other in a way that the type checker can see.  `IsEqual` and its analogues
are very fundamental types in dependently typed languages. They allow us to take
the implicit notion of type equality in the "brains" of our type checker and use
an explicit representation of it. And because dependent types allow for runtime
values to exist in types, we can create a type that uses the type checker's
implicit notion of equality to create a compile-time representation of equality
among runtime values!

How does it work? Well let's take it for a spin.

```
val trueIsEqualToTrue: IsEqual(Boolean, True, True) = {
    // Refl(Boolean, True) has type of IsEqual(Boolean, True, True) and so our
    // type checker accepts it as a return value of trueIsEqualToTrue
    Refl(Boolean, True)
}

// This is impossible to create, since Refl(Boolean, True) is of type
// IsEqual(Boolean, True, True) and Refl(Boolean, False) is of type
// IsEqual(Boolean, False, False). We don't have any way of creating a value of
// type IsEqual(Boolean, True, False) or IsEqual(Boolean, False, True)

val trueIsEqualToFalse: IsEqual(Boolean, True, False) = // Impossible
```

This is a pretty cool trick. As we will soon see, this lets us express runtime
properties about our code as type signatures!  So far the properties we've seen
are trivial, namely that `True` is equal to `True`.  Let's move on to a fancier
proposition.

```
// This type signature represents the fact that applying not twice to a Boolean
// returns the same value you started with
function notNotIsIdentity(x: Boolean): IsEqual(Boolean, x, not(not(x))) = {
    // TODO: implement this
}
```

This proposition isn't some masterful insight, but it is at least more complex
than the proposition that things are equal to themselves! Let's see how we can
get the type checker to accept this.

First let's just try stuffing `Refl` there.

```
function notNotIsIdentity(x: Boolean): IsEqual(Boolean, x, not(not(x))) = {
    // Nope this blows up with a type error!
    Refl(Boolean, x)
}
```

The compiler fails to accept that `Refl(Boolean, x)`'s type of `IsEqual(Boolean,
x, x)` can unify with `IsEqual(Boolean, x, not(not(x)))`, that is it can't tell
that `IsEqual(Boolean, x, x)` is equal to `IsEqual(Boolean, x, not(not(x)))`.

You can think of the process as something like the following

```
1. Compare IsEqual(Boolean, x, x) with IsEqual(Boolean, x, not(not(x)))
2. Boolean = Boolean, x = x, now compare x with not(not(x))
3. x has no further function applications so look at not(not(x))
4. not(not(x)) is evaluated via the definition of not (after expanding out both
   nots) to be

    case {
        case x of {
            True => False
            False => True
        }
    } of {
        True => False
        False => True
    }
5. x is an abstract variable in that case expression and so the compiler cannot
   evaluate not(not(x)) any further
6. The compiler cannot prove x to be equal to the nested case expression so it
   cannot prove x to be equal to not(not(x))
7. The compiler cannot prove IsEqual(Boolean, x, x) = IsEqual(Boolean, x, not(not(x))
```

So the compiler was unable to prove that `x = not(not(x))` during the course of
type checking. Note that the compiler was also unable to prove `x !=
not(not(x))` since it was unable to finish evaluating `not(not(x))`. We'll get
back to the `!=` case later, but for now let's return to just `=`.

As humans we know that `not(not(x))` evaluates to `x` for all `x`, so how we can
provide that information to the compiler? Once again the magic ingredient is
pattern matching! Remember that pattern matching provides the compiler with more
information in each branch that is pattern matched that it can then use to
further evaluate functions while type checking.

```
// This definition is accepted by the type checker
function notNotIsIdentity(x: Boolean): IsEqual(Boolean, x, not(not(x))) = {
    case x of {
        True => Refl(Boolean, x)
        False => Refl(Boolean, x)
    }
}
```

That might look weird if you're coming from a non-dependently typed background.
We are ultimately returning the exact same expression, namely `Refl(Boolean,
x)`. How can this type check but not our previous function body? Well the
pattern match gives the compiler that extra bit of necessary information. Let's
look at the `True` branch in greater detail.

```
True => Refl(Boolean, x)
```

On the right-hand side of `True`, the compiler now knows that `x = True`. So
let's run through the same steps we saw before.

```
1. Compare IsEqual(Boolean, x, x) with IsEqual(Boolean, x, not(not(x)))
2. Boolean = Boolean, x = x, now compare x with not(not(x))
3. x has no further function applications so look at not(not(x))
4. not(not(x)) is evaluated via the definition of not (after expanding out both
   nots) to be

    case {
        case x of {
            True => False
            False => True
        }
    } of {
        True => False
        False => True
    }
5. x = True, so now we have

    case False of {
        True => False
        False => True
    }

which evaluates to True.
6. So the compiler now knows that not(not(x)) evaluates to True. It also knows x
   evaluates to True.
7. Therefore the compiler can prove that not(not(x)) = x.
8. Therefore the compiler can prove IsEqual(Boolean, x, x) = IsEqual(Boolean, x, not(not(x))
```

Notice that crucial change in step 5! That extra bit of information that `x =
True` allows the type checker to continue evaluating `not(not(x))` whereas
before it was stuck since `x` was just an abstract variable. This allows it to
fully evaluate `not(not(x))` and `x` and find that they are the same.

The exact same thing happens in the `False` branch, and by adding what might
look like a redundant pattern match, we've helped the compiler prove that
`IsEqual(Boolean, x, not(not(x)))` for any boolean `x`!

Let's have the compiler prove some other things for us.

Note that we previously defined `notNot(x)` which is just the same thing as
`not(not(x))`. Can we express that in code?

```
function notNotIsJustNotTwice(x: Boolean): IsEqual(Boolean, notNot(x), not(not(x))) = {
    case x of {
        True => Refl(Boolean, x)
        False => Refl(Boolean, x)
    }
}
```

Yep just the same thing as before! The only difference is that in each branch of
the pattern match we simultaneously evaluate both `notNot(x)` and `not(not(x))`,
not just `not(not(x))`.

We've seen how pattern matching on ordinary, non-dependent types can introduce
new equality constraints by constraining an abstract variable to a type
constrctor. However, we can also introduce equality constraints among abstract
variables by pattern matching on dependent types.

For example we can pattern match on `Refl` to turn `IsEqual` into equality
constraints the type checker can understand.
```
function equalityIsPreservedForNot(
    x: Boolean,
    y: Boolean,
    xEqualToY: IsEqual(Boolean, x, y)
): IsEqual(Boolean, not(x), not(y)) = {
    case xEqualToY of {
        Refl(unused0, unused1) => 
            // Refl(Boolean, not(y)) would work too
            Refl(Boolean, not(x))
    }
}
```
In the `Refl` branch (which is the only branch), the type checker must unify the
original type of `xEqualToY` with the new one introduced by `Refl`. So in
particular the type checker now knows `IsEqual(Boolean, x, y) = IsEqual(Boolean,
x, x)`. With this constraint, the type checker can further derive the fact that
`x = y`.

So roughly we get the following steps, which results in a successful type check.

```
1. Derive x = y from the pattern match
        
        case xEqualToY of {
            Refl(unused0, unused1) => ... // Matching against Refl introduces
                                          // the constraint x = y
        }

2. Compare IsEqual(Boolean, not(x), not(x)) (type of Refl(Boolean, not(x))) with IsEqual(Boolean, not(x), not(y))
3. Boolean = Boolean, not(x) = not(x), now compare not(x) with not(y)
4. But we know that x = y so therefore the compiler can prove IsEqual(Boolean, not(x), not(x)) = IsEqual(Boolean, not(x), not(y))
5. Therefore Refl(Boolean, not(x)) successfully type checks
```

Given a function type `A -> B` so that e.g. `not` has the type `Boolean ->
Boolean` we can write a more general `function` and implement it in the same
way.

```
function functionsPreserveEquality(
    t0: Type,
    t1: Type,
    x: t0,
    y: t0,
    f: t0 -> t1,
    xEqualToY: IsEqual(t0, x, y)
): IsEqual(t1, f(x), f(y)) = {
    case xEqualToY of {
        Refl(unused0, unused1) => Refl(t1, f(x))
    }
}
```

The steps look much the same, just with more abstract variables:

```
1. Derive x = y from the pattern match
2. Compare IsEqual(t1, f(x), f(x)) (type of Refl(t1, f(x))) with IsEqual(t1, f(x), f(y))
3. t1 = t1, f(x) = f(x), now compare f(x) with f(y)
4. But we know that x = y so therefore the compiler can prove f(x) = f(y) by
   syntactic substitution
5. Therefore the compiler can prove IsEqual(t1, f(x), f(x)) = IsEqual(t1, f(x), f(y))
6. Therefore Refl(t1, f(x)) successfully type checks
```

So far we've seen how to prove that two values are equal to each other. What
about if we want to prove that two values are *not* equal to each other?

Let's introduce a new keyword called `impossible` to our pattern matches. As
we've seen, when pattern matching we introduce new equality constraints for our
type checker. However, if and only if the type checker detects that equality
constraints are self-contradictory, then we are allowed to write `impossible` on
the right-hand side, which will always type check with whatever the overall type
signature is.

```
function onlyIfXAndYAreEqual(
    x: Boolean,
    y: Boolean,
    xEqualToY: IsEqual(Boolean, x, y)
): Boolean = {
    case (x, y, xEqualToY) of {
        (True, False, Refl(unused0, unused1)) => impossible
        (False, True, Refl(unused0, unused1)) => impossible
        (True, True, Refl(unused0, unused1)) => True
        (False, False, Refl(unused0, unused1)) => False
    }
}
```

Let's look at `(True, False, Refl(unused0, unused1)) => impossible` in more
detail. 

```
1. Derive x = True, y = False, and IsEqual(Boolean, x, y) = IsEqual(Boolean, x,
   x). The last one comes from matching on Refl.
2. IsEqual(Boolean, x, y) = IsEqual(Boolean, x, x) implies that y = x
3. But if y = x and x = True and y = False, then True = False
4. This is a contradiction among base constructors of a type and therefore the
   typechecker permits usage of the keyword impossible in this branch
5. impossible also works with any type, in particular impossible unifies with
   Boolean, so this branch fuly typechecks
```

**Note that syntactic equality was enough to prove equality, i.e. the type
checker knows that f(x) = f(x), but syntactic inequality is not enough to prove
inequality, i.e. the typechecker cannot conclude that simply because x and y are
different variable names that x != y.** In order to use `impossible` the type
checker must derive a contradiction among constructors, e.g. `True = False`.

So for example the following function does not type check because it uses
`impossible` incorrectly.

```
function onlyIfXAndYAreEqualBrokenVersion(
    x: Boolean,
    y: Boolean,
    xEqualToY: IsEqual(Boolean, x, y)
): Boolean = {
    // Notice that we fail to match against xEqualToY
    case (x, y) of {
        // The compiler now knows that x = True and y = False, but it cannot derive
        // any contradictions among its equality constraints because it doesn't
        // know x = y since you haven't pattern matched against Refl, so it
        // rejects impossible and this whole thing fails with a type error
        (True, False) => impossible
        // Same thing here
        (False, True) => impossible
        (True, True) => True
        (False, False) => False
    }
}
```

Before we continue, I'm going to introduce a new type, suggestively called
`Contradiction` that has no constructors.

```
type Contradiction constructors {}
```

This means `Contradiction` cannot ever exist since there are no actual values of type
`Contradiction`. Well if you can't actually create a value of type `Contradiction`, how could
you ever return it from a function? Well we just said that `impossible` works
with any type... so what happens if every branch of your case statement ends in
`impossible`? Well then you can use any type, including `Contradiction`.

```
function xCannotBeBothTrueAndFalse(
    x: Boolean,
    xEqualToTrue: IsEqual(Boolean, x, True),
    xEqualToFalse: IsEqual(Boolean, x, False)
): Contradiction = {
    case (x, xEqualToTrue, xEqualToFalse) of {
        (True, Refl(unused0, unused1), Refl(unused2, unused3)) =>
            impossible
        (False, Refl(unused0, unused1), Refl(unused2, unused3)) =>
            impossible
    }
}
// Since impossible matches any type, we could've done
// function xCannotBeBothTrueAndFalse(...): Boolean
// or 
// function xCannotBeBothTrueAndFalse(...): NaturalNumber
// but those are a lot less semantically useful than Contradiction
//
// We'll revisit this with our principleOfExplosion function later
```

Note here that in the first branch `Refl(unused0, unused1)` implies `x = True`
and `Refl(unused2, unused3)` implies  `x = False` so again the type checker
derives the contradiction `True = False` which it can use to validate the usage
of `impossible`.

In fact we can see that the two `Refl`s are enough to derive a contradiction, so
we don't actually need to pattern match on `x` at all.

```
function xCannotBeBothTrueAndFalseNewVersion(
    x: Boolean,
    xEqualToTrue: IsEqual(Boolean, x, True),
    xEqualToFalse: IsEqual(Boolean, x, False)
): Contradiction = {
    case (xEqualToTrue, xEqualToFalse) of {
        (Refl(unused0, unused1), Refl(unused2, unused3)) =>
            impossible
    }
}
```

Hence we can read any function with `Contradiction` as its output type as proving that
all its input types cannot all simultaneously be true, they must contradict each
other.

And indeed, with this interpretation it becomes possible to state that in fact
`IsEqual(Boolean, True, False)` is impossible. By pattern matching on `Refl` we
immediately introduce a contradiction among base constructors, namely `True` and
`False`.

```
function trueCannotBeFalse(
    trueEqualToFalse: IsEqual(Boolean, True, False)
): Contradiction = {
    case trueEqualToFalse of {
        Refl(unused0, unused1) => impossible
    }
}
```

Here's another example.

```
function xCannotBeEqualToNotX(
    x: Boolean,
    xEqualToNotX: IsEqual(Boolean, x, not(x))
): Contradiction = {
    case (x, xEqualToNotX) of {
        (True, Refl(unused0, unused1)) => impossible
        (False, Refl(unused0, unused1)) => impossible
    }
}
```

Unlike `xCannotBeBothTrueAndFalseNewVersion` here we must pattern match on `x`.
By pattern matching on `x` we allow evaluation of `not(x)` to occur, so that we
end up with in the first branch the constraints `x = True` (by pattern matching
on `x`), `not(x) = x` (by pattern matching on `Refl`) and then `not(True) =
True` and finally `False = True`, which is a contradiction in constructors and
allows us to write `impossible`.

Having an explicit `Contradiction` type also lets us nicely write out the
[https://en.wikipedia.org/wiki/Principle_of_explosion](https://en.wikipedia.org/wiki/Principle_of_explosion).

```
function principleOfExplosion(
    proposition: Type, 
    contradiction: Contradiction
): proposition = {
    // Note that an empty pattern match unifies with any return type
    case contradiction of {}
}

// Now, assuming we have a consistent type system, we can't actually create a
// top-level value of `Contradiction`, but perhaps we are in a function that has
// contradictory values passed in.
val someContradiction: Contradiction = ...

val anythingGoes: IsEqual(Boolean, True, False) =
    principleOfExplosion(IsEqual(Boolean, True, False), someContradiction)
```

## <a id="proving-natural-num">Using type equality to prove runtime properties about our code: NaturalNumber edition</a>

Now let's move away from `Boolean`s and make some propositions about
`NaturalNumber`s.

```
function addingZeroOnLeftDoesNothing(x: NaturalNumber): IsEqual(NaturalNumber, x, add(Zero, x)) = {
    Refl(NaturalNumber, x)
}
```

In this case no pattern match is necessary. `add(Zero, x)` is able to
immediately evaluate to `x` because `add` pattern matches on the `Zero` and just
returns `x`. Roughly the steps are as follows.

```
1. Compare IsEqual(NaturalNumber, x, add(Zero, x)) with IsEqual(NaturalNumber, x, x)
2. NaturalNumber = NaturalNumber, x = x, now compare add(Zero, x) with x
3. add(Zero, x) is evaluated via the definition of add to be

    case Zero of {
        Zero => x
        Successor(prev) => Successor(add(prev, x))
    }

   which just becomes x.
4. Therefore the compiler can prove that add(Zero, x) = x
5. Therefore the compiler can prove IsEqual(NaturalNumber, x, add(Zero, x)) = IsEqual(NaturalNumber, x, x)
```

What about the right side?

```
function addingZeroOnRightDoesNothing(x: NaturalNumber): IsEqual(NaturalNumber, x, add(x, Zero)) = {
    // Type error!
    Refl(NaturalNumber, x)
}
```

This doesn't work with `Refl` because now when the type checker goes to evaluate
`add` it needs to pattern match against an abstract variable `x` and therefore
cannot proceed.

```
// Reminder that add looks like this
function add(x, y: NaturalNumber): NaturalNumber = {
    case x of {
        Zero => y
        Successor(prev) => Successor(add(prev, y))
    }
}

// When you have add(x, Zero), we aren't matching against Zero anymore, but an
// abstract x, since Zero is now on the right-hand side

    case x of {
        Zero => x
        Successor(prev) => Successor(add(prev, x))
    }
```

So we need to manually pattern match on `x` at an earlier stage to constrain the
value of `x` for the compiler to successfully evaluate the pattern match.

```
function addingZeroOnRightDoesNothing(x: NaturalNumber): IsEqual(NaturalNumber, x, add(x, Zero)) = {
    case x of {
        Zero => Refl(NaturalNumber, x) // Refl(NaturalNumber, Zero) would also work here
        Successor(x0) => ???
    }
}
```

The `Zero` branch is pretty easy. We can just directly use `Zero` because if the
type checker knows `x = Zero` then it can easily evaluate `add(x, Zero)` to just
`Zero`. However, the `Successor` branch is a bit trickier. We now know that `x =
Successor(x0)`, which is enough for `add` to evaluate once.

Let's walk through how this affects evaluation of `add`.

```
// Again, reminder that add looks like this
function add(x, y: NaturalNumber): NaturalNumber = {
    case x of {
        Zero => y
        Successor(prev) => Successor(add(prev, y))
    }
}

// Let's focus on what happens if x = Successor(x0) and y = Zero

    case (Successor(x0)) of {
        Zero => Zero // Note that the second argument to add was Zero, replacing y here
        Successor(prev) => Successor(add(prev, Zero)) // Again note that the second argument was Zero
    }

// So therefore add(Successor(x0), Zero) just evaluates to

   Successor(add(x0, Zero))
```
However, `Successor(add(x0, Zero))` still isn't syntactically the
same thing as `x` (or `Successor(x0)`) since the compiler knows `x =
Successor(x0)` in this branch)!

We have one trick up our sleeves, which is recursion on
`addingZeroOnRightDoesNothing`. We can call `addingZeroOnRightDoesNothing(x0)`
which has the type `IsEqual(NaturalNumber, x0, add(x0, Zero))`.

That looks pretty promising! If we could somehow use `IsEqual(NaturalNumber, x0,
add(x0, Zero))` to tell the compiler that `Successor(x0) = Successor(add(x0,
Zero))`, we would then be able to fill in that `???`.

```
function addingZeroOnRightDoesNothing(x: NaturalNumber): IsEqual(NaturalNumber, x, add(x, Zero)) = {
    case x of {
        Zero => Refl(NaturalNumber, x) // Refl(NaturalNumber, Zero) would also work here
        Successor(x0) => 
            // Assume we knew the following three things:
            //
            // x = Successor(x0)
            // add(x, Zero) = Successor(add(x0, Zero))
            // Successor(x0) = Successor(add(x0, Zero)) or equivalently Successor(add(x0, Zero)) = Successor(x0)
            //
            // Then we know that x = add(x, Zero) by the following substitutions
            //
            // x = add(x, Zero)
            // Successor(x0) = add(x, Zero)
            // Successor(x0) = Successor(add(x0, Zero))
            // Successor(x0) = Successor(x0)
            //
            // And we could therefore write Refl(NaturalNumber, x) and be done.
            // We already know x = Successor(x0) by pattern matching.
            // We know add(x, Zero) = Successor(add(x0, Zero)) by evaluating add
            // after taking into account x = Successor(x0)
            // So we just need to prove Successor(x0) = Successor(add(x0, Zero))
            ???
    }
}
```

Luckily we have that in the form of `functionsPreserveEquality` that we
constructed earlier.

```
// I'm using a named argument syntax here just to make it clear what arguments
// are what
val desiredEquality: IsEqual(
    NaturalNumber, 
    Successor(x0),
    Successor(add(x0, Zero))
) = functionsPreserveEquality(
    t0 = NaturalNumber,
    t1 = NaturalNumber,
    x = x0,
    y = add(x0, Zero),
    f = function(a) { Successor(a) },
    xEqualToY = // Insert some value of type IsEqual(NaturalNumber, x0, add(x0, Zero))
)
```

So putting that all together we get

```
function addingZeroOnRightDoesNothing(x: NaturalNumber): IsEqual(NaturalNumber, x, add(x, Zero)) = {
    case x of {
        Zero => Refl(NaturalNumber, x) // Refl(NaturalNumber, Zero)
        Successor(x0) =>
            // This is exactly what can go into xEqualToY in desiredEquality
            val recursiveEquality: IsEqual(NaturalNumber, x0, add(x0, Zero)) = 
                addingZeroOnRightDoesNothing(x0)

            val desiredEquality: IsEqual(
                NaturalNumber, 
                Successor(x0),
                Successor(add(x0, Zero))
            ) = functionsPreserveEquality(
                t0 = NaturalNumber,
                t1 = NaturalNumber,
                x = x0,
                y = add(x0, Zero),
                f = function(a) { Successor(a) },
                xEqualToY = recursiveEquality
            )

            // Note that because of pattern matching on Successor(x0) we know
            // x = Successor(x0)
            // This allows add(x, Zero) to evaluate via add(Successor(x0), Zero)
            // to become Successor(add(x0, Zero))
            // 
            desiredEquality
    }
}
```

Let's examine why `desiredEquality` type checks in a little bit more detail.

```
1. We compare IsEqual(NaturalNumber, x, add(x, Zero)) with 

   IsEqual(
       NaturalNumber, 
       Successor(x0),
       Successor(add(x0, Zero))
   )

2. We know x = Successor(x0) by the pattern match.
3. By evaluating add(x, Zero) on x = Successor(x0) we know 
   add(x, Zero) = Successor(add(x0, Zero))
4. Therefore by substituting those equalities we find that our two IsEquals are
   equal
```

Whew that one was a bit of a doozy! It gets easier once you've done a lot of
these and start to develop some intuition.

## <a id="dependent-data-structures">Dependent types in data structures</a>

We've seen so far how we can use dependent types to make assertions about your
code that can be proved in the type system. We can also use dependent types
to create data structures that directly obey some sort of invariant. The most
common example of this is length-indexed vectors. First let's begin with an
ordinary list, which we construct through recursion in the same way we did for
`NaturalNumber`.

```
type List(t: Type) constructors {
    Nil(type: Type): List(type)
    Cons(type: Type, value: type, restOfList: List(type)): List(type)
}

val listOfTwoElements = Cons(Boolean, True, Cons(Boolean, False, Nil(Boolean)))
```

Now we can create a `length` function for this `List` and use it to enforce
certain invariants in other functions.

```
function length(t: Type, list: List(t)): NaturalNumber = {
    case list of {
        Nil(unused) => Zero
        Cons(unused0, unused1, rest) => Successor(length(t, rest))
    }
}

// This is how it's used
val thisWillBeTwo: NaturalNumber = length(Boolean, listOfTwoElements)

function head(
    t: Type,
    list: List(t),
    isNonZeroLength: IsEqual(Boolean, greaterThan(length(t, list), zero), True)
): t {
    case list of {
        Nil(unused) =>
            case isNonZeroLength of {
                Refl(unused0, unused1) => 
                    // We can use impossible here because our earlier Nil
                    // pattern match tells the compiler list = Nil(...) which
                    // allows it to completely evaluate `length` and therefore
                    // `greaterThan` to get 
                    // `greaterThan(length(1, list), zero) = False`.
                    // But then matching against `Refl` gets the constraint
                    // `greaterThan(length(1, list), zero) = True`.
                    //
                    // This contradiction lets us then use impossible.
                    impossible
            }
        Cons(unusedType, value, unusedRest) =>
            value
    }
}

function append(t: Type, list0: List(t), list1: List(t)): List(t) = {
    case list0 of {
        Nil(unused) => 
            list1
        Cons(unusedType, value, restOfList) => 
            Cons(t, value, append(t, restOfList, list1))
    }
}

function appendCombinesLength(
    t: Type,
    list0: List(t),
    list1: List(t),
): IsEqual(NaturalNumber, length(t, append(t, list0, list1)), add(length(t, list0), length(t, list1))) = {
    // Proof omitted for brevity
}
```

Or we could directly encode the length of a list into its type.

```
type LengthIndexedList(t: Type, length: NaturalNumber) constructors {
    // LI for LengthIndexed
    LINil(type: Type): LengthIndexedList(type, zero)

    LICons(
        type: Type, 
        value: type, 
        lengthOfRestOfList: NaturalNumber,
        restOfList: LengthIndexedList(type, lengthOfRestOfList)
    ): List(type, Successor(lengthOfRestOfList))
}

val aListOfOneElement: LengthIndexedList(Boolean, one) =
    LICons(Boolean, True, zero, LINil(Boolean))

// Note that lengthOfRestOfList restricts what restOfList can be
// So e.g. the following is a type error
val thisDoesNotWork: LengthIndexedList(Boolean, one) =
    LICons(Boolean, True, one, LINil(Boolean)) // notice one instead of zero
```

This way we can create an `append` function that directly encodes the fact that
lengths of the lists sum together, rather than relying on a separate
`appendCombinesLength`.

```
function append(
    t: Type,
    lengthOfList0: NaturalNumber,
    lengthOfList1: NaturalNumber,
    list0: LengthIndexedList(t: Type, length: lengthOfList0),
    list1: LengthIndexedList(t: Type, length: lengthOfList1),
): LengthIndexedList(t: Type, length: add(lengthOfList0, lengthOfList1)) = {
    case list0 of {
        LINil(unused) => 
            case lengthOfList0 of {
                Zero => 
                    list1
                Successor(unused) =>
                    impossible
            }
        LICons(unusedType, value, lengthOfRestOfList, restOfList) =>
            case append(t, restOfList, list1) of {
                LICons(t, value)
            }
            LICons(t, value, Successor(lengthOfRestOfList), append(t, restOfList, list1))
    }
}
```

Personally I prefer using `length` over `LengthIndexedList`, but I'll talk more
about that in a future post.

## <a id="data-tagging">Using dependent types as a way of tagging data</a>

Our final examples of dependent types won't introduce anything new, but will
move away from the proof-heavy style I've presented above to a much "lighter"
style that only uses dependent types to tag certain bits of data with additional
information.

This is the style of programming I personally prefer to use when using dependent
types. I'll talk about it more at length in a future post.

```
// Imagine that these constructors are private and cannot be accessed by other
// modules in our code
type Sanitized(s: String) private constructors {
    IsSanitized(s: String): Sanitized(s)
}

// We may have some low-level way of checking whether a string is sanitized or
// not, but we generally won't be using this in other code
private function isStringSafe(s: String): Boolean = {
    // Some implementation here...
}

// This is the main function we'll be using and the only way for other modules
// to create Sanitized data since the constructors are private
function checkIfStringIsSafe(s: String): Option(Sanitized(s)) = {
    case isStringSafe(s) of {
        True => Some(Sanitized(s), IsSanitized(s))
        False => None(Sanitized(s))
    }
}

// Imagine we have this function in another module. Now we're guaranteed that s
// must have been checked for safety at some point before passing it into
// processString.
// You can't ever forget to check the string!
function processString(s: String, stringIsSanitized: Sanitized(s)): SomeCustomType = {...}

val someString: String = ...

case (checkIfStringIsSafe(someString)) of {
    // We don't use the first arguments of Some and None because those are just
    // types. This is similar to how in a non-dependently-typed language when we
    // match on e.g. an Option<Int> type we only match against Some(someInt) and
    // None instead of also matching on the Int generic.
    Some(unused, stringIsSafe) => 
        processString(someString, stringIsSafe)
    None(unused) => // raise some sort of error
}

// Now let's do an example of where the type system tells us we've messed up.

val someOtherString: String = ...

// Note that this is an error! We are checking someString instead of
// someOtherString
case (checkIfStringIsSafe(someString)) of {
    Some(unused, stringIsSafe) => 
        // This is a type error and the compiler would reject this code, because
        // stringIsSafe here is associated with someString, not someOtherString.
        // Dependent types ensure you are checking the correct string, not any
        // old string.
        processString(someOtherString, stringIsSafe)
    None(unused) => // raise some sort of error
}
```

Of course sometimes we can't simply check whether a string is safe or not. We
can only run it through a sanitizer, which might give us a new and different
string. So we can instead just tag the data that comes out of the sanitizer.

```
function sanitizeString(s: String): String = {
    // Some implementation here...
}

function proofOfSanitization(s: String): Sanitized(sanitizeString(s)) = {
    IsSanitized(sanitizeString(s))
}

val someString: String = ...

val sanitizedString: String = sanitizeString(someString)

// No matter how we implement sanitization, as long as the constructors for
// Sanitized are kept private, we always guaranteed that all strings passed to
// processString must have either been checked for or undergone sanitization.
processString(
    sanitizedString,
    // It may look like we're doing redundant work by calling sanitizeString
    // again in proofOfSanitization. I'll talk in a future post about a feature
    // that allows this to be purely a compile-time tag with no runtime
    // performance consequences.
    proofOfSanitization(someString)
)
```

We can encode the latter pattern in a concrete data type called a dependent
pair, where the type of the second element depends on the value of the first, to
"carry around the tag with its value."

```
type DependentPair(t: Type, propType: t -> Type) {
    CreateDependentPair(t: Type, propType: t -> Type, value: t, prop: propType t): DependentPair(t, propType)
}

val sanitizeStringWrapped(s: String): DependentPair(String, Sanitized) = {
    CreateDependentPair(
        String,
        Sanitized,
        sanitizeString(s),
        // Same thing as function(s) { IsSanitized(s) }
        IsSanitized
    )
}

case sanitizeStringWrapped(someString) of {
    CreateDependentPair(unused0, unused1, sanitizedString, proofOfSanitization) =>
        processString(sanitizedString, proofOfSanitization)
}
```

## <a id="why-functional">Why do dependently typed languages tend to be pure functional languages?</a>

This is a question that comes up from time to time and now that we've fully
developed the basics of how to program with dependent types we can explore the
answer. It boils down to the insight that dependent types assume immutability
and function purity.

Let's think back to the crucial fulcrum of dependent types: dependent pattern
matching. We implicitly always assumed that the values we were matching against
were immutable, otherwise it would be incorrect for the typechecker to assume
that the different branches of the pattern match guaranteed what the runtime
value of what we were matching against could be.

```
case someBoolean of {
    True =>
        // Our typechecker now assumes someBoolean is True, but that's not a
        // safe assumption if someBoolean is mutable. Imagine what would happen
        // if someBoolean could suddenly change from True to False here!
        ...
    False => ...
}
```

This means that for most of the places we used dependent types, we implicitly
assumed that the runtime values we were depending on were immutable.

As for function purity, dependent types rely on evaluation of functions at
compile time to be able to type check things in the first place. This would
become rapidly intractable if functions were mutable and so changed their
behavior over the course of typechecking or if they had side effects and could
do all sorts of crazy things as your compiler runs.

It is important to note that the way the typechecker evaluates functions does
not have to be the same way that the the runtime system evaluates the code. For
example, all throughout this post the typechecker has only been ever partially
evaluating functions rather than fully evaluating them, which is usually illegal
for a runtime system to do. You could also imagine that while the typechecker
performs a very naive, step-by-step evaluation of functions, the runtime system
compiles functions into something completely different so that e.g. recursion
turns into loops. You could even imagine different evaluation regimes where the
typechecker lazily evalates functions but the runtime system eagerly evaluates
them.

The only constraint (but it is a big constraint) is that the typechecker and the
runtime system must agree on equality. If the typechecker thinks two things are
equal the runtime system should have no way of distinguishing them. If the
typechecker thinks two things are not equal the runtime system should always be
able to distinguish them. And of course if the typechecker is unable to
determine equality then the runtime system can do whatever it wants.

Otherwise all your proofs about equality and inequality don't mean anything when
your code actually runs.

And so that concludes this introduction to dependent types! The next post will
build upon this understanding of dependent types to talk about their trade-offs
when it comes to production codebases and how to avoid their pitfalls and
capitalize on their strengths.
