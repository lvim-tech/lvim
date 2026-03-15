local icons = require("configs.base.ui.icons")
local picons = icons.projects

local function run(command_template, opts)
    opts = opts or {}
    local pass_name = opts.pass_name or false
    local cwd_project_dir = opts.cwd_project_dir or false
    local create_dir = opts.create_dir or false
    local module_init = opts.module_init or false

    local project_name, path, project_dir

    if pass_name or module_init then
        project_name = vim.fn.input("Enter project name (use '.' for current directory): ")
        if project_name == "" then
            print("Operation cancelled.")
            return
        end
    end

    local default_path = vim.fn.getcwd()
    if cwd_project_dir or create_dir or (project_name ~= nil) then
        path = vim.fn.input("Enter path (default: " .. default_path .. "): ", default_path)
        if path == "" then
            path = default_path
        end
    else
        path = default_path
    end

    local use_flat_dir = pass_name and not module_init
    if use_flat_dir then
        project_dir = path
    else
        if project_name ~= nil then
            if project_name == "." then
                project_dir = path
            else
                project_dir = path .. "/" .. project_name
            end
        else
            project_dir = path
        end
    end

    if create_dir and project_dir ~= "" and vim.fn.isdirectory(project_dir) == 0 then
        vim.fn.mkdir(project_dir, "p")
    end

    local final_command = command_template

    if module_init then
        local default_module = (project_name and project_name ~= "." and project_name) or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        local suggested = "github.com/<youruser>/" .. default_module
        local module_path = vim.fn.input("Module path for `go mod init` (e.g. " .. suggested .. "): ", suggested)
        if module_path == "" then
            print("No module path provided. Operation cancelled.")
            return
        end
        final_command = "go mod init " .. vim.fn.shellescape(module_path)
        cwd_project_dir = true
    elseif pass_name and project_name then
        local arg = (project_name == ".") and "." or vim.fn.shellescape(project_name)
        final_command = command_template .. " " .. arg
    end

    local original_win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)
    local win_config = {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        col = math.floor(vim.o.columns * 0.1),
        row = math.floor(vim.o.lines * 0.1),
        border = "single",
        style = "minimal",
    }
    local win = vim.api.nvim_open_win(buf, true, win_config)

    local cwd = cwd_project_dir and project_dir or path
    if cwd ~= "" and vim.fn.isdirectory(cwd) == 0 then
        vim.fn.mkdir(cwd, "p")
    end

    vim.fn.jobstart(final_command, {
        term = true,
        cwd = cwd,
        on_exit = function(_, exit_code, _)
            vim.defer_fn(function()
                if vim.api.nvim_win_is_valid(win) then
                    pcall(vim.api.nvim_win_close, win, true)
                end
                if vim.api.nvim_buf_is_valid(buf) then
                    pcall(vim.api.nvim_buf_delete, buf, { force = true })
                end
                if vim.api.nvim_win_is_valid(original_win) then
                    pcall(vim.api.nvim_set_current_win, original_win)
                end
                if exit_code == 0 then
                    print("Command executed successfully.")
                else
                    print("Command failed with exit code: " .. tostring(exit_code))
                end
            end, 100)
        end,
    })
    vim.cmd("startinsert")
end

return {
    name = "projects",
    label = "Newproject",
    icon = icons.common.project,
    settings = {
        {
            icon = picons.frontend,
            top = false,
            type = "spacer",
            label = "Frontend",
            bottom = false,
        },
        {
            name = "nextjs",
            icon = picons.nextjs,
            label = "Next.js",
            type = "action",
            run = function()
                run("npx create-next-app@latest", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            name = "vite",
            icon = picons.vite,
            label = "Vite",
            type = "action",
            run = function()
                run("npm create vite@latest", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            name = "svelte",
            icon = picons.svelte,
            label = "Svelte",
            type = "action",
            run = function()
                run("npm create svelte@latest", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            name = "astro",
            icon = picons.astro,
            label = "Astro",
            type = "action",
            run = function()
                run("npm create astro@latest", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            name = "react",
            icon = picons.react,
            label = "React",
            type = "action",
            run = function()
                run("npx create-react-app", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            name = "angular",
            icon = picons.angular,
            label = "Angular",
            type = "action",
            run = function()
                run("npx @angular/cli new", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            icon = picons.backend,
            top = true,
            type = "spacer",
            label = "Backend",
            bottom = false,
        },
        {
            name = "nestjs",
            icon = picons.nestjs,
            label = "NestJS",
            type = "action",
            run = function()
                run("npx @nestjs/cli new", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            name = "express",
            icon = picons.express,
            label = "Express.js",
            type = "action",
            run = function()
                run("npx express-generator", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            name = "django",
            icon = picons.django,
            label = "Django",
            type = "action",
            run = function()
                run("python3 -m django startproject", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            name = "laravel",
            icon = picons.laravel,
            label = "Laravel",
            type = "action",
            run = function()
                run("composer create-project laravel/laravel", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            icon = picons.mobile,
            top = true,
            type = "spacer",
            label = "Mobile",
            bottom = false,
        },
        {
            name = "reactnative",
            icon = picons.react_native,
            label = "React Native",
            type = "action",
            run = function()
                run("npx react-native init", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            name = "flutter",
            icon = picons.flutter,
            label = "Flutter",
            type = "action",
            run = function()
                run("flutter create", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            icon = picons.go,
            top = true,
            type = "spacer",
            label = "Go",
            bottom = false,
        },
        {
            name = "go",
            icon = picons.go,
            label = "Go Mod Init",
            type = "action",
            run = function()
                run("go mod init", { cwd_project_dir = true, create_dir = true, module_init = true })
            end,
        },
        {
            name = "go-tidy",
            icon = picons.go,
            label = "Go Mod Tidy",
            type = "action",
            run = function()
                run("go mod tidy", { cwd_project_dir = true })
            end,
        },
        {
            icon = picons.python,
            top = true,
            type = "spacer",
            label = "Python",
            bottom = false,
        },
        {
            name = "uv",
            icon = picons.python,
            label = "uv (modern)",
            type = "action",
            run = function()
                run("uv init", { pass_name = true, cwd_project_dir = true })
            end,
        },
        {
            name = "venv",
            icon = picons.python,
            label = "venv (standard)",
            type = "action",
            run = function()
                run("python3 -m venv venv", { pass_name = true, cwd_project_dir = true })
            end,
        },
    },
}
