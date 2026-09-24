return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      ensure_installed = {
        'go', 'gomod', 'gosum', 'terraform', 'hcl', 'dockerfile',
        'bash', 'lua', 'nix', 'python', 'html', 'css', 'javascript',
        'typescript', 'json', 'yaml', 'php',
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
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
