{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.my-dotfiles;
in {
  imports = [
    ./bashrc.nix
    ./dunst.nix
    ./fastfetch.nix
    ./git.nix
    ./hypr.nix
    ./kitty.nix
    ./neofetch.nix
    ./neovim.nix
    ./nushell.nix
    ./vimrc.nix
    ./waybar.nix
  ];

  options = {
    home.my-dotfiles = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable dotfiles loading into home.";
      };

      dotfilesLocalPath = lib.mkOption rec {
        type = lib.types.path;
        default = "${config.home.homeDirectory}/dotfiles";
        example = default;
        description = "Path at which to store the dotfiles locally";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      activation = {
        cloneDotfiles =
          lib.hm.dag.entryAfter
          ["installPackages" "git"]
          ''
            #!/bin/sh

            OLD_PATH="$PATH"
            PATH="${lib.makeBinPath [pkgs.git]}:$PATH"

            dotfiles_installation_path="${cfg.dotfilesLocalPath}"

            if [ ! -d "$dotfiles_installation_path" ]; then
                run \
                    git clone \
                    https://github.com/mccreemainwoody/dotfiles.git \
                    "$dotfiles_installation_path"
            fi

            PATH="$OLD_PATH"
          '';
      };
    };
  };
}
