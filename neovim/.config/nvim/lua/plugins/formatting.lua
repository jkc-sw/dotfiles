return {
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        nix = { 'alejandra' },
        bash = { 'shfmt' },
        python = { 'ruff_format' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        json = { 'prettierd' },
        jsonc = { 'prettierd' },
        yaml = { 'prettierd' },
        markdown = { 'prettierd' },
        html = { 'prettierd' },
        css = { 'prettierd' },
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = { lua = { 'luacheck' }, sh = { 'shellcheck' }, bash = { 'shellcheck' } },
      linters = {
        luacheck = {
          condition = function()
            return vim.fn.executable 'luacheck' == 1
          end,
        },
      },
    },
  },
}
