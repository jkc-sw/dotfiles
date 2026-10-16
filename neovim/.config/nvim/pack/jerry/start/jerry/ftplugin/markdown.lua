if not vim.g.jerry_enabled then
  return
end

require('jerry.markdown').setup_buffer()
require('jerry.markdown_links').setup_buffer()

-- Date headings
vim.cmd [[
  iabbrev <buffer> ats <c-r>=strftime('%Y-%m-%d %A')<cr>
  iabbrev <buffer> #T # <c-r>=strftime('%Y-%m-%d %A')<cr>
  iabbrev <buffer> #t # <c-r>=strftime('%Y-%m-%d %A')<cr>
  iabbrev <buffer> ##T ## <c-r>=strftime('%Y-%m-%d %A')<cr>
  iabbrev <buffer> ##t ## <c-r>=strftime('%Y-%m-%d %A')<cr>
  iabbrev <buffer> ###T ### <c-r>=strftime('%Y-%m-%d %A')<cr>
  iabbrev <buffer> ###t ### <c-r>=strftime('%Y-%m-%d %A')<cr>
  iabbrev <buffer> ####T #### <c-r>=strftime('%Y-%m-%d %A')<cr>
  iabbrev <buffer> ####t #### <c-r>=strftime('%Y-%m-%d %A')<cr>
]]

-- vim:et ts=2 sts=2 sw=2
