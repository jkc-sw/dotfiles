--[[
SOURCE_THESE_VIMS_START
" lua
let @h="yoprint(string.format('\<c-r>\" = %s', vim.inspect(\<c-r>\")))\<esc>j"
echom 'Sourced'
SOURCE_THESE_VIMS_END
--]]

local M = {}

-- Global maps are installed once by jerry.setup(), not on every buffer event.
M.setup = function()
  local prefix = vim.g.jerry_legacy and '<leader>t' or '<leader>jt'
  local function map(mode, key, rhs, desc)
    vim.keymap.set(mode, prefix .. key, rhs, { silent = true, desc = desc })
  end
  for _, target in ipairs({ { 'e', ':.+1', 'next' }, { 'o', ':.-1', 'previous' } }) do
    local key, pane, name = unpack(target)
    map('n', key, function() M.tmux_send_current_line_to_a_pane(pane) end, 'Send line to ' .. name .. ' tmux pane')
    map('x', key, ":<C-u>lua require('jerry.tmux').tmux_send_current_visual_block_to_a_pane('" .. pane .. "')<CR>",
      'Send selection to ' .. name .. ' tmux pane')
  end
  map('n', 'u', function() M.tmux_send_current_text_block_to_a_pane(':.+1') end, 'Send block to next tmux pane')
  map('n', 'a', function() M.tmux_send_current_text_block_to_a_pane(':.-1') end, 'Send block to previous tmux pane')
  map('n', '.', function() M.tmux_send_cword_under_cursor_to_a_pane(':.+1') end, 'Send word to next tmux pane')
  map('n', ',', function() M.tmux_send_cword_under_cursor_to_a_pane(':.-1') end, 'Send word to previous tmux pane')
end

--- @brief Wrapper function to send text to a tmux pane
--- @param text string the text to send
--- @param pane string the pane identifier
local function send_to_tmux_pane(text, pane)
  if vim.fn.executable('tmux') ~= 1 then
    vim.notify('Jerry: tmux is required to send text to a pane', vim.log.levels.WARN)
    return false
  end
  -- Use a private buffer so a failed paste cannot send an unrelated user's buffer.
  local buffer = 'jerry-' .. vim.fn.getpid()
  local result = vim.system({ 'tmux', 'load-buffer', '-b', buffer, '-' }, { stdin = text .. '\r', text = true }):wait()
  if result.code == 0 then
    result = vim.system({ 'tmux', 'paste-buffer', '-d', '-b', buffer, '-t', pane }, { text = true }):wait()
  end
  if result.code ~= 0 then
    vim.notify('Jerry: tmux send failed: ' .. (result.stderr or 'check the tmux server and target pane'), vim.log.levels.WARN)
    return false
  end
  return true
end

--- @brief Send the current cword from the buffer to another tmux pane
--- @param pane string the pane identifier
function M.tmux_send_cword_under_cursor_to_a_pane(pane)
  local text = vim.fn.expand('<cWORD>')
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
  if send_to_tmux_pane(lines, pane) then
    vim.cmd("normal! '}")
  end
end

--- @brief Send the current visual block of text from the buffer to another tmux pane
--- @param pane string the pane identifier
function M.tmux_send_current_visual_block_to_a_pane(pane)
  local lines = vim.fn['jerry#common#GetVisualSelection']()
  send_to_tmux_pane(lines, pane)
end

return M

-- vim:et ts=2 sts=2 sw=2
