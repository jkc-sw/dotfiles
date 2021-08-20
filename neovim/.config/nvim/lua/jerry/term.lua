
local vim = vim

local filter = vim.tbl_filter
local map = vim.tbl_map
local keys = vim.tbl_keys
local contains = vim.tbl_contains

local function get_term_ids()
  local bufs = vim.fn.getbufinfo()

  local bufs_vars = filter(function (buf)
    return contains(keys(buf), 'variables')
  end, bufs)

  local bufs_termid = filter(function (buf)
    return contains(keys(buf.variables), 'terminal_job_id')
  end, bufs_vars)

  return map(function (buf) return buf.variables.terminal_job_id end, bufs_termid)
end

local function get_term_id(bufidx)
  bufidx = bufidx or 1
  local terms = get_term_ids()

  if #terms < 1 then
    if bufidx > 1 then
      error('bufidx cannot be more than 1, only 1 terminal will be created')
    end

    local current_id = vim.fn.bufnr()
    vim.cmd [[ terminal ]]
    vim.api.nvim_set_current_buf(current_id)
    return get_term_ids()[bufidx]
  else
    if bufidx > #terms then
      error(string.format('bufidx cannot be more than %d', #terms))
    end

    return terms[bufidx]
  end
end

local function send(cmd, opt)
  opt = opt or {}
  local id = opt.term_id or get_term_id(opt.term_idx)

  if cmd:sub(string.len(cmd)-1) ~= "\r\n" then
    cmd = cmd .. "\r\n"
  end

  local ok, _ = pcall(vim.api.nvim_chan_send, id, cmd)
  if not ok then
    error(string.format('channel id %d is not valid, availables are %s', id, vim.inspect(get_term_ids())))
  end
end

local function send_visual(opt)
  opt = opt or {}
  local id = opt.term_id or get_term_id(opt.term_idx)

  local rstart, _ = unpack(vim.api.nvim_buf_get_mark(0, '<'))
  local rend, _ = unpack(vim.api.nvim_buf_get_mark(0, '>'))

  rend = rend + 1 -- for some reason, it doesn't get the last line

  if rstart == rend then
    rend = rstart + 1
  end
  local lines = vim.api.nvim_buf_get_lines(0, rstart - 1, rend - 1, false)

  local cmd = table.concat(lines, '\r\n')

  send(cmd, opt)
end

return {
  send = send,
  send_visual = send_visual,
}

-- vim:et sw=2 ts=2 sts=2
