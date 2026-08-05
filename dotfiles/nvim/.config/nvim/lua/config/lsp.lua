local tables = require("utils.tables")

-- LSP Enabling

local lsp_files = vim.api.nvim_get_runtime_file("lsp/*.lua", true)
local lsps = tables.map(
    lsp_files,
    function(file)
        return vim.fn.fnamemodify(file, ":t:r")
    end
)

for _, lsp in ipairs(lsps) do
    vim.lsp.enable(lsp)
end


-- Visuals

vim.opt.pumborder = "rounded"
vim.opt.winborder = "rounded"


-- Autocompletion

vim.opt.autocomplete = true
vim.opt.complete:append("o")  -- Autocompletion strategy
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }

vim.api.nvim_create_autocmd(
    "LspAttach",
    {
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)

            if not client then
                return
            end

            if client:supports_method("textDocument/completion") then
                vim.lsp.completion.enable(
                    true,
                    client.id,
                    args.buf,
                    { autotrigger = true }
                )
            else
                local name = client.config.name
                vim.notify(
                    name .. " does not support completion. Autocompletion is "
                    .. "disabled.",
                    vim.log.levels.WARN
                )
            end

            if client:supports_method("textDocument/hover") then
                vim.api.nvim_create_autocmd(
                    { "InsertEnter", "CursorMovedI" },
                    {
                        desc = "Display Hover or Signature In Insert Mode",
                        buffer = args.buf,
                        callback = function()
                            local params = vim.lsp.util.make_position_params(
                                0,
                                client.offset_encoding
                            )

                            local options = {
                                anchor_bias = "above",
                                focusable = false,
                                silent = true
                            }

                            client:request(
                                "textDocument/signatureHelp",
                                params,
                                function(_, result)
                                    if not result then
                                        return 
                                    end

                                    local signatures = result.signatures

                                    if signatures and #signatures > 0 then
                                        vim.lsp.buf.signature_help(options)
                                        return
                                    end

                                    vim.lsp.buf.hover(options)
                                end
                            )
                        end
                    }
                )
            end
        end
    }
)

-- Keybinds

vim.keymap.set(
    "n",
    "gld",
    vim.diagnostic.open_float,
    { desc = "Display Diagnostics" }
)

vim.keymap.set(
    "n",
    "glh",
    vim.lsp.buf.hover,
    { desc = "Display Symbol Hover" }
)

vim.keymap.set(
    "n",
    "glk",
    vim.lsp.buf.signature_help,
    { desc = "Display Signature Help (only for function calls)" }
)
