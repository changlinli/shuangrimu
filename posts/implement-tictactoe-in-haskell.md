---
title: Implement Tic-Tac-Toe in Haskell
cover-image: tictactoe_cereal.JPG
attribution: Rimu Shuang. "Untitled Photo". Feb 5, 2014. Under a Creative Commons 3.0 Attribution License.
subhead: "As a project to get myself with Haskell, I've been working on implementing a
commandline version of Tic-Tac-Toe along with a minimax AI to play with."
author: Rimu Shuang
date: 2014-02-05T01:27:03+0000
tags: haskell
---

As a project to get myself with Haskell, I've been working on implementing a
commandline version of Tic-Tac-Toe along with a minimax AI to play with. I've
finished that and it's available at
[https://github.com/changlinli/tictactoe-haskell](
https://github.com/changlinli/tictactoe-haskell "Haskell Tic-Tac-Toe").

Along the way I used a little bit of the Haskell `test-framework` package to
automate my unit tests and quickCheck tests. Unfortunately, I complete skipped
the part on the `test-framework` example page which mentions that
`test-framework-quickcheck2` and `test-framework-hunit` are needed in order to
actually run quickCheck tests and HUnit tests. If those packages aren't
installed, we just get errors about not finding certain required packages, even
if we just run the example on `test-framework`'s home page. That took up a lot
of unneeded pain to hunt down the problem :(.

The next goal is to get [Super
Tic-Tac-Toe](http://www.scheinerman.net/jonah/supertictactoe.html "Super
Tic-Tac-Toe") running with an AI. This is much more interesting since my friends
and I are rather bad at Super Tic-Tac-Toe and it would be interesting to see if
the computer can offer any insights into effective strategies
