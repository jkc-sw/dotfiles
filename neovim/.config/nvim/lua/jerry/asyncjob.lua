
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

      -- local tabcmd = ocmd .. " " .. cmd .. ' ' .. table.concat(args, " ")
      -- if #tabcmd > 30 then
      --   tabcmd = tabcmd:sub(1, 30)
      -- end

      if #outs > 0 then
        vim.cmd(ocmd)
        vim.api.nvim_buf_set_lines(0, 0, -1, false, outs)
        vim.bo.readonly = false
        vim.bo.modifiable = true
        vim.bo.modeline = true
        vim.bo.buftype = 'nowrite'
        vim.bo.swapfile = false
      else
        print(string.format('Command %s returns code 0', cmd .. table.concat(args, ' ')))
      end

      if code ~= 0 then
        local emsg = string.format('Program exited with error code %d', code)

        if #errs > 0 then
          emsg = string.format('%s\n%s', table.concat(errs, "\n"))
        end

        error(emsg)
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
