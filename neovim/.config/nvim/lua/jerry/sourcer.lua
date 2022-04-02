
local vim = vim

-- Store all the module functions
local M = {}

-- @brief Get a function te search the current screensection for a matching pattern and source using sourcer
-- @param sourcer (function(x) -> nil) - A function to source the block of text. x is text to source
local function new_sourcer(sourcer)
  -- @brief Search the current screensection for a matching pattern and source that as vimscript
  -- @param startpat (str) - The pattern used for searching the start of the block
  -- @param endpat (str) - The pattern used for searching the end of the block
  return function(startpat, endpat)
    -- Get the lines currently visible
    local startrow = vim.fn.line('w0')
    local endrow = vim.fn.line('w$')
    local vlines = vim.api.nvim_buf_get_lines(0, startrow, endrow, true)

    -- Iterate all the lines
    local foundstartpat, foundendpat = false, false
    local blk = {}
    for _, li in ipairs(vlines) do
      -- if we have found the startpat
      if foundstartpat then
        if li:find(endpat) then
          foundendpat = true
          -- exit the loop
          break
        end
      end
      -- if we are inside the block
      if foundstartpat and not foundendpat then
        table.insert(blk, li)
      end
      -- if we have found the startpat
      if li:find(startpat) then
        foundstartpat = true
      end
    end

    -- if not found, return
    if not foundendpat then
      return
    end

    -- Join the line with newline
    if foundstartpat and foundendpat then
      local joined = table.concat(blk, "\n")
      -- P(joined)
      sourcer(joined)
    end
  end
end

-- @brief take a block of text and execute them as vimscript
-- @param x (str) - block of text, \n as line ending
M.eval_vimscript = function (x)
  vim.api.nvim_exec(x, false)
end

-- @brief take a block of text and execute them as lua code
-- @param x (str) - block of text, \n as line ending
M.eval_lua = function (x)
  local f = loadstring(x)
  f()
end

-- @brief Search the current screensection for a matching pattern and source that as vimscript
-- @param startpat (str) - The pattern used for searching the start of the block
-- @param endpat (str) - The pattern used for searching the end of the block
M.vim_sourcer = new_sourcer(M.eval_vimscript)

-- @brief Search the current screensection for a matching pattern and source that as lua code
-- @param startpat (str) - The pattern used for searching the start of the block
-- @param endpat (str) - The pattern used for searching the end of the block
M.lua_sourcer = new_sourcer(M.eval_lua)


return M

-- vim:et sw=2 ts=2 sts=2

