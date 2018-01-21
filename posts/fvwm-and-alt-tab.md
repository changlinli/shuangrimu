---
title: FVWM and Alt-Tab
cover-image: fvwmbackground.jpg 
author: Rimu Shuang
attribution: 'Rimu Shuang. "Untitled Image". Under a Creative Commons
Attribution Share-alike Unported License (CC-BY-SA) v3.0 (NOT CC-BY) see
http://creativecommons.org/licenses/by-sa/3.0/. Background from Canonical Ltd.
at "Ubuntu 13.04 Raring Ringtail" under CC-BY-SA v3.0 and the FVWM logo from
Wikipedia at http://commons.wikimedia.org/wiki/File:Fvwm-logo.svg under CC-BY-SA
v3.0.'
subhead: Making Alt-Tab in FVWM act like other window manager's Alt-Tab
tags: fvwm, FVWM
date: 2013-05-19T15:48:06-0500
---

I've started running <a href="http://www.fvwm.org/">FVWM</a> as my window manager on top of Ubuntu lately. While I'm actually a fan of Unity (despite the intense hatred it seems to inspire in some), I was looking for a level of customization that was just not possible in Unity. 

So far FVWM has been a good experience. Although the default configuration out of the box definitely looks like something straight out of the 90s, FVWM, even in its default state, is quite usable.  

The only thing that has really been annoying has been the behavior of Alt-Tab. I've gotten very used to a specific set of behavior with Alt-Tab that doesn't work quite right in FVWM. FVWM's <a href="http://www.fvwm.org/documentation/faq/#3.3">FAQ</a> gives 
<pre><code class="prettyprint">
Key Tab A M WindowList Root c c NoDeskSort
</pre></code>
for emulating Alt-Tab as realized in most Linux distros, Windows, and Mac OSX.

Unfortunately, this didn't quite get everything right for me. The main things that FVWM's default Alt-Tab behavior was missing were
<ol>
<li>Hitting Alt-Tab doesn't transfer me immediately to another window. If I just press Alt-Tab once and let go, I stay on my current window. </li>
<li>Every time I did go to a new window with Alt-Tab, my mouse was positioned at the left-hand upper corner. This meant a lot of accidental and frustrating window closing happened.</li>
</ol> 
To address the first point, I have the following key binding:
<pre><code class="prettyprint">Key Tab A M WindowList Root c c CurrentDesk, NoGeometry, CurrentAtEnd, IconifiedAtEnd</code></pre> (which came from the FVWM FAQ as well). The important part is <code class="prettyprint">CurrentAtEnd</code>, which moves the current window to the end of a list of windows that WindowList deals with. Whenever Alt-Tab is pressed, WindowList immediately switches to the first window on its list of windows. Normally this is the current window that you're on. Adding the <code class="prettyprint">CurrentAtEnd</code> option means that the first window on the list is NOT my current window and so I immediately switch to another window. 

As for the second point, the FVWM forums have a nice link <a href=http://www.fvwmforums.org/phpBB3/viewtopic.php?f=33&t=1796>here</a> which describes one possible solution (i.e. centering the mouse in the window every time) that involves redefining <code class="prettyprint">WindowListFunc</code> (which is called by <code class="prettyprint">WindowList</code>) to center the mouse every time. This still wasn't quite ideal; I'd prefer FVWM to simply leave the mouse where it was before. Redefining <code class="prettyprint">WindowListFunc</code>, however, was the key to what I have now for FVWM's Alt-Tab function (which I like very much). 

The important idea is that <code class="prettyprint">WindowListFunc</code>'s <code class="prettyprint">WarpToWindow 5p 5p</code> was responsible for warping my mouse cursor to a 5px by 5px offset from the upper-left corner of the window. So when I redefined WindowList, I simply removed the invocation of <code class="prettyprint">WarpToWindow</code>. 

All in all, this means adding the following to your fvwm2rc file should make Alt-Tab a bit closer to what it's like in other window managers/desktop environments. 
<pre><code class="prettyprint">
DestroyFunc WindowListFunc
AddToFunc WindowListFunc
+ I Iconify off
+ I FlipFocus
+ I Raise
</code></pre>
and
<pre><code class="prettyprint">
Key Tab A M WindowList Root c c CurrentDesk, NoGeometry, CurrentAtEnd, IconifiedAtEnd
</code></pre>. 
