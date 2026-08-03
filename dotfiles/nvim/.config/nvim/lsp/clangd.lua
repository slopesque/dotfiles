-- Based-on: https://github.com/neovim/nvim-lspconfig/blob/master/lsp/clangd.lua

-- https://clangd.llvm.org/extensions.html#switch-between-sourceheader
local function switch_source_header(bufnr, client)
    local method_name = 'textDocument/switchSourceHeader'

    ---@diagnostic disable-next-line:param-type-mismatch
    if not client or not client:supports_method(method_name) then
        return vim.notify(
            string.format(
                "method %s is not supported by any servers active on the "
                .. "current buffer",
                method_name
            )
        )
    end

    local params = vim.lsp.util.make_text_document_params(bufnr)

    ---@diagnostic disable-next-line:param-type-mismatch
    client:request(
        method_name,
        params,
        function(err, result)
            if err then
                error(tostring(err))
            end

            if not result then
                vim.notify('corresponding file cannot be determined')
                return
            end

            vim.cmd.edit(vim.uri_to_fname(result))
        end,
        bufnr
    )
end

---@class ClangdInitializeResult: lsp.InitializeResult
---@field offsetEncoding? string

---@type vim.lsp.Config
return {
    cmd = { 'clangd' },
    filetypes = {
        'c',
        'cpp',
        'objc',
        'objcpp',
        'cuda'
    },
    root_markers = {
      '.clangd',
      '.clang-tidy',
      '.clang-format',
      'compile_commands.json',
      'compile_flags.txt',
      'configure.ac',
      '.git',
    },
    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { 'utf-8', 'utf-16' },
    },
    get_language_id = function(_, ftype)
        local t = {
            objc = 'objective-c',
            objcpp = 'objective-cpp',
            cuda = 'cuda-cpp'
        }
        return t[ftype] or ftype
    end,
    ---@param init_result ClangdInitializeResult
    on_init = function(client, init_result)
        if init_result.offsetEncoding then
            client.offset_encoding = init_result.offsetEncoding
        end
    end,
    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(
            bufnr,
            'LspClangdSwitchSourceHeader',
            function()
                switch_source_header(bufnr, client)
            end,
            { desc = 'Switch between source/header' }
        )
    end,
}
