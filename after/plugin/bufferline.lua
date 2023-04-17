vim.opt.termguicolors = true

local highlights = require("nord").bufferline.highlights({
    italic = true,
    bold = true
})

--  
require("bufferline").setup({
    options = {
        seperator_style = {"",  ""},
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                highlight = "Directory",
                seperator = true
            }
        },
    },
    highlights = highlights,
})
