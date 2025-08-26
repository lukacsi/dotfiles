return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("tokyonight").setup({
      styles = {
        sidebars = "transparent",  -- Make sidebars transparent
        floats = "transparent",    -- Make floating windows transparent
      },
    })
    vim.cmd.colorscheme "tokyonight-night"
  end
}

