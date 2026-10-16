local function matlab_install()
  local directory = '/usr/local/MATLAB'
  if not vim.uv.fs_stat(directory) then
    return
  end
  local versions = {}
  for name, kind in vim.fs.dir(directory) do
    if kind == 'directory' and name:match '^R20' then
      versions[#versions + 1] = vim.fs.joinpath(directory, name)
    end
  end
  table.sort(versions)
  return versions[#versions]
end

return {
  -- Home Manager supplies all external tools; LazyVim owns LSP setup.
  -- Language extras imported in config.lazy configure the common servers.
  { 'mason-org/mason-lspconfig.nvim', enabled = false },
  {
    'mason-org/mason.nvim',
    enabled = false,
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        lua_ls = { settings = { Lua = { format = { enable = false } } } },
        bashls = {},
        matlab_ls = {
          settings = {
            MATLAB = {
              indexWorkspace = true,
              installPath = matlab_install(),
              matlabConnectionTiming = 'onStart',
              telemetry = false,
            },
          },
        },
        groovyls = {
          cmd = { 'groovy-language-server' },
          root_dir = function(_, on_dir)
            on_dir(vim.fn.getcwd())
          end,
        },
        pylsp = {
          single_file_support = false,
          root_dir = function(_, on_dir)
            on_dir(vim.fn.getcwd())
          end,
          settings = { pylsp = { plugins = { pycodestyle = { maxLineLength = 300 } } } },
        },
        powershell_es = {
          cmd = vim.fn.executable 'power_es_work.sh' == 1 and { 'power_es_work.sh' }
            or { 'powershell-editor-services', '-Stdio' },
        },
      },
    },
  },
  {
    'mfussenegger/nvim-jdtls',
    opts = function(_, opts)
      -- The Nix launcher supplies its own Java environment and Lombok setup.
      opts.cmd = { vim.fn.exepath 'jdtls' }
    end,
  },
}
