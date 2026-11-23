{
  config,
  lib,
  ...
}: let
  inherit (config.home.my-dotfiles) dotfilesLocalPath;
  cfg_root = config.home.my-dotfiles;
  cfg = config.home.my-dotfiles.packages.bashrc;
in {
  options = {
    home.my-dotfiles.packages.bashrc = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = true;
        description = "Enable dotfiles for bashrc";
      };
    };
  };

  config = lib.mkIf (cfg_root.enable && cfg.enable) {
    home.file.".bashrc".source =
      config.lib.file.mkOutOfStoreSymlink
      "${dotfilesLocalPath}/dotfiles/bashrc/.bashrc";
  };
}
