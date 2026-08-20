local function preprocess_animation(animation)
    local result = animation

    result.enabled = result.enabled or true

    if not result.bezier and not result.spring then
        result.bezier = "default"
    end

    return result
end


local config = {
    general = {
        border_size = 2,
        gaps_in = 5,
        gaps_out = 20,

        ["col.active_border"] = {
            colors = { "rgba(33ccffee)",  "rgba(00ff99ee)" },
            angle = 45,
        },
        ["col.inactive_border"] = "rgba(595959aa)",

        layout = "dwindle",

        allow_tearing = false,
        resize_on_border = false,
    },

    decoration = {
        rounding = 10,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    dwindle = {
        preserve_split = true
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = false,
    },
}

local animations = {
    {
        leaf = "workspaces",
        speed = 15,
    },
    {
        leaf = "windows",
        speed = 7,
    },
    {
        leaf = "windowsIn",
        speed = 8,
    },
    {
        leaf = "windowsOut",
        speed = 8,
        style = "popin 75%",
    },
    {
        leaf = "fade",
        speed = 10,
    },
}

hl.config(config)

hl.curve(
    "default",
    {
        type = "bezier",
        points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
    }
)

for i = 1, #animations do
    animation = preprocess_animation(animations[i])
    hl.animation(animation)
end
