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
    end
  })
end

--- @brief Send the current line of text from the buffer to another tmux pane
--- @param pane string the pane identifier
function M.tmux_send_current_line_to_a_pane(pane)
  local line = vim.api.nvim_get_current_line()
  local replacedLine = string.gsub(line, '^[ \t]*', '')
  local _ = vim.system({'tmux', 'load-buffer', '-'}, { stdin = replacedLine .. '\r', text = true }):wait()
  local _ = vim.system({'tmux', 'paste-buffer', '-t', pane}, { text = true }):wait()
end

--- @brief Send the current block of text from the buffer to another tmux pane
--- @param pane string the pane identifier
function M.tmux_send_current_text_block_to_a_pane(pane)
  local lines = vim.fn['jerry#common#GetBlockSelection']()
  local _ = vim.system({'tmux', 'load-buffer', '-'}, { stdin = lines .. '\r', text = true }):wait()
  local _ = vim.system({'tmux', 'paste-buffer', '-t', pane}, { text = true }):wait()
end

--- @brief Send the current visual block of text from the buffer to another tmux pane
--- @param pane string the pane identifier
function M.tmux_send_current_visual_block_to_a_pane(pane)
  local lines = vim.fn['jerry#common#GetVisualSelection']()
  local result = vim.system({'tmux', 'load-buffer', '-'}, { stdin = lines .. '\r', text = true }):wait()
  local _ = vim.system({'tmux', 'paste-buffer', '-t', pane}, { text = true }):wait()
end

return M

-- vim:et ts=2 sts=2 sw=2
