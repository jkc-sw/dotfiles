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
      -- This small block will automatically soft warp a long line in a list. Visual only
      -- https://t3.chat/share/y8c0bx42dw
      vim.opt.breakindent = true
      -- 'list:-1' tells Vim to align soft-wrapped lines
      -- with the start of the text after the list marker
      vim.opt.breakindentopt = "list:-1"

      -- yank the lines between the nearest surrounding ``` fences (exclusive)
      vim.keymap.set(
        'n',
        '<leader>ne',
        [[<cmd>?^```?+1,/^```/-1 y<CR>]],
        { noremap = true, silent = true }
      )

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

      vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ph', '', {
        noremap = true,
        desc = 'TBD',
        callback = function()
          send_to_clipboard(M.new_search_pattern_from_shell_without_markup())
          print('ph content sent to clipboard')
        end
      })

      vim.cmd("iabbrev ,n  <c-r>=v:lua.require('jerry.markdown').new_originuuid()<cr>")

      vim.keymap.set("v", "<leader>tf", function()
        local s = vim.fn.getpos("'<")[2]
        local e = vim.fn.getpos("'>")[2]
        M.replace_range(s, e)
      end, { desc = "Format selection as markdown table" })

      vim.keymap.set("n", "<leader>tf", function()
        local buf   = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local total = #buf
        local row   = vim.api.nvim_win_get_cursor(0)[1]

        if not M.is_table_line(buf[row]) then
          vim.notify("Cursor is not inside a table", vim.log.levels.WARN)
          return
        end

        local s, e = row, row
        while s > 1      and M.is_table_line(buf[s - 1]) do s = s - 1 end
        while e < total   and M.is_table_line(buf[e + 1]) do e = e + 1 end

        M.replace_range(s, e)
      end, { desc = "Format markdown table under cursor" })
    end
  })
end

---@brief Push current position to the tag stack and add to the jump list
M.push_to_tagstack = function()
  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  local from = vim.fn.getpos('.')
  from[1] = bufnr
  local tagname = vim.fn.expand('<cword>')

  -- Save position in jumplist
  vim.cmd("normal! m'")

  local tagstack = { { tagname = tagname, from = from } }
  vim.fn.settagstack(vim.fn.win_getid(win), { items = tagstack }, 't')
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

  M.push_to_tagstack()

  vim.cmd.edit(filepath)
  vim.cmd(string.format(':%d', line_number))
end

--- @brief Matches a specific pattern in the current line and returns it.
--- @return string The matched pattern if found.
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
en ; nvim -c "lua require('jerry.markdown').jump_to_originuuid('%s')"
```]], uuid)
  return out
end

--- @brief Find an uuid in the current line and return the
--- formatted string for single line of markdown code block
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_as_markdown_singleline_code_block = function()
  local uuid = M.match_uuid_in_current_line()
  local out = string.format([[`en ; nvim -c "lua require('jerry.markdown').jump_to_originuuid('%s')"`]], uuid)
  return out
end

--- @brief Find an uuid in the current line and return the
--- formatted string jumping to src without markup
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_from_shell_without_markup = function()
  local uuid = M.match_uuid_in_current_line()
  local out = string.format([[nvim -c "lua require('jerry.markdown').jump_to_originuuid('%s')"]], uuid)
  return out
end

--- @brief Find an uuid in the current line and return the
--- formatted string jumping to src inside vim
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_from_inside_vim = function()
  local uuid = M.match_uuid_in_current_line()
  local heading = M.find_nearest_heading_above_current_line()
  local out = string.format([[
%s

```vim
lua require('jerry.markdown').jump_to_originuuid('%s')
```
]], heading, uuid)
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

--- Checks whether a single line belongs to a Markdown table.
---
---@param line string The line of text to inspect.
---@return boolean `true` if the line contains a pipe character (`|`).
M.is_table_line = function(line)
  return line:find("|") ~= nil
end

--- Formats an array of Markdown table lines by aligning every column.
---
--- Pipes the input through `tr -s ' '` (collapse whitespace) followed
--- by `column -t -s '|' -o '|'` (align columns on `|` delimiters).
---
---@param lines string[] Array of raw table lines.
---@return string[] formatted The same table with every column padded
---         so that pipes are vertically aligned.
M.fmt_table = function(lines)
  local stdin = table.concat(lines, "\n")
  local out = vim.fn.systemlist("tr -s ' ' | column -t -s '|' -o '|'", stdin)
  return out
end

--- Replaces a 1-indexed inclusive line range in the current buffer
--- with the result of formatting those lines as a Markdown table.
---
---@param s_row integer First line of the range (1-indexed, inclusive).
---@param e_row integer Last line of the range (1-indexed, inclusive).
M.replace_range = function(s_row, e_row)
  local lines = vim.api.nvim_buf_get_lines(0, s_row - 1, e_row, false)
  local formatted = M.fmt_table(lines)
  vim.api.nvim_buf_set_lines(0, s_row - 1, e_row, false, formatted)
end

return M

-- vim:et ts=2 sts=2 sw=2
