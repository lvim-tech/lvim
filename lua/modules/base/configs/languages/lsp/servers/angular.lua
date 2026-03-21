-- LSP configuration for Angular
-- Configures the Angular Language Server (ngserver) with TypeScript and Angular probe paths
-- resolved dynamically from the project's node_modules and Mason-installed packages.
---@module "modules.base.configs.languages.lsp.servers.angular"

---@type string[]  Root-directory markers used by the LSP manager to detect Angular projects
local root_markers = {
    "angular.json",
    "nx.json",
}

-- Walk up from cwd to locate the nearest node_modules directory
local root_dir = vim.fn.getcwd()
local node_modules_dir = vim.fs.find("node_modules", { path = root_dir, upward = true })[1]
---@type string  Absolute project root (parent of node_modules), or "?" if not found
local project_root = node_modules_dir and vim.fs.dirname(node_modules_dir) or "?"

---Returns the project's node_modules path, used as a probe location for TypeScript and Angular.
---@return string  Absolute path to node_modules, or empty string when no project root is found
local function get_probe_dir()
    return project_root and (project_root .. "/node_modules") or ""
end

---Reads package.json and extracts the resolved @angular/core semver version.
---Required by ngserver to select the correct Angular compiler internals.
---@return string  Semver string (e.g. "17.0.1"), or empty string when unavailable
local function get_angular_core_version()
    if not project_root then
        return ""
    end

    local package_json = project_root .. "/package.json"
    if not vim.uv.fs_stat(package_json) then
        return ""
    end

    local contents = io.open(package_json):read("*a")
    local json = vim.json.decode(contents)
    if not json.dependencies then
        return ""
    end

    local angular_core_version = json.dependencies["@angular/core"]

    -- Strip npm range prefixes (^, ~, >=) to get a plain X.Y.Z string
    angular_core_version = angular_core_version and angular_core_version:match("%d+%.%d+%.%d+")

    return angular_core_version
end

---@type string  Evaluated once at load time; passed to ngserver --tsProbeLocations and --ngProbeLocations
local default_probe_dir = get_probe_dir()
---@type string  @angular/core version string detected from package.json at load time
local default_angular_core_version = get_angular_core_version()

-- Resolve the absolute path to the ngserver executable via $PATH
local ngserver_exe = vim.fn.exepath("ngserver")
---@type string  Directory that contains the ngserver script (follows symlinks), or "?"
local ngserver_path = #(ngserver_exe or "") > 0 and vim.fs.dirname(vim.uv.fs_realpath(ngserver_exe)) or "?"
-- Three levels up from bin/ reaches the package root inside Mason
local extension_path = vim.fs.normalize(vim.fs.joinpath(ngserver_path, "../../../"))

-- Comma-separated probe locations passed to --tsProbeLocations
-- ngserver searches these directories for TypeScript's compiler API
local ts_probe_dirs = vim.iter({ extension_path, default_probe_dir }):join(",")
-- Comma-separated probe locations passed to --ngProbeLocations
-- Must point at directories that contain @angular/language-server/node_modules
local ng_probe_dirs = vim.iter({ extension_path, default_probe_dir })
    :map(function(p)
        return vim.fs.joinpath(p, "/@angular/language-server/node_modules")
    end)
    :join(",")

return {
    lsp = {
        root_patterns = root_markers,
        config = {
            name = "angular",
            cmd = {
                "ngserver",
                "--stdio",
                "--tsProbeLocations",
                ts_probe_dirs, -- directories searched for typescript/lib
                "--ngProbeLocations",
                ng_probe_dirs, -- directories searched for @angular/language-server
                "--angularCoreVersion",
                default_angular_core_version, -- tells ngserver which Angular version to target
            },
            init_options = {
                typescript = {
                    -- Point Angular LS at the TypeScript SDK bundled with the Vue language server
                    -- (shared across multiple TS-dependent language servers in this config).
                    tsdk = vim.fs.normalize(
                        "~/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib"
                    ),
                },
            },
            ---Called by nvim-lspconfig after the client attaches to a buffer.
            ---@param client any  The newly attached LSP client
            ---@param bufnr  integer         Buffer number the client attached to
            on_attach = function(client, bufnr)
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end
            end,
        },
    },
}

-- vim: foldmethod=indent foldlevel=1
