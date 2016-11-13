 with import <nixpkgs> {}; {
   sdlEnv = stdenv.mkDerivation {
     name = "sdl";
     buildInputs = [ zlib pkgconfig haskellPackages.c2hs haskellPackages.happy haskellPackages.alex file ];
     LD_LIBRARY_PATH = "${zlib}/lib";
   };
 }
