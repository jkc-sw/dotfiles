local function run()
  -- Headless -c commands run before VimEnter/VeryLazy. Reproduce the mappings
  -- that an interactive session installs before exercising real insert input.
  vim.cmd.doautocmd 'User VeryLazy'
  vim.cmd.enew()
  vim.bo.filetype = 'markdown'

  local markdown = require 'jerry.markdown'
  local links = require 'jerry.markdown_links'
  for trigger in pairs(links.trigger_specs) do
    assert(vim.fn.maparg(trigger, 'i', true, true).buffer == 1, 'Missing abbreviation: ' .. trigger)
  end

  local original_input = vim.ui.input
  vim.ui.input = function(_, callback)
    callback '0'
  end
  local function expand(trigger, expected)
    vim.cmd.stopinsert()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { '' })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('i' .. trigger .. ' <Esc>', true, false, true), 'xt', false)
    vim.wait(1000, function()
      return not vim.api.nvim_get_current_line():find('__JERRY_', 1, true)
    end)
    local line = vim.api.nvim_get_current_line()
    assert(line:match(expected), string.format('%s did not expand: %q', trigger, line))
  end

  expand(',n', '^origin:%x+%-%x+%-%x+%-%x+%-%x+ ')
  expand(',t', '^## %d%d%d%d%-%d%d%-%d%d ')
  expand(',h', '^## %d%d%d%d%-%d%d%-%d%d ')
  expand('.u', '^%- %d%d/%d%d/%d%d%d%d ')
  expand('.b', '^%- %d%d/%d%d/%d%d%d%d .*Break ')
  expand('.n', '^%+ ')

  -- Exercise the async picture abbreviation without filesystem or remote work.
  local original_picture = markdown.ask_label_for_picture_name_with_title
  markdown.ask_label_for_picture_name_with_title = function()
    return 'picture-title'
  end
  expand(',p', '^picture%-title ')
  markdown.ask_label_for_picture_name_with_title = original_picture
  vim.ui.input = original_input

  -- code; has the same conflict at the end of its trigger. Stub its blocking
  -- language prompt from an autoload file, retaining the real abbreviation.
  vim.cmd.enew { bang = true }
  vim.bo.filetype = 'ps1'
  vim.api.nvim_exec_autocmds('BufEnter', { pattern = 'abbreviations.ps1' })
  assert(vim.fn.maparg('code;', 'i', true) ~= '', 'Missing PowerShell abbreviation: code;')
  vim.cmd.runtime 'autoload/jerry/common.vim'
  local stub_dir = vim.fn.tempname()
  local stub = stub_dir .. '/autoload/jerry/common.vim'
  vim.fn.mkdir(vim.fn.fnamemodify(stub, ':h'), 'p')
  vim.fn.writefile({ 'function! jerry#common#JiraCodeFormat()', "  return 'jira-code'", 'endfunction' }, stub)
  vim.cmd.source(stub)
  vim.fn.delete(stub_dir, 'rf')
  expand('code;', '^jira%-code ')
  print 'PASS: all Markdown abbreviations registered; comma, period and semicolon triggers expand after VeryLazy'
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd.cquit(1)
else
  vim.cmd 'qa!'
end
