local config = {}

function config.treesitter()
    if not packer_plugins["playground"].loaded then
        vim.cmd [[packadd playground]]
    end
    require"nvim-treesitter.configs".setup {
        ensure_installed = "all",
        ignore_install = {"haskell"},
        highlight = {enable = true},
        indent = {enable = {"javascriptreact"}},
        playground = {
            enable = true,
            disable = {},
            updatetime = 25,
            persist_queries = false,
            keybindings = {
                toggle_query_editor = "o",
                toggle_hl_groups = "i",
                toggle_injected_languages = "t",
                toggle_anonymous_nodes = "a",
                toggle_language_display = "I",
                focus_language = "f",
                unfocus_language = "F",
                update = "R",
                goto_node = "<cr>",
                show_help = "?"
            }
        },
        autotag = {enable = true},
        rainbow = {enable = true},
        context_commentstring = {
            enable = true,
            config = {javascriptreact = {style_element = "{/*%s*/}"}}
        }
    }
end

function config.jump()
    vim.cmd([[unmap <leader>j]])
    vim.g.any_jump_disable_default_keybindings = 1
    vim.g.any_jump_list_numbers = 1
end

function config.trouble()
    require("trouble").setup {
        height = 12,
        use_lsp_diagnostic_signs = true,
        action_keys = {
            refresh = "r",
            toggle_mode = "m",
            toggle_preview = "P",
            close_folds = "zc",
            open_folds = "zo",
            toggle_fold = "zt"
        }
    }
end

function config.symbols()
    require("symbols-outline").setup {
        highlight_hovered_item = true,
        show_guides = true
    }
end

return config
