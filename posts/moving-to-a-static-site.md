---
title: Moving to a Static Site
cover-image: big_globe.svg
author: Rimu Shuang
attribution: Ronald Yang. <a href="https://unsplash.com/?photo=xagqOinFSu4">"Untitled Photo".</a> June 12, 2015. Under a Creative Commons 1.0 Universal (Public Domain Dedication) License (NOT a CC-BY 4.0 License). Post-processed by Rimu Shuang.
subhead: Moved this site from Django to Hakyll. Reasons were mainly reproducibility, security, and just curiosity.
tags: moving, django, hakyll
date: 2016-11-13T07:22:00-0500
---

I've moved to a static site (specifically from
[Django](https://www.djangoproject.com/) to
[Hakyll](https://jaspervdj.be/hakyll/))!

I found myself not spending any time maintaining my Django website. Now I have
nothing against Django itself; it's a great web framework that has only gotten
even better with its latest releases. Unfortunately, it had two drawbacks which
were amplified when I didn't maintain the website. These drawbacks are not
specific to Django, but rather to any software fully responsible for maintaining
a dynamic website.

__Security__: Django, like any other web-facing piece of software, comes out
with new security bug fixes all the time. Quite naturally, due to constraints of
effort and time, the Django team chooses to only support the most recent couple
of versions of Django with these security fixes. 

I was still on Django 1.6 and simply didn't have the interest nor time in
keeping my eye on current Django security bugs and upgrading my site as
necessary. Even though I didn't have anything valuable on my website, I owe the
greater Internet community to do my part to prevent my website from being
scooped up into a botnet.

__Reproducibility__: Increasingly I've become focused on making sure that my
computing life is reproducible with a minimum of human effort. I'm never going
to remember the hacks I did to make something work unless I have the machine do
it for me (or record it here!). 

In order to keep my software usable when my interest is no longer on it, I need
to automate set up as much as possible. A dynamic website has a bit too many
moving parts (mainly surrounding DB setup and authentication).

All I really had was a bunch of slow-changing HTML files I needed served up. And
there were plently of players in the market who could take care of security for
me for free, while reproducibility went up with the removal of mutable
components such as the DB and user accounts.

Now of course there are many different static site generators out there. The
reason why I chose Hakyll is simply because of the amount of flexibility it
offered. For math heavy posts I prefer to use LaTeX and for other posts I prefer
to use Markdown. Sometimes I'll experiment with other formats as I see fit.

Hakyll is basically a front-end to the amazing [pandoc](http://pandoc.org/),
which makes it uniquely awesome at handling all the file formats under the sun
and converting them into HTML.

So what about that "Popular Posts" thing you see below then? Well it only
updates every time I redeploy this site. Yep. Not dynamic at all. Not even
automatic.

I might put the effort into getting some sort of CI set up for this static
website and then at least it can be a bit more automatic.

But for now I'm happy with where I've landed with this project so far. Maybe in
a couple of months I'll try to improve where I'm at right now with better
infrastructure. Thanks a ton for all the software you guys have made, Django
team, Jasper Van der Jeugt, and John MacFarlane! Building my own humble little
website off the shoulders of giants and all...
