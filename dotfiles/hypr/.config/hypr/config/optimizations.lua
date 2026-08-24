local env = require("config.env")

if env.vars.LAPTOP_MODE then
    hl.config(
        {
            decoration = {
                blur = { enabled = false },
                shadow = { enabled = false },
            }
        }
    )
end

