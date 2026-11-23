{
  config,
  lib,
  ...
}: let
  inherit (config.home.my-dotfiles) dotfilesLocalPath;
  cfg_root = config.home.my-dotfiles;
  cfg = config.home.my-dotfiles.packages.dunst;
in {
  options = {
    home.my-dotfiles.packages.dunst = {
      enable = lib.mkEnableOption "Enable dotfiles for dunst";
    };
  };

  config = lib.mkIf (cfg_root.enable && cfg.enable) {
    xdg = {
      enable = true;

      configFile."dunst".source =
        config.lib.file.mkOutOfStoreSymlink
        "${dotfilesLocalPath}/dotfiles/dunst/.config/dunst";
    };
  };
}
