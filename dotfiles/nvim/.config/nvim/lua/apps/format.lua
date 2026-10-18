local format = {}

local colors = require("utils.colors")
local windows = require("utils.windows")

--
-- Utility functions
--

-- Based-on: https://github.com/stevearc/conform.nvim
local formatters = {
    alejandra = {
        command = "alejandra",
    },
    ["clang-format"] = {
        command = "clang-format",
    },
    mdformat = {
        command = "mdformat",
        args = { "-" },
    },
    nix = {
        command = "nix",
        args = { "fmt" },
    },
    ruff = {
        command = "ruff",
        args = { "format", "--force-exclude", "-" },
    },
    rustfmt = {
        command = "rustfmt",
        args = { "--emit=stdout" },
    },
    stylua = {
        command = "stylua",
        args = {
            "--search-parent-directories",
            "--respect-ignores",
            "-",
        },
    },
    ["tex-fmt"] = {
        command = "tex-fmt",
        args = { "--stdin" }
    },
}

local formatters_by_ft = {
    c = { "clang-format" },
    cpp = { "clang-format" },
    cuda = { "clang-format" },
    lua = { "stylua" },
    markdown = { "mdformat" },
    nix = { "nix", "alejandra" },
    python = { "ruff" },
    rust = { "rustfmt" },
    tex = { "tex-fmt" }
}

-- Show an error in a new popup window.
--
-- @param cmd string the executable that was run
-- @param code int an exit code
-- @param reason string the content of the error
local function show_error(cmd, code, reason)
    local message = string.format(
        "%s exited with code %d\n%s",
        cmd,
        code,
        reason
    )

    local lines = vim.split(message, '\n', { trimempty = true })

    local width = 10

    for i = 1, #lines do
        width = math.max(
            width,
            vim.fn.strdisplaywidth(lines[i])
        )
    end

    local opts = {
        width = width,
        height = #lines,
    }

    local popup = windows.open_popup(nil, opts)
    local channel = vim.api.nvim_open_term(popup.buf, {})

    vim.api.nvim_chan_send(channel, colors.wrap_in(message, colors.RED))
    vim.api.nvim_win_set_cursor(popup.win, { 1, 0 })
end

-- Get an available formatter depending on filetype.
--
-- @param filetype string a filetype
-- @return table a formatter
local function get_formatter(filetype)
    local formatters_query = formatters_by_ft[filetype]
    local formatter = nil

    for _, query_name in ipairs(formatters_query) do
        if formatter == nil then
            query = formatters[query_name]

            if query != nil and vim.fn.executable(query.command) then
                formatter = query
            end
        end
    end

    return formatter
end

-- Format a buffer.
--
-- The formatter applied on the buffer is defined by filetype.
--
-- The formatter is run along with the buffer content in a new shell command.
-- It may be processed asynchronously using a callback passed as parameter.
--
-- opts may accept the following parameters:
--   - timeout int a maximum duration for the formatter command. set by default
--                 to 5 seconds
--
-- @param buf int a buffer id
-- @param filetype string a filetype
-- @param callback ((string) -> void) a callback to process the result returned
--                                    by the formatter. set to a noop callback
--                                    by default
-- @param opts table a table of options
local function format_buf(buf, filetype, callback, opts)
    local callback = callback or function(out) end
    local opts = opts or {}
    local timeout = opts.timeout or 5000

    local formatter = get_formatter(filetype)

    if not formatter then
        vim.notify(
            "format: no formatter found for filetype " .. (filetype or "nil"),
            vim.log.levels.WARN
        )
        return
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, "\n")

    local cmd = formatter.command
    local args = formatter.args or {}
    local script_args = { cmd, unpack(args) }
    local script = table.concat(script_args, " ")

    vim.system(
        { "/bin/sh", "-c", script },
        {
            stdin = content,
            stdout = true,
            stderr = true,
            timeout = timeout,
        },
        function(out)
            if out.code == 124 then
                vim.notify(
                    string.format(
                        "format: %s timed out after %.2f ms",
                        cmd,
                        timeout
                    ),
                    vim.log.levels.WARN
                )
                return
            end

            if out.code != 0 then
                vim.notify(
                    string.format(
                        "format: %s exited with exit code %d",
                        cmd,
                        out.code
                    ),
                    vim.log.levels.ERROR
                )

                vim.schedule(
                    function()
                        show_error(cmd, out.code, out.stderr)
                    end
                )

                return
            end

            callback(out.stdout)
        end
    )
end

--
-- Public API
--

format.formatters = formatters
format.formatters_by_ft = formatters_by_ft

-- Format the buffer.
--
-- The right formatter is called depending on the buffer's filetype.
--
-- `opts` may have the following parameters :
--   - timeout (int) - a maximum duration for the formatter command
--
-- @param buf int a buffer id. defaults to 0 (the current buffer)
-- @param opts a table of options
function format.run(buf, opts)
    local buf = buf or 0
    local opts = opts or {}

    if not vim.api.nvim_buf_is_valid(buf) then
        vim.notify(
            "format: cannot proceed. buffer is invalid",
            vim.log.levels.ERROR
        )
    end

    local filetype = vim.bo[buf].filetype
    local timeout = opts.timeout or 5000

    format_buf(
        buf,
        filetype,
        function(out)
            local lines = vim.split(out, "\n", { trimempty = 1 })

            if #lines == 0 or lines[1] == "" then
                vim.notify(
                    "format: output is empty. cancelling buffer update by "
                    .. "security",
                    vim.log.levels.WARN
                )
                return
            end

            vim.schedule(
                function()
                    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
                end
            )
        end,
        {
            timeout = timeout,
        }
    )
end

return format
