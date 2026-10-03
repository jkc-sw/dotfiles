local M = {}

-- Use argument vectors so depot paths containing spaces or shell metacharacters
-- are never interpreted by a shell. Capture cwd before the asynchronous picker.
local function run(args, cwd, callback)
  vim.system(args, { text = true, cwd = cwd }, vim.schedule_wrap(function(result)
    if result.code ~= 0 then
      local message = vim.trim(result.stderr or '')
      if message == '' then
        message = vim.trim(result.stdout or '')
      end
      vim.notify('Perforce: ' .. (message ~= '' and message or 'command failed'), vim.log.levels.WARN)
      return
    end
    callback(result.stdout or '')
  end))
end

function M.opened(opts)
  opts = opts or {}
  if vim.fn.executable('p4') ~= 1 then
    vim.notify('Perforce: p4 executable not found in PATH', vim.log.levels.WARN)
    return
  end

  local cwd = opts.cwd or vim.fn.getcwd()
  run({ 'p4', '-ztag', 'opened' }, cwd, function(output)
    local files = {}
    for line in output:gmatch('[^\r\n]+') do
      local path = line:match('^%.%.%. depotFile (.+)$')
      if path then
        files[#files + 1] = path
      end
    end
    if #files == 0 then
      vim.notify('Perforce: no opened files', vim.log.levels.INFO)
      return
    end

    vim.ui.select(files, { prompt = 'P4 Opened' }, function(file)
      if not file then
        return
      end
      -- opened reports depot/client syntax, not necessarily local paths. where
      -- respects the workspace view (including remaps) and supplies a local path.
      run({ 'p4', '-ztag', 'where', file }, cwd, function(mapping)
        local path
        local excluded = false
        for line in mapping:gmatch('[^\r\n]+') do
          if line:match('^%.%.%. unmap') then
            excluded = true
            path = nil
          else
            local candidate = line:match('^%.%.%. path (.+)$')
            if candidate then
              path = not excluded and candidate or nil
              excluded = false
            end
          end
        end
        if not path then
          vim.notify('Perforce: file is not mapped in this workspace', vim.log.levels.WARN)
          return
        end
        vim.cmd.edit(vim.fn.fnameescape(path))
      end)
    end)
  end)
end

return M
