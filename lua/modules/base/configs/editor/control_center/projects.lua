local icons = require("configs.base.ui.icons")
local picons = icons.projects

local function run(command_template)
    local project_name = vim.fn.input("Enter project name (use '.' for current directory): ")
    if project_name == "" then
        print("Operation cancelled.")
        return
    end
    local default_path = vim.fn.getcwd()
    local path = vim.fn.input("Enter path (default: " .. default_path .. "): ", default_path)
    if path == "" then
        path = default_path
    end
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
    end
    local final_command
    if project_name == "." then
        final_command = command_template .. " ."
    else
        final_command = command_template .. " " .. project_name
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
    vim.fn.jobstart(final_command, {
        term = true,
        cwd = path,
        on_exit = function(_, exit_code, _)
            vim.defer_fn(function()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
                if vim.api.nvim_win_is_valid(original_win) then
                    vim.api.nvim_set_current_win(original_win)
                end
                if exit_code == 0 then
                    print("Command executed successfully.")
                else
                    print("Command failed with exit code: " .. exit_code)
                end
            end, 100)
        end,
    })
    vim.cmd("startinsert")
end

return {
    name = "projects",
    label = "New project",
    icon = icons.common.project,
    settings = {
        -- FrontEnd
        {
            icon = picons.frontend,
            top = false,
            type = "spacer",
            label = "FrontEnd",
            bottom = false,
        },
        {
            name = "nextjs",
            icon = picons.nextjs,
            label = "Next.js",
            type = "action",
            run = function()
                run("npx create-next-app@latest")
            end,
        },
        {
            name = "react",
            icon = picons.react,
            label = "React",
            type = "action",
            run = function()
                run("npx create-react-app")
            end,
        },
        {
            name = "vite",
            icon = picons.vite,
            label = "Vite",
            type = "action",
            run = function()
                run("npm create vite@latest")
            end,
        },
        {
            name = "astro",
            icon = picons.astro,
            label = "Astro",
            type = "action",
            run = function()
                run("npm create astro@latest")
            end,
        },
        {
            name = "sveltekit",
            icon = picons.svelte,
            label = "SvelteKit",
            type = "action",
            run = function()
                run("npm create svelte@latest")
            end,
        },
        {
            name = "nuxtjs",
            icon = picons.nuxt,
            label = "Nuxt.js",
            type = "action",
            run = function()
                run("npx nuxi init")
            end,
        },
        {
            name = "nue",
            icon = picons.template,
            label = "Nue",
            type = "action",
            run = function()
                run("nue create")
            end,
        },
        -- Backend
        {
            icon = picons.backend,
            top = true,
            type = "spacer",
            label = "Backend",
            bottom = false,
        },
        {
            name = "express",
            icon = picons.express,
            label = "Express.js",
            type = "action",
            run = function()
                run("npx express-generator")
            end,
        },
        {
            name = "fastify",
            icon = picons.nodejs,
            label = "Fastify",
            type = "action",
            run = function()
                run("npm create fastify@latest")
            end,
        },
        {
            name = "nestjs",
            icon = picons.nestjs,
            label = "NestJS",
            type = "action",
            run = function()
                run("npx @nestjs/cli new")
            end,
        },
        {
            name = "laravel",
            icon = picons.laravel,
            label = "Laravel",
            type = "action",
            run = function()
                run("composer create-project laravel/laravel")
            end,
        },
        {
            name = "springboot",
            icon = picons.spring,
            label = "Spring Boot",
            type = "action",
            run = function()
                run("springboot")
            end,
        },
        {
            name = "flask",
            icon = picons.flask,
            label = "Flask",
            type = "action",
            run = function()
                run(
                    "python3 -m venv venv && source venv/bin/activate && pip install flask && echo \"from flask import Flask\\napp = Flask(__name__)\\n@app.route('/')\\ndef home():\\n    return 'Hello, Flask!'\\n\\nif __name__ == '__main__':\\n    app.run(debug=True)\" > app.py"
                )
            end,
        },
        {
            name = "django",
            icon = picons.django,
            label = "Django",
            type = "action",
            run = function()
                run(
                    "python3 -m venv venv && source venv/bin/activate && pip install django && python3 -m django startproject"
                )
            end,
        },
        -- Fullstack
        {
            icon = picons.fullstack,
            top = true,
            type = "spacer",
            label = "Fullstack",
            bottom = false,
        },
        {
            name = "remix",
            icon = picons.remix,
            label = "Remix",
            type = "action",
            run = function()
                run("npx create-remix@latest")
            end,
        },
        {
            name = "t3stack",
            icon = picons.fullstack,
            label = "T3 Stack",
            type = "action",
            run = function()
                run("npx create-t3-app@latest")
            end,
        },
        -- Python
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
            label = "uv",
            type = "action",
            run = function()
                run("uv init")
            end,
        },
        {
            name = "venv",
            icon = picons.python,
            label = "venv",
            type = "action",
            run = function()
                run("python3 -m venv venv")
            end,
        },
        {
            name = "conda",
            icon = picons.python,
            label = "conda",
            type = "action",
            run = function()
                run("conda create -y -n")
            end,
        },
        -- Mobile
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
                run("npx react-native init")
            end,
        },
        {
            name = "flutter",
            icon = picons.flutter,
            label = "Flutter",
            type = "action",
            run = function()
                run("flutter create")
            end,
        },
    },
}
