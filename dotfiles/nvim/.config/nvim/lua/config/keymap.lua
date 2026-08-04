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
