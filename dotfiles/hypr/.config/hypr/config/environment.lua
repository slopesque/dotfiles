local env = require("config.env")

hl.env("HYPRCURSOR_SIZE", env.vars.cursor_size)
hl.env("HYPRCURSOR_THEME", env.vars.cursor_theme)
--
hl.env("XCURSOR_SIZE", env.vars.cursor_size)
hl.env("XCURSOR_THEME", env.vars.cursor_theme)
