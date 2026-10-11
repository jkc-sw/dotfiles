-- Keep the fresh LazyVim picker even though Perforce also uses Telescope.
vim.g.lazyvim_picker = 'snacks'
vim.g.have_nerd_font = true

-- Preserve the external clipboard transport without copying a yank twice.
if vim.fn.executable 'toclip' == 1 then
  vim.g.clip_supplier = { 'toclip' }
  vim.opt.clipboard = ''
end

pcall(require, 'config.local')
