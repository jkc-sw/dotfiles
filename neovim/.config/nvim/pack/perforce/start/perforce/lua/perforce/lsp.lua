
local jerry_lsp = require('jerry.lsp.config')
if vim.fn.executable('Start-PwshLsp.ps1') == 1 then
  jerry_lsp.setup_each_lsp('powershell_editor_service', {
    cmd = {
      "pwsh",
      -- "-NoLogo",
      -- "-NonInteractive",
      -- "-NoProfile",
      vim.fn.exepath('Start-PwshLsp.ps1'),
      vim.fn.getcwd()
    }
  })
end

-- vim:et ts=2 sw=2
