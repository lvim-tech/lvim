local config = {}

function config.vista()
    vim.g['vista#renderer#enable_icon'] = 1
    vim.g.vista_disable_statusline = 1
    vim.g.vista_default_executive = 'ctags'
    vim.g.vista_echo_cursor_strategy = 'floating_win'
    vim.g.vista_vimwiki_executive = 'markdown'
    vim.g.vista_executive_for = {
        vimwiki = 'markdown',
        pandoc = 'markdown',
        markdown = 'toc',
        typescript = 'nvim_lsp',
        typescriptreact = 'nvim_lsp'
    }
end

function config.dadbod()
    vim.api.nvim_set_keymap("n", "<leader>Du", ":DBUIToggle<CR>",
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap("n", "<leader>Df", ":DBUIFindBuffer<CR>",
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap("n", "<leader>Dr", ":DBUIRenameBuffer<CR>",
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap("n", "<leader>Dl", ":DBUILastQueryInfo<CR>",
                            {noremap = true, silent = true})
    vim.g.db_ui_auto_execute_table_helpers = true
end

function config.whichkey()
    local wk = require('whichkey_setup')
    wk.config {
        hide_statusline = false,
        default_keymap_settings = {silent = true, noremap = false}
    }
    vim.g.which_key_display_names = {
        ['<CR>'] = '↵',
        ['<TAB>'] = '⇆',
        [' '] = 'SPC'
    }
    vim.g.which_key_sep = '→'
    vim.g.which_key_timeout = 10
    vim.g.which_key_use_floating_win = 0
    vim.g.which_key_max_size = 0
    vim.cmd('autocmd! FileType which_key')
    vim.cmd(
        'autocmd FileType which_key set laststatus=0 noshowmode noruler | autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler')
    local keymap = {
        [';'] = {'<Cmd>Dashboard<CR>', 'home screen'},
        ['*'] = {'<Cmd>DogeGenerate<CR>', 'documentation generator'},
        ['/'] = {'<Cmd>CommentToggle<CR>', 'comment'},
        ['e'] = {'<Cmd>NvimTreeToggle<CR>', 'explorer'},
        ['r'] = {'<Cmd>RnvimrToggle<CR>', 'ranger'},
        ['F'] = {'<Cmd>Format<CR>', 'formal'},
        -- ['m'] = {'<Cmd>MarkdownPreviewToggle<CR>', 'markdown preview toggle'},
        ['V'] = {'<Cmd>Vista<CR>', 'vista'},
        ['b'] = {
            name = '+buffer',
            ['>'] = {'<Cmd>BufferMoveNext<CR>', 'move next'},
            ['<'] = {'<Cmd>BufferMovePrevious<CR>', 'move prev'},
            ['b'] = {'<Cmd>BufferPick<CR>', 'pick buffer'},
            ['n'] = {'<Cmd>bnext<CR>', 'next buffer'},
            ['p'] = {'<Cmd>bprevious<CR>', 'prev buffer'},
            ['a'] = {'<Cmd>Telescope buffers<CR>', 'all buffers'}
        },
        ['c'] = {
            name = '+cwd',
            ['d'] = {':cd %:p:h<CR>:pwd<CR>', 'cd to current'},
            ['l'] = {':lcd %:p:h<CR>:pwd<CR>', 'lcd to current'}
        },
        ['d'] = {
            name = '+debug',
            ['d'] = {
                name = '+dap',
                ['b'] = {'<Cmd>DapToggleBreakpoint<CR>', 'toggle breakpoint'},
                ['s'] = {'<Cmd>DapStart<CR>', 'start / continue'},
                ['f'] = {'<Cmd>DapStop<CR>', 'stop'},
                ['r'] = {'<Cmd>DapRestart<CR>', 'restart'},
                ['p'] = {'<Cmd>DapPause<CR>', 'pause'},
                ['o'] = {'<Cmd>DapStepOver<CR>', 'step over'},
                ['i'] = {'<Cmd>DapStepInto<CR>', 'step into'},
                ['O'] = {'<Cmd>DapStepOut<CR>', 'step into'},
                ['R'] = {'<Cmd>DapToggleRepl<CR>', 'togle repl'},
                ['S'] = {'<Cmd>DapGetSession<CR>', 'get session'}
            },
            ['v'] = {
                name = '+vimspector',
                ['b'] = {
                    '<Plug>VimspectorToggleBreakpoint', 'toggle breakpoint'
                },
                ['s'] = {'<Plug>VimspectorContinue<CR>', 'start / continue'},
                ['f'] = {'<Plug>VimspectorStop<CR>', 'stop'},
                ['r'] = {'<Cmd>VimspectorReset<CR>', 'reset'},
                ['R'] = {'<Plug>VimspectorRestart<CR>', 'restart'},
                ['p'] = {'<Plug>VimspectorPause<CR>', 'pause'},
                ['o'] = {'<Plug>VimspectorStepOver<CR>', 'step over'},
                ['i'] = {'<Plug>VimspectorStepInto<CR>', 'step into'},
                ['O'] = {'<Plug>VimspectorStepOut<CR>', 'step out'},
                ['c'] = {'<Plug>VimspectorRunToCursor<CR>', 'run to cursor'}
            }
        },
        ['D'] = {
            name = '+database',
            ['u'] = {'<Cmd>DBUIToggle<CR>', 'db ui toggle'},
            ['f'] = {'<Cmd>DBUIFindBuffer<CR>', 'db find buffer'},
            ['r'] = {'<Cmd>DBUIRenameBuffer<CR>', 'db rename buffer'},
            ['l'] = {'<Cmd>DBUILastQueryInfo<CR>', 'db last query'}
        },
        ['l'] = {
            name = '+lsp',
            ['r'] = {'<Cmd>LspRename<CR>', 'rename'},
            ['h'] = {'<Cmd>LspHover<CR>', 'hover'},
            ['d'] = {'<Cmd>LspDeclaration<CR>', 'declaration'},
            ['w'] = {
                name = '+workspace',
                ['a'] = {
                    '<Cmd>LspAddToWorkspaceFolder<CR>',
                    'add to workspace folder'
                },
                ['r'] = {
                    '<Cmd>LspRemoveWorkspaceFolder<CR>',
                    'remove workspace folder'
                },
                ['l'] = {
                    '<Cmd>LspListWorkspaceFolders<CR>', 'list workspace folder'
                }
            },
            ['s'] = {
                name = '+symbol',
                ['D'] = {'<Cmd>LspDocumentSymbol<CR>', 'document symbol'},
                ['W'] = {'<Cmd>LspWorkspaceSymbol<CR>', 'workspace symbol'},
                ['d'] = {
                    '<Cmd>Telescope lsp_document_symbols<CR>',
                    'Telescope document symbols'
                },
                ['w'] = {
                    '<Cmd>Telescope lsp_workspace_symbols<CR>',
                    'Telescope workspace symbols'
                }
            },
            ['R'] = {
                name = '+references',
                ['r'] = {'<Cmd>LspReferences<CR>', 'references'},
                ['c'] = {'<Cmd>LspClearReferences<CR>', 'clear references'}
            },
            ['a'] = {
                name = '+action',
                ['r'] = {'<Cmd>LspCodeAction<CR>', 'code action'},
                ['c'] = {'<Cmd>LspRangeCodeAction<CR>', 'range code action'}
            },
            ['f'] = {
                name = '+formatting',
                ['d'] = {'<Cmd>LspFormatting<CR>', 'formatting'},
                ['r'] = {'<Cmd>LspRangeFormatting<CR>', 'range formatting'},
                ['s'] = {'<Cmd>LspFormattingSync<CR>', 'sync formatting'}
            },
            ['D'] = {
                name = '+definition',
                ['d'] = {'<Cmd>LspDefinition<CR>', 'definition'},
                ['t'] = {'<Cmd>LspTypeDefinition<CR>', 'type definition'}
            },
            ['g'] = {
                name = '+diagnostics',
                ['a'] = {'<Cmd>LspGetAll<CR>', 'get all'},
                ['n'] = {'<Cmd>LspGetNext<CR>', 'next'},
                ['p'] = {'<Cmd>LspGoToNext<CR>', 'go to prev'},
                ['N'] = {'<Cmd>LspGoToPrev<CR>', 'go to next'},
                ['P'] = {'<Cmd>LspGetPrev<CR>', 'prev'},
                ['d'] = {
                    '<Cmd>Telescope lsp_document_diagnostics<CR>',
                    'document diagnostics'
                },
                ['w'] = {
                    '<Cmd>Telescope lsp_workspace_diagnostics<CR>',
                    'workspace diagnostics'
                }
            }
        },
        ['f'] = {
            name = '+fold',
            ['m'] = {'<Cmd>:set foldmethod manual<CR>', 'manual (default)'},
            ['i'] = {'<Cmd>:set foldmethod indent<CR>', 'indent'},
            ['e'] = {'<Cmd>:set foldmethod expr<CR>', 'expr'},
            ['d'] = {'<Cmd>:set foldmethod diff<CR>', 'diff'},
            ['M'] = {'<Cmd>:set foldmethod marker<CR>', 'marker'}
        },
        ['g'] = {
            name = '+git',
            ['b'] = {'<Cmd>GitBlameToggle<CR>', 'blame'},
            ['B'] = {'<Cmd>GBrowse<CR>', 'browse'},
            ['d'] = {'<Cmd>Git diff<CR>', 'diff'},
            ['j'] = {'<Cmd>NextHunk<CR>', 'next hunk'},
            ['k'] = {'<Cmd>PrevHunk<CR>', 'prev hunk'},
            ['l'] = {'<Cmd>Git log<CR>', 'log'},
            ['p'] = {'<Cmd>PreviewHunk<CR>', 'preview hunk'},
            ['r'] = {'<Cmd>ResetHunk<CR>', 'reset hunk'},
            ['R'] = {'<Cmd>ResetBuffer<CR>', 'reset buffer'},
            ['s'] = {'<Cmd>StageHunk<CR>', 'stage hunk'},
            ['S'] = {'<Cmd>Gstatus<CR>', 'status'},
            ['u'] = {'<Cmd>UndoStageHunk<CR>', 'undo stage hunk'},
            ['n'] = {'<Cmd>Neogit<CR>', 'neogit'}
        },
        ['G'] = {
            name = '+gist',
            ['b'] = {'<Cmd>Gist -b<CR>', 'post gist browser'},
            ['d'] = {'<Cmd>Gist -d<CR>', 'delete gist'},
            ['e'] = {'<Cmd>Gist -e<CR>', 'edit gist'},
            ['l'] = {'<Cmd>Gist -l<CR>', 'list public gists'},
            ['s'] = {'<Cmd>Gist -ls<CR>', 'list starred gists'},
            ['m'] = {'<Cmd>Gist -m<CR>', 'post gist all buffers'},
            ['p'] = {'<Cmd>Gist -p<CR>', 'post public gist'},
            ['P'] = {'<Cmd>Gist -P<CR>', 'post private gist'}
        },
        ['m'] = {
            name = '+bookmark',
            ['t'] = {'<Cmd>BookmarkToggle<CR>', 'toggle bookmark'},
            ['n'] = {'<Cmd>BookmarkNext<CR>', 'next bookmark'},
            ['p'] = {'<Cmd>BookmarkPrev<CR>', 'prev bookmark'}
        },
        ['t'] = {
            name = '+terminal',
            ['t'] = {
                '<Cmd>FloatermNew --wintype=normal --height=10<CR>', 'terminal'
            },
            ['f'] = {'<Cmd>FloatermNew fzf<CR>', 'fzf'},
            ['g'] = {'<Cmd>FloatermNew lazygit<CR>', 'git'},
            ['d'] = {'<Cmd>FloatermNew lazydocker<CR>', 'docker'},
            ['m'] = {'<Cmd>FloatermNew lazynpm<CR>', 'npm'},
            ['n'] = {'<Cmd>FloatermNew node<CR>', 'node'},
            ['p'] = {'<Cmd>FloatermNew python<CR>', 'python'},
            ['b'] = {'<Cmd>FloatermNew bpytop<CR>', 'bpytop'}
        }
    }
    wk.register_keymap('leader', keymap, {mode = 'n'})

end

function config.rooter() vim.g.rooter_silent_chdir = 1 end

return config
