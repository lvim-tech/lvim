-- Plugin configuration for completion and editing-assist plugins.
-- Covers: blink.cmp (completion engine with LuaSnip, ripgrep, emoji, dadbod
-- sources), nvim-autopairs, nvim-ts-autotag, and nvim-surround.

---@module "modules.base.configs.completion"

local icons = require("configs.base.ui.icons")

return {
    -- -------------------------------------------------------------------------
    -- blink.cmp: main completion engine.
    -- Configures LuaSnip, loads local VSCode / Lua snippets, defines all
    -- completion sources with scores, and sets up the completion menu layout.
    -- -------------------------------------------------------------------------
    blink_cmp = {
        ---@return table  Full blink.cmp options table
        opts = function()
            local ls = require("luasnip")
            -- Enable autosnippets and use <Tab> as the selection key in snippet mode
            ls.config.set_config({
                enable_autosnippets = true,
                store_selection_keys = "<Tab>",
            })

            -- Defer snippet loading until after startup to avoid blocking the UI
            vim.schedule(function()
                local ok_ls, _ = pcall(require, "luasnip")
                if not ok_ls then
                    vim.notify("luasnip not available; snippets not loaded", vim.log.levels.WARN)
                    return
                end

                ---@type string  Neovim config root (e.g. ~/.config/nvim)
                local config_path = vim.fn.stdpath("config")
                ---@type string  Path to VSCode-style snippet JSON files
                local vscode_path = config_path .. "/snippets/vscode"
                ---@type string  Path to Lua-format snippet files
                local lua_path = config_path .. "/snippets/lua"

                local ok_vscode, vscode_loader = pcall(require, "luasnip.loaders.from_vscode")
                if ok_vscode then
                    if vim.fn.isdirectory(vscode_path) == 1 then
                        -- Load only the local override directory when it exists
                        vscode_loader.lazy_load({ paths = { vscode_path } })
                    else
                        -- Fall back to bundled VSCode snippets from installed plugins
                        vscode_loader.lazy_load()
                    end
                end

                local ok_lua, lua_loader = pcall(require, "luasnip.loaders.from_lua")
                if ok_lua and vim.fn.isdirectory(lua_path) == 1 then
                    lua_loader.load({ paths = { lua_path } })
                end
            end)

            return {
                -- Determines whether completion is active for the current context.
                -- Returns false in prompts, special LVIM filetypes, during macro
                -- recording/playback, inside comments, and in custom cmdline UIs.
                ---@return boolean  true when completion should be shown
                enabled = function()
                    local disabled = false
                    local success, node = pcall(vim.treesitter.get_node)
                    -- Disable in prompt buffers (e.g. telescope input)
                    disabled = disabled or (vim.bo.buftype == "prompt")
                    -- Disable in the typr typing-game filetype
                    disabled = disabled or (vim.bo.filetype == "typr")
                    -- Disable in LVIM space search / tabs input buffers
                    disabled = disabled or (vim.bo.filetype == "lvim-space-search-input")
                    disabled = disabled or (vim.bo.filetype == "lvim-space-tabs-input")
                    -- Disable while a macro is being recorded or executed
                    disabled = disabled or (vim.fn.reg_recording() ~= "")
                    disabled = disabled or (vim.fn.reg_executing() ~= "")
                    -- Disable when the cursor is inside a comment node
                    disabled = disabled
                        or (
                            success
                            and node ~= nil
                            and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type())
                        )
                    -- Disable when LVIM custom cmdline / confirm UIs are active
                    disabled = disabled or vim.g.__ui_cmdline_active == true
                    disabled = disabled or vim.g.__ui_confirm_msg ~= nil
                    disabled = disabled or vim.g.__ui_list_msg ~= nil
                    local ok_ft, ft = pcall(function()
                        return vim.bo.filetype
                    end)
                    -- Disable in buffers with no filetype (scratch, unnamed)
                    if ok_ft and (ft == nil or ft == "") then
                        disabled = true
                    end
                    return not disabled
                end,

                -- Use LuaSnip as the snippet engine backend
                snippets = { preset = "luasnip" },

                sources = {
                    -- Default source priority order for normal buffers
                    default = { "lsp", "path", "snippets", "buffer", "dadbod", "ripgrep", "emoji" },
                    providers = {
                        -- LSP completions — highest score; falls back to buffer words
                        lsp = {
                            name = "lsp",
                            module = "blink.cmp.sources.lsp",
                            fallbacks = { "buffer" },
                            score_offset = 90,
                        },
                        -- Filesystem path completions relative to the current buffer's dir
                        path = {
                            name = "Path",
                            module = "blink.cmp.sources.path",
                            score_offset = 25,
                            fallbacks = { "buffer" },
                            opts = {
                                trailing_slash = false,
                                label_trailing_slash = true,
                                ---@param ctx table  blink.cmp context object (has ctx.bufnr)
                                ---@return string    Absolute directory path for the current buffer
                                get_cwd = function(ctx)
                                    return vim.fn.expand(("#%d:p:h"):format(ctx.bufnr))
                                end,
                                show_hidden_files_by_default = true,
                            },
                        },
                        -- Open-buffer word completions; limited to avoid noise
                        buffer = {
                            name = "Buffer",
                            module = "blink.cmp.sources.buffer",
                            max_items = 3,
                            min_keyword_length = 3,
                            score_offset = 15,
                        },
                        -- LuaSnip snippet completions; second-highest score after LSP
                        snippets = {
                            name = "snippets",
                            enabled = true,
                            max_items = 8,
                            min_keyword_length = 2,
                            module = "blink.cmp.sources.snippets",
                            score_offset = 85,
                        },
                        -- ripgrep-based completions searched from the git root
                        ripgrep = {
                            module = "blink-cmp-rg",
                            name = "Ripgrep",
                            opts = {
                                -- Only trigger ripgrep when the prefix is at least 3 chars
                                prefix_min_len = 3,
                                ---@param _      table   blink.cmp context (unused)
                                ---@param prefix string  Current word prefix typed by the user
                                ---@return string[]      rg command + arguments
                                get_command = function(_, prefix)
                                    return {
                                        "rg",
                                        "--no-config",
                                        "--json",
                                        "--word-regexp",
                                        "--ignore-case",
                                        "--",
                                        -- Match prefix followed by word characters
                                        prefix .. "[\\w_-]+",
                                        -- Search from git root when available, else cwd
                                        vim.fs.root(0, ".git") or vim.fn.getcwd(),
                                    }
                                end,
                                ---@param context table  blink.cmp context (has context.line, context.cursor)
                                ---@return string        Word prefix to pass to rg
                                get_prefix = function(context)
                                    return context.line:sub(1, context.cursor[2]):match("[%w_-]+$") or ""
                                end,
                            },
                        },
                        -- Emoji completions — inserts the actual emoji character
                        emoji = {
                            module = "blink-emoji",
                            name = "Emoji",
                            score_offset = 15,
                            opts = { insert = true },
                        },
                        -- vim-dadbod-ui SQL completions for database buffers
                        dadbod = {
                            name = "Dadbod",
                            module = "vim_dadbod_completion.blink",
                        },
                    },
                },

                -- Use LSP kind icons from the shared icons table
                appearance = {
                    kind_icons = icons.cmp.lsp_symbols,
                },

                completion = {
                    -- Automatically insert bracket pairs after accepting a function completion
                    accept = { auto_brackets = { enabled = true } },
                    trigger = {
                        -- Do not open the menu immediately when a trigger character is typed
                        show_on_insert_on_trigger_character = false,
                    },
                    menu = {
                        border = "padded",
                        draw = {
                            padding = 2,
                            gap = 1,
                            -- Use treesitter highlighting for LSP items in the menu
                            treesitter = { "lsp" },
                            -- Menu column layout: icon | label description | kind | source
                            columns = {
                                { "kind_icon" },
                                { "label", "label_description", gap = 1 },
                                { "kind" },
                                { "source_name" },
                            },
                            components = {
                                -- Delegate label text and highlights to colorful-menu for
                                -- syntax-aware coloring of completion items
                                label = {
                                    text = require("colorful-menu").blink_components_text,
                                    highlight = require("colorful-menu").blink_components_highlight,
                                },
                                -- Format source names as bracketed labels, e.g. [LSP] / [Buffer]
                                source_name = {
                                    ---@param ctx table  blink.cmp render context (has ctx.source_name)
                                    ---@return string    Formatted source label
                                    text = function(ctx)
                                        local name = ctx.source_name
                                        if name == "lsp" then
                                            -- LSP is always uppercased
                                            return "[" .. string.upper(name) .. "]"
                                        end
                                        -- Capitalise the first letter of other source names
                                        return "[" .. name:sub(1, 1):upper() .. name:sub(2) .. "]"
                                    end,
                                    ---@param ctx table  blink.cmp render context
                                    ---@return string    Highlight group name for the source badge
                                    highlight = function(ctx)
                                        local source = ctx.source_name
                                        if source == "lsp" then
                                            return "BlinkCmpSourceLSP"
                                        elseif source == "Buffer" then
                                            return "BlinkCmpSourceBuffer"
                                        elseif source == "Path" then
                                            return "BlinkCmpSourcePath"
                                        else
                                            return "BlinkCmpSource"
                                        end
                                    end,
                                },
                            },
                        },
                        -- Position the cmdline completion menu above the command-line area.
                        -- Reads vim.g.ui_cmdline_pos when set by a custom cmdline UI plugin.
                        ---@return integer[]  { row, col } screen position for the menu
                        cmdline_position = function()
                            if vim.g.ui_cmdline_pos ~= nil then
                                local pos = vim.g.ui_cmdline_pos
                                -- Adjust row by -1 to sit just above the cmdline
                                return { pos[1] - 1, pos[2] }
                            end
                            local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
                            return { vim.o.lines - height - 1, 0 }
                        end,
                    },
                    documentation = {
                        auto_show = true,
                        auto_show_delay_ms = 10,
                        treesitter_highlighting = true,
                        window = { border = "padded" },
                    },
                    -- Ghost text previews the top completion inline as you type
                    ghost_text = { enabled = true },
                },

                signature = { window = { border = "padded" } },

                -- Keymaps for the completion menu (insert mode)
                keymap = {
                    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                    ["<C-e>"] = { "hide", "fallback" },
                    ["<CR>"] = { "accept", "fallback" },
                    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                    ["<Down>"] = { "select_next", "fallback" },
                    ["<Up>"] = { "select_prev", "fallback" },
                    ["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
                    ["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
                    -- Scroll documentation window down / up
                    ["<C-h>"] = { "scroll_documentation_down", "fallback" },
                    ["<C-l>"] = { "scroll_documentation_up", "fallback" },
                    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                },

                -- Cmdline completion configuration (separate from insert-mode completion)
                cmdline = {
                    completion = { menu = { auto_show = true } },
                    keymap = {
                        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                        ["<C-e>"] = { "hide", "fallback" },
                        ["<CR>"] = { "accept", "fallback" },
                        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                        ["<Down>"] = { "select_next", "fallback" },
                        ["<Up>"] = { "select_prev", "fallback" },
                        ["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
                        ["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
                        ["<C-h>"] = { "scroll_documentation_down", "fallback" },
                        ["<C-l>"] = { "scroll_documentation_up", "fallback" },
                    },
                    -- Use only buffer words for search (/?) commands;
                    -- use cmdline + path sources for everything else (:commands).
                    ---@return string[]  Active source names for the current cmdline type
                    sources = function()
                        local type = vim.fn.getcmdtype()
                        if type == "/" or type == "?" then
                            return { "buffer" }
                        else
                            return { "cmdline", "path" }
                        end
                    end,
                },
            }
        end,
    },

    -- -------------------------------------------------------------------------
    -- nvim-autopairs: automatically closes brackets, quotes, etc.
    -- -------------------------------------------------------------------------
    nvim_autopairs = {
        opts = {},
    },

    -- -------------------------------------------------------------------------
    -- nvim-ts-autotag: auto-closes and auto-renames HTML/JSX tags via Treesitter.
    -- -------------------------------------------------------------------------
    nvim_ts_autotag = {
        opts = {},
    },

    -- -------------------------------------------------------------------------
    -- nvim-surround: adds/changes/deletes surrounding delimiters (quotes, brackets).
    -- -------------------------------------------------------------------------
    nvim_surround = {
        opts = {},
    },
}

-- vim: foldmethod=indent foldlevel=1
