---
title: Extensible unions in Elm
cover-image: Circle_graph_C5.svg
author: Rimu Shuang
attribution: 'David Benbennick with
contributions from Illes, and Koko90. 
<a href="https://commons.wikimedia.org/wiki/File:Circle_graph_C5.svg">Circle_graph_C5.svg</a>. 2010. Public Domain (NOT a CC-BY 4.0 License).'
subhead: Extensible unions happen to be a great fit for Elm!
tags: elm
date: 2020-08-03T00:07:00-0500
---

This is an exploratory post of what extensible unions (a.k.a. polymorphic
variants) might look like in Elm. This mainly a post to plant a seed in the
minds of the collective Elm community and is not a call to action that they need
to be implemented in Elm (although I would really really really love if they
were).

One-line headline: I think extensible unions not only fill in a missing abstract
corner of Elm's type system (rather than being a entirely novel extension to its
type system), but also solve many real-world problems affecting Elm codebases
today, all without compromising and indeed augmenting the Elm compiler's
excellent way of guiding users through refactors.

This post is jumping off a separate post [here](https://discourse.elm-lang.org/t/how-to-represent-many-subsets-of-an-enum/6088/22)
with some folks who were interested in a deeper explanation of extensible
unions/polymorphic variants. 

This post ended up being __really__ long, so I apologize for its length in
advance, but I do hope that people find it useful.

Because of its length I'll just lead off with a high-level summary.

Polymorphic variants or extensible union types are to normal Elm union types
(e.g. `type MyUnionType = UnionVariant0 | UnionVariant1 | UnionVariant2`) what
records and extensible records are to normal Elm product types (e.g. `type
MyProductType = ProductType TypeOfElement0 TypeOfElement1 TypeOfElement2`).

As such they allow for many of the same benefits that records and extensible
records bring to input types of functions and modularizing Elm models, to output
types of functions and modularizing Elm messages and update functions.

This post is split up into the following sections:

+ [What are extensible union types](#what-are-extensible-union-types): A
  introduction to some pseudo-Elm to help familiarize people with what
  extensible unions are. If you already know what extensible unions/polymorphic
  variants are you can skip this. __The crucial take away is that we already
  have the equivalent of extensible unions for products, i.e. extensible
  records. This is just filling in a hole for current union types.__
+ [What are the benefits of extensible unions (the basics)](#what-are-the-benefits-of-extensible-unions): 
  Walking through some basic, contrived cases where extensible unions can come
  in handy.
+ [Everyday Elm cases](#everyday-elm-cases): A non-exhaustive list of case
  studies of where extensible unions can help in code you're likely to see in
  real Elm codebases.
    * Reminding you when you forget certain output cases for decoding
    * Unifying different error types
    * Modular Elm code: Unifying NoMap, OutMsg, and Translator
+ [Drawbacks and things-you-might-think-are-drawbacks-but-aren't (a.k.a.
  literature review of other implementations)](#drawbacks): A dive into some
  cons and not-really-cons of extensible unions as well as how they're
  implemented in other languages (mainly OCaml).

# <a id="what-are-extensible-union-types">What are extensible union types</a>

Let's begin with a very short primer on union (a.k.a. sum types) and product
types. We'll approach them individually even though in Elm we can mix and match
them together in a single type declaration. This hopefully will make some of
the later presentation of extensible union types a little easier to follow.

Union types are those types that express an "or" relationship among its type constructors.

```elm
-- MyColor is Red *or* Green *or* Blue
type MyColor = Red | Green | Blue
```

Product types are those types that express an "and" relationship in its (single) type constructor.

```elm
-- MyUserType is a MyUser that consists of a String *and* another String (maybe
-- a first and last name)
type MyUserType = MyUser String String
```

These two kinds of types are dual, i.e. complements, to one another, where
you'll see each of them playing "opposite" roles in a lot of circumstances.
We've already seen one example here, whereas a union type can have multiple
type constructors, only one of which can be used at any given time for a single
value (i.e. only one of `Red`, `Green`, or `Blue` can be in use for a single
value of type `MyColor`), a product type has a single constructor with multiple
fields, all of which must be filled in for a single value (for any value of
`MyUserType` both strings must be provided to `MyUser`). Notice the
inverted relationship between multiple and single between the two (i.e.
multiple type constructors vs single type constructor and single variant in use
vs multiple fields must all be filled in). This sort of "dual" inversion will
show up a lot more later on.

Even though the two are complements to one another, statically typed
programming languages in general seem to favor product types over union types.
You see this with languages like Java that allow for the creation of product
types (i.e. Java classes), but have no union types. Statically typed FP
languages such as Elm address this imbalance by also allowing union types. This
unlocks a host of data modeling goodies and is the core of how Elm allows us to
create "correct by construction" models that make errors unrepresentable.

Elm, however, goes further than some other statically typed FP languages and
bestows more power to product types through record types and extensible record
types. These essentially are product types on steroids. To see that records are
fundamentally product types, note that you could in theory replace every record
type with a product type, it'd just make for really annoying code because all
of a sudden your fields are all anonymous and position-based.

However, Elm, in a fashion that somewhat echoes Java's choice to disadvantage
union types, doesn't provide equivalent power to union types. The rest of this
post is an exploration in what that might look like if Elm did.

To understand the relationship between extensible union types and normal union
types, it's perhaps illuminating to first consider the relationship between
record types and normal product types.

Notice that Elm records differ from Elm's normal product types by being

1. Structural: Normal product types in Elm are nominal, that is name-based.
  Every product type you use must have been declared somewhere and is given an
  explicit, unique name that is used for typechecking. On the other hand record
  types are anonymous. Though they can be given a name with `type alias` that
  name is non-canonical (the same record type can be given multiple different
  names) and plays no role in typechecking. In other words *the structure of a
  record type is all that matters to the type checker, not its name.*
2. Extensible: Normal product type signatures must specify all possible fields
  it supports. Extensible records only need to specify a subset of fields and
  then leave the others unspecified.

Just to make this clear, here are the three versions of a product type that Elm
supports at the current moment.

```elm
-- Normal Elm product type
type SomeProductType = ProductTypeConstructor Int String

-- Normal Elm record, notice the type alias rather than type
type alias SomeRecord = { field0 : Int, field1 : String }

-- Extensible Elm record, notice the type variable
type alias ExtensibleRecord a = { a | field0 : Int, field1 : String }
```

Extensible union types introduce these two features, namely making a type
structural and extensible, to union types. I find actual code to often be
hepful here, so I'm going to introduce some hypothetical Elm syntax here.

```elm
-- Normal Elm sum type
type User0 = RegularUser Int | AdminUser String

-- Hypothetical extensible union type, again note that this is a type alias
type alias User1 = @RegularUser Int or @AdminUser String

-- Hypothetical extensible union type actually using the extensible portion,
-- note the type variable
type alias User2 a = a or @RegularUser Int or @AdminUser String
```

Let's go over `User1` and `User2` in more detail. Names prefixed with a
an `@` symbol such as `@RegularUser` are extensible union tags. These play an
analogous role to field names in a record type. That is `@RegularUser Int` is
an independent type in the same way `{ field0 : Int }` is an independent type,
rather than just a value like `RegularUser Int`.

```elm
@SomeVariantTag MyType
^ tag name      ^ tagged type

{ recordField : MyType }
  ^ tag name    ^ tagged type
```

Likewise, just like record field names can be used as the value level to
directly create a value, extensible union tags can be used at the value level
to directly create a value.

```elm
someRegularUser : User1
-- Equivalently
-- someRegularUser : @RegularUser Int or @AdminUser String
-- or
-- someRegularUser : @AdminUser String or @RegularUser Int
-- Notice just like for record fields the order doesn't matter
-- This is different from a normal sum type where Result String Int is
-- different from Result Int String
someRegularUser = @RegularUser 0
```

Now we could also have assigned this type

```elm
someOtherRegularUser : @RegularUser Int
someOtherRegularUser = @RegularUser 0
```

or

```elm
lotsOfIrrelevantVariants : @Blah String or @Blahblah Bool or @RegularUser Int
lotsOfIrrelevantVariants = @RegularUser 0
```

For now let's leave aside why all these type signatures work other than to
hand-wave it and say they all make sense if you think of "or". We'll return to
that in just a bit when we look close at extensible types. Instead, let's look
at how to actually work with extensible unions.

Fundamentally the only thing you can do with a product type is pull out its
fields. On the flip side, fundamentally the only thing you can do with a union
type is pattern match on its variants with a case statement.

This remains true for extensible unions, which have their own associated case
statement for pattern matching on them, introduced by `case#` instead of `case`
(you could unify them as a single `case` statement, but I'm separating them for
clarity here).

```elm
toInt : @RegularUser Int or @AdminUser String -> Int
toInt user = case# user of
    @RegularUser x -> x

    @AdminUser str -> length str

-- We still have exhaustivity checking
failsToCompile : @RegularUser Int or @AdminUser String -> Int
failsToCompile user = case# user of
    @AdminUser str -> length str
    -- Compile failure, failed to handle the case of @RegularUser

-- Does compile and is automatically inferred as
-- inferred : @AdminUser String -> Int
inferred user = case# user of
    @AdminUser str -> length str

-- Inferred as
-- inferred1 : @AdminUser a -> a
inferred1 user = case# user of
    @AdminUser a -> a
```

Now let's turn our attention back to the type signatures of
`someOtherRegularUser` and `someRegularUser`.

Now what's the inferred type signature of `@RegularUser 0` if we don't provide
an explicit type signature?

```elm
-- Inferred as
-- yetAnotherRegularUser : a or @RegularUser Int
yetAnotherRegularUser = @RegularUser 0
```

This is similar to what happens with extensible records if they're a function input.

```elm
-- Inferred as an extensible record if input to a function
-- f : { a | field0 : b } -> b
f record = record.field0
```

Notice again the dual relationship between extensible records and extensible
unions! In particular outputs of a function using extensible union types are
inferred by default to be extensible union types. If we think of an Elm value as
a zero-argument function, this also suggests why `yetAnotherRegularUser` is by
default inferred to be extensible.

```elm
-- Inferred as
-- g : b -> a or @RegularUser b
g x = @RegularUser x
```

Since this is our first exposure to the actual extensibility of an extensible
union, let's explain it in a bit more detail. An extensible union type means
that any other extensible union type tags can be put in the type variable and
things will still type check.

```elm
-- Notice unlike g, g0 has a concrete type as an output where a has disappeared 
-- and been filled in by @SomeOtherTag Int
g0 : b -> @SomeOtherTag Int or @RegularUser b
g0 x = g x
```

This is exactly analogous to doing the same thing for extensible record inputs.

```elm
-- Notice that a has been filled in here by someOtherField : Int
f0 : { someOtherField : Int, field0 : b } -> b
f0 record = f record
```

Again, just as for extensible records different functions can all unify with
the same concrete input type, for extensible unions different functions can all
unify with the same concrete output type by "filling in" the type variable.

```elm
-- Again we can think of value as zero-argument functions
user0 : a or @RegularUser Int
user0 = @RegularUser 1

user1 : a or @AdminUser String
user1 = @AdminUser "admin"

thisTypechecks : Bool -> a or @RegularUser Int or @AdminUser String
thisTypechecks bool = case bool of 
    True -> user0

    False -> user1

thisTypeChecksToo : @RegularUser Int or @AdminUser String or @SomeOtherTag Bool
thisTypeChecksToo = thisTypechecks True
```

Indeed with regards to the relationship between inputs and outputs we can say
something even stronger. Extensible records never appear in the output of a
function signature unless that exact type showed up in an input.

```elm
typeInInput : { a | someField0 : Int } -> { a | someField0 : Int }
typeInInput x = x

impossibleFunction : () -> { a | someField0 : Int }
impossibleFunction = Debug.crash "We cannot conjure up an arbitrary a"
```

Analogously, extensible union types never appear in the input of a function
signature unless that exact type shows up in the output.

```elm
typeInOutput : a or @SomeTag Int -> a or @SomeTag Int
typeInOutput x = x

anotherImpossibleFunction : a or @SomeTag Int -> ()
anotherImpossibleFunction = Debug.crash "We cannot match an arbitrary a"
```

Well why is this impossible? Let's return to pattern matching.

```elm
anotherImpossibleFunction : a or @SomeTag Int -> ()
anotherImpossibleFunction x = case# x of
    @SomeTag _ -> ()
    -- Now what do we do? We don't have a tag like @SomeTag that we can use on
    -- an arbitrary a. So we have an incomplete pattern match, which is
    -- disallowed by Elm.
```

We're not allowed to pattern match on `a` because it could be anything so we
can't actually do anything useful with it. You could imagine that you're
allowed to ignore it, e.g. `_ -> ()`, but just as is the case with normal union
types, `_ -> ()` can be thought of as purely syntactic sugar that saves us from
writing out all the other cases when in theory we could've, it just would be
tedious. Because for a generic `a`, we couldn't, in theory, write out all the
other cases, we cannot use `_ -> ()` here.

This is analogous to the situation with why we can't generate an extensible
record as an output because its additional fields could be anything and we
can't generate arbitrary fields on demand.

This concludes the basic nuts and bolts of how to use extensible unions. Now
let's take a look at some use cases.

# <a id="what-are-the-benefits-of-extensible-unions">What are the benefits of extensible unions</a>

At a high level extensible unions generally bring two things to the table:

1. The ability to make a type's size "just right" when a union type is the
  output of a function.
2. The ability to use flat hierarchies of union types rather than being forced
  into nested hierarchies.

These two things may not seem like a lot, but they're actually really powerful!
(Just like how ordinary union types might not seem like a lot vs product types,
but they shape the essence of how data modeling works in Elm). We'll dig into
concrete examples soon, but first a bit of an explanation of what I mean.

What I mean by 1 is that in ordinary union types, the output type of a function
is often "too wide." That is there are values that satisfy the type signature
of the function that the function cannot actually generate. For example, a
pitfall new Elm programmers sometimes fall into is to use `Maybe` too much.

```elm
-- An exaggerated example that people don't do, but illustrative
addOne : Int -> Maybe Int
addOne x = Just (x + 1)
```

`Maybe Int` is too wide of a type for `addOne`. `addOne` never returns
`Nothing`. In fact, not only does it make `addOne` unnecessarily hard to work
with, in a sense it also throws away information, namely that `addOne` can
never actually fail, which means we're going to have an unnecessary and
confusing pattern match on `Nothing` later on (and potentially a lot of code
structured around an entirely impossible error condition).

Now in this case, we can fix things by removing the `Maybe` because it's a
wrapper type with a type variable, but a similar thing can occur for any union
type, and if it's not a wrapper type with a type variable, we can't fix it in
the same way.

Let's look at an example using types from earlier.

```elm
createRegularUser : Int -> UserType0
createRegularUser x = RegularUser x
```

`UserType0` is "too wide" here, since we know we can never get an `AdminUser`.
However, if you call `createRegularUser`, you must now handle `AdminUser` later
on in your code, even if that value can never actually show up.

If we use extensible unions, we can make the function's output size "just right".

```elm
-- We can either give it a concrete type or an extensible type. Often we'll
-- prefer the latter in a function signature for flexibility, just as in the case
-- of input records to functions.
createRegularUser0 : Int -> @RegularUser Int
createRegularUser0 x = @RegularUser x

createRegularUser0 : Int -> a or @RegularUser Int
createRegularUser0 x = @RegularUser x
```

Of course we can always try to get around this in normal Elm by simply nesting
our union types further, e.g. in this case making a separate `RegularUser`
and `AdminUser` types and then tagging them as `Regular` and `Admin` in
`UserType0`.

But this has the same downsides as deeply nested records in normal Elm: baking
in a certain access pattern and forcing tons of wrapping and unwrapping. Which
brings us to number 2.

For number 2, let's look at the following example with normal union types.

```elm
type BasicColor = Red | Green | Blue

type ExtendedColor = Pink | Lime | Aqua

-- Notice that FullColor is a nested hierarchy with two elements at the top
-- that then splits into three elements each, rather than a flat hierarchy
type FullColor = Basic BasicColor | Extended ExtendedColor

highlightColorForCrucialInformation : String -> BasicColor
highlightColorForCrucialInformation str = case str of
    "error" -> Red
    "success" -> Green
    _ -> Blue

highlightColorForNoncrucialInfo : String -> ExtendedColor
highlightColorForNoncrucialInfo str = case str of
    "error" -> Pink
    "success" -> Lime
    _ -> Aqua

highlightStr : Bool -> String -> FullColor
highlightStr isInFocus str = if isInFocus
    then 
        str
            |> highlightColorForCrucialInformation 
            |> Basic
    else
        str
            |> highlightColorForNoncrucialInfo
            |> Extended
```

Again, a nested hierarchy bakes in a single structure on how to arrange these
colors.  If your code needs to arrange those colors in another way, the type
system stops helping you and you can start to make mistakes with extraneous
`Maybe`s in the way.

```elm
type Reddishness = VeryReddish | KindOfReddish

-- I would like to just select `Red` and `Pink`, but I can't and am forced to 
-- make something a `Maybe` simply because `FullColor` is too wide.
reddishness : FullColor -> Maybe Reddishness
reddishness color = case color of
    Basic Red -> Just VeryReddish
    Extended Pink -> Just KindOfReddish
    _ -> Nothing

-- Later on I have to deal with a `Maybe` that has no real reason to exist
```

With extensible unions, we can have a flat hierarchy and take arbitrary subsets
of it instead of being locked-in.

```elm
type alias CustomColor = @Red ()
    or @Green ()
    or @Blue ()
    or @Pink ()
    or @Lime ()
    or @Aqua ()

-- We can choose to break down our types the exact same as before
type alias BasicColor = @Red () or @Green () or @Blue ()

type alias ExtendedColor = @Pink () or @Lime () or @Aqua ()

-- But we can also break it up in more than one way!
type alias Reddish = @Red () or @Pink ()

reddishness : Reddish -> Reddishness
reddishness color = case# color of
    @Red () -> VeryReddish

    @Pink () -> KindOfReddish

-- We can recover our original function as well
reddishnessMaybe : CustomColor -> Maybe Reddishness
reddishnessMaybe color = case# color of
    -- This colon syntax is syntactic sugar for the following:
    -- @Red x -> Just (reddishness @Red x)
    -- @Pink x -> Just (reddishness @Pink x)
    reddish : Reddish -> Just (reddishness reddish)
    _ -> Nothing
```

Just to keep driving home the point that extensible unions are analogous to
extensible records, let's look at the equivalent statements for extensible
records.

1. The ability to make a type's size "just right" when a product type is the
  input of a function.
2. The ability to use flat hierarchies of product types rather than being
  forced into nested hierarchies.

For an example of number 1, see

```elm
-- An ordinary product type
-- The first string is the bird's name, the second string is the bird's
-- species.
type Bird0 = Bird0 String String

-- Bird0 is too "wide" for getLengthOfBirdName, since we only care about its
-- name. It's also unnecessarily tied to the specific type `Bird0` when in theory
-- it works for any product type with a name.
getLengthOfBirdName : Bird0 -> Int
getLengthOfBirdName bird = case bird of
    Bird0 name _ -> length name

-- Extensible records lets us make the input type size "just right"
-- Again notice the duality, extensible records affect the input of a function,
-- extensible unions affect the output of a function
getLengthOfName : { a | name : String } -> Int
getLengthOfName { name } = length name
```

Number 2 is the oft-repeated advice you'll see in Elm to "keep your models
flat." Extensible unions let you "keep your messages flat" which comes with a
lot of the same benefits as keeping your model flat but we'll get to that soon
enough.

Now let's look at some more "real-world" cases that show up all the time in Elm
codebases.

# <a id="everyday-elm-cases">Everyday Elm cases</a>

## Reminding you when you forget certain output cases for decoding

As is hopefully becoming apparent, extensible union types really shine when it
comes to helping wrangle the **output** of a function.

Elm already has exhaustivity checking for the input of a function. This helps
with making sure when we add a new variant to a union we don't forget to add a
new case for encoding that union to, say a string. Unfortunately, because Elm
union types tend to be too "wide" already when they're output types, the Elm
compiler can't remind us to add a new case when decoding (i.e. when the union
is the output of a function).

Elm the language already has, in theory, the ability to check for unused rows in
a record. This was for example implemented in the IntelliJ plugin for Elm (this
was later removed because of some complications with record destructuring
[https://github.com/klazuka/intellij-elm/issues/488](https://github.com/klazuka/intellij-elm/issues/488),
this proposal doesn't have the same record destructuring issues).

Similar functionality can exist for unused variants in an extensible union type,
which allows to make sure that our types are exactly "wide enough," giving us
something analogous to Elm's exhaustivity check on inputs for our outputs.

```elm
type T0 = A | B | C

decodeFromString0 : String -> Maybe T0
decodeFromString0 str = case str of
    "a" -> Just A
    "b" -> Just B
    "c" -> Just C
    _ -> Nothing

type alias T1 = @A () or @B () or @C ()

decodeFromString1 : String -> Maybe (a or T1)
decodeFromString1 str = case str of
    "a" -> Just <| @A ()
    "b" -> Just <| @B ()
    "c" -> Just <| @C ()
    _ -> Nothing

```

```elm
-- Let's edit T0 to add D
type T0 = A | B | C | D

-- Whoops, the compiler has no way of telling us that we need to update
-- decodeFromString0 as well!

-- Now let's edit T1 to add @D ()

type alias T1 = @A () or @B () or @C () or @D ()

decodeFromString1 : String -> Maybe (a or T1)
-- WARN: The inferred type of decodeFromString1 is
-- String -> Maybe (a or A' () or B' () or C' () or D' ())
-- which disagrees with the annotated type
-- String -> Maybe (a or A' () or B' () or C' ())
-- we look like we're missing a D' () in the output, maybe consider adding it as
-- an output value, or restrict decodeFromString1 to an output type of 
-- Maybe (a or A' () or B' () or C' ())
decodeFromString1 str = case str of
    "a" -> Just <| @A ()
    "b" -> Just <| @B ()
    "c" -> Just <| @C ()
    _ -> Nothing
```

## Unifying different error types

Right now when you have many different kinds of errors that can show up in your
Elm code, the usual method is to go with nested error union types, that unify
all the error types under the same names. Apart from the superficial point of
all the annoying boilerplate that this introduces (and all the associated
wrapping and unwrapping required), more problematically this error structure
forces us into contorting the rest of our code into a single, canonical error
structure. This means that our error handlers must mirror the structure of our
error sites and that all our code must throw errors along the same divisions
(i.e. use the same hierarchy).

See for example
[https://discourse.elm-lang.org/t/how-to-represent-many-subsets-of-an-enum/6088](https://discourse.elm-lang.org/t/how-to-represent-many-subsets-of-an-enum/6088).

Here's a complete worked example of what the different error types would look
like (as well as different error handlers) from that post.

```elm
type alias Endpoint1Error = @ResourceNotFoundException ()

endpoint1 : Input1 -> Request (Result (a or Endpoint1Error) Response1)
endpoint1 = ...

type alias Endpoint2Error = @ServiceException ()
    or @ResourceNotFoundException ()
    or @ResourceConflictException ()
    or @TooManyRequestsException ()

endpoint2 : Input2 -> Request (Result (a or Endpoint2Error) Response2)
endpoint2 = ...

type alias ServiceError = @ServiceException ()
    or @ResourceNotFoundException ()
    or @ResourceConflictException ()
    or @TooManyRequestsException ()
    or @InvalidParameterValueException ()
    or @PolicyLengthExceededException ()
    or @PreconditionFailedException ()

type alias ResourceError = @ResourceNotFoundException ()
    or @ResourceConflictException ()

-- Notice these handlers have a different structure than the endpoints! But the
-- compiler still has our back making sure we haven't missed handling any errors
resourceErrorHandler : ResourceError -> String
resourceErrorHandler error = case# error of
    @ResourceNotFoundException _ -> "handled resource not found"

    @ResourceConflictException _ -> "handled resource conflict"

type alias BeingABadUserError = @TooManyRequestsException ()
    or @InvalidParameerValueException ()
    or @PolicyLengthExceededException ()
    or @PreconditionFailedException ()

badUserErrorHandler : BeingABadUserError -> String
badUserErrorHandler = ... -- Imagine something similar to resourceErrorHandler

serviceErrorHandler : ServiceError -> String
serviceErrorHandler error = case# error of
    resourceError : ResourceError -> resourceErrorHandler resourceError

    badUserError : BeingABadUserError -> badUserErrorHandler badUserError

    @ServiceException () -> "AWS seems to be experiencing problems"

-- The free variable a here let's unify with any other error types, saving us
-- manual wrapping and unwrapping
valueFromEndpoint1 : Result (a or Endpoint1Error) Response1
valueFromEndpoint1 = ...

valueFromEndpoint2 : Result (a or Endpoint2Error) Response2
valueFromEndpoint2 = ...

combinedValues : Result 
    -- Note that Endpoint2Error is a strict superset of Endpoint1Error so
    -- Endpoint1Error is complete subsumed
    (a or Endpoint2Error) 
    (Response1, Response2)
combinedValues = map2 Tuple.pair valueFromEndpoint1 valueFromEndpoint2

finalString : String
finalString = case combinedValues of
    Err error -> serviceErrorHandler error

    Ok ( value1, value2 ) -> Debug.toString value1 ++ Debug.toString value2
```

Notice that this would be quite difficult to achieve in the current state of
Elm. In particular, the way we split up the error hierarchy among the error
handlers is in a different way than the way we split up the error hierarchy
among the endpoints. We would need separate type hierarchies for each of these,
plus functions to wrap and unwrap these hierarchies to play nice with each
other.

## Modular Elm code: Unifying NoMap, OutMsg, and Translator

When we have large Elm apps, we're ofen confronted with how we should split up
our Elm code into manageable chunks. Almost always, these conversations center
around how to break up message types and update functions. (N.B. ever notice how
straightforward it is to modularize your Elm model, either by breaking it up or
by using extensible record input types, to the point that there's never a need
to talk about "model modularization patterns?" You have records and extensible
records instead of just vanilla product types to thank for that.)

There's a classic blog post that gets shared around whenever anyone asks about
how to break up updates and messages:
[https://medium.com/@\_rchaves\_/child-parent-communication-in-elm-outmsg-vs-translator-vs-nomap-patterns-f51b2a25ecb1](https://medium.com/@_rchaves_/child-parent-communication-in-elm-outmsg-vs-translator-vs-nomap-patterns-f51b2a25ecb1).

The post talks about three strategies for how to modularize Elm code: NoMap,
OutMsg, and Translator. That post has the details on those approaches, but I'll
briefly summarize the pros and cons here. I'll also add one more, that'll call
YesMap, which refers to the "component-first" approach that uses `Html.map` and
`Cmd.map` all over the place.

* NoMap: Just have a single type for all your messages. Never split it up.
    + Pro: Easy to send messages anywhere
    + Pro: The most straightforward progression from a small, monolithic Elm app
      (no custom architecture needed)
    + Pro: No crazy nesting of message types or wrapping and unwrapping needed
    + Con: Hard to understand what messages a view can actually send from a type
      signature (since every message is a single type)
    + Con: Eventually need to use `_` (or the equivalent of listing every
      message you don't care about) to handle messages from places you don't
      want to handle
    + Con: Communication in general is more implicit and loses the explicitness
      and "if it compiles it works" nature of most other Elm code.
* OutMsg and Translator (the two approaches are different, but the tradeoffs are
  largely similar):
    + Pro: Descriptive type signatures. I know exactly what messages can be
      produced by a view and which
    + Pro: Explicit control flow. The compiler guides me in hooking up all
      the messages and updates in the right place.
    + Pro: True encapsulation if desired. You can publish a submodule as a
      library as-is in a way that you can't for NoMap.
    + Con: You have to explicitly start structuring your code a certain way to
      use OutMsg or Translator, it doesn't "come for free" like NoMap does.
    + Con: Elm compiler messages can start to become "one level removed" from
      what the problem actually is (they start describing the concrete types
      that are wrong when really you want to know e.g. how you applied
      Translator incorrectly).
* YesMap: Break up your message type into a deeply nested hierarchy for each of
  the messages. The classic mini-TEA architecture that showed up early in Elm's
  lifecycle and has since been discouraged for most use cases.
    + Pro: Mainly addresses all the type-safety-related cons of NoMap
    + Con: Html.map and Cmd.map galore. Explicitly discouraged by
      [https://guide.elm-lang.org/webapps/structure.html](https://guide.elm-lang.org/webapps/structure.html)
    + Con: Insane amounts of wrapping and unwrapping. 
    + Con: Bakes in a forced component structure that may not be suitable when
      you want to mix and match portions of a component
    + Con: Medicine worse than the poison: you've gained type safety over NoMap
      at the expense of complex code with multiple indirections

So to summarize, we seem to be stuck between two general approaches. Either give
up some type safety and compiler helpfulness for cleaner code and more organic
growth a la NoMap or try to get back type safety at the expense of heavyweight
architecture choices.

Having extensible unions lets us reconcile these two desires.

```elm
-- BEGIN: Selection submodule

type SelectionElementState = ...

type SelectionElementChange = ...

-- The Int indicates how many drinks we've ordered of this type
type alias DrinkSelectionMsg = @Soda Int or @Water Int or @Juice Int

-- Returns what kind of drink and quantity a user has selected
-- A DrinkSelectionMsg is returned when an actual selection is made
-- Other user actions may trigger other kinds of updates to the element (e.g.
-- mousing over the element may cause it to change color) which result in an
-- @ElementMsg SelectionElementChange message being fired. We can then use
-- SelectionElementChange to update our ElementState
viewDrinkSelectionElement : ElementState -> 
    Html (a or DrinkSelectionMsg or @ElementMsg SelectionElementChange)
viewDrinkSelectionElement = ...

updateDrinkSelectionElement : SelectionElementChange
    -> SelectionElementState
    -> SelectionElementState
updateDrinkSelectionElement = ...

initialDrinkSelectionElementState : SelectionElementState
initialDrinkSelectionElementState = ...

-- END: Selection submodule

-- BEGIN: Top-level module

-- Notice the symmetry! Both your model and your messages are now type aliases
type alias Msg = @ClearMyDrinkSelection ()
    or DrinkSelectionMsg
    or @ElementMsg SelectionElementChange

type alias Model =
    { sodas : Int 
    , waters : Int
    , juices : Int
    , selectionState: SelectionElementState
    }

initialModel : Model
initialModel =
    { sodas = 0
    , waters = 0
    , juices = 0
    , selectionState = initialDrinkSelectionElementState
    }

update : Msg -> Model -> Model
update msg model = case# msg of
    @ClearMyDrinkSelection () -> { model | sodas = 0 , waters = 0 , juices = 0 }

    @Soda n -> { model | sodas = model.sodas + n }

    @Water n -> { model | waters = model.waters + n }

    @Juice n -> { model | juices = model.juices + n }

    @ElementMsg elementMsg -> 
        { model 
        | selectionState = updateDrinkSelectionElement elementMsg model.selectionState 
        }

totalDrinks : { a | sodas : Int, waters : Int, juices : Int } -> Int
totalDrinks { sodas, waters, juices } = sodas + waters + juices

-- Fully expanded it's
-- view : Model -> Html (a or @ClearMyDrinkSelection () or DrinkSelectionMsg or @ElementMsg SelectionElementChange)
-- Note the complete lack of wrapping and unwrapping needed here
-- viewDrink plays nicely with our button because of the extensible type
-- variable parameter
view : Model -> Html (a or Msg)
view model = Html.div 
    [] 
    [ viewDrinkSelectionElement model.selectionState
    , Html.button 
        [ Html.onClick (@ClearMyDrinkSelection ()) ] 
        [ Html.text "Clear drinks" ]
    , Html.text <| "Total drinks: " ++ Int.toString (totalDrinks model)
    ]

-- END : Top-level module
```

Let's review how this would stack up against NoMap, YesMap, OutMsg, and
Translator. We've preserved the pros of the NoMap approach (notice the lack of
Html.map and Cmd.map).  _In particular having a flat message type has given us
many of the same benefits of a flat model type, namely less indirection and lack
of lock-in into a single hierarchy_. On the other hand, because extensible union
type exhaustivity checks are still enforced in `case#` statements, we still have
all the same type safety and "on-the-rails" guiding by the Elm compiler that we
get from the other approaches.

Let's also turn to the usual advice the Elm guide gives us around structuring
Elm apps (I've paraphrased some of them here):
[https://guide.elm-lang.org/webapps/structure.html](https://guide.elm-lang.org/webapps/structure.html).

1. Do Not Plan Ahead
2. Building Modules Around Types
3. Rely on the Elm Compiler to Have Your Back with Refactors
4. Hard Component Divisions Are Unnecessary

NoMap, YesMap, OutMsg, and Translator all fail in various ways to address these
four points. OutMsg and Translator fail at point 1, requiring architectural
changes upfront, rather than arising organically from the usual impulses
programmers have when code starts getting better. NoMap fails at 2. You need a
giant message type for everything that lives in its own file.  NoMap's
compromises around type safety also damage 3. YesMap fails on 4 and makes 2
harder.

Extensible union types give us all four. Even though I chose to give my
selection element a separate model, update, and view function as well as a
distinct message type, that is not a decision I'm locked into.
_It's not an all-in decision, I can pick and choose._ I could easily have undone
any of those choices by simply inlining the function or type wherever it's used.
For example, I could decide that `updateDrinkSelectionElement` doesn't need to
be an independent function and only have the view function
`viewDrinkSelectionElement` or vice versa.  _I have not written additional code
for the sake of architecture, I've simply rearranged existing code._

Therein lies the core benefit that extensible types bring to modularizing large
Elm apps.

__With extensible union types we no longer need named patterns for how to
modularize Elm messages and update functions. Modularizing Elm messages and
updates becomes the same thing as modularizing a normal Elm function: just pull
out a chunk of the message type or update function and give it a name. Done.__

# <a id="drawbacks">Drawbacks and things-you-might-think-are-drawbacks-but-aren't (a.k.a. literature review of other implementations)</a>

So with all this good news, what's the bad news?

First let's lead with things-you-might-think-are-drawbacks-but-aren't. You might
be worried about "fat-fingering" errors that are caught by Elm's compiler for
normal unions, but aren't for extensible unions.

E.g.

```elm
type MyType0 = Hello | Bye

type alias MyType1 = @Hello () | @Bye ()

f0 myType = case myType of
    -- Typo of Hello, caught by compiler as error
    Helo -> "hello"

    Bye -> "bye"

f1 myType = case# myType of
    -- Oh no! This compiles just fine
    @Helo () -> "hello"

    @Bye () -> "bye"
```

However, for the same reasons that this isn't really a problem for field names
with extensible records, this isn't really a problem for extensible unions
either. As soon as you try to use the input type of `f1`, either by providing a
type annotation for it with `MyType1` or trying to pipe a function that returns
`MyType1` into `f1`, the compiler will yell at you, so fat-fingering isn't
really an issue.

Losing exhaustivity checking is also not an issue. I've demonstrated in some
of the previous code examples that `case#` checks exhaustivity just fine if you
provide a type annotation (i.e. it notifies you of missing cases). However, even
if you don't provide a type annotation and forget to handle a case, an analogous
phenomenon to fat-fingering occurs where as soon as you try to use that
function, the compiler will yell at you.

```elm
-- Reusing the previous types

-- Inferred as
-- incompleteFunction : @Hello () -> String
-- Note that because the extensible variant is an input, it is not inferred as
-- `a or @Hello ()` as would be the case if it was an output
incompleteFunction = case# myType of
    @Hello () -> "hello"

-- Inferred as
-- outputFunction : Int -> a or @Hello () or @Bye ()
outputFunction int = case int of
    0 -> @Hello ()

    _ -> @Bye ()

-- Compile error! 
-- Could not match `a or @Hello () or @Bye ()` with `@Hello ()`
incompleteFunction (outputFunction 0)
```

Okay, so what are the problems that you run into with extensible unions? The
first and obvious one is that Elm users now have to learn one more concept. But
what about other programming languages that have implemented them? What problems
have they run into?

OCaml is an FP programming language where extensible unions (they call them
polymorphic variants) are built into the language. And there "Real World OCaml"
(RWO) has some pretty sobering advice
[https://dev.realworldocaml.org/variants.html](https://dev.realworldocaml.org/variants.html).

> In reality, regular variants are the more pragmatic choice most of the time.
> That’s because the flexibility of polymorphic variants comes at a price....
> Variants are most problematic exactly where you take full advantage of their
> power; in particular, when you take advantage of the ability of polymorphic
> variant types to overlap in the tags they support.

So why am I so exuberant about extensible unions in Elm when the OCaml community
seems so cautious about them? This is because in my presentation of extensible
unions I've mirrored Elm's current implementation of extensible records. In
particular I've also limited them (compared to OCaml's implementation), in the
same way that Elm limits extensible records, i.e. disallowing the ability to add
or delete variants to a pre-existing extensible union (likewise Elm's extensible
records cannot add or remove fields).

__By limiting the power of extensible unions in the same way Elm already limits
the power of extensible records, we can sidestep the issues that extensible
variants pose for the OCaml community__. Here it's worth looking at the exact
examples that RWO raises to illustrate some of the problems that RWO is talking
about.

The following is OCaml code:

```elm
(* RWO states the following:
   Catch-all cases are error-prone even with ordinary variants, but they are
   especially so with polymorphic variants. *)
let is_positive_permissive = function
  | `Int   x -> Ok Int.(x > 0)
  | `Float x -> Ok Float.(x > 0.)
  | _ -> Error "Unknown number type"
```

The backtick \` in OCaml plays the same role as `@` does in our earlier
notation. Note that we explicitly cannot have the catch-all case with the
current outline of extensible unions, side-stepping this problem.

RWO talks about greater-than and less-than bounds on polymorphic variants and
attributes much of the drawbacks of polymorphic variants to them. However, those
can only exist if we allow for extensible unions to add or subtract variants
because greater-than and less-than bounds exactly represent variants that have
been added or subtraced within a function.

```elm
weCannotWriteThis : a or @A () or @B () -> a or @B ()
```

If we could write `weCannotWriteThis`, we would need notation to express that
we've removed `@A` from the output of `weCannotWriteThis` and therefore it
cannot show up in any downstream consumers of `weCannotWriteThis`'s output. This
then inexorably leads us to OCaml's polymorphic variant bounds or some
equivalent representation thereof. However, we nip it in the bud by entirely
disallowing the construction of a function like `weCannotWriteThis`!

This also nicely deals with the issue of performance that RWO raises, namely
that OCaml's polymorphic variants can't be compiled to the same efficient
representation its normal variants can. If we remove the ability to add or
remove variant tags the shape of a variant cannot change at runtime, allowing
for the same runtime representation as normal variants. Again this mirrors the
current situation with Elm records, where extensible records pose no runtime
performance penalty.

At the end of the day, the drawbacks of extensible unions are exactly analogous
to the drawbacks of extensible records, because they are the exact analogs of
extensible records. So if Elm as a community is already willing to accept those,
I argue that we've already accepted the same drawbacks of extensible unions.

So that about wraps up my post for extensible unions. Thanks for reading! I hope
it's given the Elm community some food for thought.
