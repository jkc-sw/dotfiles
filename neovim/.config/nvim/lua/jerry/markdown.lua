
local M = {}

--- @brief Given the src:uuid tag, jump to the file with that line
--- Jump to the source file and line number corresponding to a given `src:uuid` tag.
---
--- This function searches for a specific `src:uuid` tag within markdown files in the current working directory
--- using ripgrep. It expects the tag to be in the format `src:cf8d08d2-5b5b-4d20-9fc3-878b1ac78b18`.
--- If the tag is found, it opens the corresponding file and moves the cursor to the line number
--- where the tag was found.
---
--- @param tag string The `src:uuid` tag to search for.
--- @throws string Error message if the tag format is invalid, ripgrep fails, or multiple results are found.
M.jump_to_srcuuid = function(tag)
  local pattern = "^src:%w%w%w%w%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%w%w%w%w%w%w%w%w$"
  if not tag:match(pattern) then
    error("Invalid tag format. Expected src:<uuid>")
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
    tag,
    "-g",
    "*.md",
  }
  local ret = vim.system(cmd, { text = true }):wait()
  if ret.code ~= 0 then
    error(string.format("ripgrep exited with non-zero exit code: %d for %s", ret.code, vim.inspect(cmd)))
  end

  local output = ret.stdout
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

return M
