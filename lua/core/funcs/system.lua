-- System-level utilities: privileged file writes and human-readable file sizes.
---@module "core.funcs.system"
local M = {}

-- Executes a shell command with sudo by piping the user's password via stdin.
-- Uses `-p ''` to suppress sudo's own password prompt and reads it via inputsecret.
---@param cmd string  Shell command to run as root (must be properly escaped)
---@return boolean    True if the command succeeded, false on bad password or error
M.sudo_exec = function(cmd)
    vim.fn.inputsave()
    local password = vim.fn.inputsecret("Password: ")
    vim.fn.inputrestore()
    if not password or #password == 0 then
        vim.notify("Invalid password, sudo aborted!", vim.log.levels.ERROR, {
            title = "LVIM IDE",
        })
        return false
    end
    vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
    if vim.v.shell_error ~= 0 then
        vim.notify("Shell error or invalid password, sudo aborted!", vim.log.levels.ERROR, {
            title = "LVIM IDE",
        })
        return false
    end
    return true
end

-- Saves the current buffer to a temp file and copies it to its real path with
-- sudo, allowing root-owned files to be written from a user-level Neovim session.
---@param tmpfile? string  Temp file path; defaults to vim.fn.tempname()
---@param filepath? string Target file path; defaults to current buffer's file
M.sudo_write = function(tmpfile, filepath)
    if not tmpfile then
        tmpfile = vim.fn.tempname()
    end
    if not filepath then
        filepath = vim.fn.expand("%")
    end
    if not filepath or #filepath == 0 then
        vim.notify("No file name!", vim.log.levels.ERROR, {
            title = "LVIM IDE",
        })
        return
    end
    -- Use dd to perform a block-level copy so file permissions are preserved
    local cmd = string.format("dd if=%s of=%s bs=1048576", vim.fn.shellescape(tmpfile), vim.fn.shellescape(filepath))
    vim.api.nvim_command(string.format("write! %s", tmpfile))
    if M.sudo_exec(cmd) then
        vim.notify(string.format('"%s" written!', filepath), vim.log.levels.INFO, {
            title = "LVIM IDE",
        })
        vim.cmd("e!")
    end
    vim.fn.delete(tmpfile)
end

return M
