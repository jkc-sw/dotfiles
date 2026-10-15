return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'codecompanion' },
    cmd = 'RenderMarkdown',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },
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
