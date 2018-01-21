---
title: The Continuum Hypothesis Part 2 (The Constructible Universe)
cover-image: IMG_6539.svg 
author: Rimu Shuang
attribution: 'Rimu Shuang. "Untitled Photo". Jan 1, 2014. Under a Creative Commons 3.0 Attribution License.'
subhead: "Trying to demystify the continuum hypothesis"
tags: continuum_hypothesis, math
date: 2014-01-01T22:52:22-0500
---

This post is going to be tackling the notion of the constructible (or
definable) universe $L$ and the axiom $V = L$, which intuitively states
that all sets are “definable”, i.e. there is a first-order way of
uniquely stipulating what each set is. The counter-axiom,
$V \supsetneq L$, states that some sets are not definable, that is there
are some sets which may exist, but which we can never uniquely identify
using first-order logic.

Thus, in a certain sense, the axiom $V = L$ is a statement that all sets
are “well-behaved” and can be known, rather than remain forever unknown.
To begin, a subset of a model $M$ is *definable in $M$* if there is a
first-order statement $\phi$ and a tuple of elements from the model
$(a_1, a_2, \ldots, a_n) = \overline{a}$ such that
$\phi(x, \overline{a})$ holds if and only if $x$ is in the subset. We
say that an element $x$ of a model is definable if the subset
$\left\{ x \right\}$ is definable. Finally, given some set $X$, the set
of definable sets is defined (haha) as
$\text{Def}^X = \left\{ Y \subset X \mid \text{$Y$ is definable in $X$} \right\}$

The constructible universe $L$ is then constructed in stages $L_\alpha$
and is indexed by the ordinals where

$$L_{\alpha + 1} = \text{Def}^{L_\alpha}$$

and in the case of limit ordinals, we have

$$L_\lambda = \bigcup _{\alpha < \lambda} L_\alpha$$

. Finally, $L_0 = \emptyset$.

Then the axiom $V = L$ states that
$\forall x \exists \alpha (x \in L_\alpha)$.

It will turn out to be the case that $L_\kappa$ for any limit ordinal
$\kappa$ models $V = L$. I will quickly skim over why such a $L_\kappa$
satisfies ZF.

The fact that it satisfies the Emptyset axiom is immediate as is the
fact that it satisfies Extensionality. It satisfies Pairing due to the
fact that if $\psi$ and $\phi$ each define separate sets in
$x \in L_\alpha$ and $y \in L_\beta$ where $\alpha, \beta < \kappa$, the
pair of those two sets can be defined via $\varphi$ where

$$\varphi(x) := \forall y \in x (\psi(y) \lor \phi(y))$$

and hence $\left\{ x, y \right\} \in L_{\max (\alpha, \beta) + 1}$.

To see that $L_\kappa$ satisfies Union, take an arbitrary set $S$. Let
$\phi$ define the set $S$. Then $\psi (x) := \phi (\bigcup x)$ defines
$\bigcup S$ (note that this works because $a = \bigcup x$ is itself
shorthand for
$\forall z (z \in a \leftrightarrow \exists y (z \in y \in x))$).

Because $L _\kappa$ is a subset of $V$, it must also obey Foundation.
Because $\omega \in L_\kappa$, it must obey Infinity.

Now Powerset and Replacement are slightly more involved to show and so I
will save them for the next post (in addition to actually showing
$V= L$)

For those people who might wonder why I’ve used ZF instead of ZFC, it
turns out that we get Choice if we assume that $V = L$, which I will
explain in a later post as well, so I will not go into showing Choice
here.

Now assuming we’ve shown that $L_\kappa \models ZF$, if we could show
that $L_\kappa \models V = L$, then we would have shown that $V = L$ is
consistent with $ZF$. This ($L_\kappa \models ZF$) may seem immediately
apparent, but there is a little bit of subtlety here. In particular, if
it were the case that $L_\alpha ^{L_\kappa} = L_\alpha$ we would be done
immediately. However, this is not necessarily the case; what happens if
$L_\kappa$ leaves out some of the elements that would otherwise be in
$L_\alpha$? I will save this final step for showing that $V = L$ is
consistent with ZF in the next post as well.
