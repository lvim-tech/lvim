-- Overseer task template: convert the current Markdown file to PDF and preview it.
-- Filetype-gated (markdown); shells out to `pandoc` to build a sibling .pdf,
-- then opens it in the `zathura` viewer. Returns a single Overseer task spec.
return {
    name = "Markdown to PDF",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cwd = vim.fn.expand("%:p:h")
        local out_pdf = cwd .. "/" .. vim.fn.expand("%:t:r") .. ".pdf"
        return {
            cmd = {
                "sh",
                "-c",
                "pandoc '" .. file .. "' -o '" .. out_pdf .. "' && zathura '" .. out_pdf .. "'",
            },
            cwd = cwd,
        }
    end,
    condition = {
        filetype = { "markdown" },
    },
}
