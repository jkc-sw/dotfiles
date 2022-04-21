
local vim = vim

-- Store all the module functions
local M = {}

-- Local namespace
local ns = vim.api.nvim_create_namespace('jerry.sourcer')

--[[
SOURCE_THESE_VIMS_START
nnoremap <leader>ne <cmd>lua R('jerry.sourcer').vim_sourcer('TSOURCE_THESE_VIMS_START', 'TSOURCE_THESE_VIMS_END')<cr>
let @h="yoP('\<c-r>\" = ' .. vim.inspect(\<c-r>\"))\<esc>+"
echom 'Sourced'
SOURCE_THESE_VIMS_END
--]]

-- @brief Get a function te search the entire file for a matching pattern closest to the cursor and source using sourcer
-- @param sourcer (function(x) -> nil) - A function to source the block of text
--        function(x) -> nil
--        Arguments:
--          x (str) - Block of text to source
-- @param excluders ({(function() -> bool)...}) - A table of functions to skip under some conditions
--        function() -> bool
--        Returns:
--          bool - True to skip this source, False to continue the rest of the function
local function new_sourcer(sourcer, excluders)
  -- @brief Search the entire file for a matching pattern closest to the cursor and source that as vimscript
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
    local startrow = 0 -- vim.fn.line('0')
    local endrow = -1 -- vim.fn.line('$')
    local vlines = vim.api.nvim_buf_get_lines(0, startrow, endrow, true)
    -- P(vlines[1]..'1')
    -- P(vlines[2]..'2')
    -- P(vlines[#vlines - 1]..'$-1')
    -- P(vlines[#vlines]..'$')

    -- Get the current cursor location
    local curln, _ = unpack(vim.api.nvim_win_get_cursor(0))
    -- P('curln = ' .. vim.inspect(curln))

    -- Iterate all the lines
    local foundstartpat = false
    local blk = {}
    local lastblk = {}
    local lastrange = {0, -1}
    local dist = -1
    local lastdist = -1
    local startln = 0
    local endln = 0
    for ln, li in ipairs(vlines) do
      -- if we have found the startpat
      if foundstartpat then
        if li:find(endpat) then
          endln = ln + startrow
          -- only do the following if there are lines
          if (endln - startln) > 1 then
            -- Calculate the distance and store the result
            dist = math.min(math.abs(startln - curln), math.abs(endln - curln))
            -- P('endln = ' .. vim.inspect(endln))
            -- P('startln = ' .. vim.inspect(startln))
            -- P('dist = ' .. vim.inspect(dist))
            -- P('lastdist = ' .. vim.inspect(lastdist))
            -- P('lastblk = ' .. vim.inspect(lastblk))
            -- P('blk = ' .. vim.inspect(blk))

            -- If first time or distance is shorter, we will store the result
            if lastdist == -1 or dist < lastdist then
              lastdist = dist
              lastblk = blk
              blk = {}
              lastrange = {startln, endln - 1}
            end
            foundstartpat = false
            -- -- exit the loop
            -- break
          end
        end
      end

      -- if we are inside the block
      if foundstartpat then
        table.insert(blk, li)
      end

      -- if we have found the startpat
      if li:find(startpat) then
        if not li:find(endpat) then
          -- only when they are not on the same line
          -- store the start line
          startln = ln + startrow
          foundstartpat = true
        end
      end
    end

    -- if not found, return
    if #lastblk < 1 then
      vim.api.nvim_echo({{
        'jerry.sourcer: No block found to be sourced', 'WarningMsg'
      }}, true, {})
      return
    end

    -- Join the line with newline
    local joined = table.concat(lastblk, "\n")
    -- P(joined)
    sourcer(joined)

    -- highlight it
    -- Reference from 'runtime/lua/vim/highlight.lua'
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    vim.highlight.range(0, ns, 'IncSearch', {lastrange[1], 0}, {lastrange[2], 0}, 'V', false, 200)  -- -1 to adjust 0/1 index difference
    vim.defer_fn(
      function()
        if vim.api.nvim_buf_is_valid(0) then
          vim.api.nvim_buf_clear_namespace(0, 0, 0, -1)
        end
      end,
      150
    )
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

--[[
TSOURCE_THESE_VIMS_START
echom "Sourced 1"
TSOURCE_THESE_VIMS_END
--]]

--[[
TSOURCE_THESE_VIMS_START
echom "Sourced 2"
TSOURCE_THESE_VIMS_END
--]]

-- vim:et sw=2 ts=2 sts=2

