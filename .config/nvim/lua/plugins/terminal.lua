return {
    "akinsho/toggleterm.nvim",
    version = '*', -- or specify the version you prefer
    config = function()
      require("toggleterm").setup{
        -- Configuration options for toggleterm.nvim
        size = 20,
        open_mapping = [[<A-t>]],  -- Change this mapping to open/close the terminal
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        persist_size = true,
        direction = "float", --"horizontal", -- Options: horizontal, vertical, tab, float
        close_on_exit = true,
        shell = "zsh"
      }
    end
}
