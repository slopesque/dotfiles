vim.g.autoformat_enabled = false 

local function toggle_autoformat()
    vim.g.autoformat_enabled = not vim.g.autoformat_enabled

    local new_mode

    if vim.g.autoformat_enabled then
        new_mode = "enabled"
    else
        new_mode = "disabled"
    end

    vim.notify("Autoformat " .. new_mode, vim.log.levels.INFO)
end

local configuration = {
    notify_on_error = true,
    formatters = {
        nix = { command = "nix", args = { "fmt" } }
    },
    formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        lua = { "stylua" },
        markdown = {},
        nix = { "nix", "alejandra", "nixfmt" },
        python = { "ruff" },
        rust = { "rustfmt" },
        tex = { "tex-fmt" }
    },
    format_on_save = function()
        if not vim.g.autoformat_enabled then
            return nil
        end

        return {
            timeout_ms = 5000,
            lsp_format = "fallback"
        }
    end,
}

return {
    {
        src = "https://github.com/stevearc/conform.nvim",
        entrypoint = "conform",
        options = configuration,
        post_config = function()
            vim.keymap.set(
                "n",
                "<leader>lf",
                function()
                    require("conform").format(
                        {
                            async = true,
                            lsp_format = "fallback"
                        }
                    )
                end,
                {
                    desc = "Format buffer"
                }
            )

            vim.keymap.set(
                "n",
                "<leader>lF",
                toggle_autoformat,
                {
                    desc = "Toggle autoformat"
                }
            )
        end
    }
}
