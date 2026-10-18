local fzf = {}

local exec = require("utils.exec")
local fs = require("utils.fs")

-- Return the arguments needed for the fuzzy-finder previewer.
--
-- The default previewer is cat. If bat is available, it is used instead.
--
-- When cat is used, it is always returned with no arguments.
--
-- @param string[] extra arguments to provide to the previewer. extra args are
--                 only applied if bat is available
-- @return string[] A list of arguments
function fzf.previewer(extra_args)
    local previewer = "cat"

    if vim.fn.executable("bat") == 1 then
        previewer = string.format(
            '"bat --force-colorization --style=numbers %s "',
            extra_args and table.concat(extra_args, " ") or "{}"
        )
    end

    return previewer
end

-- Run the fuzzy-finder.
--
-- Interactions with the fuzzy-finder are provided using a new terminal popup
-- window.
--
-- `opts` may have the following arguments:
--   - args (string[]) - the arguments to provide to the fuzzy-finder
--   - callback ((string) -> void) - a callback used to handle the chosen file.
--                                   defaults to opening the file in edit mode
--   - cwd (string) - a path to a directory from which to run the fuzzy-finder
--   - fzf (string) - the name of the fuzzy-finder executable
--   - pipe_in (string[]) - a command to be used as input to the fuzzy-finder.
--                          the command and its arguments will be piped in to
--                          the fzf executable
--
-- @param opts the option with to use for the fuzzy-finder
function fzf.run(opts)
    opts = opts or {}

    local args = opts.args or {}
    local callback = opts.callback or fs.open
    local cwd = opts.cwd or nil
    local fzf = opts.fzf or "fzf"
    local pipe_in = opts.pipe_in or {}

    local cmd = pipe_in

    if #pipe_in > 0 then
        table.insert(cmd, "|")
    end

    table.insert(cmd, fzf)
    cmd = vim.list_extend(cmd, args)

    exec.display_interactive_window(
        cmd,
        {
            callback = callback,
            cwd = cwd,
            read_stdout = true,
        }
    )
end

return fzf
