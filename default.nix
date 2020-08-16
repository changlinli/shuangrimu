{ nixpkgs ? import (builtins.fetchTarball {
  # Descriptive name to make the store path easier to identify
  name = "nixos-unstable-2020-08-15";
  # Commit hash for nixos-unstable as of 2018-09-12
  url = "https://github.com/nixos/nixpkgs/archive/4789d6feafd9ba0613b9f1fd4dcd6b1ed0572f4b.tar.gz";
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  sha256 = "12csj97ac59wacjv3rr8df8cqanji9ah7ixm19p1m1xaxbp7j1v6";
}) {}
, compiler ? "default" 
}:

let

  inherit (nixpkgs) pkgs;

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  f = { mkDerivation
      # Haskell dependencies
      , base
      , bifunctors
      , blaze-html
      , filepath
      , hakyll
      , stdenv
      , primitive
      , stack
      , latex-svg-hakyll
      , latex-svg-image
      , latex-svg-pandoc
      # Non-Haskell dependencies
      , texlive
      }:
      mkDerivation {
        pname = "shuangrimu";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [
          base bifunctors blaze-html filepath hakyll latex-svg-hakyll latex-svg-image latex-svg-pandoc
        ];
        executableSystemDepends = [
          (texlive.combine {
            inherit (texlive) 
            scheme-basic 
            xetex 
            xecjk 
            fandol 
            setspace 
            fontspec
            chktex 
            enumitem 
            xifthen 
            ifmtarg 
            filehook
            upquote 
            tools 
            ms 
            geometry 
            graphics 
            oberdiek
            fancyhdr 
            lastpage 
            xcolor 
            etoolbox 
            unicode-math
            ucharcat 
            sourcesanspro 
            tcolorbox 
            pgf 
            environ
            trimspaces 
            parskip 
            hyperref 
            url 
            euenc
            preview
            bussproofs;
          })
        ];
        license = stdenv.lib.licenses.gpl3;
      };

  drv = haskellPackages.callPackage f {};

in

  if pkgs.lib.inNixShell then drv.env else drv
