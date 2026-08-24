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

local function enable_completion(client, buffer)
    if not client:supports_method("textDocument/completion") then
        vim.notify(
            client.name .. " does not support completion. Autocompletion is "
            .. "disabled.",
            vim.log.levels.WARN
        )
    end

    local completion_config = { autotrigger = true }

    vim.lsp.completion.enable(true, client.id, buffer, completion_config)
end

local function enable_hover(client, buffer, group)
    if not client:supports_method("textDocument/hover") then
        vim.notify(
            client.name .. " does not support hover. Hover assistance is "
            .. "disabled.",
            vim.log.levels.WARN
        )
        return
    end

    local supports_signature_help =
        client:supports_method("textDocument/signatureHelp")

    if not supports_signature_help then
        vim.notify(
            client.name .. " supports hover but not signature help. Signature "
            .. "help assistance is disabled.",
            vim.log.levels.WARN
        )
    end

    vim.api.nvim_create_autocmd(
        { "InsertEnter", "CursorMovedI" },
        {
            desc = "Display Hover or Signature In Insert Mode",
            group = group,
            buffer = buffer,
            callback = function()
                local window_options = {
                    anchor_bias = "above",
                    focusable = false,
                    silent = true
                }

                if not supports_signature_help then
                    vim.lsp.buf.hover(window_options)
                    return
                end

                client:request(
                    "textDocument/signatureHelp",
                    vim.lsp.util.make_position_params(
                        0,
                        client.offset_encoding
                    ),
                    function(err, result)
                        if err then
                            vim.notify(
                                "Signature Help failed: " .. err.message,
                                vim.log.levels.ERROR)
                            return
                        end

                        local signatures = result and result.signatures

                        if signatures and #signatures > 0 then
                            vim.lsp.buf.signature_help(window_options)
                            return
                        end

                        vim.lsp.buf.hover(window_options)
                    end
                )
            end
        }
    )
end

local function enable_auto_format(client, buffer, group)
    if not client:supports_method("textDocument/format") then
        return
    end

    vim.api.nvim_create_autocmd(
        "BufWritePre",
        {
            desc = "Format file before saving (if enabled)",
            group = group,
            buf = buffer,
            callback = function(args)
                if not vim.g.autoformat_enabled then
                    return
                end

                local buffer_id = buffer
                local full_name = args.file
                local name = vim.fn.fnamemodify(full_name, ":t")

                local format_config = {
                    async = false,
                    bufnr = buffer_id,
                    id = client.id,
                    timeout_ms = 5000,
                }

                vim.lsp.buf.format(format_config)
                vim.notify(name .. " autoformatted")
            end,
        }
    )
end

vim.api.nvim_create_autocmd(
    "LspAttach",
    {
        desc = "Initialize LSP utilities",
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)

            if not client then
                return
            end

            enable_completion(client, args.buf)
            enable_hover(client, args.buf)
        end
    }
)

-- Keybinds

vim.keymap.set(
    "n",
    "<space>la",
    vim.lsp.buf.code_action,
    { desc = "Display Code Actions" }
)

vim.keymap.set(
    "n",
    "<space>ld",
    vim.lsp.buf.definition,
    { desc = "Go to Symbol Definition" }
)

vim.keymap.set(
    "n",
    "<space>lD",
    vim.diagnostic.open_float,
    { desc = "Display Diagnostics" }
)

vim.keymap.set(
    "n",
    "<space>lh",
    vim.lsp.buf.hover,
    { desc = "Display Symbol Hover" }
)

vim.keymap.set(
    "n",
    "<space>lj",
    vim.lsp.buf.signature_help,
    { desc = "Display Signature Help" }
)

vim.keymap.set(
    "n",
    "<space>li",
    vim.lsp.buf.implementation,
    { desc = "Display symbol implementations" }
)

vim.keymap.set(
    "n",
    "<space>ln",
    vim.lsp.buf.rename,
    { desc = "Rename symbol" }
)

vim.keymap.set(
    "n",
    "<space>lr",
    vim.lsp.buf.references,
    { desc = "Display symbol references" }
)
