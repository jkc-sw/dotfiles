local M = {}

local edge_browser = [[C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe]]
local placeholder_ns = vim.api.nvim_create_namespace('jerry_markdown_links')
local placeholder_seq = 0

M.trigger_specs = {
  cnk = { kind = 'browser', label = 'Crucible' },
  enk = { kind = 'browser', label = 'Open in Edge', browser = edge_browser },
  gnk = { kind = 'browser', label = 'Github' },
  ink = { kind = 'browser', label = 'Link' },
  mnk = { kind = 'title_and_browser', label = '' },
  nk = { kind = 'browser', label = '' },
  nj = { kind = 'markdown', label = '' },
  onk = { kind = 'browser', label = 'Open in Default App' },
  pnk = { kind = 'browser', label = 'Project' },
  rnk = { kind = 'browser', label = 'Reference' },
  sck = { kind = 'browser', label = 'Slack' },
  spt = { kind = 'browser', label = 'SharePoint' },
  tnk = { kind = 'browser', label = 'Topic' },
  ynk = { kind = 'browser', label = 'Youtube' },
}

local function strip_terminal_suffix(txt)
  if txt == nil then
    return nil
  end
  local out = txt:gsub("1~$", "")
  return out
end

local function trim_quotes(txt)
  local out = txt:gsub('^"+', '')
  out = out:gsub('"+$', '')
  return out
end

local function clean_label(label)
  return strip_terminal_suffix(label or '')
end

local function clean_link(link)
  local out = strip_terminal_suffix(link or '')
  out = vim.trim(out)
  out = trim_quotes(out)
  return out
end

local function to_forward_slashes(txt)
  local out = txt:gsub('\\', '/')
  return out
end

local function prompt_input(prompt, default, cb)
  vim.ui.input({ prompt = prompt, default = default or '' }, function(input)
    if input == nil then
      cb(nil)
      return
    end
    cb(strip_terminal_suffix(input))
  end)
end

local function replacement_lines(txt)
  if txt == nil or txt == '' then
    return {}
  end
  return vim.split(txt, '\n', { plain = true })
end

local function replacement_end_cursor(row, col, lines)
  if #lines == 0 then
    return { row + 1, col }
  end
  if #lines == 1 then
    return { row + 1, col + #lines[1] }
  end
  return { row + #lines, #lines[#lines] }
end

local function locate_placeholder(bufnr, placeholder, row_hint)
  if row_hint ~= nil then
    local hinted_line = vim.api.nvim_buf_get_lines(bufnr, row_hint - 1, row_hint, false)[1]
    if hinted_line ~= nil then
      local start_col = hinted_line:find(placeholder, 1, true)
      if start_col ~= nil then
        return row_hint - 1, start_col - 1
      end
    end
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for idx, line in ipairs(lines) do
    local start_col = line:find(placeholder, 1, true)
    if start_col ~= nil then
      return idx - 1, start_col - 1
    end
  end

  error('Unable to locate markdown link placeholder')
end

local function create_placeholder_mark(bufnr, placeholder, row_hint)
  local row, col = locate_placeholder(bufnr, placeholder, row_hint)
  return vim.api.nvim_buf_set_extmark(bufnr, placeholder_ns, row, col, {
    end_row = row,
    end_col = col + #placeholder,
    right_gravity = false,
    end_right_gravity = true,
  })
end

local function replace_placeholder(bufnr, extmark_id, txt)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local extmark = vim.api.nvim_buf_get_extmark_by_id(bufnr, placeholder_ns, extmark_id, { details = true })
  if #extmark == 0 then
    return
  end

  local row = extmark[1]
  local col = extmark[2]
  local details = extmark[3]
  local lines = replacement_lines(txt)

  vim.api.nvim_buf_set_text(bufnr, row, col, details.end_row, details.end_col, lines)
  vim.api.nvim_buf_del_extmark(bufnr, placeholder_ns, extmark_id)

  if vim.api.nvim_get_current_buf() ~= bufnr then
    return
  end

  vim.api.nvim_win_set_cursor(0, replacement_end_cursor(row, col, lines))
  vim.cmd.startinsert()
end

local function build_wrapped_link(browser, label, link)
  return M.wrap_link(browser or '', label, link)
end

local function build_markdown_title_link(browser, label, link)
  return '## ' .. label
    .. "\n\n"
    .. require('jerry.markdown').new_originuuid()
    .. "\n\n"
    .. build_wrapped_link(browser, label, link)
end

local function link_text_from_spec(spec, label, link)
  if spec.kind == 'browser' then
    return build_wrapped_link(spec.browser, label, link)
  end
  if spec.kind == 'markdown' then
    return M.wrap_markdown_link(label, link)
  end
  if spec.kind == 'title_and_browser' then
    return build_markdown_title_link(spec.browser, label, link)
  end

  error('Unsupported markdown link kind: ' .. spec.kind)
end

local function prompt_for_text(spec, cb)
  local function ask_for_link(label)
    prompt_input('Url:', '', function(link)
      if link == nil then
        cb('')
        return
      end

      local clean = clean_link(link)
      if clean == '' then
        cb('')
        return
      end

      local clean_lbl = clean_label(label or '')
      if clean_lbl == '' then
        clean_lbl = clean
      end

      cb(link_text_from_spec(spec, clean_lbl, clean))
    end)
  end

  local should_prompt_label = spec.kind == 'title_and_browser' or spec.label == ''
  if should_prompt_label then
    prompt_input('Label:', spec.label, function(label)
      if label == nil then
        cb('')
        return
      end
      ask_for_link(label)
    end)
    return
  end

  ask_for_link(spec.label)
end

function M.wrap_link(exe, label, link)
  local clean = clean_link(link)
  if clean == '' then
    return ''
  end

  local clean_lbl = clean_label(label)
  local lines = {
    'Use below to handle this: ' .. clean_lbl,
    '```ps1',
  }

  if exe ~= nil and exe ~= '' then
    table.insert(lines, "Start-Process \"" .. exe .. "\" -ArgumentList '\"" .. clean .. "\"'")
  else
    table.insert(lines, 'Start-Process "' .. clean .. '"')
    table.insert(lines, 'tnpreview "' .. clean .. '"')
  end

  table.insert(lines, 'cpnew "' .. clean .. '"')
  table.insert(lines, '```')
  return to_forward_slashes(table.concat(lines, '\n'))
end

function M.wrap_markdown_link(label, link)
  local clean = clean_link(link)
  if clean == '' then
    return ''
  end

  local clean_lbl = clean_label(label)
  if clean_lbl == '' then
    clean_lbl = clean
  end

  return '[' .. clean_lbl .. '](' .. clean .. ')'
end

function M.prompt_browser_link_sync(browser, label)
  vim.fn.inputsave()
  local clean_lbl = label or ''
  if clean_lbl == '' then
    clean_lbl = strip_terminal_suffix(vim.fn.input('Label:', clean_lbl))
  end
  local link = vim.fn.input('Url:')
  vim.fn.inputrestore()

  local clean = clean_link(link)
  if clean == '' then
    return ''
  end

  clean_lbl = clean_label(clean_lbl)
  if clean_lbl == '' then
    clean_lbl = clean
  end

  return build_wrapped_link(browser, clean_lbl, clean)
end

function M.expand_abbrev(trigger)
  local spec = M.trigger_specs[trigger]
  if spec == nil then
    error('Unknown markdown link trigger: ' .. trigger)
  end

  placeholder_seq = placeholder_seq + 1
  local bufnr = vim.api.nvim_get_current_buf()
  local row_hint = vim.api.nvim_win_get_cursor(0)[1]
  local placeholder = string.format('__JERRY_MARKDOWN_LINK_%d_%d__', bufnr, placeholder_seq)

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    local extmark_id = create_placeholder_mark(bufnr, placeholder, row_hint)
    prompt_for_text(spec, function(txt)
      vim.schedule(function()
        replace_placeholder(bufnr, extmark_id, txt)
      end)
    end)
  end)

  return placeholder
end

function M.setup_buffer()
  if vim.b.jerry_markdown_links_setup_done then
    return
  end
  vim.b.jerry_markdown_links_setup_done = true

  for trigger, _ in pairs(M.trigger_specs) do
    vim.cmd(string.format(
      [[inoreabbrev <buffer> <expr> %s v:lua.require('jerry.markdown_links').expand_abbrev('%s')]],
      trigger,
      trigger
    ))
  end
end

return M

-- vim:et ts=2 sts=2 sw=2
