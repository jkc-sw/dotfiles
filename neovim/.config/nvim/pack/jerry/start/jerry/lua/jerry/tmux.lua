--[[
SOURCE_THESE_VIMS_START
" lua
let @h="yoprint(string.format('\<c-r>\" = %s', vim.inspect(\<c-r>\")))\<esc>j"
echom 'Sourced'
SOURCE_THESE_VIMS_END
--]]

local M = {}

-- Targets use tmux syntax: ':.+1' / ':.-1' is the next / previous pane in the
-- current window, ':+.1' / ':-.1' the first pane of the next / previous window.
-- Inside zellij ($ZELLIJ_PANE_ID set) the same targets resolve to zellij panes
-- (windows are tabs); everywhere else the commands go to tmux.

--- @brief Register the global pane shortcuts
M.setup = function()
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = 'Panes: ' .. desc })
  end

  map('n', '<leader>te', function()
    M.tmux_send_current_line_to_a_pane ':.+1'
  end, 'Send line or selection to next pane')
  map(
    'v',
    '<leader>te',
    ":<C-U>lua require('jerry.tmux').tmux_send_current_visual_block_to_a_pane(':.+1')<CR>",
    'Send line or selection to next pane'
  )
  map('n', '<leader>to', function()
    M.tmux_send_current_line_to_a_pane ':.-1'
  end, 'Send line or selection to previous pane')
  map(
    'v',
    '<leader>to',
    ":<C-U>lua require('jerry.tmux').tmux_send_current_visual_block_to_a_pane(':.-1')<CR>",
    'Send line or selection to previous pane'
  )
  map('n', '<leader>tu', function()
    M.tmux_send_current_text_block_to_a_pane ':.+1'
  end, 'Send text block to next pane')
  map('n', '<leader>ta', function()
    M.tmux_send_current_text_block_to_a_pane ':.-1'
  end, 'Send text block to previous pane')
  map('n', '<leader>t.', function()
    M.tmux_send_cword_under_cursor_to_a_pane ':.+1'
  end, 'Send WORD to next pane')
  map('n', '<leader>t,', function()
    M.tmux_send_cword_under_cursor_to_a_pane ':.-1'
  end, 'Send WORD to previous pane')
end

local function in_zellij()
  return vim.env.ZELLIJ ~= nil and vim.env.ZELLIJ_PANE_ID ~= nil
end

local function run(cmd, opts)
  local out = vim.system(cmd, opts or { text = true }):wait()
  if out.code ~= 0 then
    vim.notify(table.concat(cmd, ' ') .. ': ' .. (out.stderr or ''), vim.log.levels.ERROR)
  end
  return out
end

--- @brief Resolve a tmux-style relative target to a zellij pane id
--- @param target string ':.+1', ':.-1', ':+.1' or ':-.1'
--- @return string|nil pane id such as 'terminal_3'
local function zellij_pane(target)
  local out = run { 'zellij', 'action', 'list-panes', '--json', '--all' }
  if out.code ~= 0 then
    return nil
  end
  local me = tonumber(vim.env.ZELLIJ_PANE_ID)
  local current
  local tabs, positions = {}, {}
  for _, p in ipairs(vim.json.decode(out.stdout)) do
    if not p.is_plugin then
      if p.id == me then
        current = p
      end
      if not p.is_floating and not p.is_suppressed then
        if not tabs[p.tab_position] then
          tabs[p.tab_position] = {}
          table.insert(positions, p.tab_position)
        end
        table.insert(tabs[p.tab_position], p)
      end
    end
  end
  if not current or #positions == 0 then
    vim.notify('zellij: pane ' .. tostring(me) .. ' not found', vim.log.levels.ERROR)
    return nil
  end
  table.sort(positions)
  for _, ring in pairs(tabs) do
    table.sort(ring, function(a, b)
      if a.pane_x ~= b.pane_x then
        return a.pane_x < b.pane_x
      end
      return a.pane_y < b.pane_y
    end)
  end

  local function step_from(list, match, step)
    local i = 0
    for k, v in ipairs(list) do
      if match(v) then
        i = k
        break
      end
    end
    return list[(i - 1 + step) % #list + 1]
  end

  local pane_step = ({ [':.+1'] = 1, [':.-1'] = -1 })[target]
  local tab_step = ({ [':+.1'] = 1, [':-.1'] = -1 })[target]
  local pane
  if pane_step then
    local ring = tabs[current.tab_position] or tabs[positions[1]]
    pane = step_from(ring, function(p)
      return p.id == current.id
    end, pane_step)
  elseif tab_step then
    local pos = step_from(positions, function(v)
      return v == current.tab_position
    end, tab_step)
    pane = tabs[pos][1]
  else
    vim.notify('zellij: unsupported target ' .. target, vim.log.levels.ERROR)
    return nil
  end
  return 'terminal_' .. pane.id
end

--- @brief Wrapper function to send text to a tmux or zellij pane
--- @param text string the text to send
--- @param pane string the pane identifier
local function send_to_tmux_pane(text, pane)
  if in_zellij() then
    local id = zellij_pane(pane)
    if id then
      run { 'zellij', 'action', 'write-chars', '--pane-id', id, text .. '\r' }
    end
    return
  end
  local _ = vim.system({ 'tmux', 'load-buffer', '-' }, { stdin = text .. '\r', text = true }):wait()
  local _ = vim.system({ 'tmux', 'paste-buffer', '-t', pane }, { text = true }):wait()
end

--- @brief Re-run the last shell command (Up, Enter) in another pane
--- @param pane string the pane identifier
function M.repeat_last_command(pane)
  if in_zellij() then
    local id = zellij_pane(pane)
    if id then
      run { 'zellij', 'action', 'write', '--pane-id', id, '27', '91', '65', '13' }
    end
    return
  end
  run { 'tmux', 'send-keys', '-t', pane, 'Up', 'Enter' }
end

--- @brief Send the current cword from the buffer to another tmux pane
--- @param pane string the pane identifier
function M.tmux_send_cword_under_cursor_to_a_pane(pane)
  local text = vim.fn.expand '<cWORD>'
  send_to_tmux_pane(text, pane)
end

--- @brief Send the current line of text from the buffer to another tmux pane
--- @param pane string the pane identifier
function M.tmux_send_current_line_to_a_pane(pane)
  local line = vim.api.nvim_get_current_line()
  local replacedLine = string.gsub(line, '^[ \t]*', '')
  send_to_tmux_pane(replacedLine, pane)
end

--- @brief Send the current block of text from the buffer to another tmux pane
--- @param pane string the pane identifier
function M.tmux_send_current_text_block_to_a_pane(pane)
  local lines = vim.fn['jerry#common#GetBlockSelection']()
  send_to_tmux_pane(lines, pane)
  vim.cmd "normal! '}"
end

--- @brief Send the current visual block of text from the buffer to another tmux pane
--- @param pane string the pane identifier
function M.tmux_send_current_visual_block_to_a_pane(pane)
  local lines = vim.fn['jerry#common#GetVisualSelection']()
  send_to_tmux_pane(lines, pane)
end

return M

-- vim:et ts=2 sts=2 sw=2
