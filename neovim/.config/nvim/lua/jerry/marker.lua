
local vim = vim

-- Store all the module functions
local M = {}

-- @brief A function that generate mark based on the pattern
-- @param pat (str) - The pattern to search for, like "MARK_THIS_PLACE x" where x can be any register name
M.mark_these = function(pat)
  -- Get all the lines
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

  -- Iterate all the lines and search it, put the result in the table
  local marklocs = {}
  for ln, li in ipairs(lines) do
    local _, _, mark = li:find(pat .. " (%w)")
    if mark then
      if not marklocs[mark] then
        marklocs[mark] = {ln}
      else
        table.insert(marklocs[mark], ln)
      end
    end
  end

  -- Iterate each, and only set
  local errmsgs = {}
  for k, v in pairs(marklocs) do
    if #v ~= 1 then
      -- Create the warning message
      table.insert(errmsgs, 'For mark "' .. k .. '", there are multiple locations: ' .. vim.inspect(v) .. '. Ln ' .. v[1] .. ' is marked')
    end

    -- if only 1 location
    vim.api.nvim_buf_set_mark(0, k, v[1], 0, {})
  end

  -- If warning messages, echo it
  if not vim.tbl_isempty(errmsgs) then
    local msgs = {}
    -- Add highlight group
    for _, msg in ipairs(errmsgs) do
      table.insert(msgs, {msg, 'WarningMsg'})
    end
    -- Print it
    vim.api.nvim_echo(msgs, true, {})
  end
end

return M

-- vim:et sw=2 ts=2 sts=2

