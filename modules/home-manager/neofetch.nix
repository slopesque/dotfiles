{
  config,
  lib,
  ...
}: let
  inherit (config.home.my-dotfiles) dotfilesLocalPath;
  cfg_root = config.home.my-dotfiles;
  cfg = config.home.my-dotfiles.packages.neofetch;
in {
  options = {
    home.my-dotfiles.packages.neofetch = {
      enable = lib.mkEnableOption "Enable dotfiles for neofetch";
    };
  };

  config = lib.mkIf (cfg_root.enable && cfg.enable) {
    xdg = {
      enable = true;

      configFile."neofetch".source =
        config.lib.file.mkOutOfStoreSymlink
        "${dotfilesLocalPath}/dotfiles/neofetch/.config/neofetch";
    };
  };
}
