local configs = require'nvim_lsp/configs'
local defaults = require'defaults'

-- pwsh
-- Setup the lsp with custom command setup
configs.powershell_editor_service = {
  default_config = {
    cmd = {
      "pwsh",
      "-NoLogo",
      "-NonInteractive",
      "-NoProfile",
      defaults.pses_bundle_path.."/PowerShellEditorServices/Start-EditorServices.ps1",
      "-BundledModulesPath",
      defaults.pses_bundle_path,
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
}

-- hdl
configs.hdl_checker = {
  default_config = {
    cmd = {
      defaults.lsp_condaenv_bin.."hdl_checker", "--lsp"
    },
    filetypes = {"vhdl", "verilog", "systemverilog"},
    root_dir = function()
      return vim.fn.getcwd()
    end,
    docs = {
      description = [[
https://github.com/suoto/hdl_checker
      ]]
    }
  }
}

-- vim:et ts=2 sw=2
