
local vim = vim
local Job = require('plenary.job')

local njobs = 0

local function job_report()
  if njobs > 0 then
    return "nAsyncJob: " .. tostring(njobs)
  end
  return ''
end

local function store_line(t)
  return function(_, line)
    table.insert(t, line)
  end
end

local function run(ocmd, cmd, ...)
  local args = ...
  if type(args) ~= 'table' then
    args = {args}
  end

  local outs = {}
  local errs = {}
  Job:new({
    command = cmd,
    args = args,

    on_start = function()
      njobs = njobs + 1
    end,
    on_stdout = store_line(outs),
    on_stderr = store_line(errs),
    on_exit = vim.schedule_wrap(function(_, code)
      njobs = njobs - 1

      -- Bring all the reference to the local scope to make sure it is freed
      local louts = outs
      local lerrs = errs
      local locmd = ocmd
      local lcmd = cmd
      -- outs = nil -- Prevent memory leak
      -- errs = nil -- Prevent memory leak
      -- args = nil -- Prevent memory leak
      -- ocmd = nil -- Prevent memory leak
      -- cmd = nil -- Prevent memory leak

      if #louts > 0 or (#lerrs > 0 and code ~= 0) then
        vim.cmd(locmd)

        if #louts > 0 then
          vim.api.nvim_buf_set_lines(0, -1, -1, false, louts)
        end

        if #lerrs > 0 then
          vim.api.nvim_buf_set_lines(0, -1, -1, false, lerrs)
        end

        vim.bo.readonly = false
        vim.bo.modifiable = true
        vim.bo.modeline = true
        vim.bo.buftype = 'nowrite'
        vim.bo.swapfile = false
      end

      if code ~= 0 then
        error(string.format('Program %s exited with error code %d', lcmd, code))
      else
        print(string.format('Program %s exit ok', lcmd))
      end

    end)
  }):start()
end

local function run_to_tab(cmd, ...)
  run('tabnew', cmd, ...)
end

local function run_to_split(cmd, ...)
  run('split', cmd, ...)
end

local function run_to_vsplit(cmd, ...)
  run('vsplit', cmd, ...)
end

return {
  job_report = job_report,
  run_to_tab = run_to_tab,
  run_to_split = run_to_split,
  run_to_vsplit = run_to_vsplit,
}

-- vim:et sw=2 ts=2 sts=2
