Shuangrimu
==========

This repository contains the code for generating the Shuangrimu website. It is
an entirely static site built using Hakyll.

Developing the site
------------------

### With Nix

The easiest way to get this site up and built is by using Nix. If you have Nix
already installed, you can simply do `nix-shell .` within the top-level of this
project. This will pull down all the necesssary packages to get this running,
including GHC.

### With Cabal

Alternatively if you don't want to use Nix, you can build this with your own GHC
and Cabal.

Running the site
----------------

By default there is a development server

Deploying the site
------------------

Because this site is built using Hakyll, it's essentially a custom-built
compiler that compiles a bunch of blog posts written in Markdown or whatever
other input language Pandoc accepts and converts it out to HTML with custom
styling along the way.

Running `site.lhs` will generate a bunch of HTML, CSS, and Javascript output in
the `_site` folder. This can then be served up by your choice of webserver.

In my particular case I configure the web server to serve pages with the `.html`
suffix as optional (with a redirect as necessary). That is of course a decision
that is entirely up to you.

Writing new posts
-----------------

Any new post is a markdown file that goes in the `posts` directory. I also have
a `drafts` directory for drafts I'm not quite ready to publish yet, but that's
purely a convention (since any folder that is not `posts` gets ignored, I could
have used another name such as `notposts`).

Misc Bugs (a.k.a. why htaccess is not .htaccess)
------------------------------------------------

For some reason Hakyll isn't able to match on files with a period as the first
character. See
[https://github.com/jaspervdj/hakyll/issues/560](https://github.com/jaspervdj/hakyll/issues/560).
