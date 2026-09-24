return {
  {
    -- nvim-treesitter main branch: new API (configs module removed 2025)
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local parsers = {
        'go', 'gomod', 'gosum', 'terraform', 'hcl', 'dockerfile',
        'bash', 'lua', 'nix', 'python', 'html', 'css', 'javascript',
        'typescript', 'json', 'yaml', 'php',
      }
      require('nvim-treesitter').install(parsers)

      vim.api.nvim_create_autocmd('FileType', {
        pattern = parsers,
        callback = function()
          vim.treesitter.start()          -- highlighting
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"  -- indentation
        end,
      })
    end,
  },
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    keys = {
      { '<leader>f', function() require('conform').format({ async = true, lsp_fallback = true }) end, desc = 'Format buffer' },
    },
    opts = {
      formatters_by_ft = {
        go = { 'goimports', 'gofmt' },
        terraform = { 'terraform_fmt' },
        hcl = { 'terraform_fmt' },
        bash = { 'shfmt' },
        sh = { 'shfmt' },
        python = { 'ruff_format' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        css = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
        lua = { 'stylua' },
        nix = { 'nixpkgs-fmt' },
        php = { 'lsp_format' },
        ['_'] = { 'trim_whitespace' },
      },
      format_on_save = { timeout_ms = 1000, lsp_fallback = true },
    },
  },
  -- telescope-fzf-native: much faster grep/find
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      require('telescope').setup({
        extensions = { fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true } },
      })
      pcall(require('telescope').load_extension, 'fzf')
    end,
  },
}
