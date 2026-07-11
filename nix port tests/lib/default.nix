# Entry point for the Kamalen Shell lib helpers.
# Usage in flake.nix: lib = import ./lib { inherit nixpkgs; };
{ nixpkgs, ... }:

import ./helpers.nix { inherit nixpkgs; lib = nixpkgs.lib; }
