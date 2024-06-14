
local jerry_lsp = require('jerry.lsp.config')
if vim.fn.executable('power_es_work.sh') == 0 then
  jerry_lsp.setup_each_lsp('powershell_es', {
    cmd = {'power_es_work.sh'}
  })
end

-- vim:et ts=2 sw=2
