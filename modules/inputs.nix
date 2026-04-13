# modules/inputs.nix
################################################################################
# Declares shared flake inputs for modules in this repository.
# Inputs can be declared near usage when practical, not just here.
################################################################################

{
  flake-file.inputs = {
    # Global nixpkgs channel used by follows = "nixpkgs".
    nixpkgs.url =
      "https://channels.nixos.org/nixos-unstable-small/nixexprs.tar.xz";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
