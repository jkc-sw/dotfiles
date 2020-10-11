local configs = require 'nvim_lsp/configs'

-- Define the path to the lsp location
local pses_bundle_path = vim.env.HOME..'/repos/PowerShellEditorServices/module'
-- Setup the lsp with custom command setup
configs.powershell_editor_service = {
  default_config = {
    cmd = {
      "pwsh",
      "-NoLogo",
      "-NonInteractive",
      "-NoProfile",
      pses_bundle_path.."/PowerShellEditorServices/Start-EditorServices.ps1",
      "-BundledModulesPath",
      pses_bundle_path,
      "-LogPath",
      vim.fn.getcwd().."/logs.log",
      "-SessionDetailsPath",
      vim.fn.getcwd().."/session.json",
      -- "-FeatureFlags",
      -- "@()",
      -- "-AdditionalModules",
      -- "@()",
      "-HostName",
      "nvim_lsp.powershell_editor_service",
      "-HostProfileId",
      "nvim_lsp.powershell_editor_service",
      "-HostVersion",
      "1.0.0",
      "-LogLevel",
      "Normal",
      "-Stdio"
    };
    filetypes = {"ps1", "powershell", "psm1", "pwsh", "psd1"};
    root_dir = function()
      return vim.fn.getcwd()
    end;
  };
  docs = {
    description = [[
https://github.com/PowerShell/PowerShellEditorServices
`PowershellEditorServices` to provide lsp capability for Powershell
    ]];
    default_config = {
      root_dir = "vim's starting directory";
    };
  };
};
-- vim:et ts=2 sw=2
