-- Overseer task template: run the current Rust file or Cargo project.
-- Filetype-gated (rust); uses `cargo run` when a Cargo.toml is present, otherwise
-- compiles the single file with `rustc` to ./out and executes it.
return {
    name = "RUST RUN",
    builder = function()
        local cwd = vim.fn.expand("%:p:h")
        local file = vim.fn.expand("%:p")
        local cmd
        if vim.fn.filereadable(cwd .. "/Cargo.toml") == 1 then
            cmd = { "cargo", "run" }
        else
            local output = cwd .. "/out"
            cmd = { "bash", "-c", string.format("rustc '%s' -o '%s' && '%s'", file, output, output) }
        end
        return {
            cmd = cmd,
            cwd = cwd,
            components = { "default" },
        }
    end,
    condition = {
        filetype = { "rust" },
    },
}
