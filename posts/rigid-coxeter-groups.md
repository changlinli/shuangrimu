---
title: Rigid Coxeter Groups
cover-image: Finite_coxeter.png
author: Rimu Shuang
attribution: 'Rimu Shuang. "Untitled Image". Dec 3, 2012. Under a Creative
Commons Attribution 3.0 License.'
subhead: Making Alt-Tab in FVWM act like other window manager's Alt-Tab
tags: math
date: 2012-12-03T15:05:42-0500
---

The study of the rigidity of Coxeter groups is motivated by the observation that for Coxeter systems $(W, S)$, isomorphisms of the underlying Coxeter groups do not guarantee isomorphisms of the Coxeter systems themselves. This is most easily seen in the diagrams associated with Coxeter systems; the same Coxeter group with two different sets of Coxeter generators can give rise to dramatically different Coxeter diagrams. The natural question then arises in which cases does the group structure of a Coxeter system in fact determine the associated Coxeter diagram? From this question comes the natural definitions rigid Coxeter groups. 

Definition:
	A rigid Coxeter group is a Coxeter group $W$ with simple roots $S$ such that the Coxeter System $(W,S)$ gives rise to the same Coxeter diagram (up to isomorphism) regardless of the $S$ chosen. 
	Equivalently a rigid Coxeter group always has an automorphism on $W$ which takes any choice of Coxeter generators $S$ to any other choice of Coxeter generators $S'$ (assuming $S$ and $S'$ both give rise to the same group).  

There is a stronger condition for Coxeter groups than rigidity known as strong rigidity. A strongly rigid Coxeter group is a rigid Coxeter group in which given any choice of Coxeter generators $S$ and $S'$, there exists an inner automorphism on the group taking $S$ to $S'$.  
\end{definition}

In order to show that these definitions are meaningful, it is instructive to consider both examples of and non-examples of rigid Coxeter groups and strongly rigid Coxeter group. The Cartesian product of the group of two elements, i.e. $(C_2)^n$ is a rigid Coxeter group. To see this, identify $C_2$ with the field of two elements $\mathbb{F}_2$. Then we can create the vector space $(\mathbb{F}_2)^n$ over $\mathbb{F}_2$. We can embed $(\mathbb{F}_2)^n$ in $\mathbb{R}^n$ and from that we can use $(C_2)^n$'s natural group action on $\mathbb{R}^n$ of the following:
	Given $(c_1, \ldots c_n) \in (C_2)^n$ and $(r_1, \ldots, r_n) \in \mathbb{R}^n$ and $(c_1, \ldots, c_n)(r_1, \ldots, r_n) = (r_1', \ldots, r_n')$, if $c_i = 0$ then $r_i' = r_i$ otherwise if $c_i = 1$ then $r_i' = -r_i$. 
	We note that our simple reflections $S$ are naturally identified with the simple roots which in turn are a basis for $(\mathbb{F}_2)^n$ (via linear independence). Since our only choice of scalars is $1$ or $0$, the vector space automorphisms of $(\mathbb{F}_2) ^n$ are precisely the group automorphisms of $(C_2)^n$. Then because for any two bases there always exists a vector space automorphism mapping one to the other, for any two Coxeter generator sets $S$ and $S'$, there must always be a group automorphism mapping one to the other. 

Note, however, that $(C_2)^n$ is not strongly rigid. Its abelian nature means that the only inner automorphism is the identity map. 

An example of a strongly rigid Coxeter group is $D^3$, i.e. the symmetries of the triangle. Note that any Coxeter generator must be a reflection, not a rotation (since there are no $180^\circ$ rotations possible on a triangle). Note too that two reflections are necessary to generate the Coxeter group and that each plane fixed by the reflection is separated by $120^\circ$ from the plane fixed by the other reflection.  Then it becomes geometrically apparent that conjugating by a rotation $r$ is sufficient to take any pair of reflections to another pair of reflections. 

More about rigid Coxeter groups will be posted soon. 
