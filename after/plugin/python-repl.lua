require("nvim-python-repl").setup({
    execute_on_send=true, 
    vsplit=true,
    spawn_command={
        python="python -m IPython --TerminalInteractiveShell.highlighting_style=one-dark --no-autoindent", 
    }
}) 

vim.api.nvim_set_keymap('n', '<C-ss>', ":<C-U>SendPySelection<CR>", {noremap=true, silent=true})
