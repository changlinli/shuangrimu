---
title: GHCJS is Amazing
cover-image: haskell-code.png
author: Rimu Shuang
attribution: 'Rimu Shuang. "Untitled Photo". Jan 4, 2015. Under a Creative
Commons 3.0 Attribution License. Symbols generated by LaTeX snippet from Gerold
Meisinger. ["Pretty printing Haskell code in
Latex"](http://lambdor.net/?p=273).'
subhead: "If you're looking for a Haskell to JS compiler, GHCJS is gloriously
close to becoming a one-stop-shop."
tags: haskell
date: 2015-01-04T18:16:56+0000
---

Over the weekend I finally decided to take the jump and install the 2014 Haskell
Platform on my Debian system. I had been waiting for it to get into the repos,
but I was tired of waiting and decided to download the binaries myself. This
gave me the wonderful opportunity to install
[GHCJS](https://github.com/ghcjs/ghcjs) and try it out. 

It's absolutely amazing. Luite Stegeman and everyone else who worked on GHCJS
thank you! It was a bit of a pain to get it installed (although apparently it is
miles better now than it was previously), but the main point is that all Haskell
code that GHC can compile compiles with GHCJS. When I first did the simple `main
= putStrLn "Hello World!"` I felt that it was kind of cool, as it always is when
compiling to a new target or trying out a new language. Then I took an existing
Haskell project, made no adjustments to it whatsoever and hit `cabal install`.
It worked perfectly. No hitches no nothing. Just install and blam! it was done.

There was definitely a performance hit (my executables were usually running
about 50x slower) and the generated JS files were pretty large (although the
[GHCJS wiki's](https://github.com/ghcjs/ghcjs/wiki/Deployment "GHCJS Deployment
Wiki Page") advice to use Google's [Closure
Compiler](https://developers.google.com/closure/compiler/ "Closure Compiler
Page") definitely helps cut down on size), but the magic was that I needed to
change absolutely nothing. 

So this short post is a long-winded way of saying if you like Haskell, try GHCJS
and it will blow your mind.