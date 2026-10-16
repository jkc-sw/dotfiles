if not vim.g.jerry_enabled then
  return
end

-- Jira markup
vim.cmd [[
  iabbrev <buffer> nfor <c-r>=jerry#common#JiraNoFormat()<cr><up>
  iabbrev <buffer> code; <c-r>=jerry#common#JiraCodeFormat()<cr><up>
]]

-- vim:et ts=2 sts=2 sw=2
