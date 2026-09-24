return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      require('lspconfig').gopls.setup({ capabilities = capabilities })
      require('lspconfig').dockerls.setup({ capabilities = capabilities })
      require('lspconfig').docker_compose_language_service.setup({ capabilities = capabilities })

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
