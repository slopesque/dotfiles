local env = {}

-- Convert a table of executable commands to their hl.dsp.exec_cmd equivalent.
-- @param executables A table of executables associated with a name
-- @return The table referencing each key to its executable disptatcher
local function define_dispatchers(executables)
    dispatchers = {}

    for name, executable in pairs(executables) do
        dispatchers[name] = hl.dsp.exec_cmd(executable)
    end

    return dispatchers
end

env.tools = {
    browser = "brave",
    emoji = "ibus emoji",
    exit = "hyprshutdown",
    file_manager = "pcmanfm",
    locker = "hyprlock",
    menu = "~/.config/hypr/utils/rofi-focus-mode-wrapper.sh",
    screenshot = "hyprshot -m region -f \"$(date +'%y%m%d_%Hh%Mm%Ss').png\"",
    terminal = "kitty",
}

env.vars = {
    theme = "Adwaita-dark",
    cursor_size = "24",
    cursor_theme = "miku-cursor-linux",
    LAPTOP_MODE = false,
}

require("config.override_env")(env)

env.tools = define_dispatchers(env.tools)

return env
