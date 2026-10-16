local markdown_fenced_languages = { 'python', 'ps1', 'cpp', 'bash', 'vim', 'matlab' }

local function ensure_markdown_fenced_languages()
  local current = vim.g.markdown_fenced_languages
  if type(current) ~= 'table' then
    current = {}
  end

  for _, lang in ipairs(markdown_fenced_languages) do
    if not vim.tbl_contains(current, lang) then
      table.insert(current, lang)
    end
  end

  vim.g.markdown_fenced_languages = current
end

ensure_markdown_fenced_languages()

-- Trim whitespace on save
vim.api.nvim_create_augroup('nowhitespaceattheend', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'nowhitespaceattheend',
  pattern = '*',
  callback = function()
    vim.fn['jerry#common#TrimWhitespace']()
  end,
})

-- Global abbreviations. Filetype-specific ones live in ftplugin/ as <buffer> abbreviations.
vim.cmd [[
  iabbrev vimet vim:et ts=4 sts=4 sw=4
  iabbrev tit SOURCE_THESE_VIMS_START<cr><cr>echom 'Sourced'<cr>SOURCE_THESE_VIMS_END
  iabbrev tyt SOURCE_THESE_LUAS_START<cr><cr>print('Sourced')<cr>SOURCE_THESE_LUAS_END
  iabbrev tpt MARK_THIS_PLACE
]]

-- DisableSomeSyntax
vim.api.nvim_create_augroup('DisableSomeSyntax', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'TabEnter' }, {
  group = 'DisableSomeSyntax',
  pattern = { '*.groovy', '*.html' },
  command = 'syntax sync fromstart',
})
