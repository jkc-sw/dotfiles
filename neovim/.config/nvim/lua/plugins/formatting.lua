return {
  {
    'stevearc/conform.nvim',
    -- Language extras and formatting.prettier supply the remaining formatters.
    opts = {
      formatters_by_ft = {
        nix = { 'alejandra' },
        bash = { 'shfmt' },
        -- Avoid LSP fallback formatting, which pylsp would also offer.
        python = { 'ruff_format' },
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
