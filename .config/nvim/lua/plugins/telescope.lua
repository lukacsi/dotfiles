return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set('n', '<leader><C-p>', function()
        builtin.find_files({ hidden = true })
        end, {})
      vim.keymap.set('n', '<leader><C-f>', function()
        builtin.live_grep({ additional_args = function(args)
          return vim.list_extend(args, { "--hidden" })
          end })
        end, {})
      vim.keymap.set('n', '<C-p>', builtin.find_files, {})
      vim.keymap.set('n', '<C-f>', builtin.live_grep, {})
    end
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require("telescope").setup {
        extensions = {
          require("telescope.themes").get_dropdown {}
        }
      }
      require("telescope").load_extension("ui-select")
    end
  }
}
