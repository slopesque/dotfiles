{
  config,
  lib,
  ...
}: let
  inherit (config.home.my-dotfiles) dotfilesLocalPath;
  cfg_root = config.home.my-dotfiles;
  cfg = config.home.my-dotfiles.packages.waybar;
in {
  options = {
    home.my-dotfiles.packages.waybar = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = true;
        description = "Enable dotfiles for waybar";
      };
    };
  };

  config = lib.mkIf (cfg_root.enable && cfg.enable) {
    xdg = {
      enable = true;

      configFile."waybar".source =
        config.lib.file.mkOutOfStoreSymlink
        "${dotfilesLocalPath}/dotfiles/waybar/.config/waybar";
    };
  };
}
