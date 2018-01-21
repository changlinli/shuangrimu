---
title: The Continuum Hypothesis Part 1
cover-image: IMG_4194.svg
author: Rimu Shuang
attribution: 'Rimu Shuang. "Untitled Photo". Dec 8, 2013. Under a Creative
Commons 3.0 Attribution License.'
subhead: "The archetypical math problem independent of modern math axioms"
tags: continuum_hypothesis, math
date: 2013-12-08T20:48:50-0500
---

One of the most famous problems in mathematics whose resolution has been
proved to be independent (i.e. cannot be proved or disproved) of the
foundations of modern mathematics is the Continuum Hypothesis (CH). I’ll
be providing a (hopefully) self-contained treatment of CH in a series of
blog posts here suitable for people who have had some experience with
proof-based mathematics, but may have never taken a set theory course.

The first thing to make clear is what I mean when I say the foundations
of modern mathematics, which I take to be ZFC. ZFC, or “Zermelo-Frankel
with Choice” is a series of axioms which are used for the set theory
which underpins much of modern mathematics. One of the biggest changes
in mathematics in the 20th century as opposed to the 19th was to
reformulate the various branches of mathematics in set theory. As such,
ZFC is now commonly considered the foundations for most of modern
mathematics.

As a matter of notation, now that we are delving into things that might
be considered to be the intersection of logic and mathematics, I happen
to use $a \Rightarrow b$ and $a \rightarrow b$ interchangeably. Some
people use the former for a notion known as “implication” and the latter
for a notion known as the “material conditional.” The former is a
semantic idea (there is a meaningful sense in that one sentence implies
another) and the latter is a syntactic idea (it just so happens,
coincidentally, that when $a$ is true, $b$ is true as well, when $a$ is
false, $b$ is false, and when $a$ is false, $b$ can be anything). For
our purposes the differences are insignificant. It turns out that
something known as the Completeness Theorem in model theory implies that
there is no distinction, at least in the case of first-order logic. I
will also be using the word “set” to refer to objects which fulfill ZFC
axioms and “class” to syntactic objects for which the membership
relation $\in$ makes sense, but which may not be a set. For example the
collection of all sets $V$ is not a set (via ), but it is a class
because the sentence $x \in V$ still makes sense (it simple means that
$x$ is a set). As you can see classes are emphatically *not* formally
defined (at least ZFC) and so I won’t try to give a very rigorous
definition of them since they only serve as a shortcut for describing a
syntactic object.

So before we proceed further let’s define exactly what ZFC is. The
language of ZFC is $\left\{ \in \right\}$, a binary relation symbol. The
axioms of ZFC (i.e. the sentences which make up its theory after
accounting for logical implication) are as follows:

1.  Extensionality:
    $\forall x \forall y (x = y \Leftrightarrow \forall z(z \in x \Leftrightarrow z \in y))$

    In other words two sets are equal if and only if they contain the
    same elements. Note that this is not as trivial as it sounds. In the
    case of mathematical objects with added structure, such as a group,
    it is entirely possible for two groups to contain the same elements,
    but not be the same group because of differences in their group
    operators. Essentially, what this axiom tells us is that sets *have
    no structure apart from the elements they have*. It is this lack of
    structure that makes sets suitable as a foundation upon which to
    construct the rest of mathematics.

2.  Foundation:
    $\forall x (x \not= \emptyset \Rightarrow \exists y \in x \forall z \in x (z \not \in y))$

    All sets are well-founded; that is there is no set $S$ such that
    $x_0, x_1, x_2, \ldots$ where $x_0 = S$ and $x_{i + 1} \in x_i$.

3.  Emptyset: $\exists x \forall y(y \not \in x)$

    There exists at least one set and this set has no elements.

4.  Pairing:
    $\forall x \forall y \exists a \forall z (z \in a \Leftrightarrow (z = x \lor z = y))$

    From any two sets we can construct another set whose elements are
    precisely those sets. In other words, if $x$ and $y$ are sets, then
    we have a notion of ${\{ x, y \}}$ as a set.

5.  Union:
    $\forall x \exists a \forall z (z \in a \Leftrightarrow \exists y (z \in y \in x))$

    If $S$ is a set, then $\bigcup S$ is a set as well. Of note is the
    fact that we *cannot take arbitrary unions*. We have to ensure that
    the things (i.e. the elements of $S$) we are unioning must be able
    to form a set $S$ first.

6.  Powerset:
    $\forall x \exists a \forall y (y \in a \Leftrightarrow y \subseteq x)$

    The powerset of a set is a set.

7.  Infinity:
    $\exists x (\emptyset \in x \land \forall y (y \in x \Rightarrow y \cup \left\{ y \right\} \in x))$

    There exists an infinite set.

8.  Replacement:
    $\forall p_1 \cdots p_n \forall a[\forall y \in a \exists! z \varphi(y, z, p_1, \ldots, p_n) \Rightarrow \exists b \forall z (z \in b \Leftrightarrow \exists y \in a \varphi(y, z, p_1, \ldots, p_n))]$

    Any function which can be defined in the language of set theory
    takes sets to sets. That is if the function’s domain is a set, then
    its image is a set as well. Note that this “axiom” is actually more
    accurately termed an axiom-schema, as it consists of an infinite
    number of axioms, one for each value of $n$.

9.  Choice:
    $\forall x (\forall y \in x (y \not= \emptyset) \Rightarrow \exists f(\text{func}(f) \land \text{dom}(f) = x) \land \forall y \in x (f (y) \in y))$
    where $\text{func}(f)$ is the formal statement that $f$ is a
    function and $\text{dom}(f)$ is the domain of $f$.

    Given a set $S$ of sets $s_i$, there is a choice function which
    takes $S$ as its domain and whose image consists of one element from
    each $s_i$.

The axiom (schema) of Replacement can actually be restated (I will not
prove that this is equivalent) as two axioms (axiom schemas).

1.  Restricted Comprehension:
    $\forall p_1 \cdots \forall p_n \forall a \exists b \forall x (x \in b \leftrightarrow (x \in a \land \varphi(x, p_1, \ldots, p_n)))$

    Given a set $a$, any subclass of that set that I can construct by
    using a first-order formula to restrict membership of elements in
    $a$ is also a set. This is called *restricted* comprehension,
    because I can’t arbitrarily form sets such as
    $\left\{ x \mid x = x \right\}$, but must first preface the set by
    including it in another, previously known set, i.e.
    $\left\{ x \subset y \mid x = x \right\}$ where $y$ is already known
    to be a set.

2.  Collection:
    $\forall p_1 \cdots \forall p_n \forall a (\forall y \in a \exists! z \varphi(y, z, p_1, \ldots, p_n)) \rightarrow \exists b \forall z(\exists y \in a \varphi(y, z, p_1, \ldots, p_n) \rightarrow z \in b)$

    Given a set $a$ and some first-order formula which associates each
    $a$ with a single $z$ (i.e. a function, although I refrained from
    using that term since usually functions are assumed to be sets
    themselves), there is a set $b$ such that the class of all such $z$
    is a subclass.

In order to understand what comes next, we need to introduce just a few
definitions from a branch of mathematics called model theory. A
collection of axioms and their implications is called a “theory.” For a
very simple example of a theory, I might have a theory $T_0$ which
consists solely of the statement “There exists at least one object.” Any
mathematical object which the theory describes (i.e. any object for
which there is an interpretation of the theory that makes the theory
true for that object) is said to be a “model” or “structure” that
“satisfies” the theory.

In our case, any model other than the emptyset satisfies $T_0$.
Similarly, the theory of groups is defined to be all the axioms which
define a group and their logical implications. Hence we could define the
theory of a “horde” of groups to be a theory that stipulates each object
of the horde to be something that satisfies group theory and for there
to be at least an infinite number of objects in the horde.

In a similar fashion, the theory of ZFC defines a “universe” of sets.
More rigorously, a theory is based on a language, which is a collection
of function symbols, relation symbols, and constant symbols. Along with
the standard first-order logical symbols of $\exists, \forall, =, (, )$
and an arbitrary number of variable names and the standard syntactic
rules which govern how these logical symbols can be arranged, these
symbols form the pool of symbols from which all logical statements can
be written. These logical statements, which consist of a finite number
of these language symbols, in turn are known as “formulas.” Any variable
which is preceded at some point by a quantifier ($\exists$ or $\forall$)
is called a “bound variable.” Any formula whose variables (if any) are
all bound is called a sentence.

For example $x = y$ is a formula. $\exists x \forall y (x = y)$ is an
example of a sentence (the one this case stipulates that our universe
consists of a single element). Sentences can be said to be true or
false, formulas, however, cannot. Models, however, can have elements,
which when substituted for variables may or may not make the formula
true. In our example, clearly any model has elements which satisfy
$x = y$ (simply substitute the same element for both $x$ and $y$).
However, not many models satisfy $\exists x \forall y (x = y)$ (satisfy
in this case meaning that the sentence is true in this model).

Now the crucial trick to the continuum hypothesis is that there are many
possible models which can satisfy the axioms of ZFC. The existence of
infinitely many models of set theory is a deep result that stems from
something called the [Lowenheim-Skolem
Theorem](http://en.wikipedia.org/wiki/Lowenheim-Skolem_theorem), which
states that theories written in first-order logic cannot specify the
cardinality of the models that satisfy the theory. If an infinite model
satisfies the theory, then for every infinite cardinal there is a model
of that cardinality which satisfies that theory.

So how do we end up proving the independence of the continuum
hypothesis? The general outline of the proof that the continuum
hypothesis cannot be *disproved* within ZFC is as follows:

1.  Construct a model of ZFC (call it $L$), which is constructed by
    definable sets.

2.  Show that the axiom $V = L$, i.e. that all sets are definable, is
    consistent with ZFC

3.  Show that assuming $V = L$ we can prove the continuum hypothesis

To prove the other direction, namely that the continuum hypothesis
cannot be *proved* within ZFC we generally turn to a concept called
“forcing.” Forcing can be used to prove that the continuum hypothesis
cannot be *disproved*, but the machinery that we develop in the $V = L$
approach is useful in forcing so generally forcing is only used in this
one direction. Forcing in the case of the continuum hypothesis involves
the following:

1.  Construct a model of ZFC (for which we can again use a variant of
    $L$)

2.  Construct a map from $2^{ \omega }$ to $\omega _n$ for some chosen
    $n > 1$ (it turns out we can choose any $n$). Note that this map is
    not be in our original model of ZFC.

    1.  Take all finite restrictions of this hypothetical map; because
        these are finite, they must be in $L$. Together, they also
        uniquely identify a single map (simply take their union). This
        class (note that this collection is *not* a set in our model of
        ZFC, otherwise by the Axiom of Union we would already have our
        map) of finite restrictions is known as a *generic*.

    2.  Enlarge our model of ZFC to include this class as a set.

3.  Make sure the map we constructed and added as a set to our model
    didn’t, as a side effect, cause $\omega _n$ to turn into $\omega _1$
    (otherwise we would have only proven $2 ^{\omega}$ is the same as
    $\omega _1$. In other words we want to show that we *preserved
    cardinals*.

4.  Then we will have a map from $2 ^\omega$ to $\omega _n$ and
    everything between $\omega$ and $\omega _n$ is thus a counterexample
    to the continuum hypothesis.

Now that we have a gameplan of how to go about proving the independence
of the continuum hypothesis, next week we’ll begin by constructing $L$.
