return {
    {
        "https://github.com/lewis6991/gitsigns.nvim",
        entrypoint = "gitsigns",
        options = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
        },
    }
}
