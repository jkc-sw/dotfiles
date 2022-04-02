
local vim = vim

-- Store all the module functions
local M = {}

-- @brief A function that generate mark based on the pattern
-- @param pat (str) - The pattern to search for, like "MARK_THIS_PLACE x" where x can be any register name
M.mark_these = function(pat)
  -- Get all the lines
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  -- Iterate all the lines and search it
  for ln, li in ipairs(lines) do
    local _, _, mark = li:find(pat .. " (%w)")
    if mark then
      vim.api.nvim_buf_set_mark(0, mark, ln, 0, {})
    end
  end
end

return M

-- vim:et sw=2 ts=2 sts=2

