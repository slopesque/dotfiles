local strings = require("utils.strings")

DUMP_MAX_LENGTH = 60

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

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = "Dump text upon yank",
    group = yank_group,
    callback = function()
        local dumped_text = vim.fn.getreg('"')
        local bytes_size = #dumped_text
        local _, lines_count = string.gsub(dumped_text, "\n", "")

        dumped_text = strings.pretty_print_str(dumped_text, DUMP_MAX_LENGTH)

        local output = string.format(
            "Yanking: `%s` ; %iB %iL",
            dumped_text,
            bytes_size,
            lines_count
        )

        vim.notify(output)
    end,
})
