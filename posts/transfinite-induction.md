---
title: Transfinite Induction
cover-image: IMG_0873.svg
author: Rimu Shuang
attribution: 'Rimu Shuang. "Untitled Photo". Jan 23, 2014. Under a Creative
Commons 3.0 Attribution License.'
subhead: "A not finished summary of transfinite induction..."
tags: math
date: 2014-01-23T01:00:08-0500
---

NOT FINISHED: Just to comply with Beeminder's deadlines, getting something out

Before continuing with the constructible universe and $V = L$, it is
first necessary to take a look rigorously at what transfinite induction
is. I won’t prove a lot of what I say here, just lay the formal
groundwork so that we can understand why $V = L$ is in fact a
first-order axiom. Most of the time, it is sufficient to think of
transfinite induction as ordinary induction plus the limit ordinal case.
In other words, if we provide a base case, a successor ordinal case, and
a limit ordinal case, then we’ve shown that something is true for all
ordinals. To put this more rigorously, we’ll start with defining
well-founded relations.

I will use $<$ instead of the more common $R$ to describe the relations
we’ll talk about here because although we not have the property of
transitivity, in most other ways, the relations we’re talking about act
very much like orders. A well-founded relation $<$ on a class $C$ is a
linear relation such that every non-empty set $S$ which is a subset of
$C$ has a $<$-minimal element where a $<$-minimal element in a set $S$
is an element $e$ such that $\forall x \in S(e < x)$ and moreover that
the class $\text{ext} _{<} (x) \left\{ y \in C \mid y < x \right\}$ is a
set (i.e. that $<$ is set-like). We have to define one last term which
is $\text{pred} _< (x) = \left\{ y \in X \mid y TC(\text{<})x \right\}$
where $TC$ is the [transitive
closure](http://en.wikipedia.org/wiki/Transitive_closure) of $<$.

Then transfinite induction put rigorously refers to the theorem that if
$<$ is a well-founded relation on a class $C$ and $X \subseteq C$ such
that
$\forall x \in X (\text{pred}_< (x) \subset X \rightarrow x \in X)$,
then $X = C$. In this case we’ll say that two classes $C_1$ and $C_2$
are equal under a well-founded relation $<$ if for all $x$ in $C_1$, $x$
is in $C_2$ and the sets $S _i = \left\{ y \in C_i \mid y < x \right\}$
are equal and vice versa (switching $C_2$ for $C_1$). To see that this
accords with the informal definition provided at the beginning of this
post, let $C$ be the class of all ordinals. Then what the theorem states
is that if we have a statement such that its truth for all ordinals less
than some ordinal $\tau$ implies its truth for $\tau$, then the
statement is true for all ordinals. Hence this ends up in practice
reducing to just checking that something holds for the next successor
ordinal and then checking that it holds for the next limit ordinal
because every ordinal is either a successor ordinal or a limit ordinal.

Transfinite induction yields transfinite recursion, a method of
constructing mathematical objects beyond normal recursion. The formal
statement is that given a well-founded relation $<$ on a class $C$ and a
function $G: C \times X \to X$, there is a unique function $F: C \to X$
such that
$\forall c \in C (F(c) = G(c, F \upharpoonright \text{pred}_< (c)))$
where
$F \upharpoonright S = \left\{ (x, y) \in F \mid x \in S \right\}$. To
see again how this ends up working in practice, let’s begin with a
slightly less general definition and work through how the Von Neumann
universe $V = \cup _{\alpha \in \text{Ord}} V_\alpha$ is constructed.

1.  $V_0 = \emptyset$

2.  $V_{\alpha + 1} = \mathcal{P}(V_\alpha)$

3.  $V_{\lambda} = \cup _{\alpha < \lambda} V_\alpha$ if $\lambda$ is a
    limit ordinal

Our slightly less general definition of transfinite recursion is the
following: Given an ordinal $\alpha$, for all $\beta < \alpha$ let
$g _\beta$ be a function $\beta \to \text{Ord}$, let $f$ be a function
$\text{Ord} \to \text{Ord}$ and let $G : B \to \text{Ord}$ where
$B = \left\{ g_\beta \mid \beta < \alpha \right\}$. Then there is a
unique $F: \text{Ord} \to \text{Ord}$ such that $F(0) = \alpha _0$,
$F(\beta + 1) = f(F(\beta))$ if $\beta + 1 \in \alpha$ and
$F(\lambda) = G(F \upharpoonright \lambda)$ if $\lambda \in \alpha$.

In the case of the Von Neumann universe, to see how this plays out,
let’s fix some limit ordinal $\tau$. Then for all $\beta < \tau$ let
$g_\beta: \beta \mapsto \beta$ and
