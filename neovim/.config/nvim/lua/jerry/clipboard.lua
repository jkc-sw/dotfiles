
local M = {}

--- @brief Send the content to the clipboard provider
--- @param content string
--- @throws No clipboard provider
M.send_to_clipboard = function(content)
  if not content then
    return
  end
  if #vim.g.clip_supplier < 1 then
    error("No clipboard supplier found. Please set vim.g.clip_supplier")
  end
  vim.system({vim.g.clip_supplier[1]}, { stdin = content, text = true }):wait()
  vim.fn.setreg('"', content)
end

return M

-- vim:et ts=2 sts=2 sw=2
