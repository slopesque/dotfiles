return {
    {
        src = "https://github.com/romus204/tree-sitter-manager.nvim",
        entrypoint = "tree-sitter-manager",
        options = {
            auto_install = true,
            -- NOTE: skip neovim's builtin parsers
            noauto_install = {
                "c",
                "lua",
                "markdown",
                "markdown_inline",
                "query",
                "vim",
                "vimdoc"
            }
        },
        post_config = function()
            vim.keymap.set(
                "n",
                "<leader>tm",
                "<cmd>TSManager<CR>",
                { desc = "Display Tree-Sitter Manager" }
            )
        end
    }
}
