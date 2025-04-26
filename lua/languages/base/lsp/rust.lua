local global = require("core.global")
local dap = require("dap")
local navic = require("nvim-navic")

local setup_diagnostics = require("languages.utils.setup_diagnostics")
local lsp_utils = require("languages.utils")

local lsp_server_name = "rust-analyzer"
local debbuger_server_name = "cpptools"

-- DAP
local debbuger_server_async = lsp_utils.is_lsp_server_installed(debbuger_server_name)

local debbuger_server_result
while not debbuger_server_result do
    debbuger_server_result = debbuger_server_async()
    vim.wait(100)
end

if debbuger_server_result then
    dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = global.mason_path .. "/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
    }
    dap.configurations.rust = {
        {
            name = "Launch file",
            type = "cppdbg",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = true,
        },
    }
end
-- DAP

-- LSP
local function reload_workspace(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" })
    for _, client in ipairs(clients) do
        vim.notify("Reloading Cargo Workspace")
        client.request("rust-analyzer/reloadWorkspace", nil, function(err)
            if err then
                error(tostring(err))
            end
            vim.notify("Cargo workspace reloaded")
        end, 0)
    end
end

local function is_library(fname)
    local user_home = vim.fs.normalize(vim.env.HOME)
    local cargo_home = os.getenv("CARGO_HOME") or user_home .. "/.cargo"
    local registry = cargo_home .. "/registry/src"
    local git_registry = cargo_home .. "/git/checkouts"
    local rustup_home = os.getenv("RUSTUP_HOME") or user_home .. "/.rustup"
    local toolchains = rustup_home .. "/toolchains"
    for _, item in ipairs({ toolchains, registry, git_registry }) do
        if vim.fs.relpath(item, fname) then
            local clients = vim.lsp.get_clients({ name = "rust_analyzer" })
            return #clients > 0 and clients[#clients].config.root_dir or nil
        end
    end
end

local lsp_server_config = {
    name = "rust",
    cmd = { "rust-analyzer" },
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local reused_dir = is_library(fname)
        if reused_dir then
            on_dir(reused_dir)
            return
        end
        local cargo_crate_dir = lsp_utils.root_pattern("Cargo.toml")(fname)
        local cargo_workspace_root

        if cargo_crate_dir == nil then
            on_dir(
                lsp_utils.root_pattern("rust-project.json")(fname)
                    or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
            )
            return
        end
        local cmd = {
            "cargo",
            "metadata",
            "--no-deps",
            "--format-version",
            "1",
            "--manifest-path",
            cargo_crate_dir .. "/Cargo.toml",
        }
        vim.system(cmd, { text = true }, function(output)
            if output.code == 0 then
                if output.stdout then
                    local result = vim.json.decode(output.stdout)
                    if result["workspace_root"] then
                        cargo_workspace_root = vim.fs.normalize(result["workspace_root"])
                    end
                end

                on_dir(cargo_workspace_root or cargo_crate_dir)
            else
                vim.notify(("[rust_analyzer] cmd failed with code %d: %s\n%s"):format(output.code, cmd, output.stderr))
            end
        end)
    end,
    filetypes = _G.file_types.rust,
    settings = {
        ["rust-analyzer"] = {
            assist = {
                importEnforceGranularity = true,
                importPrefix = "crate",
            },
            cargo = {
                allFeatures = true,
            },
            checkOnSave = true,
            inlayHints = { locationLinks = false },
            diagnostics = {
                enable = true,
                experimental = {
                    enable = true,
                },
            },
        },
    },
    before_init = function(init_params, config)
        if config.settings and config.settings["rust-analyzer"] then
            init_params.initializationOptions = config.settings["rust-analyzer"]
        end
    end,
    on_attach = function(client, bufnr)
        setup_diagnostics.keymaps(client, bufnr)
        setup_diagnostics.document_highlight(client, bufnr)
        setup_diagnostics.document_auto_format(client, bufnr)
        setup_diagnostics.inlay_hint(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
        end
        vim.api.nvim_buf_create_user_command(0, "LspCargoReload", function()
            reload_workspace(0)
        end, { desc = "Reload current cargo workspace" })
    end,
    capabilities = setup_diagnostics.get_capabilities(),
}

local lsp_server_async = lsp_utils.is_lsp_server_installed(lsp_server_name)

local lsp_server_result
while not lsp_server_result do
    lsp_server_result = lsp_server_async()
    vim.wait(100)
end

_G.rust_lsp_config = lsp_server_config

if lsp_server_result then
    return lsp_server_config
else
    vim.notify("An error occurred while setting up the LSP (" .. lsp_server_name .. ")!", vim.log.levels.ERROR)
end
-- LSP

-- vim: foldmethod=indent foldlevel=0
