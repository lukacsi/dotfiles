return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup{
      ensure_installed = {
        "lua_ls",
        "terraformls",
        "clangd",
        "rust_analyzer",
        "ltex",
        "pylyzer",
        "markdown_oxide",
        "tflint",
        "bashls"
        }
      }
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
      lspconfig.yamlls.setup {
        settings = {
          yaml = {
            schemas = {
              kubernetes = "k8s-*.yaml",
              ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
              ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
              ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/**/*.{yml,yaml}",
              ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
              ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
              ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
              ["http://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}",
            },
          },
        },
      }
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
    end
  },
  {
    "hrsh7th/nvim-cmp",             -- Autocompletion plugin
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",       -- LSP source for nvim-cmp
      "hrsh7th/cmp-buffer",         -- Buffer completions
      "hrsh7th/cmp-path",           -- Path completions
      "hrsh7th/cmp-cmdline",        -- Command-line completions
      "L3MON4D3/LuaSnip",           -- Snippet engine
      "saadparwaiz1/cmp_luasnip"    -- Snippets source for nvim-cmp
    },
    config = function()
      local cmp = require("cmp")
      local cmp_enabled = true
      function ToggleCmp()
        cmp_enabled = not cmp_enabled
        if cmp_enabled then
          cmp.setup({
            snippet = {
              expand = function(args)
                require("luasnip").lsp_expand(args.body)
              end,
            },
            mapping = {
              ["<Tab>"] = cmp.mapping.select_next_item(),
              ["<S-Tab>"] = cmp.mapping.select_prev_item(),
              ["<C-b>"] = cmp.mapping.scroll_docs(-4),
              ["<C-f>"] = cmp.mapping.scroll_docs(4),
              ["<C-Space>"] = cmp.mapping.complete(),
              ["<C-e>"] = cmp.mapping.abort(),
              ["<CR>"] = cmp.mapping.confirm({ select = true }),
            },
            sources = cmp.config.sources({
              { name = "nvim_lsp" },
              { name = "luasnip" },
              { name = "buffer" },
              { name = "path" },
            })
          })

          print("Autocompletion enabled")
        else
          cmp.setup({
            sources = {}  -- Disable sources to effectively turn off autocompletion
          })
          print("Autocompletion disabled")
        end
      end
      -- Add LSP capabilities to nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("lspconfig")["lua_ls"].setup { capabilities = capabilities }
      require("lspconfig")["clangd"].setup { capabilities = capabilities }
      require("lspconfig")["ltex"].setup { capabilities = capabilities }
      require("lspconfig")["terraformls"].setup { capabilities = capabilities }
      require("lspconfig")["markdown_oxide"].setup { capabilities = capabilities }
      require("lspconfig")["pylyzer"].setup { capabilities = capabilities }
      require("lspconfig")["rust_analyzer"].setup { capabilities = capabilities }
      require("lspconfig")["tflint"].setup { capabilities = capabilities }
      require("lspconfig")["bashls"].setup { capabilities = capabilities }

      vim.api.nvim_set_keymap("n", "<leader>tc", ":lua ToggleCmp()<CR>", { noremap = true, silent = true })

      cmp.setup.buffer {
        sources = {
          { name = "vsnip" },
          { name = "nvim_lsp" },
          { name = "path" },
          {
            name = "buffer",
            option = {
              get_bufnrs = function()
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
              end,
            },
          },
        },
      }
    end
  }
}
