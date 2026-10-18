local exec = {}

local colors = require("utils.colors")
local windows = require("utils.windows")

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
                        output = colors.wrap_in(
                            error .. "\n" .. out.stderr,
                            colors.RED
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

function exec.display_interactive_window(args, opts)
    if not opts then
        opts = {}
    end

    if #args < 1 then
        vim.schedule(
            function()
                vim.notify(
                    "exec.lua: command input is empty",
                    vim.log.levels.ERROR
                )
            end
        )
    end

    local executable = args[1]

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

    local stdout_buf = nil
    local popup = windows.open_popup(nil, {})

    local function close_popup()
        if not vim.api.nvim_win_is_valid(popup.win) then
            return
        end

        vim.api.nvim_win_close(popup.win, true)
    end

    vim.keymap.set(
        "t",
        "<Esc><Esc>",
        close_popup,
        {
            desc = "Close terminal popup",
            buffer = popup.buf,
        }
    )

    local cmd = table.concat(args, " ")

    if opts.read_stdout then
        stdout_buf = vim.fn.tempname()
        cmd = string.format("%s > %s", cmd, stdout_buf)
    end

    local callback = opts.callback or function() end
    local cwd = opts.cwd or nil

    vim.fn.jobstart(
        { "sh", "-c", cmd },
        {
            cwd = cwd,
            term = true,
            on_exit = function(_, _, _)
                vim.schedule(
                    function()
                        close_popup()

                        if not stdout_buf then
                            return
                        end

                        local ok, lines = pcall(vim.fn.readfile, stdout_buf)

                        if not ok then
                            vim.notify(
                                executable .. " popup: failed to read output file",
                                vim.log.levels.ERROR
                            )
                            return
                        end

                        os.remove(stdout_buf)

                        if #lines < 1 then
                            return
                        end

                        local choice = lines[1]

                        callback(choice)
                    end
                )
            end,
        }
    )
    vim.cmd.startinsert()
end

return exec
