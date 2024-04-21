return {
  "nvim-treesitter/nvim-treesitter",
  build = function()
    require("nvim-treesitter.install").update({ with_sync = true })()
  end,
  config = function ()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = 'all',
      sync_install = false,
      auto_install = false,
      context_commentstring = {
        enable = false,
      },
      highlight = {
        enable = true,
        disable = { 'cpp' }
      },
      indent = {
        enable = false,
        disable = { 'python' }
      }
    })
  end
}

-- vim:et ts=2 sts=2 sw=2
