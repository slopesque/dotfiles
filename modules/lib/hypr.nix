{
  config,
  lib,
  ...
}: let
  inherit (config.home.my-dotfiles) dotfilesLocalPath;
  cfg = config.home.my-dotfiles.packages.hypr;
in {
  options = {
    home.my-dotfiles.packages.hypr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = true;
        description = "Enable dotfiles for the hypr environment";
      };

      overrides = {
        hyprland = {
          extras = lib.mkOption {
            type = lib.types.str;
            default = ''
            '';
            example = ''
              hl.exec_cmd("fcitx5")
            '';
            description = ''
              Extra Hyprland instruction to run during Hyprland
              session.

              Those instructions will be run after the full
              initialization of the Hyprland configuration,
              use it to add or replace config values or run
              custom processes.
            '';
          };

          extras-env = lib.mkOption {
            type = lib.types.str;
            default = ''
            '';
            example = ''
              return function(env)
                env.tools.terminal = "alacritty"
                env.vars.cursor_size = 12
              end
            '';
            description = ''
              Extra Hyprland instructions to run during Hyprland
              session.

              This should define a Lua module which can be
              utilized as a function taking as a parameter a
              reference to the global environment table. It will
              be called after its initial initialisation so that
              you may replace or insert whatever you want in it.

              Use this to add/override environment variables and
              change your default terminal, GTK theme...
            '';
          };
        };
      };
    };
  };

  config =
    lib.mkIf cfg.enable
    {
      home.activation = {
        applyOverrides =
          lib.hm.dag.entryAfter
          ["cloneDotfiles"]
          ''
            #!/bin/sh

            hyprland_overrides_path="${config.xdg.configHome}/hypr/config/overrides.lua"
            hyprland_overrides_env_path="${config.xdg.configHome}/hypr/config/override_env.lua"

            hyprland_overrides_content="${cfg.overrides.hyprland.extras}"
            hyprland_overrides_env_content="${cfg.overrides.hyprland.extras-env}"


            dry_run() {
                echo "would write $hyprland_overrides_env_content to $hyprland_overrides_env_path"
                echo "would write $hyprland_overrides_content to $hyprland_overrides_path"
            }

            write_overrides() {
                echo \
                    "$hyprland_overrides_env_content" \
                    > "$hyprland_overrides_env_path"
                echo \
                    "$hyprland_overrides_content" \
                    > "$hyprland_overrides_path"
            }

            # if [ -n "$DRY_RUN" ]; then
            #     dry_run
            # else
            write_overrides
            # fi
          '';
      };

      xdg = {
        enable = true;

        configFile = {
          "hypr".source =
            config.lib.file.mkOutOfStoreSymlink
            "${dotfilesLocalPath}/dotfiles/hypr/.config/hypr";
        };

        dataFile = {
          "icons/miku-cursor-linux" = {
            source = ../../themes/cursors/miku-cursor-linux/.local/share/icons/miku-cursor-linux;
          };

          "wallpapers/hyprlock-bg" = {
            source = ../../themes/wallpapers/hyprlock-bg/.local/share/wallpapers/hyprlock-bg;
            recursive = true;
          };

          "wallpapers/hyprpaper-bg" = {
            source = ../../themes/wallpapers/hyprpaper-bg/.local/share/wallpapers/hyprpaper-bg;
            recursive = true;
          };
        };
      };
    };
}
