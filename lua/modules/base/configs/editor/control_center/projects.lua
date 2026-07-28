-- New-project scaffolding group for the LVIM Control Center.
-- Exposes actions that bootstrap new projects (frontend / backend / mobile / Go /
-- Python) by running the matching CLI scaffolder (create-next-app, vite, django,
-- go mod init, uv, ...) inside a floating terminal.
--
-- The local `run(command_template, opts)` helper drives all of them: it asks for what it needs
-- through `vim.ui.input` (a chain, because the answers are asynchronous), creates the directory,
-- builds the final command and launches it in lvim-shell's float. `opts` flags:
--   pass_name        append the prompted name as a CLI argument
--   cwd_project_dir  run inside the created project directory
--   create_dir       mkdir -p the project directory first
--   module_init      special-case `go mod init` (prompts for a module path)
-- Returns a Control Center group descriptor.

---@module "modules.base.configs.editor.control_center.projects"

local icons = require("configs.base.ui.icons")
local picons = icons.projects

--- Ask a sequence of questions through `vim.ui.input`, then hand the answers to `done`.
---
--- `vim.ui.input`, not `vim.fn.input`: the raw one is a cmdline prompt that bypasses the editor's
--- own input surface (lvim-hud serves `vim.ui.input` in the message zone) and blocks the loop while
--- it waits. Being asynchronous, the questions have to be a CHAIN rather than three statements —
--- each step may compute its prompt and default from the answers already given.
---@param steps table[]  { key, prompt, default?, required? } — prompt/default may be fun(answers)
---@param done fun(answers: table<string, string>)
---@return nil
local function ask(steps, done)
    local answers = {}
    local function step(i)
        local spec = steps[i]
        if spec == nil then
            done(answers)
            return
        end
        local default = spec.default
        if type(default) == "function" then
            default = default(answers)
        end
        local prompt = spec.prompt
        if type(prompt) == "function" then
            prompt = prompt(answers)
        end
        vim.ui.input({ prompt = prompt, default = default, completion = spec.completion }, function(value)
            -- nil = the user cancelled; "" = an empty answer. A required step accepts neither.
            if value == nil or (spec.required and value == "") then
                if value ~= nil then
                    vim.notify("New project: cancelled (" .. spec.key .. " is required).", vim.log.levels.INFO)
                end
                return
            end
            answers[spec.key] = value
            step(i + 1)
        end)
    end
    step(1)
end

local function run(command_template, opts)
    opts = opts or {}
    local pass_name = opts.pass_name or false
    local cwd_project_dir = opts.cwd_project_dir or false
    local create_dir = opts.create_dir or false
    local module_init = opts.module_init or false

    local default_path = vim.fn.getcwd()
    local steps = {}
    if pass_name or module_init then
        steps[#steps + 1] = {
            key = "name",
            prompt = "Project name (use '.' for the current directory): ",
            required = true,
        }
    end
    if cwd_project_dir or create_dir or pass_name or module_init then
        steps[#steps + 1] = {
            key = "path",
            prompt = "Path: ",
            default = default_path,
            completion = "dir",
        }
    end
    if module_init then
        steps[#steps + 1] = {
            key = "module",
            required = true,
            prompt = "Module path for `go mod init`: ",
            default = function(a)
                local base = (a.name and a.name ~= "." and a.name) or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
                return "github.com/<youruser>/" .. base
            end,
        }
    end

    ask(steps, function(a)
        local project_name = a.name
        local path = (a.path ~= nil and a.path ~= "") and a.path or default_path

        local project_dir
        if pass_name and not module_init then
            project_dir = path
        elseif project_name ~= nil and project_name ~= "." then
            project_dir = path .. "/" .. project_name
        else
            project_dir = path
        end

        if create_dir and project_dir ~= "" and vim.fn.isdirectory(project_dir) == 0 then
            vim.fn.mkdir(project_dir, "p")
        end

        local final_command = command_template
        local in_project_dir = cwd_project_dir
        if module_init then
            final_command = "go mod init " .. vim.fn.shellescape(a.module)
            in_project_dir = true
        elseif pass_name and project_name then
            local arg = (project_name == ".") and "." or vim.fn.shellescape(project_name)
            final_command = command_template .. " " .. arg
        end

        local cwd = in_project_dir and project_dir or path
        if cwd ~= "" and vim.fn.isdirectory(cwd) == 0 then
            vim.fn.mkdir(cwd, "p")
        end

        -- The scaffolder runs in lvim-shell's float — the same themed terminal surface every other
        -- TUI in this config opens in, which also restores the previous window and cleans up its
        -- buffer when the command exits. (This used to be a hand-rolled `nvim_open_win` + jobstart
        -- with its own close/restore bookkeeping, i.e. a second, unthemed float implementation.)
        -- lvim-shell is LAZY (`cmd = "LvimShell"`), so it is not on the runtimepath yet and a plain
        -- `require` would fail here. The loader's own seam loads it exactly as a trigger would —
        -- dependencies, config and load report included; `packadd` would do none of that.
        require("lvim-pack").load_plugin("lvim-shell", "control-center: new project")
        require("lvim-shell").float(final_command, "<CR>", {
            cwd = cwd,
            ui = { float = { title = "New project" } },
        })
    end)
end


return {
    name = "projects",
    label = "New project",
    icon = icons.common.project,
    settings = {
        {
            icon = picons.frontend,
            top = true,
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
