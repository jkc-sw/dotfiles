# Neovim configuration

This is a native LazyVim configuration. Home Manager deploys this directory
and supplies Neovim, language servers, formatters, linters, Tree-sitter's CLI,
and build tools. lazy.nvim installs every third-party plugin; LazyVim owns the
UI, completion, editor options, keymaps, formatting and language-server setup.
Mason and mason-lspconfig are disabled: executables come from Nix.
nvim-treesitter builds and installs its grammars using the supplied CLI/compiler.
The complete supported parser set is installed, preserving the former Nix
`withAllGrammars` coverage. The first installation can take several minutes.

`init.lua` loads `lua/config/lazy.lua`, following the LazyVim starter layout.
`lua/plugins` contains the retained custom tools and small overrides. The
local `jerry` and `perforce` plugins provide tmux, journal, clipboard, code
block, Perforce and MATLAB workflows. They register their custom features
through `.setup()`; `config.keymaps` applies custom shortcuts after LazyVim's
defaults. There is no separate Home Manager editor profile.

## Native defaults

Gruvbox Material provides a warm colorscheme with its default medium background.
The UI and completion use LazyVim's own settings: Noice, Snacks, lualine,
bufferline, which-key, Blink and native snippets. Snacks is the only picker,
including the Perforce opened-files picker (`<leader>eo`).

Languages use LazyVim's extras, imported in `lua/config/lazy.lua` (not
`lazyvim.json`, whose `:LazyExtras` copy lives in the state directory):
`lang.{clangd,cmake,docker,go,java,json,markdown,nix,python,rust,tex,typescript,yaml}`,
`formatting.prettier` and `coding.mini-surround`. Java uses the Nix `jdtls`
launcher. `lua/plugins/lsp.lua` only adds servers no extra covers (Bash, MATLAB,
Groovy, PowerShell, pylsp) and small overrides; `lua/plugins/formatting.lua`
keeps Alejandra for Nix and Ruff for Python. Add a language by importing its
extra and supplying its tools through Home Manager.

Surround uses mini.surround on the `gs` prefix (`gsa`, `gsd`, `gsr`, `gsf`,
`gsh`), so Flash's `s` jumps without waiting.

`lua/plugins/annotations.lua` restores rendered Markdown, color previews and
context labels at the end of code blocks. Context labels retain the previous
`disable_virtual_lines` setting so they do not insert extra display lines.
Use `:RenderMarkdown toggle`, `:ColorizerToggle` and `:NvimContextVtToggle`
to toggle these displays. Home Manager supplies `latex2text` for Markdown math.
Git integration uses Neogit, Gitsigns and Lazygit;
Fugitive is no longer installed.

The local plugin detects `.inc` as BitBake and `.keymap` as the custom keymap
syntax. `:ArgsToQF` replaces the quickfix list with the current `:args`, keeping
filenames literal, including spaces and punctuation.

Snacks animations are disabled in `lua/config/options.lua`. The Snacks scroll
module is disabled in `lua/plugins/ui.lua` so buffer movement updates immediately.

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

Personal overrides swap `;` and `:` in Normal/Visual mode: `;` enters the
command line and `:` repeats the last character find. Normal `H` / `L` retain
their native top/bottom screen motions; `M` retains the middle motion.
Use `[b` / `]b` for previous/next buffer navigation.

Insert-mode punctuation does not insert LazyVim's extra undo breaks, which
prevent abbreviations such as `,n`, `.u` and `code;` from expanding. Markdown
(`ats`, `#t`, ...) and PowerShell (`nfor`, `code;`) abbreviations are
buffer-local, defined in the `jerry` ftplugins, and expand after a delimiter
such as Space. Trailing whitespace is trimmed on save, except in diffs and
Markdown, where two trailing spaces are a line break.

Conform uses Nix-provided StyLua, Alejandra, shfmt, Ruff, Prettier, goimports
and gofumpt.
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
these untracked files.

Upstream configuration references:
https://www.lazyvim.org/configuration
https://lazy.folke.io/usage/lockfile
