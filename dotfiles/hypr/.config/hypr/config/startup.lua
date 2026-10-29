local env = require("config.env")

local STARTUP_SOUND_FILE = "~/.local/share/audio/startup.wav"
local THEME_SWITCH_HANDLER = "~/.config/hypr/utils/theme-autoswitcher"
local THEME_SWITCH_INTERVAL = 600

local function delay(seconds, command)
    return "sleep " .. seconds .. " " .. command
end

local function if_true(condition, command)
    if not condition then
        return nil
    end

    return command
end

local commands = {
    "hyprctl setcursor " .. env.vars.cursor_theme .. " " .. env.vars.cursor_size,
    if_true(env.vars.HYPRPM_ON, "hyprpm reload"),
    if_true(env.vars.OPENRC_ON, "openrc --user " .. env.vars.OPENRC_LEVEL),
    if_true(
        env.vars.OPENRC_ON,
        "dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY PATH"
    ),
    delay(
        1,
        THEME_SWITCH_HANDLER .. " " .. THEME_SWITCH_INTERVAL
    ),
    delay(2, "pw-play " .. STARTUP_SOUND_FILE),
}

local function startup()
    for i = 1, #commands do
        if commands[i] ~= nil then
            hl.exec_cmd(commands[i])
        end
    end
end

local function shutdown()
    if env.vars.OPENRC_ON then
        hl.exec_cmd("openrc --user default")
    end
end

hl.on("hyprland.start", startup)
hl.on("hyprland.shutdown", shutdown)
