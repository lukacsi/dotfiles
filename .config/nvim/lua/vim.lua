vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.g.mapleader = " "

-- Function to increase indentation by 2
local function increase_indent()
    vim.opt.tabstop = vim.opt.tabstop:get() + 2
    vim.opt.softtabstop = vim.opt.softtabstop:get() + 2
    vim.opt.shiftwidth = vim.opt.shiftwidth:get() + 2
    print("Indentation increased to " .. vim.opt.tabstop:get())
end

-- Function to decrease indentation by 2
local function decrease_indent()
    local new_tabstop = math.max(vim.opt.tabstop:get() - 2, 2)
    local new_softtabstop = math.max(vim.opt.softtabstop:get() - 2, 2)
    local new_shiftwidth = math.max(vim.opt.shiftwidth:get() - 2, 2)
    vim.opt.tabstop = new_tabstop
    vim.opt.softtabstop = new_softtabstop
    vim.opt.shiftwidth = new_shiftwidth
    print("Indentation decreased to " .. vim.opt.tabstop:get())
end

-- Create a command to increase indentation
vim.api.nvim_create_user_command('IncreaseIndent', increase_indent, {
    desc = 'Increase indentation settings by 2'
})

-- Create a command to decrease indentation
vim.api.nvim_create_user_command('DecreaseIndent', decrease_indent, {
    desc = 'Decrease indentation settings by 2'
})

vim.api.nvim_set_keymap('n', '<Leader>ii', ':IncreaseIndent<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Leader>di', ':DecreaseIndent<CR>', { noremap = true, silent = true })


vim.api.nvim_buf_set_keymap(0, "n", "<leader>yt", ":YAMLTelescope<CR>", { noremap = false })
vim.api.nvim_buf_set_keymap(0, "n", "<leader>yl", ":!yamllint %<CR>", { noremap = true, silent = true })
