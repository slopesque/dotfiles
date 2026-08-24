local web_devicons = {
    "https://github.com/nvim-tree/nvim-web-devicons"
}

return {
    -- Global Theme
    {
        src = "https://github.com/folke/tokyonight.nvim",
        entrypoint = "tokyonight",
        priority = 100,
        options = {
            transparent = true,
            styles = {
                comments = { italic = false },
                sidebars = "transparent",
                floats = "transparent",
            }
        },
        post_config = function()
            vim.cmd.colorscheme("tokyonight-night")
        end
    },

    -- Status Line
    {
        src = "https://github.com/nvim-lualine/lualine.nvim",
        entrypoint = "lualine",
        dependencies = { web_devicons },
        options = {
            options = {
                theme = "tomorrow_night",

                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },

                refresh = {
                    statusline = 100,
                    tabline = 100,
                    winbar = 100
                }
            }
        }
    },

    -- Notifications
    {
        src = "https://github.com/nvim-mini/mini.notify"
    },

    -- Utilities
    {
        src = "https://github.com/lukas-reineke/indent-blankline.nvim",
        entrypoint = "ibl"
    }
}
