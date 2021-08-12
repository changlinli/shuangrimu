---
title: A Language Agnostic Introduction to Dependent Types
cover-image: Prokudin-Gorskii-25_scale.jpg
author: Rimu Shuang
attribution: 'Public Domain. Shot by Sergey Prokudin-Gorsky. 1910. Originally
from http://en.wikipedia.org/wiki/File:Prokudin-Gorskii-25.jpg.'
subhead: 'An explanation of dependent types that assumes only basic familiarity
with any statically typed programming language'
tags: Miscellaneous
date: 2021-05-22T19:27:26-0800
---

"Dependent types" has always been one of those terms that lurks in the
background of various chats about programming that seems to hav

Our pseudocode will be written in a language that's a cross between

```
// This is a comment

/*
 * This is a block comment
 */

/*
 * This is how we create a new type
 *
 * Type constructors are the atomic "building blocks" of our programs. Every
 * non-function expression ultimately evaluates to one of these constructors of
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

type Shape constructors {
    Rectangle(isSquare: Boolean): Shape
    Circle: Shape
    Triangle(isEquilateral: Boolean): Shape
}

// Here's how we declare variables
// Once assigned they're immutable, we'll take more later about why this is
// important
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
```

We can also have the equivalent of generics in other languages, however we're
going to do this in a little different manner.

Here's the first semi-exotic thing that you might not have seen in other
statically typed languages. We have a special "type of types" called `Type`.
Any expression that is a `Type` can be used in a type signature.

This means that we don't have separate generic arguments to type denoted by
angle or square brackets such as `List<Int>` or `List[Int]` that you might find
in other languages. We just use the same round parentheses as usual. This is a
little wordier than the usual treatment of generics, but that's because I'm
intentionally showing you all the machinery and not hiding things behind various
inference mechanisms.

```
// This is similar to an Option<T>, Option[T], or Maybe t type you might find in
// other languages
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

But an explicit `Type` by itself isn't a dependent type quite yet. Here's our
first true dependent type, that is a `Type` that depends on a runtime value.

```
// Again note that capitalizing the first letter of this function is just
// convention, nothing more
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

```
function useAtRuntime(boolean: Boolean): NaturalNumber = {
    // Does this type check?
    // The answer is no, we'll go into a bit more later, but basically the
    // compiler can't evaluate abstract variables so it can't figure out what
    // type ShapeOrNumber(boolean) evaluates to, which is just as well since
    // this can't possibly work if boolean is False
    val result: ShapeOrNumber(boolean) = 1
    result
}
```

The answer is that you must pattern match! Every pattern match gives the
compiler additional information about the runtime value of a variable in that
branch. Then in the branches of your pattern match you can recover literals that
you pass to `ShapeOrNumber`.

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
            val result: ShapeOrNumber(boolean) = 1
            result
        }
        False => 0
    }
}

// useAtRuntimeTryAgain(True) is 1
// useAtRuntimeTryAgain(False) is 0
```

This is important! Pattern matching in a dependently typed language can be
thought of as a more powerful form of flow typing that you might see in
languages such as Kotlin or Typescript. That is pattern matching introduces
additional information about various equalities among different values and
types that occur in that branch.

This bears repeating: **pattern matching is the fundamental tool that we use to
tell the compiler more information about which types are equal to each other.**

This brings me to the subject of type equality. All languages with static type
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
// Luckily our type checker knows Boolean = Boolean!
val thisDoesWork : Boolean = True
```

Certain other statically typed languages might allow for very basic computations
on top of types, such as calculating type equality after resolving various type
synonyms, and somewhat more rarely statically typed languages might also allow
for non-trivial type-level computations before calculating type equality.

Dependent types extend this and allow for runtime functions to be used in
computations before calculating type equality. How exactly does this happen?
Well the only kinds of computation that exist in our language so far are
function application and function evaluation and the only non-trivial bit of
that is pattern matching. So we only need to worry about function evaluation.

If a function appears in a signature, when type checking the compiler will try
to evaluate a function until it reaches an abstract variable in a pattern match.

If after this series of evaluations there are no more function applications left
in either 

Then it will check whether what it has after this evaluation is syntactically
equal or not. If they are syntactically equal then the compiler concludes the
two types are equal. Otherwise the compiler declares it doesn't know whether
they are equal or not (note importantly).

Don't worry if you didn't quite get that, we'll get to some examples that will
illustrate the idea further.

First let's return to our very first type declaration of `Boolean`.

```
type Boolean constructors {
    // The ": Boolean" may look redundant right now, but it will come in handy
    // later when we have more complicated constructors
    True: Boolean
    False: Boolean
}
```

At the time we noted that the `: Boolean` looks redundant and up until now it
really has been kind of redundant. All of our custom could've been written
without it and it could've been inferred by the compiler. However, now let's
make use of the fact that our constructors have explicit return types.

```
type IsEqual(t: Type, x: t, y: t) constructors {
    // Refl is short for reflexive. As we start to use IsEqual more, you may
    // start to see how usages of Refl are equivalent to the reflexivity
    // property of equality
    Refl(t: Type, x: t): IsEqual(t, x, x)
}
```

We are using the trick of having a single value `x` in the argument to `Refl`
duplicated in the return type of `IsEqual`. This constrains `IsEqual`'s `x` and
`y` arguments to be equal to each other in a way that the type checker can see.
`IsEqual` and its analogues are very fundamental types in dependently typed
languages. They allow us to take the implicit notion of type equality in the
"brains" of our type checker and use an explicit representation of it. And
because dependent types allow for runtime values to exist in types, we can
create a type that uses the type checker's implicit notion of equality to create
a compile-time representation of equality among runtime values!

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

This is a pretty cool trick! The type signature of our values and functions are
now logical propositions that expresses a runtime property about our code!  So
far the propositions we've seen are trivial, namely that every value is equal to
itself.  Let's move on to a fancier proposition.

```
// This type signature represents the fact that applying not twice to a Boolean
// returns the same value you started with
function notNotIsIdentity(x: Boolean): IsEqual(Boolean, x, not(not(x))) = {
    // TODO: implement this
}
```

This proposition isn't some masterful insight, but it is at least more complex
than the proposition that all things are equal to themselves! Let's see how we
can get the type checker to accept this.

First let's just try stuffing `Refl` there.

```
function notNotIsIdentity(x: Boolean): IsEqual(Boolean, x, not(not(x))) = {
    // Nope this blows up with a type error!
    Refl(Boolean, x)
}
```

The compiler fails to accept that `Refl(Boolean, x)`'s type of `IsEqual(Boolean,
x, x)` can unify with `IsEqual(Boolean, x, not(not(x)))`.

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
not(not(x))` since it was unable to finish evaluating `not(not(x))`! We'll get
back to the `!=` case later, but for now let's return to equality.

As humans we know that `not(not(x))` evaluates to `x` for all `x`, so how we can
provide that information to the compiler? The magic ingredient is pattern
matching! Remember that pattern matching provides the compiler with more
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
6. Therefore the compiler can prove that not(not(x)) = x.
7. Therefore the compiler can prove IsEqual(Boolean, x, x) = IsEqual(Boolean, x, not(not(x))
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
            // Refl(Boolean, y) would work too
            Refl(Boolean, x)
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
2. Compare IsEqual(Boolean, x, x) (type of Refl(Boolean, x)) with IsEqual(Boolean, x, y)
3. Boolean = Boolean, x = x, now compare x with y
4. But we know that x = y so therefore the compiler can prove IsEqual(Boolean, x, x) = IsEqual(Boolean, x, y)
5. Therefore Refl(Boolean, x) successfully type checks
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
5. Therefore Refl(t1, f(x)) successfully type checks
```

The exact same function body also lets us prove this new statement. The reason
is that `not(not(x))` and `notNot(x)` are both able to evaluate in each branch
of the `case` statement when applied to `True` and `False` and after evaluation
the compiler observes that the results are syntactically identical.

So far we've seen how to prove that two values are equal to each other. What
about if we want to prove that two values are *not* equal to each other?

Let's introduce a new keyword called `impossible` to our pattern matches. As
we've seen, when pattern matching we introduce new equality constraints for our
type checker. However, if the type checker detects that equality constraints are
self-contradictory, then we are allowed to write `impossible` on the right-hand
side, which will always type check with whatever the overall type signature is.

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
detail. The equality constraints the type checker detects are `x = True`, `y =
False`, and then `IsEqual(Boolean, x, x) = IsEqual(Boolean, x, y)` which implies
`x = y`. However, that would imply `True = False`, which the type checker knows
is wrong, so the type checker allows us to insert the `impossible` keyword,
which then unifies with `Boolean` because as we said before `impossible` unifies
with anything, if the type checker detects a contradiction that allows you to
use the keyword `impossible`.

**Note that syntactic equality was enough to prove equality, i.e. the type
checker knows that f(x) = f(x), but syntactic inequality is not enough to prove
inequality, i.e. the typechecker cannot conclude that simply because x and y are
different variable names that x != y.** In order to use `impossible` the type
checker must derive a contradiction among constructors, e.g. `True = False`.

So for example the following function does not type check because it uses
`impossible` incorrectly.

```
function doesntWork(x: Boolean, y: Boolean): Boolean = {
    case (x, y) of {
        // Sure the compiler now knows x = a and y = b but it cannot conclude
        // that a != b
        (a, b) => impossible
    }
}
```

Before we continue, I'm going to introduce a new type called `Empty` that has no
constructors.

```
type Empty constructors {}
```

This means `Empty` cannot ever exist since there are no actual values of type
`Empty`. Well if you can't actually create a value of type `Empty`, how could
you ever return it from a function? Well we just said that `impossible` unifies
with any type... so what happens if every branch of your case statement ends in
`impossible`?

```
function xCannotBeBothTrueAndFalse(
    x: Boolean,
    xEqualToTrue: IsEqual(Boolean, x, True),
    xEqualToFalse: IsEqual(Boolean, x, False)
): Empty = {
    case (x, xEqualToTrue, xEqualToFalse) of {
        (True, Refl(unused0, unused1), IsEqual(unused2, unused3)) =>
            impossible
        (False, Refl(unused0, unused1), IsEqual(unused2, unused3)) =>
            impossible
    }
}
```

Note here that in the first branch `Refl(unused0, unused1)` implies `x = True`
and `Refl(unused2, unused3)` implies  `x = False` so again the type checker
derives the contradiction `True = False` which it can use to validate the usage
of `impossible`.

In fact we can see that the two `Refl`s are enough to derive a contradiction, so
we don't actually need to pattern match on `x` at all.

```
function xCannotBeBothTrueAndFalse(
    x: Boolean,
    xEqualToTrue: IsEqual(Boolean, x, True),
    xEqualToFalse: IsEqual(Boolean, x, False)
): Empty = {
    case (xEqualToTrue, xEqualToFalse) of {
        (Refl(unused0, unused1), IsEqual(unused2, unused3)) =>
            impossible
    }
}
```

Hence we can read any function with `Empty` as its output type as proving that
all its input types cannot all simultaneously be true, they must contradict each
other.

Here's another example.

```
function xCannotBeEqualToNotX(
    x: Boolean,
    xEqualToNotX: IsEqual(Boolean, x, not(x))
): Empty = {
    case (x, xEqualToNotX) of {
        (True, Refl(unused0, unused1)) => impossible
        (False, Refl(unused0, unused1)) => impossible
    }
}
```

Unlike `xCannotBeBothTrueAndFalse` here we must pattern match on `x`. By pattern
matching on `x` we allow evaluation of `not(x)` to occur, so that we end up with
in the first branch the constraints `x = True` (by pattern matching on `x`),
`not(x) = x` (by pattern matching on `Refl`) and then `not(True) = True` and
finally `False = True`, which is a contradiction in constructors and allows us
to write `impossible.

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
    // Notice that it isn't case Zero anymore!
    case x of {
        Zero => x
        Successor(prev) => Successor(add(prev, x))
    }
```

So we need to manually pattern match on `x` for the compiler to help it out.

```
function addingZeroOnRightDoesNothing(x: NaturalNumber): IsEqual(NaturalNumber, x, add(x, Zero)) = {
    case x of {
        Zero => Refl(NaturalNumber, x) // Refl(NaturalNumber, Zero) would also work here
        Successor(x0) => ???
    }
}
```

So the `Zero` branch is pretty easy. We can just directly use `Zero` because if
the type checker knows `x = Zero` then it can easily evaluate `add(x, Zero)` to
just `Zero`. However, the `Successor` branch is a bit trickier. We now know that
`x = Successor(x0)`, which is enough for `add` to evaluate once.

```
    case (Successor(x0)) of {
        Zero => Zero // Note that the second argument to add was Zero, replacing y here
        Successor(prev) => Successor(add(prev, Zero)) // Again note that the second argument was Zero
    }
```
yields `Successor(add(x0, Zero))`. However, that still isn't syntactically the
same thing as `x` (or `Successor(x0)`) since the compiler knows `x =
Successor(x0)` in this branch)!

We have one trick up our sleeves, which is recursion on
`addingZeroOnRightDoesNothing`. We can call `addingZeroOnRightDoesNothing(x0)`
which has the type `IsEqual(NaturalNumber, x0, add(x0, Zero))`.

That looks pretty promising! If we could somehow use `IsEqual(NaturalNumber, x0,
add(x0, Zero))` to tell the compiler `add(x0, Zero) = x0` that would let us
prove that `Successor(add(x0, Zero)) = Successor(x0)` which then lets us fill in
that `???`.

Luckily we have that in the form of `functionsPreserveEquality` that we
constructed earlier.

```
// I'm using a named argument syntax here just to make it clear what arguments
// are what
val desiredEquality: IsEqual(
    NaturalNumber, 
    Successor(add(x0, Zero)), 
    Successor(x0)
) = functionsPreserveEquality(
    t0 = NaturalNumber,
    t1 = NaturalNumber,
    x = add(x0, Zero),
    y = x0,
    f = function(a) { Successor(a) },
    xEqualToY = IsEqual(NaturalNumber, add(x0, Zero), x0)
)
```

So putting that all together we get

```
function addingZeroOnRightDoesNothing(x: NaturalNumber): IsEqual(NaturalNumber, x, add(x, Zero)) = {
    case x of {
        Zero => Refl(NaturalNumber, x) // Refl(NaturalNumber, Zero)
        Successor(x0) =>
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
                xEqualToY = IsEqual(NaturalNumber, x0, add(x0, Zero))
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


