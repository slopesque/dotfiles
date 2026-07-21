-- Autocommand groups

local yank_group = vim.api.nvim_create_augroup("yank", { clear = true })

-- Autocommands

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight upon yank",
    group = yank_group,
    callback = function()
        vim.hl.on_yank()
    end,
})
