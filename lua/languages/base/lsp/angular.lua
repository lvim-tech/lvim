local navic = require("nvim-navic")
local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_installer = require("languages.lsp_installer")

local lsp_dependencies = {
    "angular-language-server",
}

local lsp_config = nil
local root_markers = {
    "angular.json",
    "nx.json",
}

local root_dir = vim.fn.getcwd()
local node_modules_dir = vim.fs.find("node_modules", { path = root_dir, upward = true })[1]
local project_root = node_modules_dir and vim.fs.dirname(node_modules_dir) or "?"

local function get_probe_dir()
    return project_root and (project_root .. "/node_modules") or ""
end

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

    angular_core_version = angular_core_version and angular_core_version:match("%d+%.%d+%.%d+")

    return angular_core_version
end

local default_probe_dir = get_probe_dir()
local default_angular_core_version = get_angular_core_version()

local ngserver_exe = vim.fn.exepath("ngserver")
local ngserver_path = #(ngserver_exe or "") > 0 and vim.fs.dirname(vim.uv.fs_realpath(ngserver_exe)) or "?"
local extension_path = vim.fs.normalize(vim.fs.joinpath(ngserver_path, "../../../"))

local ts_probe_dirs = vim.iter({ extension_path, default_probe_dir }):join(",")
local ng_probe_dirs = vim.iter({ extension_path, default_probe_dir })
    :map(function(p)
        return vim.fs.joinpath(p, "/@angular/language-server/node_modules")
    end)
    :join(",")

lsp_installer.ensure_mason_tools(lsp_dependencies, function()
    lsp_config = {
        name = "angular",
        cmd = {
            "ngserver",
            "--stdio",
            "--tsProbeLocations",
            ts_probe_dirs,
            "--ngProbeLocations",
            ng_probe_dirs,
            "--angularCoreVersion",
            default_angular_core_version,
        },
        filetypes = _G.file_types.angular,
        init_options = {
            typescript = {
                tsdk = vim.fs.normalize(
                    "~/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib"
                ),
            },
        },
        on_attach = function(client, bufnr)
            setup_diagnostics.keymaps(client, bufnr)
            setup_diagnostics.document_highlight(client, bufnr)
            setup_diagnostics.inlay_hint(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                navic.attach(client, bufnr)
            end
        end,
        capabilities = setup_diagnostics.get_capabilities(),
    }
end)

return setmetatable({}, {
    __index = function(_, key)
        if key == "config" then
            return lsp_config
        elseif key == "root_patterns" then
            return root_markers
        end
    end,
})

-- vim: foldmethod=indent foldlevel=1
