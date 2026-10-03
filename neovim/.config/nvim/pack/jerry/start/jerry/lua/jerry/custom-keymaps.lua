local M = {}

-- Keep the distribution's picker, LSP, formatting and window keys intact.
function M.setup()
  local function map(mode, suffix, rhs, desc)
    vim.keymap.set(mode, '<leader>j' .. suffix, rhs, { silent = true, desc = desc })
  end
  map('n', 'sl', function()
    require('jerry.sourcer').lua_sourcer('SOURCE_THESE_LUAS_START', 'SOURCE_THESE_LUAS_END')
  end, 'Source marked Lua')
  map('n', 'sv', function()
    require('jerry.sourcer').vim_sourcer('SOURCE_THESE_VIMS_START', 'SOURCE_THESE_VIMS_END')
  end, 'Source marked Vimscript')
  map('n', 'el', function()
    require('jerry.sourcer').eval_lua(vim.api.nvim_get_current_line())
  end, 'Evaluate Lua line')
  map('x', 'el', ":<C-u>lua require('jerry.sourcer').eval_lua(table.concat(vim.fn['jerry#common#GetVisualSelectionAsList'](), '\\n'))<CR>", 'Evaluate Lua selection')
  map('n', 'ev', function()
    require('jerry.sourcer').eval_vimscript(vim.api.nvim_get_current_line())
  end, 'Evaluate Vimscript line')
  map('x', 'ev', ":<C-u>lua require('jerry.sourcer').eval_vimscript(table.concat(vim.fn['jerry#common#GetVisualSelectionAsList'](), '\\n'))<CR>", 'Evaluate Vimscript selection')
  map('n', 'm', function() require('jerry.marker').mark_these('MARK_THIS_PLACE') end, 'Jump to personal marker')
  map('n', 'T', function() require('jerry.term').send(vim.api.nvim_get_current_line()) end, 'Send line to terminal')
  map('x', 'T', ":<C-u>lua require('jerry.term').send_visual()<CR>", 'Send selection to terminal')
end

return M
