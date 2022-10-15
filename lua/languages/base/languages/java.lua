local global = require("core.global")
local languages_setup = require("languages.base.utils")

local language_configs = {}

local function start_server_tools()
    local jdtls_launcher =
        vim.fn.glob(global.mason_path .. "/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar")
    local jdtls_bundles = {
        vim.fn.glob(
            global.mason_path .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
        ),
    }
    vim.list_extend(
        jdtls_bundles,
        vim.split(vim.fn.glob(global.mason_path .. "/packages/java-test/extension/server/*.jar"), "\n")
    )
    local jdtls_config = global.mason_path .. "/packages/jdtls/config_" .. global.os
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = global.cache_path .. "/workspace-root/" .. project_name
    require("jdtls").start_or_attach({
        cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xms1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",
            "-jar",
            jdtls_launcher,
            "-configuration",
            jdtls_config,
            "-data",
            workspace_dir,
        },
        filetyps = { "java" },
        root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
        bundles = jdtls_bundles,
        settings = {
            java = {},
        },
        init_options = {
            bundles = jdtls_bundles,
        },
        on_attach = function(client, bufnr)
            require("jdtls").setup_dap({ hotcodereplace = "auto" })
            require("jdtls.dap").setup_dap_main_class_configs()
            -- require("jdtls").test_class()
            -- require("jdtls").test_nearest_method()
            client.offset_encoding = "utf-16"
            table.insert(global["languages"]["java"]["pid"], client.rpc.pid)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            languages_setup.document_highlight(client, bufnr)
            languages_setup.document_formatting(client, bufnr)
        end,
    })
end

language_configs["lsp"] = function()
    languages_setup.setup_languages({
        ["language"] = "java",
        ["dap"] = { "java-debug-adapter", "java-test" },
        ["jdtls"] = {},
    })
    local function check_status()
        if global.install_proccess == false then
            local JdtlsHooks = vim.api.nvim_create_augroup("JdtlsHooks", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                group = JdtlsHooks,
                pattern = "java",
                callback = function()
                    start_server_tools()
                end,
            })
            vim.tbl_filter(function(buf)
                if
                    vim.api.nvim_buf_is_valid(buf)
                    and vim.api.nvim_buf_get_option(buf, "buflisted")
                    and vim.api.nvim_buf_get_option(buf, "filetype") == "java"
                then
                    vim.api.nvim_buf_set_option(buf, "filetype", "java")
                end
            end, vim.api.nvim_list_bufs())
        else
            vim.defer_fn(function()
                check_status()
            end, 1000)
        end
    end
    check_status()
end

return language_configs
