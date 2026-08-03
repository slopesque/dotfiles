return {
    cmd = { "emmylua_ls" },
    filetypes = { "lua" },
    root_markers = {
        { ".emmyrc.json", ".emmyrc.lua", ".luarc.json" },
        ".git"
    },
    settings = {
        runtime = {
            version = "LuaJIT"
        }
    }
}
