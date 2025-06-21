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
      vim.keymap.set("n", "<leader>te", function() M.tmux_send_current_line_to_a_pane(':.+1') end)
      vim.keymap.set("n", "<leader>to", function() M.tmux_send_current_line_to_a_pane(':.-1') end)
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

return M

-- vim:et ts=2 sts=2 sw=2
