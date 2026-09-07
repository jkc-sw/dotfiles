local M = {}

local namespace = vim.api.nvim_create_namespace('jerry_luacheck')
local missing_tools = {}

local function notify_missing(tool)
  if missing_tools[tool] then
    return
  end
  missing_tools[tool] = true
  vim.notify(
    ('Lua tooling: `%s` is not installed; install it to enable this feature.'):format(tool),
    vim.log.levels.WARN
  )
end

local function project_root(filename)
  return vim.fs.root(filename, { '.stylua.toml', '.luacheckrc' })
    or vim.fn.fnamemodify(filename, ':h')
end

local function is_lua_buffer(bufnr)
  return vim.bo[bufnr].filetype == 'lua' and vim.api.nvim_buf_get_name(bufnr) ~= ''
end

function M.format(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not is_lua_buffer(bufnr) then
    return
  end
  if vim.fn.executable('stylua') ~= 1 then
    notify_missing('stylua')
    return
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  local input = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
  local result = vim.system(
    { 'stylua', '--stdin-filepath', filename, '-' },
    { cwd = project_root(filename), stdin = input, text = true }
  ):wait()

  if result.code ~= 0 then
    vim.notify(('StyLua failed: %s'):format(result.stderr), vim.log.levels.ERROR)
    return
  end

  local lines = vim.split(result.stdout, '\n', { plain = true, trimempty = false })
  if lines[#lines] == '' then
    table.remove(lines)
  end
  if vim.deep_equal(lines, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) then
    return
  end
  pcall(vim.cmd, 'silent! undojoin')
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

function M.lint(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not is_lua_buffer(bufnr) then
    return
  end
  if vim.fn.executable('luacheck') ~= 1 then
    notify_missing('luacheck')
    return
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  local command = { 'luacheck', '--codes', '--ranges', '--formatter', 'plain', filename }
  vim.system(command, {
    cwd = project_root(filename),
    text = true,
  }, function(result)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      local diagnostics = {}
      for line in vim.gsplit(result.stdout, '\n', { plain = true, trimempty = true }) do
        local _, lnum, col, end_col, code, message = line:match('^(.-):(%d+):(%d+)%-(%d+): %((%u%d+)%) (.*)$')
        if lnum then
          table.insert(diagnostics, {
            lnum = tonumber(lnum) - 1,
            col = tonumber(col) - 1,
            end_col = tonumber(end_col),
            severity = code:sub(1, 1) == 'E' and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
            source = 'luacheck',
            code = code,
            message = message,
          })
        end
      end
      vim.diagnostic.set(namespace, bufnr, diagnostics)
    end)
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup('jerry_lua_tools', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = group,
    pattern = '*.lua',
    callback = function(event)
      M.format(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
    group = group,
    pattern = '*.lua',
    callback = function(event)
      M.lint(event.buf)
    end,
  })
  vim.api.nvim_create_user_command('LuaFormat', function()
    M.format()
  end, { desc = 'Format the current Lua buffer with StyLua' })
  vim.api.nvim_create_user_command('LuaLint', function()
    M.lint()
  end, { desc = 'Lint the current Lua buffer with Luacheck' })
end

return M
