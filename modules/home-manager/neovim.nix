{
  config,
  lib,
  ...
}: let
  inherit (config.home.my-dotfiles) dotfilesLocalPath;
  cfg_root = config.home.my-dotfiles;
  cfg = config.home.my-dotfiles.packages.neovim;
in {
  options = {
    home.my-dotfiles.packages.neovim = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = true;
        description = "Enable dotfiles for neovim";
      };
    };
  };

  config = lib.mkIf (cfg_root.enable && cfg.enable) {
    xdg = {
      enable = true;

      configFile."nvim".source =
        config.lib.file.mkOutOfStoreSymlink
        "${dotfilesLocalPath}/dotfiles/nvim/.config/nvim";
    };
  };
}
