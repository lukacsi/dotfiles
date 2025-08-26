return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    vim.keymap.set('n', '<C-n>', ':Neotree filesystem toggle right<CR>')
    require('neo-tree').setup {
      enable_git_status = true,
      default_component_configs = {
        icon = {
          git_status = true,
          show_git_icons = true,
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,
        },
      },
      git_status = {
        symbols = {
          added     = "",
          modified  = "",
          deleted   = "",
          renamed   = "",
          untracked = "",
          ignored   = "",
        },
      },
    }
  end
}
