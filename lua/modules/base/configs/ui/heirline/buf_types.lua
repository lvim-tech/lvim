-- Buftype exclusion list for heirline.
-- Buffer types whose windows should not show the normal statusline/winbar
-- (special/non-file buffers). Consumed by the heirline statusline/winbar conditions.
return {
    "nofile",
    "prompt",
    "help",
    "terminal",
}
