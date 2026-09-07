local ok, lazydev = pcall(require, 'lazydev')
if not ok then
  return
end

pcall(lazydev.setup, {
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
})
