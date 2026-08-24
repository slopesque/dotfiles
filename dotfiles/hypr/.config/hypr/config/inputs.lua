local variables = {
    input = {
        kb_layout = "fr,us",
        kb_variant = ",",
        kb_model = "",
        kb_options = "grp:win_space_toggle",
        kb_rules = "",

        follow_mouse = 1,

        sensitivity = 0,

        touchpad = {
            natural_scroll = false
        }
    }
}

local gestures = {
    { fingers = 3, direction = "horizontal", action = "workspace" },
    { fingers = 3, direction = "up"        , action = "fullscreen" },
    { fingers = 3, direction = "down"      , action = "close" },
}

hl.config(variables)

for _, gesture in ipairs(gestures) do
    hl.gesture(gesture)
end
