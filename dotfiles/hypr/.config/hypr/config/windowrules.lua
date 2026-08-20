local window_rules = {
    -- Ignore maximize requests from apps
    {
        name = "ignore_max_requests",
        match = {
            class = ".*",
        },
        suppress_event = "maximize",
    },

    -- Fix dragging issues with XWaylad
    {
        name = "no_focus_on_xwayland_float",
        match = {
            class = "^$",
            title = "^$",
            xwayland = true,
            float = true,
            fullscreen = false,
            pin = false,
        },
        no_focus = true,
    },
}

for i = 1, #window_rules do
    hl.window_rule(window_rules[i])
end
