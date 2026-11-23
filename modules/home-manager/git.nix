{
  config,
  lib,
  ...
}: let
  inherit (config.home.my-dotfiles) dotfilesLocalPath;
  cfg_root = config.home.my-dotfiles;
  cfg = config.home.my-dotfiles.packages.git;
in {
  options = {
    home.my-dotfiles.packages.git = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = true;
        description = "Enable dotfiles for git";
      };
    };
  };

  config = lib.mkIf (cfg_root.enable && cfg.enable) {
    home.file.".gitconfig".source =
      config.lib.file.mkOutOfStoreSymlink
      "${dotfilesLocalPath}/dotfiles/git/.gitconfig";

    programs.git.enable = true;
  };
}
