local M = {}

local exact = {
  ['<leader>pp'] = 'Paste',
  ['<leader>p'] = 'Paste',
  ['<leader>r'] = 'Tmux',
  ['<leader>,.'] = 'Evaluation',
  ['<leader>,p'] = 'Evaluation',
  ['<leader>,u'] = 'Journal',
  ['<leader>.u'] = 'Journal',
  ['<leader>.b'] = 'Journal',
  ['<leader>T'] = 'Terminal',
  ['<leader>ty'] = 'Sourcing',
  ['<leader>ti'] = 'Sourcing',
  ['<leader>tp'] = 'Text tools',
  ['<leader>th'] = 'Journal',
  ['<leader>tn'] = 'Journal',
  ['<leader>tf'] = 'Formatting',
  ['<leader>ne'] = 'Snippets',
  ['<leader>pt'] = 'Snippets',
  ['<leader>pn'] = 'Snippets',
  ['<leader>pf'] = 'Snippets',
  ['<leader>ph'] = 'Snippets',
  ['<leader>fm'] = 'Formatting',
  ['<leader>gQ'] = 'LSP',
  ['<leader>Hl'] = 'Highlights',
  ['<leader>cf'] = 'Formatting',
  ['<leader>cF'] = 'Formatting',
  ['<leader>cd'] = 'Diagnostics',
  ['<leader>sd'] = 'Diagnostics',
  ['<leader>sD'] = 'Diagnostics',
  ['<leader>ss'] = 'LSP',
  ['<leader>sS'] = 'LSP',
  ['<leader>sH'] = 'Highlights',
  ['<leader>su'] = 'Undo',
  ['<leader>st'] = 'Tasks',
  ['<leader>ui'] = 'Highlights',
  ['<leader>uf'] = 'Formatting',
  ['<leader>uF'] = 'Formatting',
  ['<leader>ud'] = 'Diagnostics',
  ['<leader>un'] = 'Notifications',
  ['<leader>n'] = 'Notifications',
  ['<leader>ft'] = 'Terminal',
  ['<C-/>'] = 'Terminal',
  ['<leader><space>'] = 'Files',
  ['<leader>,'] = 'Buffers',
  ['<leader>/'] = 'Search',
  ['<leader>-'] = 'Windows',
  ['<leader>|'] = 'Windows',
  ['gd'] = 'LSP',
  ['gD'] = 'LSP',
  ['gr'] = 'LSP',
  ['gI'] = 'LSP',
  ['gy'] = 'LSP',
  ['K'] = 'LSP',
  ['gK'] = 'LSP',
  ['<leader>K'] = 'Help',
  ['<S-h>'] = 'Buffers',
  ['<S-l>'] = 'Buffers',
  ['<C-S>'] = 'Files',
  ['gx'] = 'Files',
  ['%'] = 'Navigation',
  ['g%'] = 'Navigation',
  ['[%'] = 'Navigation',
  [']%'] = 'Navigation',
  ['g['] = 'Navigation',
  ['g]'] = 'Navigation',
  ['n'] = 'Search',
  ['N'] = 'Search',
  ['s'] = 'Navigation',
  ['S'] = 'Navigation',
  ['j'] = 'Navigation',
  ['k'] = 'Navigation',
}

local categories = {}
for _, name in ipairs {
  'Appearance',
  'Argument list',
  'Buffers',
  'Comments',
  'Completion',
  'Diagnostics',
  'Editing',
  'Evaluation',
  'Files',
  'Formatting',
  'Git',
  'Help',
  'Highlights',
  'Journal',
  'LSP',
  'Location list',
  'Navigation',
  'Notifications',
  'Pairs',
  'Paste',
  'Perforce',
  'Quickfix',
  'Search',
  'Sessions',
  'Snippets',
  'Sourcing',
  'Surround',
  'Tabs',
  'Tags',
  'Tasks',
  'Terminal',
  'Text tools',
  'Text objects',
  'Tmux',
  'Undo',
  'Windows',
} do
  categories[name] = true
end

---Resolve a logical category without changing a mapping or its options.
function M.category(map, source)
  local described = (map.desc or ''):match '^([^:]+): '
  if categories[described] then
    return described
  end
  local key = map.lhs or ''
  if key:sub(1, 1) == vim.g.mapleader then
    key = '<leader>' .. key:sub(2)
  end
  if map.mode == 'i' and key:lower() == '<c-k>' then
    return 'LSP'
  end
  if exact[key] then
    return exact[key]
  end
  if key:match '^<leader><[Tt][Aa][Bb]>' then
    return 'Tabs'
  end
  if key:match '^<leader>e.' then
    return 'Perforce'
  end
  if key == '<leader>e' or key == '<leader>E' or key:match '^<leader>f' then
    return 'Files'
  end
  if key:match '^<leader>b' or key:match '^[%[%]][bB]$' then
    return 'Buffers'
  end
  if key:match '^[%[%]][aA]$' then
    return 'Argument list'
  end
  if key:match '^[%[%]][lL]$' or key:match '^[%[%]]<[Cc]%-[Ll]>$' or key:match '^<leader>x[lL]$' then
    return 'Location list'
  end
  if key:match '^[%[%]]T$' or key:match '^[%[%]]<[Cc]%-[Tt]>$' then
    return 'Tags'
  end
  if key:match '^<leader>g' or key:match '^[%[%]]h$' then
    return 'Git'
  end
  if key:match '^<leader>c' then
    return 'LSP'
  end
  if key:match '^[%[%]][dew]$' then
    return 'Diagnostics'
  end
  if key:match '^<leader>x[qQ]$' or key:match '^[%[%]][qQ]$' or key:match '^[%[%]]<[Cc]%-[Qq]>$' then
    return 'Quickfix'
  end
  if key:match '^<leader>x' then
    return 'Diagnostics'
  end
  if key:match '^<leader>s' then
    return 'Search'
  end
  if key:match '^<leader>u' then
    return 'Appearance'
  end
  if key:match '^<leader>q' then
    return 'Sessions'
  end
  if key:match '^<leader>w' or key:match '^<[Cc]%-[hjkl]>$' or key:match '^<[Cc]%-[UDLR]' then
    return 'Windows'
  end
  if key:match '^<leader>o' or key:match '^<leader>t[eoua.,]$' then
    return 'Tmux'
  end
  if key:match '^[%[%]]t$' then
    return 'Tasks'
  end

  local text = ((map.desc or '') .. ' ' .. (map.rhs or '') .. ' ' .. (source or '')):lower()
  if key:match '^[ai]' and (map.mode == 'x' or map.mode == 'v' or map.mode == 'o') then
    return 'Text objects'
  end
  for _, rule in ipairs {
    { 'Comments', 'comment' },
    { 'Text objects', 'textobject', 'textobj' },
    { 'Surround', 'sandwich', 'surround' },
    { 'Pairs', 'minipairs', 'open action', 'close action', 'closeopen action' },
    { 'Completion', 'blink', 'cmp', 'complete' },
    { 'Snippets', 'snippet', 'luasnip' },
    { 'Git', 'fugitive', 'gitsigns', 'neogit', 'git ' },
    { 'LSP', 'lsp', 'signature', 'hover' },
    { 'Diagnostics', 'diagnostic', 'warning', 'error' },
    { 'Terminal', 'terminal' },
    { 'Help', 'help', 'manual' },
    { 'Search', 'search', 'find', 'grep' },
    { 'Navigation', 'goto', 'jump', 'motion', 'node' },
    { 'Paste', 'paste', 'register' },
  } do
    for i = 2, #rule do
      if text:find(rule[i], 1, true) then
        return rule[1]
      end
    end
  end
  return map.mode == 't' and 'Terminal' or 'Editing'
end

function M.describe(lhs, desc, mode)
  return M.category { lhs = lhs, desc = desc, mode = mode } .. ': ' .. desc
end

---Add category fields to a picker item; retain its original preview/action.
function M.transform(item)
  local map = item.item
  item.category = M.category(map, item.file)
  local desc = map.desc and map.desc ~= '' and map.desc or map.rhs
  item.keymap_description = (desc and desc ~= '' and desc or 'Lua callback'):gsub('^' .. item.category .. ': ', '')
  item.text = item.category .. ' ' .. item.text
end

return M
