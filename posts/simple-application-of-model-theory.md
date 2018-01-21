---
title: Simple Application of Model Theory
cover-image: IMG_3709.svg
author: Rimu Shuang
attribution: 'Rimu Shuang. "Untitled Photo". Nov 24, 2013. Under a Creative
Commons 3.0 Attribution License.'
subhead: Yeah right... we'll see
tags: math, model_theory
date: 2013-11-24T23:31:24-0500
---

Recently I’ve been taking a class in model theory and my undergraduate
thesis will probably touch on model theory in some way. As such I’ve
decided to write a little about *why* anybody should care about model
theory.

First off, model theory is a branch of mathematics that straddles the
boundary between logic and math. Most model theory deals with [first
order logic](http://en.wikipedia.org/wiki/First-order_logic) and what
kind of mathematical *structures* satisfy certain first-order
statements. In essence model theory is built around the idea of
*differentiating what can be said about a mathematical structure from
the mathematical structure itself*. Of course we usually modify “what
can be said” to say “what can be said within first order logic” because
the philosophical question arises of whether mathematical structures
exist independently of whether we are able to describe them. Although
model theory does crop up in philosophy, for now we can avoid this
(which is too philosophical and mystical for my taste) path of inquiry.

Now, even for most other branches of math, studying the very logic
systems that gird mathematics seems a bit of overkill. After all,
questions of the merits of first-order logic, the restrictions that such
logics impose on us, and the study of general mathematical structures
seems too abstract even for much of mathematics.

Instead to show the power of model theory, it is useful to consider an
example which our professor showed us on the first day of our class and
which will be the topic of this post (note that as a result I *did not
come up with this example*). Euclid, the famous Greek mathematician, had
a series of geometric postulates as follows:

1.  Between any two points there can be drawn a line.

2.  Any finite line segment can be extended infinitely in both
    directions.

3.  Any circle can be described by a center and a radius.

4.  All right angles are equal to each other.

5.  (Parallel Postulate) Given any line $L$ and point not contained in
    the line, there exists exactly one line which is parallel to $L$.
    Note that this is not Euclid’s original axiom, but it turns out to
    be logically equivalent.

Following the spirit of Euclid and the conditions that the
mathematicians investigating these postulates were under, I won’t
attempt to provide very rigorous definitions of what these mean. Instead
I’ll just provide a short note to say that two lines are parallel if the
minimum distance from one point $p$ of one line to the points on the
other line remains constant for any choice of $p$.

For several millennia, it seemed that Euclid’s parallel postulate should
be provable from the other four, mainly based off an intuition that the
fifth postulate was more “complicated” than the others, especially since
the other four seemed more to be definitions and the parallel postulate
seemed to be more of a theorem. Some people might be thinking right now,
“ah ha hyperbolic geometry is the counter-example!” And they would be
right, but it turns out that the thought process behind proving the
independence of the parallel postulate is an archetypical example of the
thinking that drives model theory.

Model theory concerns itself first with “theories,” sets of “sentences”
which are in turn, roughly, syntactically valid collections of symbols
drawn from some agreed upon language. The second object that model
theory concerns itself with is the mathematical structures which fit
within the constraints of some given theory. Such a structure is said to
“satisfy” the associated theory. So for example if I have a theory that
consists of the single sentence “This structure must have an element,”
then any mathematical structure except the empty set satisfies this
theory. Likewise, if I have a theory that consists of the group axioms,
then any group satisfies this theory.

In this way model theory sort of turns traditional mathematical theories
on top of their heads. Normally we think of a mathematical theory such
as field theory to define a set of mathematical objects which we then
call “fields.” Model theory, on the other hand, presupposes the
existence of fields and says that instead it just so happens that they
satisfy a theory that we then call “field theory” (well it is possible
to take a
non-[Platonist](http://plato.stanford.edu/entries/platonism-mathematics/)
view, but this is generally the easiest).

Thus, while traditionally it doesn’t make too much sense to ask what
mathematical objects satisfy, say, the axioms of set theory, e.g.
[ZFC](http://en.wikipedia.org/wiki/Zermelo-Fraenkel_set_theory), since
we usually specify the theory first and then say everything defined by
this is a “set.” It turns out that there are many different models of
set theory (i.e. there are different notions of exactly what constitutes
the universe of sets, even under ZFC). I’ll save that discussion for
another time though.

Turning back to our theory at hand, namely the Euclidean postulates, if
we are able to find a mathematical structure which satisfies the first
four postulates, but does not satisfy the parallel postulate, then we
know that the parallel postulate must be logically independent of the
other postulates, i.e. the other postulates cannot prove the parallel
postulate. If they could prove the parallel postulate, then every
mathematical structure we could find that satisfied the first four
postulates must then also satisfy the parallel postulate.

And that is where hyperbolic geometry comes in. In fact, however, there
is an even simpler example of a mathematical structure which satisfies
the first four postulates, but does not satisfy the last postulate. We
can use the sphere and define lines as great circles on our sphere and
points as points on the surface of the sphere.

We can verify each of the postulates one by one.

1.  Any two points on the surface of a sphere can be connected by a
    great circle.

2.  Any arc of a great circle can be extended into an entire great
    circle (let’s call the length of a great circle infinite).

3.  Circles can be defined as projections of a circle in a plane on the
    spherical surface.

4.  Right angles are indeed all equal.

5.  The parallel postulate does *not* hold because given any two great
    circles, they must intersect at some point.

Hence via a simple application of model theory, we’re able to solve a
problem that plagued mathematicians for thousands of years. Yay model
theory!
