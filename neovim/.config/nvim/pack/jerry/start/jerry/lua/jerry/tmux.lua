--[[
SOURCE_THESE_VIMS_START
" lua
let @h="yoprint(string.format('\<c-r>\" = %s', vim.inspect(\<c-r>\")))\<esc>j"
echom 'Sourced'
SOURCE_THESE_VIMS_END
--]]

local M = {}

--- @brief Setup all the autocommand
--- @throws TBD
M.setup = function()
  local augroup_id = vim.api.nvim_create_augroup("jerry_tmux", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
    group = augroup_id,
    desc = 'TBD',
    callback = function(ev)
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map("n", "<leader>te", function() M.tmux_send_current_line_to_a_pane(':.+1') end, opts)
      map("v", "<leader>te", ":<C-U>lua require('jerry.tmux').tmux_send_current_visual_block_to_a_pane(':.+1')<CR>", opts)
      map("n", "<leader>to", function() M.tmux_send_current_line_to_a_pane(':.-1') end, opts)
      map("v", "<leader>to", ":<C-U>lua require('jerry.tmux').tmux_send_current_visual_block_to_a_pane(':.-1')<CR>", opts)
      map("n", "<leader>tu", function() M.tmux_send_current_text_block_to_a_pane(':.+1') end, opts)
      map("n", "<leader>ta", function() M.tmux_send_current_text_block_to_a_pane(':.-1') end, opts)
      map("n", "<leader>t.", function() M.tmux_send_cword_under_cursor_to_a_pane(':.+1') end, opts)
      map("n", "<leader>t,", function() M.tmux_send_cword_under_cursor_to_a_pane(':.-1') end, opts)
    end
  })
end

--- @brief Wrapper function to send text to a tmux pane
--- @param text string the text to send
--- @param pane string the pane identifier
local function send_to_tmux_pane(text, pane)
  local _ = vim.system({'tmux', 'load-buffer', '-'}, { stdin = text .. '\r', text = true }):wait()
  local _ = vim.system({'tmux', 'paste-buffer', '-t', pane}, { text = true }):wait()
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
  send_to_tmux_pane(lines, pane)
end

--- @brief Send the current visual block of text from the buffer to another tmux pane
--- @param pane string the pane identifier
function M.tmux_send_current_visual_block_to_a_pane(pane)
  local lines = vim.fn['jerry#common#GetVisualSelection']()
  send_to_tmux_pane(lines, pane)
end

return M

-- vim:et ts=2 sts=2 sw=2
