local M = {}

function M.setup(opts)
  opts = opts or {}
  local markdown_fenced_languages = { 'python', 'ps1', 'cpp', 'bash', 'vim', 'matlab' }
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

  if opts.legacy then
    -- LazyVim owns formatting and yank highlighting in the default profile.
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = vim.api.nvim_create_augroup('nowhitespaceattheend', { clear = true }),
      callback = function()
        vim.fn['jerry#common#TrimWhitespace']()
      end,
    })
    vim.api.nvim_create_autocmd('TextYankPost', {
      group = vim.api.nvim_create_augroup('LuaHighlight', { clear = true }),
      callback = function()
        pcall(function() require('vim.hl').on_yank() end)
      end,
    })
  end

  -- Filetype abbreviations belong to the current buffer, including extensionless files.
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('jerry_abbreviations', { clear = true }),
    callback = function()
      vim.cmd [[
        iabbrev <buffer> vimet vim:et ts=4 sts=4 sw=4
        iabbrev <buffer> tit SOURCE_THESE_VIMS_START<cr><cr>echom 'Sourced'<cr>SOURCE_THESE_VIMS_END
        iabbrev <buffer> tyt SOURCE_THESE_LUAS_START<cr><cr>print('Sourced')<cr>SOURCE_THESE_LUAS_END
        iabbrev <buffer> tpt MARK_THIS_PLACE
      ]]
      if vim.bo.filetype == 'markdown' then
        -- markdown_links owns ats, including its interactive date offset.
        for depth = 1, 4 do
          local heading = string.rep('#', depth)
          for _, suffix in ipairs({ 'T', 't' }) do
            vim.cmd('iabbrev <buffer> ' .. heading .. suffix .. ' ' .. heading
              .. " <c-r>=strftime('%Y-%m-%d %A')<cr>")
          end
        end
      elseif vim.bo.filetype == 'ps1' then
        vim.cmd [[
          iabbrev <buffer> nfor <c-r>=jerry#common#JiraNoFormat()<cr><up>
          iabbrev <buffer> code; <c-r>=jerry#common#JiraCodeFormat()<cr><up>
        ]]
      end
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'TabEnter' }, {
    group = vim.api.nvim_create_augroup('DisableSomeSyntax', { clear = true }),
    pattern = { '*.groovy', '*.html' },
    command = 'syntax sync fromstart',
  })
end

return M
