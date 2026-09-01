local env = require("config.env")

local function with_leader(keys)
    return "SUPER + " .. keys
end

-- /--------------------*
-- |                    |
-- |  Hyprland control  |
-- |                    |
-- *--------------------/

hl.bind(with_leader("SHIFT + E"), env.tools.exit)

hl.bind(
    with_leader("SHIFT + B"),
    hl.dsp.dpms({ action = "on" }),
    {
        description = "Manual screen turn-on",
        locked = true,
    }
)

hl.bind(
    with_leader("SHIFT + N"),
    hl.dsp.dpms({ action = "off" }),
    {
        description = "Manual screen turn-off",
        locked = true,
    }
)


-- /--------------------*
-- |                    |
-- |   Apps launching   |
-- |                    |
-- *--------------------/

hl.bind(with_leader("F"), env.tools.browser)
hl.bind(with_leader("semicolon"), env.tools.emoji)
hl.bind(with_leader("E"), env.tools.file_manager)
hl.bind(with_leader("L"), env.tools.locker)
hl.bind(with_leader("D"), env.tools.menu)
hl.bind(with_leader("SHIFT + R"), env.tools.screenshot)
hl.bind(with_leader("Return"), env.tools.terminal)


-- /--------------------*
-- |                    |
-- |   Window control   |
-- |                    |
-- *--------------------/

hl.bind(with_leader("SHIFT + A"), hl.dsp.window.close())

hl.bind(with_leader("V"), hl.dsp.window.float())
hl.bind(with_leader("P"), hl.dsp.window.pseudo())

local directions = {"left", "right", "up", "down"}

for _, direction in ipairs(directions) do
    hl.bind(
        with_leader(direction),
        hl.dsp.focus({ direction = direction })
    )
end

hl.bind(with_leader("mouse:272"), hl.dsp.window.drag())
hl.bind(with_leader("mouse:273"), hl.dsp.window.resize())


-- /--------------------*
-- |                    |
-- |  Workspace control |
-- |                    |
-- *--------------------/

local workspace_bindings = {
    "ampersand",
    "eacute",
    "quotedbl",
    "apostrophe",
    "parenleft",
    "minus",
    "egrave",
    "underscore",
    "ccedilla",
    "agrave"
}

for i = 1, #workspace_bindings do
    hl.bind(
        with_leader(workspace_bindings[i]),
        hl.dsp.focus({ workspace = i })
    )

    hl.bind(
        with_leader("SHIFT + " .. workspace_bindings[i]),
        hl.dsp.window.move({ workspace = i })
    )
end

-- special Workspace
hl.bind(
    with_leader("S"),
    hl.dsp.workspace.toggle_special("kid")
)

hl.bind(
    with_leader("SHIFT + S"),
    hl.dsp.window.move({ workspace = "special:kid" })
)


-- /--------------------*
-- |                    |
-- |    Sound control   |
-- |                    |
-- *--------------------/

local function brightnessctl(command)
    return hl.dsp.exec_cmd("brightnessctl " .. command)
end

local function playerctl(command)
    return hl.dsp.exec_cmd("playerctl " .. command)
end

local function wpctl(command)
    return hl.dsp.exec_cmd("wpctl " .. command)
end

hl.bind(
    "XF86AudioRaiseVolume",
    wpctl("set-volume @DEFAULT_AUDIO_SINK@ 5%+")
)
hl.bind(
    "XF86AudioLowerVolume",
    wpctl("set-volume @DEFAULT_AUDIO_SINK@ 5%-")
)

hl.bind(
    "XF86AudioMute",
    wpctl("set-mute @DEFAULT_AUDIO_SINK@ toggle")
)
hl.bind(
    "XF86AudioMicMute",
    wpctl("set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
)

hl.bind("XF86MonBrightnessUp", brightnessctl("set 10%+"))
hl.bind("XF86MonBrightnessDown", brightnessctl("set 10%-"))

hl.bind("XF86AudioNext", playerctl("next"))
hl.bind("XF86AudioPause", playerctl("play-pause"))
hl.bind("XF86AudioPlay", playerctl("play-pause"))
hl.bind("XF86AudioPrev", playerctl("previous"))
