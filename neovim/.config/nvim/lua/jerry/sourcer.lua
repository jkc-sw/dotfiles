
local vim = vim

-- Store all the module functions
local M = {}

-- @brief Get a function te search the current screensection for a matching pattern and source using sourcer
-- @param sourcer (function(x) -> nil) - A function to source the block of text
--        function(x) -> nil
--        Arguments:
--          x (str) - Block of text to source
-- @param excluders ({(function() -> bool)...}) - A table of functions to skip under some conditions
--        function() -> bool
--        Returns:
--          bool - True to skip this source, False to continue the rest of the function
local function new_sourcer(sourcer, excluders)
  -- @brief Search the current screensection for a matching pattern and source that as vimscript
  -- @param startpat (str) - The pattern used for searching the start of the block
  -- @param endpat (str) - The pattern used for searching the end of the block
  return function(startpat, endpat)
    -- Run the excluders
    for _, excluder in ipairs(excluders) do
      if excluder() then
        return
      end
    end

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

-- @brief An excluder to skip init.vim and init.lua
-- @return bool - True if the file is init.vim or init.lua
M.initfile_excluder = function()
  local fn = vim.fn.expand('%:t')
  if fn == 'init.vim' or fn == 'init.lua' then
    print('init.vim and init.lua are excluded from sourcer')
    return true
  end
  return false
end

-- @brief Search the current screensection for a matching pattern and source that as vimscript
-- @param startpat (str) - The pattern used for searching the start of the block
-- @param endpat (str) - The pattern used for searching the end of the block
M.vim_sourcer = new_sourcer(M.eval_vimscript, {M.initfile_excluder})

-- @brief Search the current screensection for a matching pattern and source that as lua code
-- @param startpat (str) - The pattern used for searching the start of the block
-- @param endpat (str) - The pattern used for searching the end of the block
M.lua_sourcer = new_sourcer(M.eval_lua, {M.initfile_excluder})

return M

-- vim:et sw=2 ts=2 sts=2

