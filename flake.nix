{
  description = "Nix Home-Manager configuration for dotfiles";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    ...
  } @ _:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      formatter = pkgs.alejandra;

      devShells = {
        default = pkgs.mkShell {
          pname = "Dotfiles development shell";
          packages = with pkgs; [
            alejandra
            bash-language-server
            nixd
            emmylua-ls
          ];
        };
      };

      homeModules = rec {
        default = dotfiles;
        dotfiles = import ./modules/lib;
      };
    });
}
