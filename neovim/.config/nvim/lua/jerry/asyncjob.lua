
local vim = vim
local Job = require('plenary.job')

local njobs = 0

local function job_report()
  if njobs > 0 then
    return "#jobs: " .. tostring(njobs)
  end
  return ''
end

local function store_line(t)
  return function(_, line)
    table.insert(t, line)
  end
end

local function run(ocmd, cmd, args)
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

      if #louts > 0 or (#lerrs > 0 and code ~= 0) then
        vim.cmd(locmd)

        if #louts > 0 then
          vim.api.nvim_buf_set_lines(0, 0, -1, false, louts)
        end

        if #lerrs > 0 then
          vim.api.nvim_buf_set_lines(0, 0, -1, false, lerrs)
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

local function run_to_tab(cmd, args)
  run('tabnew', cmd, args)
end

local function run_to_split(cmd, args)
  run('split', cmd, args)
end

local function run_to_vsplit(cmd, args)
  run('vsplit', cmd, args)
end

return {
  job_report = job_report,
  run_to_tab = run_to_tab,
  run_to_split = run_to_split,
  run_to_vsplit = run_to_vsplit,
}

-- vim:et sw=2 ts=2 sts=2
