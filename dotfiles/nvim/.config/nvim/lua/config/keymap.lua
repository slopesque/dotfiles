--
-- Less boring shortcuts
--

-- Esc+Esc --> Exit terminal mode (shortcut)
vim.keymap.set(
    "t",
    "<Esc><Esc>",
    "<C-\\><C-n>",
    { desc = "Exit terminal mode" }
)

-- CTRL+<hjikl> --> Switch focused window (shortcut)
vim.keymap.set(
    "n",
    "<C-h>",
    "<C-w><C-h>",
    { desc = "Move focus to the left window" }
)
vim.keymap.set(
    "n",
    "<C-l>",
    "<C-w><C-l>",
    { desc = "Move focus to the right window" }
)
vim.keymap.set(
    "n",
    "<C-j>",
    "<C-w><C-j>",
    { desc = "Move focus to the lower window" }
)
vim.keymap.set(
    "n",
    "<C-k>",
    "<C-w><C-k>",
    { desc = "Move focus to the upper window" }
)

--
-- Utilitaries
--

-- <Esc> --> Clear all search result highlights
vim.keymap.set(
    "n",
    "<Esc>",
    "<cmd>nohlsearch<CR>",
    { desc = "Clear all search highlights" }
)

vim.keymap.set(
    "n",
    "<leader>t",
    "<cmd>StartTerminal<CR>",
    { desc = "Open a new terminal window" }
)

--
-- Git
--

vim.keymap.set(
    "n",
    "<leader>ga",
    "<cmd>GitAdd<CR>",
    { desc = "Stage the current file to Git" }
)

vim.keymap.set(
    "n",
    "<leader>gc",
    "<cmd>GitCommit false<CR>",
    { desc = "Commit changes" }
)

vim.keymap.set(
    "n",
    "<leader>gC",
    "<cmd>GitCommit true<CR>",
    { desc = "Amend commit with staged changes" }
)

vim.keymap.set(
    "n",
    "<leader>gl",
    "<cmd>GitLog<CR>",
    { desc = "Display Git history" }
)

vim.keymap.set(
    "n",
    "<leader>gr",
    function()
        vim.notify(
            "Did you mean to request a file reset ? Use <leader>gR !",
            vim.log.levels.WARN
        )
    end,
    { desc = "Nothing (raise a warning for reset)" }
)

vim.keymap.set(
    "n",
    "<leader>gR",
    "<cmd>GitRestore<CR>",
    { desc = "Reset the current file to last Git state" }
)

vim.keymap.set(
    "n",
    "<leader>gu",
    "<cmd>GitUnstage<CR>",
    { desc = "Unstage the current file from Git" }
)

--
-- Spelling Assistance
--

local function toggle_spell(enable, language)
    vim.opt_local.spell = enable
    vim.opt_local.spelllang = language or ""
end

vim.keymap.set(
    "n",
    "<leader>see",
    function()
        toggle_spell(true, "en_us")
    end,
    { desc = "Enable spelling checker for English" }
)

vim.keymap.set(
    "n",
    "<leader>sef",
    function()
        toggle_spell(true, "fr_fr,en_us")
    end,
    { desc = "Enable spelling checker for French" }
)

vim.keymap.set(
    "n",
    "<leader>se/",
    function()
        local language = vim.ui.input()
        toggle_spell(true, language)
    end,
    { desc = "Enable spelling checker for a custom language" }
)

vim.keymap.set(
    "n",
    "<leader>sd",
    function()
        toggle_spell(false)
    end,
    { desc = "Disable spelling checker" }
)

vim.keymap.set(
    "n",
    "<leader>sc",
    "=z",
    { desc = "Correct word spelling" }
)

vim.keymap.set(
    "n",
    "<leader>sa",
    "zG",
    { desc = "Add word as a good spell in memory" }
)
