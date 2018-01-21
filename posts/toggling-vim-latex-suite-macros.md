---
title: Toggling Vim Latex-Suite's Macros
cover-image: vim_clean_mode.jpg
author: Rimu Shuang
attribution: 'Bert Hymans. "Vim the editor that''s also a ...".
http://www.flickr.com/photos/heymans/8903973272/. Under a Creative Commons
Attribution-NonCommercial-ShareAlike 2.0 License at
http://creativecommons.org/licenses/by-nc-sa/2.0/deed.en (NOT CC-BY!).'
subhead: Dipping My Toes in Vimscript
tags: latex, vim
date: 2013-06-07T21:28:08-0500
---

The LaTeX-suite for Vim is a great tool for writing LaTeX code. Among its amazing features are its set of macros implemented with its IMAP() function. For example, typing <code>EFI</code> while in Insert mode will result in the following. 
<pre><code class=prettyprint>
\begin{equation}
	
	\label{<++>}
\end{equation}<++>
</code></pre>
The <code><++></code> are little tags that Vim automatically jumps to and deletes (via <code>Ctrl-j</code>), allowing the user to write an equation in the equation environment and then immediately jump to writing a label and then immediately jump out of the equation environment without extraneous key movements. See <a href=http://vim-latex.sourceforge.net/documentation/latex-suite.html#latex-macros>here</a>.

Unfortunately this can be a huge pain at times. I was trying to write the word "DELETE" in a LaTeX document and every time I would suddenly would be presented with "DEL--gigantic blob of table environment text here--." 
It was rather annoying. 

The LaTeX-suite comes with the Vim global variable "g:Imap_FreezeImap," which if is "let"ed to 1, will disable these macros. I was looking to map these to a nice set of keys to allow for easy toggling back and forth. 

Alas, it doesn't seem that there's a way of toggling variables (as opposed to Vim options) without using Vimscript functions. So I looked, with every intention of spending as little time and effort as possible, at a few tutorials of vimscript. As soon as I learned how to declare functions and negate variables, I figured I should be set. 

So naturally I came up with
<pre><code class="prettyprint">
function ToggleFreezeImap()
    let g:Imap_FreezeImap = !g:Imap_FreezeImap
endfunction
</code></pre> to add to my <code>vimrc</code>. Unfortunately this didn't work. I spent some time puzzling over it. I changed into a conditional if-else statement. I looked up using global variables in conditional statements. Nothing seemed to click. 

Apparently, what I was missing was that even global variables need to first be declared in my <code>vimrc</code>. So I needed something like
<pre><code class="prettyprint">
let g:Imap_FreezeImap = 0
function ToggleFreezeImap()
    let g:Imap_FreezeImap = !g:Imap_FreezeImap
endfunction
noremap <C-m> :call ToggleFreezeImap() <CR>
</code></pre>. 

So that concludes my first tentative, brief (VERY brief) foray into Vimscript. 
