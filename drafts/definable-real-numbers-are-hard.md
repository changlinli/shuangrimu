---
title: Defining definable real numbers is hard
cover-image: Prokudin-Gorskii-25_scale.jpg
author: Rimu Shuang
attribution: 'Public Domain. Shot by Sergey Prokudin-Gorsky. 1910. Originally
from http://en.wikipedia.org/wiki/File:Prokudin-Gorskii-25.jpg.'
subhead: People like 
tags: haskell
date: 2020-03-30T16:41:00-0500
---

Definable real numbers showed up a few weeks ago in a post on Hacker News.

It seemed interesting enough and garnered some discussion. However, it had a
fatally flawed conception of them. This conception shows up in a lot of places
so I'll address it here.

First let's start with the initial argument. The definable real numbers are
those real numbers which can be uniquely defined by some description. A
description is a finite collection of words. The set of all finite collections
of words is a countable set. The real numbers are uncountable. Hence there are
(uncountably many) real numbers which are not definable.

Seems solid enough right?

But what if I told you it's possible that every real number is definable?

Joel Hamkins' has a great exposition of this
[here](https://mathoverflow.net/questions/44102/is-the-analysis-as-taught-in-universities-in-fact-the-analysis-of-definable-numb).
However, his explanation may be a bit complex and technical for people
unfamiliar with model theory.

I'll attempt to bridge the gap between understanding the naive argument I've
presented above and Hamkin's answer.

I'll mainly be aiming for intuition here rather than rigor. There's just not
enough space in a single post to handle all the rigor necessary.

The heart of the matter is that the word "definable (in ZFC)" is a fundamentally different
word than the words "real number," "countable," and "set." The latter three are
all formalizable in ZFC. Being "definable" (i.e. being definable in the language
of ZFC) is not formalizable within ZFC. Indeed the statement "definable within a
formal system A" is not a statement that can be expressed in A!

There's a formal argument that we can make here, but I'll make an informal one
instead. Let $DR$ be the set of definable real numbers. Then its complement
within the real numbers is $NDR$, the non-definable real numbers. Take the least
element of $NDR$. This well-defined and a single number. Therefore it belongs in
$DR$. Hence we have a contradiction.

Note that this does not mean that all hope is lost. Definable as a unique
element with ZFC is a perfectly fine definition in a system that is richer than
ZFC. We just can't define this notion of "definable" within ZFC itself. Even
within ZFC we can still salvage something. While the general notion of definable
cannot be expressed in ZFC, we can express each instance of what it means to be
definable relative to a single statement within ZFC within ZFC. That is given a
single formula $F$ with a free variable $x$ in the language of ZFC, we can
express the statement "there is only one $x$ that satisfies $F(x)$." We simply
cannot quantify over all $F$ "at once" in a single statement within ZFC which
prevents us from saying something like "there is an F such that there is only
one $x$ that satisfies $F(x)$".

But here's an interesting fact. It is possible that for every element $x$ in the
universe of ZFC, there is a corresponding formula $F$ so that $x$ is the only element
satisfying $F$. In particular this means that for every real number there is a
corresponding finite formula $F$ that uniquely defines it!

How's that possible? I aim only for a hand-wavy sketch here and omit all proofs.
See the referenced paper in Hamkins' answer for a rigorous explanation.

First, let's start off with an extremely quick introduction to model theory. It
is often useful when examining axiomatic systems to distinguish between the
axioms (the theory) and the mathematical object satisfying those axioms (the
model).

For example the axioms that define what it means to be a group form a theory.
Each concrete example of a group (e.g. the integers under addition) is then a
model of that theory.

This same division can be applied to ZFC, the common purported axioms underlying
most of modern mathematics. There is ZFC itself, i.e. the theory, and then various
"universes" of sets that satisfy ZFC, i.e. the model.

Let's step through this in a little bit more detail with a simple illustration.
ZFC is a bit complicated for our purposes so we'll have an extremely cut-down
version of it that we'll call $T$. $T$'s axioms are as follows

+ Axiom of Extensionality: Two sets are equal if they have the same elements.
+ Axiom of the Empty Set: The empty set ($\emptyset$) exists which contains no
  elements.
+ Axiom of Single-Element Sets: If a set exists, then the set containing it as its only element also exists.
+ Axiom of the Pair of Empties: The set $\{ \emptyset, \{ \emptyset \} \}$ exists.

These axioms are rather bare and unsuitable for producing introducing
interesting theorems, but we can get some uninteresting ones out of them.

Theorem: The set $\{ \{ \emptyset \} \}$ exists.

Proof: Apply the Axiom of Single-Element Sets twice to the Axiom of the Empty
Set.

Note that our usual universe $U$ of sets that we usually think of when we think
of ZFC and the world of mathematics fulfills these axioms. That's the world
that's contains the natural numbers, the power set of the natural numbers, etc.

However, there are much more restricted universes which also fulfill these
axioms. In particular there are _sets_ in our usual universe which can be models
of these limited axioms. See for example the set 

$X = \{\{ \emptyset \}, \{ \{ \emptyset \} \}, \{ \{ \{ \emptyset \} \} \} \ldots\} \union \{ \{ \emptyset, \{ \emptyset \} \} \}$

Note that this entire set $X$ is a model of our theory. It is also an element of
$U$. That means that, considered, as a model of $T$, $X$ is not itself a set,
only its elements are, in the same way that our usual universe of all sets is
not itself a set.

That is $X$ is a sort of mini-universe of sets, while itself being only a single
element in a larger universe of sets. $X$ is a little bit peculiar. Apart from
being much sparser and smaller than $U$, it has a different notion of what the
empty set is. In $X$, $\{ \emptyset \}$ is in fact the empty set, because there
are no other elements in $X$ that are elements of $\{ \emptyset \}$ (since $X$
doesn't contain $\emptyset$).

Nonetheless, both $X$ and our larger universe of sets must satisfy every theorem
provable from $T$'s axioms. And indeed $X$ does contain the set $\{ \{ \emptyset
\} \}$! Or at least $X$ contains a version of it. There's an extra level of
nesting because $X$ thinks that $\{ \emptyset \}$ is the empty set. What we've
shown here is the ability for our universe of sets to introspect itself.

Our universe satisfies $T$. However, one of the elements of our universe (namely
$X$) itself also satisfies $T$. This is rather powerful because we can prove
facts about our universe and its relationship to $T$ by examining the properties
of $X$.

It is also worth emphasizing that nonetheless $X$ and our normal universe are
very different! For example, we give the following (very bare-bones) definition
of something resembling a function. Given two sets $A$ and $B$, we say $A$ is
mappable to $B$ if there is a set $C$ that is equal to the pair $\{ A, B \}$.

Remember that in the world of ZFC, everything is a set, including functions! So
we're just trying to formalize, in a very bare-bones manner, when a function
between two sets exists.

Given the definition of mappable, we say that a set $A$ is emptyable if it is
mappable to $\emptyset$.

Now in the model of $T$ as presented by $X$, there is only one set that is
emptyable, while in $U$ all sets are emptyable. This indicates whether any set
that is not $\{ \emptyset \}$ is emptyable is independent of the axioms of $T$.

Perhaps more interestingly, while $X$ and $U$ both agree that the Axiom of the
Pair of Empties holds, the sets that $X$ thinks are used in the axiom are not
the same sets that $U$ thinks are used.

What $X$ thinks is $\emptyset$ is what $U$ thinks is $\{ \emptyset \}$, since no
elements of $X$ are themselves elements of what $U$ thinks is $\{ \emptyset \}.
And what $X$ thinks is $\{ \emptyset \}$ is therefore what $U$ thinks is $\{ \{
\emptyset \} \}$.

So we have a situation where $X$ and $U$ both agree on a statement, but
disagree on its interpretation.

Alright with that in mind let's turn our attention back to ZFC.

The following is non-obvious and would take a while to prove so I'll just state
it by fiat. This introspection is also possible with ZFC. That is within our
universe of sets, there is a single set (in fact there are many) which itself,
when considered as its own universe of sets, satisfies ZFC.

Just as before, given some universe of sets $U$ satisfies ZFC, we have a set $X$
such that $X$ is a member of $U$ but is itself a valid model for ZFC as well.

Perhaps even more bizarrely, $X$ can be countable!

Now how can that be? The real numbers can be formalized with ZFC which means
that every real number must be an element of $X$. Moreover we know that we can
prove within ZFC that the real numbers are uncountable, so how can $X$ be
countable?

Well in the same way that when we were examining $T$, both $U$ and $X$ agreed
that the Axiom of the Pair of Empties was true, but disagreed on what
$\emptyset$ actually was, here $U$ and $X$ both agree with the statement "the
real numbers are uncountable," but disagree on what the real numbers actually
are and what it means to be countable.

Let's assume for now that $U$ and $X$ both agree on the natural numbers (which
does not necessarily have to be true). $X$ might then present a set which it
calls the "real numbers" and claim that there is no injective map from its real
numbers to the natural numbers. However, all that means is that this injective
map (remember functions are ultimately sets in ZFC) does not exist in $X$. $U$
might in fact actually contain this map as an element and therefore from $U$'s
perspective what $X$ calls the "real numbers" actually form a countable set and
are therefore not what $U$ calls the "real numbers."

So we've now explained how a countable set $X$ can act as a model for ZFC. I now
claim that is also possible that every element of $X$ to be definable within
ZFC. I won't prove this, because it's hard and Hamkins does that. However, I
hope that it's at least plausible because $X$ can be countable.

There's an important distinction here to be made between countability and
definability. Countability, as we've explored, is relative to a given model.
However, definability is not, at least not in the same way. Because definability
itself cannot be defined in ZFC, we are forced to rely on a stronger meta-system
that can define definability. This stronger meta-system then defines
definability in a way that is absolute across all its models of ZFC. So while we
might say that relative to $X$ or relative to $U$ a set is countable or
uncountable, we must say in an absolute sense whether a set is definable,
because neither $X$ nor $U$, using the language of $T$, can state that a set is
definable.

Hamkins' answer shows that given this absolute notion of definability, there is
a model of ZFC where every element is definable.

But after all this you might still be left with a nagging sense that I've pulled
a trick over you. After all, by claiming that every element and in particular
every real number of $X$ is definable, haven't I given a function from the real
numbers to the natural numbers? Take each finite description associated to each
real number, encode it as a natural number, and voila, we have a mapping of the
real numbers to the natural numbers. And sure maybe this mapping doesn't exist
in $X$ or even $U$, but it exists in our meta-system! And there are definitely
more real numbers than natural numbers, so we must at some point run out of
descriptions!

But this is the thing, the cardinality of a set is a set-theoretic concept that
relies only on functions. The intuitive notion that the cardinality of a set is a
measure of its size is only that: hand-wavy intuition. Ultimtely cardinality is
about the existence of a function between two sets, which itself (in ZFC) is
ultimately just a statement that a third set exists with a certain relationship
to those two sets.

It is entirely possible that an uncountable set and a countable set are the same
"size" in some intuitive sense, but simply lack the appropriate function to
witness that. That is, there aren't necessarily "more" real numbers than natural
numbers, we just lack access to the function that will injectively map the real
numbers to the natural numbers. This is precisely what occurs when $X$ is a
countable model of ZFC.

Hence while the fact that the finite descriptions of the real numbers do indeed
give a mapping onto the natural numbers, this mapping cannot be formalized as a
function in ZFC because definability (with the language of ZFC) is not
formalizable within ZFC. Therefore we "lack access" to the function that will
witness that the real numbers are countable.

Another way to think about $X$ and $U$ is to reverse the relationship and
imagine that our starting universe is $X$ and we can try to expand it into $U$.
In particular we could decide to simply add this mapping from the real numbers
to the natural numbers as a formal function into $X$. But keep in mind that the
axioms of ZFC cause a cascade of new sets to be created when we add just one.

In particular, by adding this mapping to $X$, this cascade will cause our real
numbers to suddenly gain a lot of new members and our new models' conception of
the real numbers will once again be out of the reach of this original mapping.

So even though it's possible that every real number is definable, the mapping
induced by its definability remains out of the reach of ZFC no matter how hard
we try. Conversely, while it is possible that every real number is definable

I'll close with a quote from Hamkins. "The claims... on the existence of
non-definable numbers and objects, are simply unwarranted. For all you know, our
set-theoretic universe is pointwise definable, and every object is uniquely
specified by a property."
