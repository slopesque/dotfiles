local picker_key = "<Space><Space>"

-- Bind a picker to the current Neovim keymap.
--
-- Any picker can be activated using the <Space><Space> key combination, along
-- with the dedicated key for the picker.
--
-- @param key string The key combination associated with the picker
-- @param picker string The picker to run
-- @param desc string An elegant description for the new picker keymap
local function bind_picker(key, picker, desc)
    vim.keymap.set(
        "n",
        picker_key .. key,
        "<cmd>Pick " .. picker .. "<CR>",
        { desc = desc }
    )
end

return {
    {
        src = "https://github.com/nvim-mini/mini.pick",
        post_config = function(self)
            bind_picker("b", "buffers", "Open Buffers Picker")
            bind_picker("f", "files", "Open Files Picker")
            bind_picker("g", "grep", "Open Grep Pattern Picker")
            bind_picker("h", "help", "Open Help Pages Picker")
            bind_picker("r", "resume", "Open Last Opened Picker")
        end
    },
    {
        src = "https://github.com/folke/which-key.nvim",
        entrypoint = "which-key"
    }
}
