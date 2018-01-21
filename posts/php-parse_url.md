---
title: PHP parse_url
cover-image: sad_dog.jpg
author: Rimu Shuang
attribution: '"Sad Dog", Hubert Figuière, Flickr,
http://farm5.staticflickr.com/4042/4465657345_7ec6a546be_o.jpg'
subhead: PHP loves making magical variables...
tags: php
date: 2013-07-08T13:44:43-0500
---

There have been many rants on the internet about PHP. This will not be another
long rant. There have been many admirable ones already. 

And besides, PHP, for all its faults, is the duct tape that holds the internet
together.

I'm just here to vent about one thing. I've been doing a lot of code maintenance
at work lately. I stumbled across PHP's `parse_str`. 

`parse_str`. Generates variables on the fly. Terrible. Terrible terrible terrible.
I have variables whose very declaration ARE DEPENDENT ON USER-GENERATED INPUT.
User comes up with creative URL query strings? I get creatively named variables.
Magically. GAAAAAAHHHHHHH!

Lesson: ALWAYS use the optional array argument of `parse_str` or pain and agony
will ensue. 
