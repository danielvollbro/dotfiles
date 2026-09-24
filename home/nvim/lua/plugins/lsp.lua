return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local servers = {
        gopls = {},
        dockerls = {},
        docker_compose_language_service = {},
        terraformls = {},
        bashls = {},
        intelephense = {},
        html = {},
        cssls = {},
        ts_ls = {},
        pyright = {},
        jsonls = {},
        yamlls = {},
        nixd = {},
        lua_ls = {},
      }
      for server, opts in pairs(servers) do
        opts.capabilities = capabilities
        require('lspconfig')[server].setup(opts)
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        end,
      })
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
        }, {
          { name = 'buffer' },
        }),
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
      })
    end,
  },
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    keys = { { '<leader>x', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics' } },
    opts = {},
  },
  {
    'ray-x/go.nvim',
    ft = { 'go' },
    dependencies = { 'ray-x/guihua.lua', 'neovim/nvim-lspconfig' },
    config = function()
      require('go').setup({
        goimports = 'gopls',
        gofmt = 'gofmt',
      })
    end,
  },
}
