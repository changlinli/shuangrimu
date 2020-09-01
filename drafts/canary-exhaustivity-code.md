---
title: Canary Exhaustivity Functions: Making Sure Your Outputs (Not Just Inputs) Cover All Cases
cover-image: Prokudin-Gorskii-25_scale.jpg
author: Rimu Shuang
attribution: 'Public Domain. Shot by Sergey Prokudin-Gorsky. 1910. Originally
from http://en.wikipedia.org/wiki/File:Prokudin-Gorskii-25.jpg.'
subhead: We can get exhaustivity checking for inputs, why not outputs?
tags: haskell
date: 2020-02-24T18:31:00-0500
---

Many modern statically typed languages these days provide facilities for
exhaustively checking that all variants of an input are handled for some
definition of "input." The predominant approach is to use a discriminated union
(i.e. a sum type).

In language-agnostic terms it looks like something like the following:

```
type MyType = 
  (MyInt Int) OR (MyString String) OR (MyOtherString String) OR SomeOtherValue
```

Essentially this means 

Note that the tagging  allows us to
distinguish (the "discrimination" in discriminated union)

In Scala it looks like

```scala
sealed trait MyType
final case class MyInt(int: Int) extends MyType
final case class MyString(string: String) extends MyType
final case class MyOtherString(string: String) extends MyType
case object SomeOtherValue extends MyType
```

In Kotlin it looks like

```kotlin
sealed class MyType
data class MyInt(int: Int): MyType()
data class MyString(string: Sring): MyType()
data class MyOtherString(string: String): MyType()
case object SomeOtherValue extends MyType
```

In Haskell it looks like

```haskell
data MyType = 
  MyInt Int | MyString String | MyOtherString String | SomeOtherValue
```

However, in all of these languages
