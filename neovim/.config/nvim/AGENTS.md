# Neovim configuration

Home Manager provides the Neovim executable and language-server executables.
It also provides formatters, linters, and Tree-sitter CLI/build tools.
The complete editor configuration is LazyVim, bootstrapped by `config.lazy`.
Third-party plugins are declared in `lua/plugins` and installed by lazy.nvim.
Mason is disabled. LazyVim/nvim-treesitter compile and manage the grammars
using the executables supplied by Home Manager. Keep LazyVim's native UI, completion, options and shortcuts.

The `jerry` and `perforce` local plugins register custom tools and runtime files
through `.setup()`. Apply retained custom mappings in `config.keymaps`, after
LazyVim's native defaults. Do not reintroduce a parallel Home Manager feature
flag, manual third-party `.setup()` calls, or copies of LazyVim's defaults.

Commit the baseline `lazy-lock.json` and `lazyvim.json`. Runtime manager state
and private overrides live under Neovim's XDG state directory, outside Git.
Never put credentials, private endpoints or secret-store paths in this repo.
