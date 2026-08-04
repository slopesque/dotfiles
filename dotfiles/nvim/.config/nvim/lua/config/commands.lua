local git = require("utils.git")
local tables = require("utils.tables")

--
-- Utilities
--

local function validate_path(path)
    local path_exists = (
        vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
    )

    if not path_exists then
        vim.notify(path .. " does not exist", vim.log.levels.ERROR)
        return false
    end

    return true
end

local function perform(paths, callback)
    if #paths < 1 then
        local current_path = vim.api.nvim_buf_get_name(0)

        if current_path == nil or current_path == "" then
            vim.notify(
                "Current buffer doesn't refer to a file !",
                vim.log.levels.ERROR
            )
            return
        end

        table.insert(paths, current_path)
    end

    paths = tables.map(paths, vim.fs.abspath)

    if not tables.all(tables.map(paths, validate_path)) then
        return
    end

    callback(paths)
end

--
-- Shortcuts
--

vim.api.nvim_create_user_command(
    "StartTerminal",
    function(opts)
        vim.cmd("vs")
        vim.cmd("terminal")
        vim.cmd("startinsert")
    end,
    {
        nargs = 0,
        desc = "Open a new terminal window"
    }
)

--
-- Git commands
--

vim.api.nvim_create_user_command(
    "GitAdd",
    function(opts)
        local paths = opts.fargs
        perform(paths, git.add)
    end,
    {
        nargs = "*",
        complete = "file",
        desc = "Add files to Git stage"
    }
)

vim.api.nvim_create_user_command(
    "GitCommit",
    function(opts)
        local amend = opts.fargs[1]
        amend = amend ~= nil and amend == "true"

        local function process_commit(message, amend)
            if not amend and (not message or message == "") then
                vim.notify(
                    "Message was empty, commit aborted",
                    vim.log.levels.WARN
                )
                return
            end

            vim.cmd("redraw")
            git.commit(message, amend)
        end

        if amend then
            process_commit(nil, amend)
        else
            vim.ui.input(
                {
                    prompt = "Write down commit message: "
                },
                function(input)
                    process_commit(input, amend)
                end
            )
        end
    end,
    {
        nargs = "?",
        complete = function(input)
            local options = { "true", "false" }

            return vim.tbl_filter(
                function(value)
                    return vim.startswith(value, input)
                end,
                options
            )
        end,
        desc = "Commit changes"
    }
)

vim.api.nvim_create_user_command(
    "GitLog",
    function(opts)
        git.log()
    end,
    {
        nargs = 0,
        desc = "Display current Git tree"
    }
)

vim.api.nvim_create_user_command(
    "GitRestore",
    function(opts)
        local paths = opts.fargs
        perform(paths, git.restore)
    end,
    {
        nargs = "*",
        complete = "file",
        desc = "Reset files to last Git state"
    }
)

vim.api.nvim_create_user_command(
    "GitUnstage",
    function(opts)
        local paths = opts.fargs
        perform(paths, git.unstage)
    end,
    {
        nargs = "*",
        complete = "file",
        desc = "Unstage files from Git stage"
    }
)
