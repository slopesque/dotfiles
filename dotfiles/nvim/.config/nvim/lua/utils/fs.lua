local fs = {}

-- Variables

fs.config_path = vim.fn.stdpath("config") .. "/lua"

-- Functions

-- @alias PatternCallback fun(name: string, path: string): boolean

-- Returns all the files stored in the directory.
--
-- This processes the directory recursively.
--
-- @param path string A relative or absolute path to the directory to process
-- @param pattern PatternCallback|nil A pattern that the file should satisfy
-- @return string[] A list containing the path of each file satisfying the
--                  pattern
function fs.ls_dir(path, pattern)
    return vim.fs.find(
        pattern,
        {
            path = path,
            type = "file",
            limit = math.huge
        }
    )
end

-- Convert the configuration file path name to a module.
--
-- Assumes the path is valid and leads to a valid Lua file which is stored in
-- Neovim's default configuration root folder.
--
-- @param path string The path of the file.
-- @param config_root string The path representing the root folder of the
--                           Neovim configuration the file is part of.
-- @return string The module name of the file
function fs.path_to_module(path)
    local module_name = path

    module_name = vim.fs.relpath(fs.config_path, path)
    module_name = string.sub(module_name, 0, -5)
    module_name = string.gsub(module_name, "/", ".")

    return module_name
end

-- Call `require` over the file at `path`.
--
-- Assumes the path is valid and leads to a valid Lua file which is stored in
-- Neovim's default configuration root folder.
--
-- Equivalent to `require(fs.path_to_module(path))`.
--
-- @param path string The path of the file
-- @return any The content of the module as queried by `require`
function fs.require_from_path(path)
    local module = fs.path_to_module(path)
    return require(module)
end

return fs
