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

Running `site.hs` will generate a bunch of HTML, CSS, and Javascript output in
the `_site` folder. This can then be served up by your choice of webserver.

The development server used (`mighty`) is a production-ready webserver that can
be used. Alternatively, I've included an 

In my particular case I configure the web server to serve pages with the `.html`
suffix as optional. That is of course a decision that is entirely up to you.
