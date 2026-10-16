return {
  {
    -- lang.markdown owns loading and the <leader>um toggle.
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {
      completions = { blink = { enabled = true } },
      code = { border = 'thick' },
    },
  },
  {
    'catgoose/nvim-colorizer.lua',
    event = 'LazyFile',
    opts = {},
  },
  {
    'haringsrob/nvim_context_vt',
    event = 'LazyFile',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = { disable_virtual_lines = true },
  },
}
