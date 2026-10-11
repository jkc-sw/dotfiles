# Neovim configuration

This is a native LazyVim configuration. Home Manager deploys this directory
and supplies Neovim, language servers, formatters, linters, Tree-sitter's CLI,
and build tools. lazy.nvim installs every third-party plugin; LazyVim owns the
UI, completion, editor options, keymaps, formatting and language-server setup.
Mason and mason-lspconfig are disabled: executables come from Nix.
nvim-treesitter builds and installs its grammars using the supplied CLI/compiler.

`init.lua` loads `lua/config/lazy.lua`, following the LazyVim starter layout.
`lua/plugins` contains the retained custom tools and small overrides. The
local `jerry` and `perforce` plugins provide tmux, journal, clipboard, code
block, Perforce and MATLAB workflows. They register their custom features
through `.setup()`; `config.keymaps` applies custom shortcuts after LazyVim's
defaults. There is no separate Home Manager editor profile.

## Native defaults

Gruvbox Material provides a warm colorscheme with its default medium background.
The UI and completion use LazyVim's own settings: Noice, Snacks, lualine,
bufferline, which-key, Blink and native snippets. Telescope
remains available for custom Perforce/AI pickers; Snacks is the default picker.
Java uses LazyVim's language extra with the Nix `jdtls` launcher. Other
retained language-server settings are in `lua/plugins/lsp.lua`.

The leader is Space. Useful native shortcuts:

| Keys | Action |
| --- | --- |
| `<leader><space>`, `<leader>ff` | Find files at the project root |
| `<leader>/`, `<leader>sg` | Grep at the project root |
| `<leader>fF`, `<leader>sG` | Find files / grep in the current directory |
| `<leader>,`, `<leader>fb` | Buffers |
| `<leader>e`, `<leader>E` | Explorer at the root / current directory |
| `<leader>cd` | Full diagnostic message in a floating window |
| `<leader>sk` | Fuzzy search keyboard shortcuts |
| `<leader>ca`, `<leader>cr`, `<leader>cf` | Code actions, rename, format |
| `<leader>snl`, `<leader>snh`, `<leader>sna` | Last message / history / all messages |
| `<leader>xx`, `<leader>xX`, `[d`, `]d` | Diagnostics and navigation |
| `<leader>uf`, `<leader>uF` | Toggle global / buffer autoformat |
| `<leader>qs`, `<leader>qS`, `<leader>ql` | Restore / select / last session |

`<leader>sk` includes a category column. Search `Diagnostics`, `Tmux`,
`Perforce`, `Journal`, `Snippets`, `Sourcing` or `Formatting` to find related
shortcuts. Custom descriptions include categories in which-key too.
`KEYMAPS.md` records the old aliases relocated to native defaults, including
formatting (`<leader>cf`) and closing a tab (`<leader><Tab>d`). Unique custom
actions retain their shortcuts. Use `<leader>fe` and `<leader>fb` to avoid
prefix waits caused by the longer custom `<leader>e*` and `<leader>,*` mappings.

Conform uses Nix-provided StyLua, Alejandra, shfmt, Ruff and prettierd.
`:ConformInfo` shows the selected formatter. LazyVim controls formatting on
save and its toggles. `:LuaFormat` and `:LuaLint` delegate to Conform and
nvim-lint; Luacheck and ShellCheck publish diagnostics through nvim-lint.
Project Lua policies live in `.stylua.toml` and `.luacheckrc`.

## Writable state and updates

Home Manager's configuration directory is read-only. On first startup,
`config.lazy` copies the tracked `lazy-lock.json` and `lazyvim.json` baselines
to Neovim's XDG state directory (normally `~/.local/state/nvim`). lazy.nvim
and `:LazyExtras` write those state copies. Plugin downloads and compiled
parsers use Neovim's XDG data directory, outside the repository.

Use `:Lazy` to manage plugins, `:Lazy update` to update them and `:Lazy restore`
to restore the current state lockfile. The tracked lockfile records the tested
baseline for new installations. To adopt an updated baseline for other
machines, copy the state `lazy-lock.json` (and `lazyvim.json` for extra
selections) into this repository, review, commit, and update the Nix input.
Existing installations keep their state selections until explicitly reset.

Machine-local options belong in
`~/.local/state/nvim/local/lua/config/local.lua`; private plugin specs belong
in `~/.local/state/nvim/local/lua/plugins/local.lua`. The bootstrap includes
that directory in the runtime path. Keep credentials in the environment or
these untracked files. The retained CodeCompanion adapter reads
`AZURE_OPENAI_API_KEY` and `AZURE_OPENAI_ENDPOINT`; private model/adapter
settings belong in local plugin specs.

Upstream configuration references:
https://www.lazyvim.org/configuration
https://lazy.folke.io/usage/lockfile
