{
  config,
  lib,
  ...
}: let
  inherit (config.home.my-dotfiles) dotfilesLocalPath;
  cfg_root = config.home.my-dotfiles;
  cfg = config.home.my-dotfiles.packages.agents;
in {
  options = {
    home.my-dotfiles.packages.agents.pi = {
      enable = lib.mkEnableOption "Enable configuration for Pi coding agent.";
    };
  };

  config = lib.mkIf cfg_root.enable {
    home.file.".pi" = lib.mkIf cfg.pi.enable {
      source =
        config.lib.file.mkOutOfStoreSymlink
        "${dotfilesLocalPath}/dotfiles/pi/.pi";
    };
  };
}
