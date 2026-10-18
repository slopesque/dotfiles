local exec = require("utils.exec")
local files_manager = require("apps.files_manager")
local fs = require("utils.fs")
local fzf = require("apps.fzf")
local git = require("apps.git")
local tables = require("utils.tables")

--
-- Utilities
--

local function get_current_file()
    local current_path = vim.api.nvim_buf_get_name(0)

    if current_path == nil or current_path == "" then
        return nil
    end

    return current_path
end

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
        local current_path = get_current_file()

        if current_path == nil then
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

--
-- Fuzzy-finder
--

vim.api.nvim_create_user_command(
    "FzfFiles",
    function(opts)
        local path = opts.fargs[1]

        local args = {
            "--preview",
            fzf.previewer(),
            "--preview-window",
            "right:55%",
        }

        fzf.run(
            {
                args = args,
                cwd = path,
            }
        )
    end,
    {
        nargs = "*",
        complete = "dir",
        desc = "Run fuzzy-finder (on files)",
    }
)

vim.api.nvim_create_user_command(
    "FzfBuffers",
    function()
        local buffers = vim.api.nvim_list_bufs()

        local buffer_names = {}

        for i = 1, #buffers do
            if vim.api.nvim_buf_is_valid(buffers[i]) then
                local name = vim.api.nvim_buf_get_name(buffers[i])

                if name != "" and not string.find(name, "notify") then
                    local clean_name = vim.fn.fnamemodify(name, ":.")
                    table.insert(buffer_names, clean_name)
                end
            end
        end

        local args = {
            "--preview",
            fzf.previewer(),
            "--preview-window",
            "right:55%",
        }

        local pipe_in = {
            "echo",
            "-e",
            table.concat(buffer_names, "\\\\n"),
        }

        fzf.run(
            {
                args = args,
                pipe_in = pipe_in,
            }
        )
    end,
    {
        nargs = 0,
        desc = "Run fuzzy-finder (on buffers)",
    }
)

vim.api.nvim_create_user_command(
    "FzfGrep",
    function(opts)
        local pattern = opts.fargs[1]

        if pattern == nil then
            vim.ui.input(
                {
                    prompt = "Specify grep pattern: ",
                },
                function(input)
                    pattern = input
                end
            )
        end

        if pattern == "" then
            return
        end

        local pipe_in = {
            "rg",
            "--color=never",
            "--no-heading",
            "--line-number",
            pattern,
        }

        local preview_args = {
            "--highlight-line={2}",
            "--line-range={2}:",
            "{1}",
        }

        local args = {
            "--delimiter",
            ":",
            "--preview",
            fzf.previewer(preview_args),
            "--preview-window",
            "right:55%",
        }

        fzf.run(
            {
                args = args,
                pipe_in = pipe_in,
                callback = function(choice)
                    local file, line = string.match(choice, "^(.*):(%d+):.*$")
                    fs.open(file)
                    vim.api.nvim_win_set_cursor(0, { tonumber(line), 0 })
                end,
            }
        )
    end,
    {
        nargs = "*",
        desc = "Run fuzzy-finder (over ripgrep)",
    }
)

--
-- Applications
--

vim.api.nvim_create_user_command(
    "FilesManager",
    function(opts)
        local path = opts.fargs[1]

        if path == "" then
            path = nil
        end

        if path == nil then
            path = git.get_repository_root()
        end

        if path == nil then
            path = vim.fn.getcwd()
        end

        files_manager.run(
            {
                path = path,
            }
        )
    end,
    {
        nargs = "*",
        complete = "dir",
        desc = "Run Yazi file manager",
    }
)

vim.api.nvim_create_user_command(
    "Fastfetch",
    function(opts)
        local fastfetch = "fastfetch"
        local cmd = { fastfetch, "--logo", "auto", "--pipe", "false" }
        exec.display_command_popup(cmd)
    end,
    {
        nargs = 0,
        desc = "Run fastfetch",
    }
)

vim.api.nvim_create_user_command(
    "Onefetch",
    function(opts)
        local onefetch = "onefetch"
        local path = opts.fargs[1]

        if path == nil then
            path = get_current_file()
            path = git.get_repository_root(path)
        end

        local cmd = { onefetch, "--nerd-fonts", path }
        exec.display_command_popup(cmd)
    end,
    {
        nargs = "*",
        complete = "dir",
        desc = "Run onefetch",
    }
)
