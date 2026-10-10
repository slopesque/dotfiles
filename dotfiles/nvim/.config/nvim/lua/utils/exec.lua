local exec = {}

local windows = require("utils.windows")

--
-- Inner utilities
--

-- Shortcut to color magic values.
local COLORS = {
    RED = "\27[31m",
    RESET = "\27[0m",
}

-- Return a visible text-only view of the string
--
-- Params:
--   * str (string) - A string
--
-- Returns:
--   string - A view of the string without color magic values and trimmed on
--            the right.
local function purify_str(str)
    return (
        str
            :gsub("\27%[[%d;?]*[%a]", "")
            :gsub("%s+$", "")
    )
end

--
-- High-level API
--

function exec.display_command_popup(cmd, opts)
    if #cmd < 1 then
        vim.schedule(
            function()
                vim.notify(
                    "exec.lua: command input is empty",
                    vim.log.levels.ERROR
                )
            end
        )
    end

    local executable = cmd[1]

    if vim.fn.executable(executable) == 0 then
        vim.schedule(
            function()
                vim.notify(
                    executable .. " was not found in PATH",
                    vim.log.levels.ERROR
                )
            end
        )
        return
    end

    vim.system(
        cmd,
        { text = true },
        function(out)
            vim.schedule(
                function()
                    local output = out.stdout

                    if out.code != 0 then
                        error = executable .. " exited with code " .. out.code
                        output = (
                            COLORS.RED .. error .. "\n" .. out.stderr
                            .. COLORS.RESET
                        )
                        vim.notify(error, vim.log.levels.ERROR)
                    end

                    local lines = vim.split(
                        output,
                        '\n',
                        { trimempty = true }
                    )

                    local width = 10

                    for i = 1, #lines do
                        local clean_line = purify_str(lines[i])
                        width = math.max(
                            width,
                            vim.fn.strdisplaywidth(clean_line)
                        )
                    end

                    local opts = {
                        width = width,
                        height = #lines,
                    }

                    local popup = windows.open_popup(nil, opts)
                    local channel = vim.api.nvim_open_term(popup.buf, {})

                    vim.api.nvim_chan_send(channel, output)
                    vim.api.nvim_win_set_cursor(popup.win, { 1, 0 })
                end
            )
        end
    )
end

return exec
