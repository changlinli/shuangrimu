---
title: Uniform Computability
cover-image: barbed_wire.svg
author: Rimu Shuang
attribution: 'Rimu Shuang. "Untitled Photo". Jan 15, 2014. Under a Creative
Commons 3.0 Attribution License.'
subhead: "Defining what it means for something to be uniformly computable"
tags: computability_theory, math
date: 2014-01-04T18:16:56-0500
---

I’ve been doing a bunch of reading for school and invariably the words
“uniform computability” pop up a lot, but to the best of my knowledge, I
don’t think I’ve actually seen a place where it’s actually been defined.
I’ve yet to see where the notion of uniform computability is defined, so
I’ll take a stab at it here.

Let’s take the simplest example, where we have a set $\mathcal{S}$ of
sets $S_i$. Then say that each set $S_i$ is computable and has a
computable indicator function $\varphi _{S_i} $, although each of these
sets is nice and computable, it may be an actual pain to come up with
the $\varphi _{S_i}$ for each set. It does us very little good to say
that all of these sets $S_i$ are computable, if we can’t find the
computable function associated with each of them.

However, in some circumstances, we can and to describe those
circumstances, we use the term “uniform computability.” Specifically
$\mathcal{S}$ is uniformly computable if the $S_i$ can be computably
enumerated and there is a computable function $\psi$ such that if given
$i$ as an input (where $i$ is assumed to be the computable index), it
can return the Gödel number of the computable program associated with
the indicator function for $S_i$.

More generally, given some computably enumerable set $\mathcal{S}$ whose
elements are each computable, if there is a computable function that
yields the Gödel number of the computable program associated with that
element, then $\mathcal{S}$ is uniformly computable.
