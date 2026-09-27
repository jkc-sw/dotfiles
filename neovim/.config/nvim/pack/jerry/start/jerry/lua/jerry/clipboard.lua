
local M = {}

--- @brief Send the content to vim.g.clip_supplier, or to the `+` register
--- when no supplier is configured
--- @param content string
M.send_to_clipboard = function(content)
  if not content then
    return
  end
  local supplier = vim.g.clip_supplier
  if type(supplier) ~= 'table' or #supplier < 1 then
    vim.fn.setreg('+', content)
  else
    vim.system({supplier[1]}, { stdin = content, text = true }):wait()
  end
  vim.fn.setreg('"', content)
end

return M

-- vim:et ts=2 sts=2 sw=2
