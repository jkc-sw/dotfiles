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
  { 'mason-org/mason-lspconfig.nvim', enabled = false },
  {
    'mason-org/mason.nvim',
    enabled = false,
  },
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      local servers = {
        ['*'] = { mason = false },
        clangd = { filetypes = { 'c', 'cpp', 'cc', 'objc', 'objcpp' } },
        rust_analyzer = {},
        lua_ls = { settings = { Lua = { format = { enable = false } } } },
        gopls = {},
        golangci_lint_ls = {},
        jsonls = {},
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
        nil_ls = {},
        dockerls = {},
        texlab = {},
        ts_ls = {},
        cmake = {},
        jdtls = {},
        yamlls = {
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = { format = { enable = true }, validate = true, hover = true, completion = true },
          },
        },
        ruff = { init_options = { settings = { args = {} } } },
        pyright = {},
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
      }
      opts.servers = vim.tbl_deep_extend('force', opts.servers or {}, servers)
      -- Applies to built-in and subsequently enabled language extras alike.
      for _, server in pairs(opts.servers) do
        if type(server) == 'table' then
          server.mason = false
        end
      end
    end,
  },
  {
    'mfussenegger/nvim-jdtls',
    opts = function(_, opts)
      -- The Nix launcher supplies its own Java environment and Lombok setup.
      opts.cmd = { vim.fn.exepath 'jdtls' }
    end,
  },
}
