local files_manager = {}

local exec = require("utils.exec")
local fs = require("utils.fs")

-- Run the file manager.
--
-- The selected file will be opened by Neovim in edit mode.
--
-- `opts` may have the following parameters:
--   - callback ((string) -> void) - a callback to handle the selected file.
--                                   defaults to opening the file
--   - path (string) - the path from which to open the file manager
function files_manager.run(opts)
    local callback = opts.callback or fs.open
    local path = opts.path

    local yazi = "yazi"
    local cmd = { yazi, "--chooser-file=/dev/stdout", path }

    exec.display_interactive_window(
        cmd,
        {
            callback = fs.open,
            cwd = path,
            read_stdout = true,
        }
    )
end

return files_manager
