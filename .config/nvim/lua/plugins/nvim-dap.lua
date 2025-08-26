return {
  -- Core DAP Plugin with all configurations
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require('dap')

      -- Configure the GDB adapter
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
      }

      -- Common configurations for C, C++, and Rust
      local common_configs = {
        {
          name = "Launch",
          type = "gdb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          args = {},
          setupCommands = {
            {
              text = "set print pretty on",
              description = "Enable pretty printing",
              ignoreFailures = false
            },
          },
        },
        {
          name = "Attach to Process",
          type = "gdb",
          request = "attach",
          processId = function()
            return vim.fn.input('PID to attach: ')
          end,
          cwd = '${workspaceFolder}',
        },
      }

      -- Assign configurations to relevant filetypes
      dap.configurations.c = common_configs
      dap.configurations.cpp = common_configs
      dap.configurations.rust = common_configs

      -- Keybindings for nvim-dap
      -- Helper function to set key mappings
      local function map(mode, lhs, rhs, opts)
        local options = { noremap = true, silent = true }
        if opts then
          options = vim.tbl_extend('force', options, opts)
        end
        vim.api.nvim_set_keymap(mode, lhs, rhs, options)
      end

      -- DAP Keybindings
      map('n', '<F5>', '<Cmd>lua require"dap".continue()<CR>', {})
      map('n', '<F6>', '<Cmd>lua require"dap".step_over()<CR>', {})
      map('n', '<F7>', '<Cmd>lua require"dap".step_into()<CR>', {})
      map('n', '<F8>', '<Cmd>lua require"dap".step_out()<CR>', {})
      map('n', '<Leader>b', '<Cmd>lua require"dap".toggle_breakpoint()<CR>', {})
      map('n', '<Leader>B', '<Cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>', {})
      map('n', '<Leader>lp', '<Cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>', {})
      map('n', '<Leader>dr', '<Cmd>lua require"dap".repl.open()<CR>', {})
      map('n', '<Leader>dl', '<Cmd>lua require"dap".run_last()<CR>', {})
      -- Add more keybindings here if necessary
    end
  },

  -- DAP UI Plugin
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup({
        controls = {
          element = "repl",
          enabled = true,
          icons = {
            disconnect = "",
            pause = "",
            play = "",
            run_last = "",
            step_back = "",
            step_into = "",
            step_out = "",
            step_over = "",
            terminate = ""
          }
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
          border = "single",
          mappings = {
            close = { "q", "<Esc>" }
          }
        },
        force_buffers = true,
        icons = {
          collapsed = "",
          current_frame = "",
          expanded = ""
        },
        layouts = { {
            elements = { {
                id = "scopes",
                size = 0.40
              }, {
                id = "breakpoints",
                size = 0.25
              }, {
                id = "stacks",
                size = 0.25
              }, {
                id = "watches",
                size = 0.10
              } },
            position = "left",
            size = 40
          }, {
            elements = { {
                id = "repl",
                size = 0.7
              }, {
                id = "console",
                size = 0.3
              } },
            position = "bottom",
            size = 30
          } },
        mappings = {
          edit = "e",
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          repl = "r",
          toggle = "t"
        },
        render = {
          indent = 1,
          max_value_lines = 100
        }
      })

      -- Automatically open/close dapui
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },

  -- DAP Virtual Text Plugin
  {
    "theHamsta/nvim-dap-virtual-text",
    requires = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        show_stop_reason = true,
        commented = false,
      })
    end
  },
}

