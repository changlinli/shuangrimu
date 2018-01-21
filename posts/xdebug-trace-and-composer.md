---
title: XDebug Trace and Composer
cover-image: composer_screen.png
author: Rimu Shuang
attribution: 'Rimu Shuang. "Untitled Photo". Jul 25, 2013. Under a Creative
Commons 3.0 Attribution License.'
subhead: A log of what it took to figure out why Composer was being so slow
tags: composer, php, xdebug
date: 2013-11-24T23:31:24-0500
---

Composer is a godsend for PHP projects. It makes setting dependencies so much
easier.

Unfortunately for me, I spent the better part of a day trying to figure out why
Composer was taking an insane amount of time to download Doctrine (since I
wanted to try Doctrine out). My composer.json file was as simple as could
possibly be; the only requirement listed was Doctrine 2.3.4. Yet I waited for
over an hour and Composer still hadn't finished! 

I turned on -vvv and --profile but both just gave me the cryptic piece of
information that Composer was taking forever to read from its cache. Clearly
Composer was spending a lot of time sorting through the graph of dependencies,
but I couldn't figure out why it would take so long. 

Then I remembered that I had left `auto_trace` on in Xdebug. I thought that this
might help me diagnose the problem and went into /tmp to take a look. It turns
out Xdebug itself was the problem. The trace file was 4.5 GB (and that was after
I had stopped the Composer process midway)! 

So after turning off `auto_trace` in Xdebug, everything was well and installing
Doctrine took about 15 seconds. So moral of the story is tracing can sometimes
have a HUGE performance hit. 
