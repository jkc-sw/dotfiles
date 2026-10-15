local function run()
  local fixtures = assert(vim.env.NVIM_TEST_FIXTURES, 'Set NVIM_TEST_FIXTURES to a temporary fixture directory')
  assert(vim.bo.filetype == 'bitbake', 'Startup .inc file must be BitBake')
  assert(vim.fn.exists ':ArgsToQF' == 2, 'ArgsToQF must load at startup')

  local function edit(name, lines)
    local path = fixtures .. '/' .. name
    if lines then
      vim.fn.writefile(lines, path)
    end
    vim.cmd.edit { path, bang = true }
    return path
  end

  edit('later.inc', { 'DESCRIPTION = "fixture"' })
  assert(vim.bo.filetype == 'bitbake', 'Existing .inc file must be BitBake')
  edit 'new.inc'
  assert(vim.bo.filetype == 'bitbake', 'New .inc file must be BitBake')
  edit('layout.keymap', { '#define KEY 1', '&kp A &trans' })
  assert(vim.bo.filetype == 'keymap', '.keymap must use the custom filetype')
  assert(vim.b.current_syntax == 'keymap', 'Custom keymap syntax must load')

  local names = { 'with space.txt', 'symbols%#[x]!.txt', "quote'name.txt" }
  vim.cmd 'argdelete *'
  for _, name in ipairs(names) do
    local path = fixtures .. '/' .. name
    vim.fn.writefile({ 'fixture' }, path)
    vim.cmd('$argadd ' .. vim.fn.fnameescape(path))
  end
  vim.cmd.ArgsToQF()
  local qf = vim.fn.getqflist()
  assert(#qf == #names, 'ArgsToQF must preserve the complete argument list')
  for i, name in ipairs(names) do
    assert(vim.fn.bufname(qf[i].bufnr) == fixtures .. '/' .. name, 'ArgsToQF changed filename: ' .. name)
    assert(qf[i].valid == 1 and qf[i].lnum == 1, 'Quickfix entries must be usable')
  end
  vim.cmd 'argdelete *'
  vim.cmd.ArgsToQF()
  assert(#vim.fn.getqflist() == 0, 'An empty argument list must clear quickfix')

  local plugins = require('lazy.core.config').plugins
  assert(not plugins['vim-fugitive'], 'Fugitive must be removed')
  assert(vim.fn.exists ':Gwrite' == 0, 'Fugitive commands must be absent')
  local ts = require 'nvim-treesitter'
  local supported = require('nvim-treesitter.config').norm_languages('all', { unsupported = true })
  local configured = require('lazy.core.plugin').values(plugins['nvim-treesitter'], 'opts', false).ensure_installed
  local installed = ts.get_installed()
  for _, lang in ipairs(supported) do
    assert(vim.tbl_contains(configured, lang), 'Parser omitted from configuration: ' .. lang)
    assert(vim.tbl_contains(installed, lang), 'Supported language not installed: ' .. lang)
  end
  for lang, sample in pairs {
    cpp = 'int main() { return 0; }',
    css = 'a { color: #ff0000; }',
    dockerfile = 'FROM alpine\nRUN echo ok\n',
    make = 'all:\n\t@echo ok\n',
    scss = '$color: #ff0000;\na { color: $color; }\n',
    sql = 'SELECT 1;\n',
    fish = 'echo hello\n',
    bitbake = 'DESCRIPTION = "fixture"\n',
  } do
    local trees = vim.treesitter.get_string_parser(sample, lang):parse()
    assert(trees[1] and not trees[1]:root():has_error(), 'Parser failed for ' .. lang)
  end

  edit('notes.md', { '# Recovered heading', '', '```lua', 'print("hello")', '```', '', 'plain text', '' })
  vim.api.nvim_win_set_cursor(0, { 7, 0 })
  vim.cmd.redraw()
  assert(plugins['render-markdown.nvim']._.loaded, 'Markdown renderer must load on its filetype event')
  assert(require('render-markdown').get(), 'Markdown rendering must be enabled')
  assert(#require('render-markdown.state').validate() == 0, 'Markdown renderer configuration must be valid')
  assert(vim.fn.executable 'latex2text' == 1, 'Home Manager must supply the Markdown math converter')
  local math = vim.fn.system({ 'latex2text' }, [[\frac{1}{2}]])
  assert(vim.v.shell_error == 0 and vim.trim(math) ~= '', 'Markdown math converter failed')
  local markdown_ns = vim.api.nvim_get_namespaces()['render-markdown.nvim']
  assert(markdown_ns, 'Markdown renderer must load for Markdown buffers')
  assert(
    vim.wait(2000, function()
      return #vim.api.nvim_buf_get_extmarks(0, markdown_ns, 0, -1, {}) > 0
    end),
    'Markdown renderer did not create any decorations'
  )

  edit('colors.css', { 'a { color: #ff0000; background: #00ff00; }' })
  vim.cmd.redraw()
  assert(plugins['nvim-colorizer.lua']._.loaded, 'Color previews must load on LazyFile')
  assert(require('colorizer').is_buffer_attached(0), 'Color previews must attach automatically')
  local color_ns = vim.api.nvim_get_namespaces().colorizer
  assert(
    vim.wait(1000, function()
      return #vim.api.nvim_buf_get_extmarks(0, color_ns, 0, -1, {}) >= 2
    end),
    'Color previews did not highlight both colors'
  )

  edit('context.lua', { 'local function recovered()', '  local value = 1', '  return value', 'end' })
  assert(plugins.nvim_context_vt._.loaded, 'Context hints must load on LazyFile')
  vim.treesitter.get_parser(0):parse()
  vim.api.nvim_win_set_cursor(0, { 2, 4 })
  vim.api.nvim_exec_autocmds('CursorMoved', { buffer = 0 })
  local context_ns = vim.api.nvim_get_namespaces().context_vt
  assert(context_ns, 'Context hint plugin must load')
  local context = vim.api.nvim_buf_get_extmarks(0, context_ns, 0, -1, { details = true })
  assert(#context > 0, 'Context plugin did not annotate the enclosing function')
  for _, mark in ipairs(context) do
    assert(not mark[4].virt_lines, 'Context hints must not add virtual lines')
  end

  print(
    string.format(
      'PASS: filetypes, quickfix, %d supported languages, Markdown, colors, context hints; Fugitive removed',
      #supported
    )
  )
end

-- Exercise normal startup ordering, including LazyFile and VeryLazy, before
-- checking integrations. Headless -c commands alone run before these events.
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.defer_fn(function()
      local ok, err = xpcall(run, debug.traceback)
      if not ok then
        vim.api.nvim_err_writeln(err)
        vim.cmd.cquit(1)
      else
        vim.cmd 'qa!'
      end
    end, 100)
  end,
})
