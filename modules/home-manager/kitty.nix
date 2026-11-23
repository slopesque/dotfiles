{
  config,
  lib,
  ...
}: let
  inherit (config.home.my-dotfiles) dotfilesLocalPath;
  cfg_root = config.home.my-dotfiles;
  cfg = config.home.my-dotfiles.packages.kitty;
in {
  options = {
    home.my-dotfiles.packages.kitty = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = true;
        description = "Enable dotfiles for kitty";
      };
    };
  };

  config = lib.mkIf (cfg_root.enable && cfg.enable) {
    xdg = {
      enable = true;

      configFile."kitty".source =
        config.lib.file.mkOutOfStoreSymlink
        "${dotfilesLocalPath}/dotfiles/kitty/.config/kitty";
    };
  };
}
