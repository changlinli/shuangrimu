---
title: SMBC and 2 + 2
cover-image: 2_plus_2_crop_black.png
author: Rimu Shuang
attribution: 'Zach Weinersmith. ["Untitled Comic"](http://www.smbc-comics.com/?id=3227). Jan. 2, 2014. Under a [Creative Commons Attribution-Share Alike Unported 3.0 License](http://creativecommons.org/licenses/by-sa/3.0/) (NOT a CC-BY 3.0 License).'
subhead: Thoughts on 2 + 2 from SMBC
tags: math, peano_axioms, smbc, xkcd
date: 2014-01-06T01:26:05-0500
---

__Awesome! He let me use the original comic as the cover image. Thanks!__

The web comic Saturday Morning Breakfast Cereal came out with [this
comic](http://www.smbc-comics.com/?id=3227), which presented a hilarious
cute child unfortunately asked to prove that $4$ is the unique answer to
$2 + 2$. Luckily, for the child, he or she (it’s rather difficult to
tell) could probably have just said “because.” The question of why
$2 + 2$ is really a definitional one; that is because Peano addition of
the natural numbers is a function from
$\mathbb{N} \times \mathbb{N} \to \mathbb{N}$, by definition all finite
sums are unique.

A quick look at the [Peano
axioms](http://en.wikipedia.org/wiki/Peano_axioms) is sufficient to see
why this is the case. In particular because addition $a + b$ is defined
recursively on $b$ such that $b$ decrements by $1$ each time and each
number consists of a finite number of applications of the successor
function ($\sigma$) on zero, we get as an end result that $a + b$ is
$\sigma \circ \sigma \circ \cdots \circ \sigma (x)$ which is a unique
natural number.

However, we should be quick to point out that we have only shown that
addition is unique up to isomorphism. This is because the successor
function is *not* unique, but only unique up to set isomorphism. In
particular, if I happened to label two particular natural numbers $x$
and $y$, there might be one successor function that maps $x$ to $y$ and
another that doesn’t. Of course, “labeling” the natural numbers without
the aid of the successor function is usually irrelevant to what we’re
studying, so for all intents and purposes addition is unique.

Disregarding the math, perhaps the easiest practical demonstration that
addition is a function and hence $2 + 2$ has a unique answer is that you
can code it in Haskell as below.

    data Natural = Zero | Succ Natural deriving (Show)

    (-+-) :: Natural -> Natural -> Natural
    x -+- Zero = x
    x -+- (Succ y) = Succ (x -+- y)

Unfortunately, apparently [nobody uses
Haskell](http://www.xkcd.com/1312/).
