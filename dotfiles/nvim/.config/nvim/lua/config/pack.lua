local fs_utils = require("utils.fs")
local strings = require("utils.strings")
local tables = require("utils.tables")

local workflow = {}

-- Constants

local plugins_folder = fs_utils.config_path .. "/plugins"

-- Functions

-- @class Plugin
-- @field src string Source repository of the plugin
-- @field dependendecies string|Plugin[] Dependencies of the plugin. They will
--                                       be downloaded and triggered before the
--                                       plugin, with a priority of n+1.
-- @field name string The name of the plugin
-- @field priority number Priority of the plugin in the execution table. Plugins
--                        with higher priority values will be run first.

-- Return a vim.pack view for plugin.
-- @param plugin Plugin A plugin configuration
-- @return object A view that can be provided to vim.pack.add so that it may be
--                downloaded.
local function to_vim_pack(plugin)
    return { name = plugin.name, src = plugin.src }
end


-- `require` over all the files from a provided list of paths.
-- @param paths string[] A list of valid Lua files
-- @return any[] The content of each module as queried by `require`
local function require_paths(paths)
    -- Let's just assume that every module will inevitably return a list...
    return tables.accumulate(paths, fs_utils.require_from_path)
end

-- Extract all plugin files from the given folder.
-- @param path string The path of the folder to iterate into
-- @return string[] The list of all Lua files in path that isn't named init.lua
local function extract_plugin_files(path)
    return fs_utils.ls_dir(
        path,
        function(name, path)
            return string.match(name, ".*%.lua$") and name ~= "init.lua"
        end
    )
end

-- Desugar a plugin and give it the expected format for all plugins.
-- @param plugin string|table<string, any> The plugin to expand
-- @return Plugin Its complete plugin representation
local function desugar_plugin(plugin)
    if type(plugin) == "string" then
        plugin = { src = plugin }
    end

    if not plugin.src then
        assert(
            #plugin > 0,
            "could not find any reference to use as src for element: "
            .. vim.inspect(plugin)
        )

        plugin.src = table.remove(plugin, 1)
        vim.print(plugin)
    end

    plugin.name = plugin.name or string.match(plugin.src, "^.*/(.*)$")

    plugin.dependencies = plugin.dependencies or {}
    plugin.entrypoint = plugin.entrypoint or plugin.name
    plugin.options = plugin.options or {}
    plugin.priority = plugin.priority or 0

    plugin.config = plugin.config or function()
        require(plugin.entrypoint).setup(plugin.options)
    end

    return plugin
end

-- Unpack all the dependencies of the plugin, incrementing their priority.
--
-- The priority of a dependency is plugin.priority + dependency.priority + 1.
--
-- @param plugin Plugin A plugin
-- @return Plugin[] An array containing all its dependencies and subdependencies
--                  along with an appropriate updated priority value.
local function unpack_dependency_tree(plugin)
    local all_nodes = {}

    for _, dependency in ipairs(plugin.dependencies) do
        dependency.priority = dependency.priority + plugin.priority + 1

        local subdeps = unpack_dependency_tree(dependency)

        all_nodes = tables.merge(all_nodes, subdeps)
        table.insert(all_nodes, dependency)
    end

    return all_nodes
end

-- Extract all the priorities used in the list of plugins.
-- @param plugins Plugin[] A list of plugins
-- @return number[] The list of all unique priorities in plugins, sorted
--                  from highest to lowest
local function get_priority_levels(plugins)
    local priorities = tables.map(
        plugins,
        function(plugin) return plugin.priority end
    )

    priorities = tables.distinct(priorities)

    table.sort(
        priorities,
        function(a, b) return a > b end
    )

    return priorities
end

-- Raise an error if an incorrect plugin configuration was found.
--
-- If every plugin is valid, do nothing.
--
-- @param plugins string|table<string, any>[] A list of plugin configurations.
-- @return string|table<string, any>[] plugins
function workflow.validate(plugins)
    local function validate(plugin)
        local p_type = type(plugin)
        assert(
            p_type == "table" or p_type == "string",
            "Type of plugin should be a table or a string, not " .. p_type
        )
    end

    tables.foreach(plugins, validate)

    return plugins
end

-- Desugar all the plugins in the list.
-- @param plugins string|table<string, any>[] A list of sugared plugins
-- @return Plugin[] A list of formally-defined plugins
function workflow.desugar(plugins)
    local function desugar(plugin)
        local full_plugin = desugar_plugin(plugin)

        full_plugin.dependencies = tables.map(
            full_plugin.dependencies,
            desugar_plugin
        )

        return full_plugin
    end

    return tables.map(plugins, desugar)
end

-- Extract the dependencies from the plugins to convert it to one dimension.
-- @param Plugin[] A list of plugins with or without dependencies
-- @return Plugin[] The list of all the plugins with their dependencies at
--                  first level
function workflow.extract_dependencies(plugins)
    local collected_plugins = {}

    for _, plugin in ipairs(plugins) do
        local dependencies = unpack_dependency_tree(plugin)

        for _, dependency in ipairs(dependencies) do
            table.insert(collected_plugins, dependency)
        end

        table.insert(collected_plugins, plugin)
    end

    return collected_plugins
end

-- Download and activate all the plugins.
-- @param plugins Plugin[] A list of plugins
-- @return Plugin[] plugins
function workflow.deploy(plugins)
    if #plugins < 1 then
        return plugins
    end

    local priorities = get_priority_levels(plugins)
    local plugins_views = tables.map(plugins, to_vim_pack)

    vim.pack.add(plugins_views)

    for i = 1, #priorities do
        local batch = tables.filter(
            plugins,
            function(plugin) return plugin.priority == priorities[i] end
        )

        tables.foreach(
            batch,
            function(plugin) plugin.config() end
        )
    end

    return plugins
end

-- Operate the entire plugin manager workflow over the provided input.
-- @param plugins string|table<string, any>[] A list of plugins
function workflow.apply(plugins)
    local steps = {
        workflow.validate,
        workflow.desugar,
        workflow.extract_dependencies,
        workflow.deploy,
    }

    tables.pipeline(plugins, steps)
end

-- Main process

local plugin_files = extract_plugin_files(plugins_folder)
local plugins = require_paths(plugin_files)

workflow.apply(plugins)
