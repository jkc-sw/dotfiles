--[[
SOURCE_THESE_VIMS_START
" lua
let @h="yoprint(string.format('\<c-r>\" = %s', vim.inspect(\<c-r>\")))\<esc>j"
echom 'Sourced'
SOURCE_THESE_VIMS_END
--]]

local M = {}
local send_to_clipboard = require('jerry.clipboard').send_to_clipboard

--- @brief Setup all the autocommand
--- @throws TBD
M.setup = function()
  local augroup_id = vim.api.nvim_create_augroup("jerry_markdown", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
    group = augroup_id,
    desc = 'TBD',
    pattern = { "*.md" },
    callback = function(ev)
      vim.api.nvim_buf_set_keymap(0, 'n', '<leader>pt', '', {
        noremap = true,
        desc = 'TBD',
        callback = function()
          send_to_clipboard(M.new_search_pattern_as_markdown_multiline_code_block())
          print('pt content sent to clipboard')
        end
      })

      vim.api.nvim_buf_set_keymap(0, 'n', '<leader>pn', '', {
        noremap = true,
        desc = 'TBD',
        callback = function()
          send_to_clipboard(M.new_search_pattern_as_markdown_singleline_code_block())
          print('pn content sent to clipboard')
        end
      })

      vim.api.nvim_buf_set_keymap(0, 'n', '<leader>pf', '', {
        noremap = true,
        desc = 'TBD',
        callback = function()
          send_to_clipboard(M.new_search_pattern_from_inside_vim())
          print('pf content sent to clipboard')
        end
      })

      vim.cmd("iabbrev ,n  <c-r>=v:lua.require('jerry.markdown').new_originuuid()<cr>")
    end
  })
end


--- @brief Given a pattern, find the line number and file name it has
--- @param pattern string
--- @return {filepath: string, line_number: integer}[]
M.get_filename_linenum_of_a_pattern = function(pattern)
  -- I don't check whether rg exist. I am using home-manager with nix to build neovim setup.
  -- Ripgrep is a dependency for my neovim install
  local cmd = {
    "rg",
    "--column",
    "--line-number",
    "--no-heading",
    "--color=never",
    "-e",
    pattern,
    "-g",
    "*.md",
  }
  local ret = vim.system(cmd, { text = true }):wait()
  if ret.code ~= 0 then
    return {}
  end

  local output = ret.stdout
  if not output then
    return {}
  end
  local lines = vim.split(output, "\n", { trimempty = true })

  local matches = {}
  for _, line in ipairs(lines) do
    local filepath, line_number, _ = line:match("([^:]+):(%d+):(.*)")
    table.insert(matches, {
      filepath = filepath,
      line_number = line_number
    })
  end

  return matches
end

--- @brief Given the origin:uuid tag, jump to the file with that line
--- Jump to the source file and line number corresponding to a given `origin:uuid` tag.
---
--- This function searches for a specific `origin:uuid` tag within markdown files in the current working directory
--- using ripgrep. It expects the tag to be in the format `origin:cf8d08d2-5b5b-4d20-9fc3-878b1ac78b18`.
--- If the tag is found, it opens the corresponding file and moves the cursor to the line number
--- where the tag was found.
---
--- @param uuid string The `origin:uuid` uuid to search for.
--- @throws string Error message if the tag format is invalid, ripgrep fails, or multiple results are found.
M.jump_to_originuuid = function(uuid)
  local pattern = "^%w%w%w%w%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%w%w%w%w%w%w%w%w$"
  if not uuid:match(pattern) then
    error("Invalid uuid format. Expected <uuid>")
  end

  local orig_pattern = "origin:" .. uuid

  local matches = M.get_filename_linenum_of_a_pattern(orig_pattern)
  if #matches ~= 1 then
    error(string.format("Pattern %s found %d matches (~=1). Please rg search and fix it", orig_pattern, #matches))
  end

  local match = matches[1]
  local filepath, line_number = match.filepath, match.line_number

  vim.cmd.edit(filepath)
  vim.cmd(string.format(':%d', line_number))
end

--- @brief Matches a specific pattern in the current line and returns it.
--- @return The matched pattern if found.
--- @error Throws an error if the pattern is not found.
M.match_uuid_in_current_line = function()
  local line = vim.api.nvim_get_current_line()
  local pattern = "origin:(%w%w%w%w%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%w%w%w%w%w%w%w%w)"
  local uuid = line:match(pattern)
  if not uuid then
    error("Cannot find origin:uuid in the current line")
  end
  return uuid
end

--- @brief Generate and return a new uuid tag as string
--- @return string
--- @throws string Error message if the tag format is invalid, ripgrep fails, or multiple results are found.
M.new_originuuid = function()
  for attempt_num = 1, 3, 1 do
    local uuid = string.sub(vim.system({ 'uuidgen' }, { text = true }):wait().stdout, 1, -2)
    local out = 'origin:' .. uuid
    local matches = M.get_filename_linenum_of_a_pattern(out)
    if #matches == 0 then
      return out
    end
    print(string.format('WARN (attempt %d): New uuid %s is in conflict with another one in the system, retry', attempt_num, uuid))
  end
  error('Unable to generate a new UUID without a conflict for 3 times. This should never happens')
end

--- @brief Find an uuid in the current line and return the
--- formatted string for multiple line of markdown code block
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_as_markdown_multiline_code_block = function()
  local uuid = M.match_uuid_in_current_line()
  local out = string.format([[```
en ; nvim "lua require('jerry.markdown').jump_to_originuuid('%s')"
```]], uuid)
  return out
end

--- @brief Find an uuid in the current line and return the
--- formatted string for single line of markdown code block
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_as_markdown_singleline_code_block = function()
  local uuid = M.match_uuid_in_current_line()
  local out = string.format([[`en ; nvim "lua require('jerry.markdown').jump_to_originuuid('%s')"`]], uuid)
  return out
end

--- @brief Find an uuid in the current line and return the
--- formatted string jumping to src inside vim
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_from_inside_vim = function()
  local uuid = M.match_uuid_in_current_line()
  local heading = M.find_nearest_heading_above_current_line()
  local out = string.format([[%s

```vim
lua require('jerry.markdown').jump_to_originuuid('%s')
```]], heading, uuid)
  return out
end

--- @brief Find the line matching the pattern backward and return the line
--- @return string
--- @throws When pattern is not found
M.find_nearest_heading_above_current_line = function()
  local matched_line_nr = vim.fn.search('^## .*$', "bnW")
  local heading = vim.api.nvim_buf_get_lines(0, matched_line_nr - 1, matched_line_nr, true)[1]
  if not heading then
    error("Cannot find the heading backward from the current line")
  end
  return heading
end

return M

-- vim:et ts=2 sts=2 sw=2
