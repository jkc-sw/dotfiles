-- Conform owns automatic formatting in Home Manager. Keep the shared manual
-- LuaFormat command and Luacheck diagnostics, without a second save formatter.
require('jerry.lua-tools').setup { format = false }

require('conform').setup {
  default_format_opts = { lsp_format = 'fallback' },
  formatters_by_ft = {
    lua = { 'stylua' },
    nix = { 'alejandra' },
    sh = { 'shfmt' },
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
  format_on_save = function(bufnr)
    if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
      return
    end
    return { timeout_ms = 1000, lsp_format = 'fallback' }
  end,
}
