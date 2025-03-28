
--[[
SOURCE_THESE_VIMS_START
" lua
let @h="yoprint(string.format('\<c-r>\" = %s', vim.inspect(\<c-r>\")))\<esc>j"
echom 'Sourced'
SOURCE_THESE_VIMS_END
--]]

local M = {}

--- @brief Given the src:uuid tag, jump to the file with that line
--- Jump to the source file and line number corresponding to a given `src:uuid` tag.
---
--- This function searches for a specific `src:uuid` tag within markdown files in the current working directory
--- using ripgrep. It expects the tag to be in the format `src:cf8d08d2-5b5b-4d20-9fc3-878b1ac78b18`.
--- If the tag is found, it opens the corresponding file and moves the cursor to the line number
--- where the tag was found.
---
--- @param uuid string The `src:uuid` uuid to search for.
--- @throws string Error message if the tag format is invalid, ripgrep fails, or multiple results are found.
M.jump_to_srcuuid = function(uuid)
  local pattern = "^%w%w%w%w%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%w%w%w%w%w%w%w%w$"
  if not uuid:match(pattern) then
    error("Invalid uuid format. Expected <uuid>")
  end

  -- I don't check whether rg exist. I am using home-manager with nix to build neovim setup.
  -- Ripgrep is a dependency for my neovim install
  local cmd = {
    "rg",
    "--column",
    "--line-number",
    "--no-heading",
    "--color=never",
    "-e",
    "src:" .. uuid,
    "-g",
    "*.md",
  }
  local ret = vim.system(cmd, { text = true }):wait()
  if ret.code ~= 0 then
    error(string.format("ripgrep exited with non-zero exit code: %d for %s", ret.code, vim.inspect(cmd)))
  end

  local output = ret.stdout
  if not output then
    error(string.format("ripgrep cannot find any src:uuid matching %s", uuid))
  end
  local lines = vim.split(output, "\n", { trimempty = true })

  if #lines ~= 1 then
    error(string.format("Expected exactly one result, but got %d, from ripgrep, that are %s", #lines, vim.inspect(lines)))
  end

  local line = lines[1]
  local filepath, line_number, _ = line:match("([^:]+):(%d+):(.*)")

  if not filepath or not line_number then
    error("Failed to parse ripgrep output with input of " .. line)
  end

  vim.cmd.edit(filepath)
  vim.cmd(string.format(':%d', line_number))
end

--- @brief Matches a specific pattern in the current line and returns it.
--- @return The matched pattern if found.
--- @error Throws an error if the pattern is not found.
M.match_uuid_in_current_line = function()
  local line = vim.api.nvim_get_current_line()
  local pattern = "src:(%w%w%w%w%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%w%w%w%w%w%w%w%w)"
  local uuid = line:match(pattern)
  if not uuid then
    error("Cannot find src:uuid in the current line")
  end
  return uuid
end

--- @brief Generate and return a new uuid tag as string
--- @return string
--- @throws string Error message if the tag format is invalid, ripgrep fails, or multiple results are found.
M.new_srcuuid = function()
  local uuid = string.sub(vim.system({'uuidgen'}, { text = true }):wait().stdout, 1, -2)
  local out = 'src:' .. uuid
  return out
end

--- @brief Find an uuid in the current line and return the
--- formatted string for multiple line of markdown code block
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_as_markdown_multiline_code_block = function()
  local uuid = M.match_uuid_in_current_line()
  local out = string.format([[```
en ; nvim "lua require('jerry.markdown').jump_to_srcuuid('%s')"
```]], uuid)
  return out
end

--- @brief Find an uuid in the current line and return the
--- formatted string for single line of markdown code block
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_as_markdown_singleline_code_block = function()
  local uuid = M.match_uuid_in_current_line()
  local out = string.format([[`en ; nvim "lua require('jerry.markdown').jump_to_srcuuid('%s')"`]], uuid)
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
lua require('jerry.markdown').jump_to_srcuuid('%s')
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
