local git = {}

-- Utilities

local function check_success(out)
    if out.code ~= 0 then
        vim.schedule(
            function()
                vim.notify(
                    "git command failed: " .. out.stderr,
                    vim.log.levels.ERROR
                )
            end
        )
        return false
    end

    return true
end

-- Interface

function git.add(paths)
    local command = { "git", "add", unpack(paths) }

    local function process_output(out)
        if not check_success(out) then
            return
        end

        vim.schedule(
            function()
                vim.notify(#paths .. " path(s) added", vim.log.levels.INFO)
            end
        )
    end

    vim.system(command, { text = true }, process_output)
end

function git.commit(message, amend)
    local command = { "git", "commit" }

    local function process_output(out)
        if not check_success(out) then
            return
        end

        vim.system(
            { "git", "rev-parse", "HEAD" },
            { text = true },
            function(subout)
                assert(subout.code == 0)
                local commit_hash = subout.stdout
                vim.schedule(
                    function()
                        vim.notify(
                            "Commit created with hash: " .. commit_hash,
                            vim.log.levels.INFO
                        )
                    end
                )
            end
        )
    end

    if amend then
        command = vim.list_extend(command, { "--amend", "--no-edit" })
    else
        assert(message and message ~= "", "message is empty, cannot commit")
        command = vim.list_extend(command, { "-m", message })
    end

    vim.system(command, { text = true }, process_output)
end

function git.log(paths)
    local command = { "git", "log", "--graph" }

    local function process_output(out)
        if out.code ~= 0 then
            vim.schedule(
                function()
                    vim.notify(
                        "Displaying tree failed: " .. out.stderr,
                        vim.log.levels.ERROR
                    )
                end
            )
            return
        end

        vim.schedule(
            function()
                local output_lines = vim.split(out.stdout, "\n")
                local buffer = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_lines(buffer, 0, -1, true, output_lines)

                vim.api.nvim_buf_set_option(buffer, "bufhidden", "wipe")
                vim.api.nvim_buf_set_option(buffer, "filetype", "git")
                vim.api.nvim_buf_set_option(buffer, "modifiable", false)

                vim.cmd("vsplit")
                local new_window = vim.api.nvim_get_current_win()
                vim.api.nvim_win_set_buf(new_window, buffer)
            end
        )
    end

    vim.system(command, { text = true }, process_output)
end

function git.restore(paths)
    local command = { "git", "restore", unpack(paths) }

    local function process_output(out)
        if not check_success(out) then
            return
        end

        vim.schedule(
            function()
                local buffers = vim.api.nvim_list_bufs()

                for _, buffer in ipairs(buffers) do
                    local name = vim.api.nvim_buf_get_name(buffer)

                    if name and name ~= "" then
                        local path = vim.fs.abspath(name)

                        if vim.tbl_contains(paths, path) then
                            vim.api.nvim_buf_call(
                                buffer,
                                function()
                                    vim.cmd("edit!")
                                end
                            )
                        end
                    end
                end
            end
        )
    end

    vim.system(command, { text = true }, process_output)
end

function git.unstage(paths)
    local command = { "git", "restore", "--staged", unpack(paths) }

    local function process_output(out)
        if not check_success(out) then
            return
        end

        vim.schedule(
            function()
                vim.notify(#paths .. " path(s) unstaged", vim.log.levels.INFO)
            end
        )
    end

    vim.system(command, { text = true }, process_output)
end

return git
