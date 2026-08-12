local env = require("config.env")

local STARTUP_SOUND_FILE = "~/.local/share/audio/startup.wav"
local THEME_SWITCH_HANDLER = "~/.config/hypr/utils/theme-autoswitcher"
local THEME_SWITCH_INTERVAL = 600

local function delay(seconds, command)
    return "sleep " .. seconds .. " " .. command
end

local commands = {
    "dunst",
    "hyprctl setcursor " .. env.vars.cursor_theme .. " " .. env.vars.cursor_size,
    "hypridle",
    "hyprpaper",
    "waybar",
    delay(
        1,
        THEME_SWITCH_HANDLER .. " " .. THEME_SWITCH_INTERVAL
    ),
    delay(2, "pw-play " .. STARTUP_SOUND_FILE)
}

local function startup()
    for i = 1, #commands do
        hl.exec_cmd(commands[i])
    end
end

hl.on("hyprland.start", startup)
