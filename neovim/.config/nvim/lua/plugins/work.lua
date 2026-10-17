local path = vim.fn.stdpath 'config' .. '-work/pack/mks/start/mks'

if not vim.uv.fs_stat(path) then
  return {}
end

return {
  {
    name = 'mks',
    dir = path,
    lazy = false,
  },
}
