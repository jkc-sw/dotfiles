--[[
SOURCE_THESE_VIMS_START
" lua
let @h="yoprint(string.format('\<c-r>\" = %s', vim.inspect(\<c-r>\")))\<esc>j"
echom 'Sourced'
SOURCE_THESE_VIMS_END
--]]

local M = {}
local send_to_clipboard = require('jerry.clipboard').send_to_clipboard
local markdown_links = require('jerry.markdown_links')
local markdown_buffer_group = vim.api.nvim_create_augroup('jerry_markdown_ftplugin', { clear = false })
local ask_label_for_picture_name_impl

local placeholder_ns = vim.api.nvim_create_namespace('jerry_markdown')
local placeholder_seq = 0

local function strip_terminal_suffix(txt)
  if txt == nil then
    return nil
  end

  return txt:gsub('1~$', '')
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

  error('Unable to locate placeholder')
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

local function format_current_file_for_journal_jump()
  local out = vim.fn.expand('%')
  out = out:gsub('"', '\\"')
  out = out:gsub('\\', '/')
  out = out:gsub('.*/[jJ]ournal/', './')
  return out
end

local function escape_shell_search_line(line)
  local out = line:gsub('\\', '\\\\')
  out = out:gsub('"', '\\`"')
  out = out:gsub('%.', '\\.')
  out = out:gsub('%*', '\\\\*')
  out = out:gsub('/', '\\/')
  out = out:gsub('%[', '\\[')
  return out
end

local function escape_vim_search_line(line)
  local out = line:gsub('"', '\\"')
  out = out:gsub('%*', '\\\\*')
  return out
end

local function prompt_with_placeholder(prompt_func)
  placeholder_seq = placeholder_seq + 1
  local bufnr = vim.api.nvim_get_current_buf()
  local row_hint = vim.api.nvim_win_get_cursor(0)[1]
  local placeholder = string.format('__JERRY_MARKDOWN_%d_%d__', bufnr, placeholder_seq)

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    local extmark_id = create_placeholder_mark(bufnr, placeholder, row_hint)
    prompt_func(function(txt)
      vim.schedule(function()
        replace_placeholder(bufnr, extmark_id, txt)
      end)
    end)
  end)

  return placeholder
end

--- @brief Setup markdown-specific options, keymaps, and abbreviations for the current buffer.
M.setup_buffer = function()
  if vim.b.jerry_markdown_setup_done then
    return
  end
  vim.b.jerry_markdown_setup_done = true

  vim.opt_local.wrap = true
  vim.opt_local.spell = true
  vim.opt_local.linebreak = true

  -- This small block will automatically soft wrap a long line in a list. Visual only.
  -- https://t3.chat/share/y8c0bx42dw
  vim.opt_local.breakindent = true
  -- 'list:-1' tells Vim to align soft-wrapped lines with the list text.
  vim.opt_local.breakindentopt = "list:-1"

  vim.keymap.set('n', '<leader>th', function()
    vim.fn.search('^## \\d\\{4}-\\d\\{2}-\\d\\{2}', 'bW')
  end, { buffer = 0, desc = 'Jump to previous journal heading' })

  vim.keymap.set('n', '<leader>tn', function()
    vim.fn.search('^## \\d\\{4}-\\d\\{2}-\\d\\{2}', 'W')
  end, { buffer = 0, desc = 'Jump to next journal heading' })

  -- yank the lines between the nearest surrounding ``` fences (exclusive)
  vim.keymap.set(
    'n',
    '<leader>ne',
    [[<cmd>?^```?+1,/^```/-1 y<CR>]],
    { buffer = 0, noremap = true, silent = true }
  )

  vim.keymap.set('n', '<leader>pt', function()
    send_to_clipboard(M.new_search_pattern_as_markdown_multiline_code_block())
    print('pt content sent to clipboard')
  end, { buffer = 0, desc = 'Copy multiline jump snippet' })

  vim.keymap.set('n', '<leader>pn', function()
    send_to_clipboard(M.new_search_pattern_as_markdown_singleline_code_block())
    print('pn content sent to clipboard')
  end, { buffer = 0, desc = 'Copy single-line jump snippet' })

  vim.keymap.set('n', '<leader>pf', function()
    send_to_clipboard(M.new_search_pattern_from_inside_vim())
    print('pf content sent to clipboard')
  end, { buffer = 0, desc = 'Copy Vim jump snippet' })

  vim.keymap.set('n', '<leader>ph', function()
    send_to_clipboard(M.new_search_pattern_from_shell_without_markup())
    print('ph content sent to clipboard')
  end, { buffer = 0, desc = 'Copy shell jump snippet' })

  vim.keymap.set('n', '<leader>.u', [[gg/^-<space>/<CR>}O<C-R>=strftime('- %m/%d/%Y %H:%M:%S %p ')<CR>]], { buffer = 0 })
  vim.keymap.set('n', '<leader>.b', [[gg/^-<space>/<CR>}O<C-R>=strftime('- %m/%d/%Y %H:%M:%S %p Break ')<CR><Esc>A]], { buffer = 0 })
  vim.keymap.set('n', '<leader>,u', [["ryygg/^-<space>/<CR>}"rP0d4Wi<C-R>=strftime('- %m/%d/%Y %H:%M:%S %p ')<CR><Esc>A ]], { buffer = 0 })

  vim.fn.setreg('c', vim.api.nvim_replace_termcodes([[V/^## \<CR>k"Ld]], true, false, true))

  vim.keymap.set("v", "<leader>tf", function()
    local s = vim.fn.getpos("'<")[2]
    local e = vim.fn.getpos("'>")[2]
    M.replace_range(s, e)
  end, { buffer = 0, desc = "Format selection as markdown table" })

  vim.keymap.set("n", "<leader>tf", function()
    local buf = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local total = #buf
    local row = vim.api.nvim_win_get_cursor(0)[1]

    if not M.is_table_line(buf[row]) then
      vim.notify("Cursor is not inside a table", vim.log.levels.WARN)
      return
    end

    local s, e = row, row
    while s > 1 and M.is_table_line(buf[s - 1]) do
      s = s - 1
    end
    while e < total and M.is_table_line(buf[e + 1]) do
      e = e + 1
    end

    M.replace_range(s, e)
  end, { buffer = 0, desc = "Format markdown table under cursor" })

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = markdown_buffer_group,
    buffer = 0,
    callback = function()
      M.search_and_replace_invalid_sharepoint_link()
      vim.cmd([[silent! %s/Ã‚Â’/'/g]])
    end,
  })

  vim.api.nvim_create_autocmd('InsertLeave', {
    group = markdown_buffer_group,
    buffer = 0,
    callback = function()
      M.code_block_enable_paste_mode(false)
    end,
  })
end

M.take_me_here_shell = function(one_liner)
  local current_line = escape_shell_search_line(vim.api.nvim_get_current_line())
  local filepath = format_current_file_for_journal_jump()
  local out = string.format([[```ps1
en ; nvim "%s" -c "/^%s/"
```
]], filepath, current_line)
  if one_liner then
    out = string.format('`en ; nvim "%s" -c "/^%s/"`', filepath, current_line)
  end

  vim.api.nvim_echo({ { 'TakeMeHereShell copys: ' .. out } }, false, {})
  return out
end

M.take_me_here_vim = function()
  local current_line = escape_vim_search_line(vim.api.nvim_get_current_line())
  local filepath = format_current_file_for_journal_jump()
  local out = ''

  if current_line:match('^## ') then
    out = '\n' .. current_line .. '\n\n'
  end

  out = out .. string.format([[```vim
execute "e ".fnameescape("%s") | call search("^%s")
```
]], filepath, current_line)

  vim.api.nvim_echo({ { 'TakeMeHereVim copys: ' .. out } }, false, {})
  return out
end

---@brief Push current position to the tag stack and add to the jump list
M.push_to_tagstack = function()
  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  local from = vim.fn.getpos('.')
  from[1] = bufnr
  local tagname = vim.fn.expand('<cword>')

  -- Save position in jumplist
  vim.cmd("normal! m'")

  local tagstack = { { tagname = tagname, from = from } }
  vim.fn.settagstack(vim.fn.win_getid(win), { items = tagstack }, 't')
end

--- @brief Given a pattern, find the line number and file name it has
--- @param pattern string
--- @return {filepath: string, line_number: integer}[]
M.get_filename_linenum_of_a_pattern = function(pattern)
  -- I don't check whether rg exist. I am using home-manager with nix to build neovim setup.
  -- Ripgrep is a dependency for my neovim install
  local cmd = {
    "rg",
    "--column",
    "--line-number",
    "--no-heading",
    "--color=never",
    "-e",
    pattern,
    "-g",
    "*.md",
  }
  local ret = vim.system(cmd, { text = true }):wait()
  if ret.code ~= 0 then
    return {}
  end

  local output = ret.stdout
  if not output then
    return {}
  end
  local lines = vim.split(output, "\n", { trimempty = true })

  local matches = {}
  for _, line in ipairs(lines) do
    local filepath, line_number, _ = line:match("([^:]+):(%d+):(.*)")
    table.insert(matches, {
      filepath = filepath,
      line_number = tonumber(line_number),
    })
  end

  return matches
end

--- @brief Given the origin:uuid tag, jump to the file with that line
--- Jump to the source file and line number corresponding to a given `origin:uuid` tag.
---
--- This function searches for a specific `origin:uuid` tag within markdown files in the current working directory
--- using ripgrep. It expects the tag to be in the format `origin:cf8d08d2-5b5b-4d20-9fc3-878b1ac78b18`.
--- If the tag is found, it opens the corresponding file and moves the cursor to the line number
--- where the tag was found.
---
--- @param uuid string The `origin:uuid` uuid to search for.
--- @throws string Error message if the tag format is invalid, ripgrep fails, or multiple results are found.
M.jump_to_originuuid = function(uuid)
  local pattern = "^%w%w%w%w%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%w%w%w%w%w%w%w%w$"
  if not uuid:match(pattern) then
    error("Invalid uuid format. Expected <uuid>")
  end

  local orig_pattern = "origin:" .. uuid

  local matches = M.get_filename_linenum_of_a_pattern(orig_pattern)
  if #matches ~= 1 then
    error(string.format("Pattern %s found %d matches (~=1). Please rg search and fix it", orig_pattern, #matches))
  end

  local match = matches[1]
  local filepath, line_number = match.filepath, match.line_number

  M.push_to_tagstack()

  vim.cmd.edit(filepath)
  vim.cmd(string.format(':%d', line_number))
end

--- @brief Matches a specific pattern in the current line and returns it.
--- @return string The matched pattern if found.
--- @error Throws an error if the pattern is not found.
M.match_uuid_in_current_line = function()
  local line = vim.api.nvim_get_current_line()
  local pattern = "origin:(%w%w%w%w%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%w%w%w%w%w%w%w%w)"
  local uuid = line:match(pattern)
  if not uuid then
    error("Cannot find origin:uuid in the current line")
  end
  return uuid
end

--- @brief Generate and return a new uuid tag as string
--- @return string
--- @throws string Error message if the tag format is invalid, ripgrep fails, or multiple results are found.
M.new_originuuid = function()
  for attempt_num = 1, 3, 1 do
    local uuid = string.sub(vim.system({ 'uuidgen' }, { text = true }):wait().stdout, 1, -2)
    local out = 'origin:' .. uuid
    local matches = M.get_filename_linenum_of_a_pattern(out)
    if #matches == 0 then
      return out
    end
    print(string.format('WARN (attempt %d): New uuid %s is in conflict with another one in the system, retry', attempt_num, uuid))
  end
  error('Unable to generate a new UUID without a conflict for 3 times. This should never happens')
end

--- @brief Find an uuid in the current line and return the
--- formatted string for multiple line of markdown code block
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_as_markdown_multiline_code_block = function()
  local uuid = M.match_uuid_in_current_line()
  local out = string.format([[```
en ; nvim -c "lua require('jerry.markdown').jump_to_originuuid('%s')"
```]], uuid)
  return out
end

--- @brief Find an uuid in the current line and return the
--- formatted string for single line of markdown code block
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_as_markdown_singleline_code_block = function()
  local uuid = M.match_uuid_in_current_line()
  local out = string.format([[`en ; nvim -c "lua require('jerry.markdown').jump_to_originuuid('%s')"`]], uuid)
  return out
end

--- @brief Find an uuid in the current line and return the
--- formatted string jumping to src without markup
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_from_shell_without_markup = function()
  local uuid = M.match_uuid_in_current_line()
  local out = string.format([[nvim -c "lua require('jerry.markdown').jump_to_originuuid('%s')"]], uuid)
  return out
end

--- @brief Find an uuid in the current line and return the
--- formatted string jumping to src inside vim
--- @return string
--- @throws When uuid is not found
M.new_search_pattern_from_inside_vim = function()
  local uuid = M.match_uuid_in_current_line()
  local heading = M.find_nearest_heading_above_current_line()
  local out = string.format([[
%s

```vim
lua require('jerry.markdown').jump_to_originuuid('%s')
```
]], heading, uuid)
  return out
end

--- @brief Find the line matching the pattern backward and return the line
--- @return string
--- @throws When pattern is not found
M.find_nearest_heading_above_current_line = function()
  local matched_line_nr = vim.fn.search('^## .*$', "bnW")
  if matched_line_nr == 0 then
    error("Cannot find the heading backward from the current line")
  end

  local heading = vim.api.nvim_buf_get_lines(0, matched_line_nr - 1, matched_line_nr, false)[1]
  if not heading then
    error("Cannot find the heading backward from the current line")
  end
  return heading
end

--- Checks whether a single line belongs to a Markdown table.
---
---@param line string The line of text to inspect.
---@return boolean `true` if the line contains a pipe character (`|`).
M.is_table_line = function(line)
  return line:find("|") ~= nil
end

--- Formats an array of Markdown table lines by aligning every column.
---
--- Pipes the input through `tr -s ' '` (collapse whitespace) followed
--- by `column -t -s '|' -o '|'` (align columns on `|` delimiters).
---
---@param lines string[] Array of raw table lines.
---@return string[] formatted The same table with every column padded
---         so that pipes are vertically aligned.
M.fmt_table = function(lines)
  local stdin = table.concat(lines, "\n")
  local out = vim.fn.systemlist("tr -s ' ' | column -t -s '|' -o '|'", stdin)
  return out
end

--- Replaces a 1-indexed inclusive line range in the current buffer
--- with the result of formatting those lines as a Markdown table.
---
---@param s_row integer First line of the range (1-indexed, inclusive).
---@param e_row integer Last line of the range (1-indexed, inclusive).
M.replace_range = function(s_row, e_row)
  local lines = vim.api.nvim_buf_get_lines(0, s_row - 1, e_row, false)
  local formatted = M.fmt_table(lines)
  vim.api.nvim_buf_set_lines(0, s_row - 1, e_row, false, formatted)
end

M.ask_user_for_jira_tag_return_jf_output = function(prefix)
  return prompt_with_placeholder(function(cb)
    prompt_input('Jira tag:', '', function(jtag)
      if jtag == nil or jtag == '' then
        vim.api.nvim_err_writeln('No jira tag is entered')
        cb('')
        return
      end

      local jfoutput
      if vim.fn.has('win32') == 1 then
        jfoutput = vim.fn.system({
          'pwsh.exe',
          '-NoProfile',
          '-Command',
          "Import-Module MyModules00 ; jf '" .. jtag .. "' -Passthru",
        })
      else
        local ip = vim.env.BOXX_IP
        if ip == nil then
          error('AskUserForJiraTagReturnJfOutput needs to access env var BOXX_IP, but it is not found')
        end

        local user = vim.env.BOXX_USER
        if user == nil then
          error('AskUserForJiraTagReturnJfOutput needs to access env var BOXX_USER, but it is not found')
        end

        local ret = vim.system({ 'jfssh', jtag }, { text = true, stderr = false }):wait()
        jfoutput = ret.stdout or ''
      end

      jfoutput = vim.trim(jfoutput)
      if prefix ~= nil and prefix ~= '' then
        cb(prefix .. ' ' .. jfoutput)
      else
        cb(jfoutput)
      end
    end)
  end)
end

M.code_block = function()
  return prompt_with_placeholder(function(cb)
    prompt_input('Lang:', '', function(lang)
      if lang == nil then
        lang = ''
      end
      M.code_block_enable_paste_mode(true)
      cb('```' .. lang .. '\n```')
    end)
  end)
end

M.code_block_enable_paste_mode = function(enable)
  if vim.g.code_block_enable_paste_mode == nil then
    vim.g.code_block_enable_paste_mode = false
  end

  if enable then
    vim.o.paste = true
    vim.g.code_block_enable_paste_mode = true
    return
  end

  if vim.g.code_block_enable_paste_mode then
    vim.o.paste = false
    vim.bo.expandtab = true
    vim.g.code_block_enable_paste_mode = false
  end
end

M.get_date_offset = function(dayoffset, prefix)
  local offset = dayoffset
  if offset == nil or offset == '' then
    return prompt_with_placeholder(function(cb)
      prompt_input('Day of offset:', '', function(input)
        if input == nil then
          input = ''
        end
        local seconds = (tonumber(input) or 0) * 60 * 60 * 24
        cb((prefix or '') .. vim.fn.strftime('%Y-%m-%d %A', vim.fn.localtime() + seconds))
      end)
    end)
  end

  local seconds = (tonumber(offset) or 0) * 60 * 60 * 24
  return (prefix or '') .. vim.fn.strftime('%Y-%m-%d %A', vim.fn.localtime() + seconds)
end

M.get_date_offset_no_day = function(offset)
  local day_offset = offset
  if day_offset == nil or day_offset == '' then
    return prompt_with_placeholder(function(cb)
      prompt_input('Day of offset:', '', function(input)
        if input == nil then
          input = ''
        end
        local seconds = (tonumber(input) or 0) * 60 * 60 * 24
        cb(vim.fn.strftime('%Y-%m-%d', vim.fn.localtime() + seconds))
      end)
    end)
  end

  local seconds = (tonumber(day_offset) or 0) * 60 * 60 * 24
  return vim.fn.strftime('%Y-%m-%d', vim.fn.localtime() + seconds)
end

M.search_and_replace_invalid_sharepoint_link = function()
  vim.cmd([[silent! %s/\((http.*\)\/:\([^:/ ]\):\//\1\/%3A\2%3A\//]])
end

M.ask_label_for_picture_name_with_title = function(label)
  return prompt_with_placeholder(function(cb)
    prompt_input('Label:', label or '', function(clean_label)
      if clean_label == nil then
        clean_label = ''
      end

      ask_label_for_picture_name_impl(clean_label, function(body)
        cb('## ' .. clean_label .. '\n\n' .. M.new_originuuid() .. '\n\n' .. body)
      end)
    end)
  end)
end

ask_label_for_picture_name_impl = function(label, cb)
  local clean_label = label or ''

  local function process_label(lbl)
    if lbl == nil then
      if cb then
        cb('')
      end
      return
    end

    clean_label = lbl
    clean_label = strip_terminal_suffix(clean_label) or ''
    local default_pic_name = clean_label:lower():gsub(' ', '-')
    default_pic_name = default_pic_name:gsub("'", '')
    default_pic_name = default_pic_name:gsub('[!@#$%%^&,:*()%-=%[%]/\\ ?|]+', '-')

    prompt_input('Filename:', default_pic_name .. '.', function(pic_name)
      if pic_name == nil then
        if cb then
          cb('')
        end
        return
      end

      local note_parent_folder_name = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':h:t')
      local note_type_dash_index = note_parent_folder_name:find('-', 1, true)
      if note_type_dash_index == nil then
        vim.api.nvim_err_writeln("Folder name '" .. note_parent_folder_name .. "' derived from '" .. vim.fn.expand('%:p') .. "' is not supported. No - is found")
        if cb then
          cb('')
        end
        return
      end

      local folder_name = note_parent_folder_name:sub(1, note_type_dash_index - 1)
      local pic_path_prefix = folder_name .. '/' .. M.get_date_offset_no_day(0) .. '-'
      local link = (pic_path_prefix .. pic_name):gsub('/', '\\')
      if clean_label == '' then
        clean_label = link
      end

      local txt = markdown_links.wrap_link('', clean_label, link)
      markdown_links.prompt_browser_link('', clean_label, function(browser_link)
        if #browser_link > 0 then
          txt = browser_link .. "\n\n" .. txt
        end

        if cb then
          cb(txt)
        end
      end)
    end)
  end

  if clean_label == '' then
    prompt_input('Label:', clean_label, function(lbl)
      process_label(lbl)
    end)
  else
    process_label(clean_label)
  end
end

M.ask_label_for_picture_name = function(label)
  return prompt_with_placeholder(function(cb)
    ask_label_for_picture_name_impl(label, cb)
  end)
end

return M

-- vim:et ts=2 sts=2 sw=2
