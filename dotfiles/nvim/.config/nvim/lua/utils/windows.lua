local windows = {}

local buffers = require("utils.buffers")

--
-- Window Templates
--

-- Open a new popup window.
--
-- A popup window is basically just a centered floating window. :p
--
-- Options can be specified as a table with the following keys. All keys are
-- optional:
--   * width (int) - The width of the window
--   * height (int) - The height of the window
--   * columns (int) - The number of columns of the window
--   * rows (int) - The number of rows of the window
--   * position (string) - The relative position of the window.
--
-- Params:
--   * buf (int) - The buffer to associate with the window. If nil, a new buffer
--                 will be defined instead.
--   * opts (table) - The options to define the window. See description.
--
-- Returns:
--   table - A new table containing the window's information. buf contains the
--           window's buffer id, and win contains the id of the window itself.
function windows.open_popup(buf, opts)
    if buf == nil then
        buf = buffers.create_temporary_buf()
    end

    if opts == nil then
        opts = {}
    end

    local max_width = math.floor(vim.o.columns * 0.8)
    local max_height = math.floor(vim.o.lines * 0.8)

    local position = opts.position or "editor"
    local width = opts.width or math.floor(vim.o.columns * 0.7)
    local height = opts.height or math.floor(vim.o.lines * 0.7)

    width = math.min(width, max_width)
    height = math.min(height, max_height)

    local columns = opts.columns or (math.floor((vim.o.columns - width) / 2))
    local rows = opts.rows or (math.floor((vim.o.lines - height) / 2) - 1)

    local win = vim.api.nvim_open_win(
        buf,
        true,
        {
            relative = position,
            width = width,
            height = height,
            col = columns,
            row = rows,
            style = "minimal",
        }
    )

    local function close_win()
        if not vim.api.nvim_win_is_valid(win) then
            return
        end

        vim.api.nvim_win_close(win, true)
    end

    vim.keymap.set(
        "n",
        "<Esc><Esc>",
        close_win,
        {
            desc = "Close popup",
            buffer = buf,
        }
    )

    vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" },
        {
            buffer = buf,
            callback = function()
                vim.schedule(close_win)
            end,
        }
    )

    return { buf = buf, win = win }
end

return windows
