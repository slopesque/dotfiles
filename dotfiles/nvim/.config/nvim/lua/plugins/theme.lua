return {
    {
        src = "https://github.com/folke/tokyonight.nvim",
        priority = 100,
        config = function()
            require("tokyonight").setup({
                transparent = true,
                styles = {
                    comments = { italic = false },
                    sidebars = "transparent",
                    floats = "transparent",
                },
            })

            vim.cmd.colorscheme("tokyonight-night")
        end
    }
}
