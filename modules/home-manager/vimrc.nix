{
  config,
  lib,
  ...
}: let
  inherit (config.home.my-dotfiles) dotfilesLocalPath;
  cfg_root = config.home.my-dotfiles;
  cfg = config.home.my-dotfiles.packages.vim;
in {
  options = {
    home.my-dotfiles.packages.vim = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = true;
        description = "Enable dotfiles for vim";
      };
    };
  };

  config = lib.mkIf (cfg_root.enable && cfg.enable) {
    home.file.".vimrc".source =
      config.lib.file.mkOutOfStoreSymlink
      "${dotfilesLocalPath}/dotfiles/vimrc/.vimrc";
  };
}
