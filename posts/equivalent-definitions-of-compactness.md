---
title: Equivalent Definitions of Compactness
cover-image: transparent_image_1.png
author: Rimu Shuang
attribution: 'It is a transparent image... do you need attribution?'
subhead: Proving equivalence among three different definitions
tags: first, math
date: 2012-08-02T21:00:45-0500
---

I've just realized how quickly the summer has passed by and how little math I've been able to cram into my noggin (the fact that I haven't been able to get through much of my real analysis books nor have I been able to review any of Galois and field theory has been glaring me in the face). I was flipping through the beginnings of several books on real analysis and I stumbled across three definitions of compact sets in $\mathbb{R}^n$ (namely Edwards, Stein, and Rudin). Namely we have 

1.	A set is compact if any (possibly uncountable) open covering of the set contains a finite open covering of the set. 
2.	A set is compact if it is closed and bounded. 
3.	A set is compact if every infinite subset has a limit point contained in the set (i.e. both the existence of a limit point and being contained in the set are stipulated). 

Interestingly none of these books (at least not that I was able to find) prove the equivalence of the three definitions. They sometimes prove one direction (i.e. that one of the definitions implies one of the others), but not an if and only if relation. So I decided to set out and try to prove the equivalence of all three. So, because compactness is an important concept in analysis as well as other fields of math (especially topology), let's prove their equivalence! 

Before we start, it is important to note that in fact the equivalence of these definitions is NOT true in general for topological spaces, but let's just stick to $\mathbb{R}^n$ for now. 

First let's prove the equivalence of the last two, namely that if and only if a set is closed and bounded, every infinite subset has a limit point contained in the set. First let's prove that if a set is closed and bounded, then every infinite subset has a limit point contained in the set. It follows from the definition of a closed subset that if the infinite subset has a limit point, then it must be contained in the set (since a closed set contains all its limit points). However, we don't yet have a guarantee that every infinite subset has a limit point. 

To prove that any infinite subset $S$ must have a limit point (which is by no means true in general, think integers in the real line), we turn to the boundedness condition. If the set is bounded, then it is contained in an open ball of radius $r$, which then means it is contained in a closed cube of side length $r'$ (a ball centered around the point $p$ and a rectangle are used here to refer respectively to the sets ${x: |x - p| < r}$ for some $r'$ and the Cartesian product of $n$ (where $n$ is in $\mathbb{R}^n$) intervals in $\mathbb{R}$). We denote the ``volume'' of a cube to be the product of the lengths of the intervals that make up its sides. 

Now let each point in our subset be contained by a cube centered at the point, where the side length of the cube is half of the infimum of the distance (as defined by the Euclidean norm) between that point and any other point in our subset $S$. This shows there is no lower limit to the distance (as defined by the Euclidean norm) between any two points in our subset (if we did, then there would be a lower limit to the volume of these cubes, which means it is impossible for the volume of an infinite number of these cubes to sum to a finite number). 

This by itself does not imply the existence of a limit point, but because our subset $S$ is bounded because the parent set is bounded, we have something more we can work with. Let us make a sequence of sets of balls around every point in $S$ defined sequentially. The first set of balls (let's call it $S_1$) consists of balls of radius $2r$ (where $r$ is the radius of the open ball that contains the entire set as mentioned earlier). Thus every ball in $S_1$ contains all the other points of $S$. Then let us halve the radius of all the balls to make our second set $S_2$ and continue to halve the radius over and over again ad infinitum (with an arbitrary step denoted as $S_n$). 

Now if we examine those points contained in the intersection of at least two balls (let us denote those points as $S_{n, intersect}$) at some given step, we note that at every step of our construction, we have a non-empty intersection of balls, because there is no lower limit to the distance between two points, i.e. $S_{n, intersect}$ is non-empty for all $n$. Then we note that those points in $S_{\infty, intersect}$ (shorthand for points contained in all $S_{n, intersect}$), are precisely limit points, since the balls in $S_{n, intersect}$ become arbitrarily small. Thus we have at least one limit point since $S_{\infty, intersect}$ must be non-empty. 

So now we've proved that closed and bounded $\Rightarrow$ every infinite subset has a limit points contained in the set. 

Going the other direction, we need to prove that if every infinite subset has a limit point contained in the set, then all limit points are contained in the set and moreover the set is bounded. To prove that all limit points are contained in the set, let us assume that for some given infinite subset $S$, one of its limit points $p'$ is contained in the parent set $S'$, but we are unsure about another limit point $p$. Then let us make a new sequence $\mathcal{X}$. We start with a ball $B_r(p)$, $r$ being its radius, centered on $p$. Then we can apply the same trick as we did going the other direction and examine all the $B_{r/2^n}(p)$ for $n \in \mathbb{N}$. Then let us examine $B_{r/2^{n+1}}\setminus B_{r/2^n}(p)$ and pick either one point from this ``slice'' or no points if the ``slice'' is empty and add this to $\mathcal{X}$. This construction of $\mathcal{X}$ is then an infinite subset which has only one limit point, namely $p$, and therefore $p$ must be in our set. So all limit points are in our set. 

As for showing boundedness, we can do so in a similar fashion. Let us choose an arbitrary point $y$ in $S$ whose parent set is $P$. Then we can make a sequence of balls $B_1 (y), B_2(y), B_3(y) \ldots$ ad infinitum. Then we once again look at a ``slice'' $B_{2n + 1} \setminus B_{2n}$  (i.e. only every other slice) and pick one point from the set if it is nonempty and add it to a new sequence $\mathcal{Y}$. If $S$ were unbounded, then we would be guaranteed to have an infinite number of points in $\mathcal{Y}$ since no ball would contain all points of $P$; however, $\mathcal{Y}$ has no limit points since the infimum of the distance between any two points is at least $1$,  which contradicts our assumption that all infinite subsets must have a limit point. 

So now were done with showing that two of of the three definitions are equivalent. And I'll stop here for now and pick up next time. 
