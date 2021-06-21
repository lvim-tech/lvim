local utils = {}

-- LSP
function utils.add_to_workspace_folder() vim.lsp.buf.add_workspace_folder() end
function utils.list_workspace_folders() vim.lsp.buf.list_workspace_folders() end
function utils.remove_workspace_folder() vim.lsp.buf.remove_workspace_folder() end
function utils.workspace_symbol() vim.lsp.buf.workspace_symbol() end
function utils.references()
    vim.lsp.buf.references()
    vim.lsp.buf.clear_references()
end
function utils.clear_references() vim.lsp.buf.clear_references() end
function utils.code_action() vim.lsp.buf.code_action() end
function utils.range_code_action() vim.lsp.buf.range_code_action() end
function utils.declaration()
    vim.lsp.buf.declaration()
    vim.lsp.buf.clear_references()
end
function utils.definition()
    vim.lsp.buf.definition()
    vim.lsp.buf.clear_references()
end
function utils.type_definition() vim.lsp.buf.type_definition() end
function utils.document_highlight() vim.lsp.buf.document_highlight() end
function utils.document_symbol() vim.lsp.buf.document_symbol() end
function utils.implementation() vim.lsp.buf.implementation() end
function utils.incoming_calls() vim.lsp.buf.incoming_calls() end
function utils.outgoing_calls() vim.lsp.buf.outgoing_calls() end
function utils.formatting() vim.lsp.buf.formatting() end
function utils.range_formatting() vim.lsp.buf.range_formatting() end
function utils.formatting_sync() vim.lsp.buf.formatting_sync() end
function utils.hover() vim.lsp.buf.hover() end
function utils.rename() vim.lsp.buf.rename() end
function utils.signature_help() vim.lsp.buf.signature_help() end
-- Diagnostic
function utils.get_all() vim.lsp.diagnostic.get_all() end
function utils.get_next() vim.lsp.diagnostic.get_next() end
function utils.get_prev() vim.lsp.diagnostic.get_prev() end
function utils.goto_next() vim.lsp.diagnostic.goto_next() end
function utils.goto_prev() vim.lsp.diagnostic.goto_prev() end
function utils.show_line_diagnostics() vim.lsp.diagnostic
    .show_line_diagnostics() end
function utils.virtual_text_show()
    require("lsp.global.languages.virtualtext").show()
end
function utils.virtual_text_hide()
    require("lsp.global.languages.virtualtext").hide()
end
-- GIT signs
function utils.preview_hunk() require('gitsigns').preview_hunk() end
function utils.next_hunk() require('gitsigns').next_hunk() end
function utils.prev_hunk() require('gitsigns').prev_hunk() end
function utils.stage_hunk() require('gitsigns').stage_hunk() end
function utils.undo_stage_hunk() require('gitsigns').undo_stage_hunk() end
function utils.reset_hunk() require('gitsigns').reset_hunk() end
function utils.reset_buffer() require('gitsigns').reset_buffer() end
function utils.blame_line() require('gitsigns').blame_line() end
-- Set path
function utils.set_global_path() require('core.funcs').set_global_path() end
function utils.set_window_path() require('core.funcs').set_window_path() end
-- Snap
local snap = require 'snap'
local fzf = snap.get 'consumer.fzf'
local limit = snap.get 'consumer.limit'
local producer_file = snap.get'producer.ripgrep.file'.args {
    "--iglob", "!vendor/* node_modules/* target/* git/*"
}
local producer_vimgrep = snap.get 'producer.ripgrep.vimgrep'
local producer_buffer = snap.get 'producer.vim.buffer'
local producer_oldfile = snap.get 'producer.vim.oldfile'
local producer_git = snap.get 'consumer.fzf'(snap.get 'producer.git.file')
local producer_help = snap.get 'consumer.fzf'(snap.get 'producer.vim.help')
local select_file = snap.get 'select.file'
local select_vimgrep = snap.get 'select.vimgrep'
local preview_file = snap.get 'preview.file'
local preview_vimgrep = snap.get 'preview.vimgrep'

function init_treesitter()
    if not packer_plugins['nvim-treesitter'].loaded then
        vim.cmd [[packadd nvim-treesitter]]
    end
end

function utils.snap_files()
    init_treesitter()
    snap.run({
        prompt = '  Files  ',
        producer = fzf(producer_file),
        select = select_file.select,
        multiselect = select_file.multiselect,
        views = {preview_file}
    })
end

function utils.snap_grep()
    init_treesitter()
    snap.run({
        prompt = '  Grep  ',
        producer = limit(10000, producer_vimgrep),
        select = select_vimgrep.select,
        multiselect = select_vimgrep.multiselect,
        views = {preview_vimgrep}
    })
end

function utils.snap_grep_selected_word()
    init_treesitter()
    snap.run({
        prompt = '  Grep  ',
        producer = limit(10000, producer_vimgrep),
        select = select_vimgrep.select,
        multiselect = select_vimgrep.multiselect,
        views = {preview_vimgrep},
        initial_filter = vim.fn.expand('<cword>')
    })
end

function utils.snap_git()
    init_treesitter()
    snap.run {
        prompt = '  Git  ',
        producer = producer_git,
        select = snap.get'select.file'.select,
        multiselect = snap.get'select.file'.multiselect,
        views = {snap.get 'preview.file'}
    }
end

function utils.snap_help()
    init_treesitter()
    snap.run {
        prompt = " ﲉ Help  ",
        producer = producer_help,
        select = snap.get'select.help'.select,
        views = {snap.get 'preview.help'}
    }
end

function utils.snap_buffers()
    init_treesitter()
    snap.run({
        prompt = ' ﬘ Buffers  ',
        producer = fzf(producer_buffer),
        select = select_file.select,
        multiselect = select_file.multiselect,
        views = {preview_file}
    })
end

function utils.snap_old_files()
    init_treesitter()
    snap.run({
        prompt = '  Oldfiles  ',
        producer = fzf(producer_oldfile),
        select = select_file.select,
        multiselect = select_file.multiselect,
        views = {preview_file}
    })
end

return utils
