return {
    get_configuration = function()
        return {
            notify_on_error = true,
            format_on_save = function(bufnr)
                -- Disable "format_on_save lsp_fallback" for languages that don't
                -- have a well standardized coding style. You can add additional
                -- languages here or re-enable it for the disabled ones.
                local disable_filetypes = { txt = true }
                return disable_filetypes[vim.bo[bufnr].filetype] and nil
                    or {
                        timeout_ms = 3000, -- Nix formatter can be slow
                        lsp_format = "fallback",
                    }
            end,
            formatters = require("config.plugins.formatters.types").get_formatters(),
            formatters_by_ft = require("config.plugins.formatters.formatters").get_formatters(),
        }
    end,
}
