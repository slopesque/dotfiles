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
        border_size = 3,
        gaps_in = 5,
        gaps_out = 20,

        ["col.active_border"] = "rgba(292c3dcc)",
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

local curves = {
    {
        "default",
        {
            type = "bezier",
            points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
        }
    },
    {
        "openSnap",
        {
            type = "bezier",
            points = { { 0.16, 1 }, { 0.3, 1.04 } },
        }
    },
    {
        "closeSmooth",
        {
            type = "bezier",
            points = { { 0.4, 0 }, { 0.2, 1 } },
        }
    }
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
        style = "gnomed",
        curve = "openSnap",
    },
    {
        leaf = "windowsOut",
        speed = 8,
        style = "gnomed",
        curve = "closeSmooth",
    },
    {
        leaf = "fade",
        speed = 10,
    },
    {
        leaf = "layers",
        speed = 9,
    },
    {
        leaf = "layersOut",
        speed = 12,
    },
}

hl.layer_rule(
    {
        name = "notifications_slide",
        match = {
            namespace = "notifications",
        },
        animation = "slide right",
    }
)

hl.config(config)

for i = 1, #curves do
    name, curve = table.unpack(curves[i])
    hl.curve(name, curve)
end

for i = 1, #animations do
    animation = preprocess_animation(animations[i])
    hl.animation(animation)
end
