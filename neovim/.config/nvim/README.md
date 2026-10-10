# Neovim configuration

The custom configuration lives in the `jerry` and `perforce` plugins and
supports two integrators. Loading either plugin module alone has no effect; an
integrator must call its `.setup()` function.

## Home Manager

Home Manager provides Neovim, language servers, and third-party plugins. The
root `init.lua` is the Home Manager entrypoint and enables the corresponding
feature explicitly:

```lua
require('jerry').setup {
  features = {
    home_manager = true,
  },
}

require('perforce').setup()
```

This feature owns all configuration under `jerry.plugins-cfg`, the custom LSP
configuration, the colorscheme, and the Tree-sitter integration. It expects
those plugins and executables to have been installed by Home Manager.

## LazyVim

LazyVim owns third-party plugins and LSP servers through lazy.nvim and Mason;
mise provides standalone executables. `lua/plugins/jerry.lua` is a LazyVim
plugin spec that loads both local plugins and calls their setup functions. The
shared `jerry` plugin is configured without the Home Manager feature:

```lua
require('jerry').setup()
require('perforce').setup()
```

This enables the shared custom options, keymaps, autocommands, filetype
support, and Lua utilities without applying the Home Manager plugin or LSP
configuration.

### Home Manager editing profile

With `features.home_manager = true`, the editor uses LazyVim-style defaults:
relative line numbers, a visible sign column, two-space indentation, Snacks
pickers and explorer, a dashboard, bufferline, which-key hints, Gitsigns,
Flash, Trouble, Todo comments, mini.ai, mini.pairs, and Persistence sessions.
Gruvbox Material, the shared custom tools, MATLAB, Perforce, and the `toclip`
integration are retained. These third-party setups are never applied by the
LazyVim integrator.

Home Manager supplies all plugins and executables through Nix. There is no
lazy.nvim or Mason bootstrap in this profile. Telescope remains available for
the custom pickers, while Snacks owns `vim.ui.select` and the main search keys.
Blink completion uses Enter to accept a selection and includes LazyDev support.

Useful keys (the leader is Space):

| Keys | Action |
| --- | --- |
| `<leader><space>`, `<leader>ff` | Find files at the LSP/Git root |
| `<leader>fF`, `<leader>sG` | Find files / grep in the current directory |
| `<leader>/`, `<leader>sg` | Grep at the LSP/Git root |
| `<leader>,`, `<leader>fb` | Buffers |
| `<leader>e`, `<leader>E` | Explorer at the root / current directory |
| `<S-h>`, `<S-l>`, `[b`, `]b` | Previous / next buffer |
| `<leader>bd`, `<leader>bo` | Delete buffer / other buffers, preserving splits |
| `<C-h/j/k/l>`, `<leader>-`, `<leader>\|` | Window navigation and splits |
| `s`, `S` | Flash jump / Tree-sitter selection |
| `<leader>gg`, `<leader>gs`, `<leader>gh*` | Lazygit, Git status, hunk actions |
| `gd`, `gr`, `gI`, `gy`, `K` | LSP navigation and hover |
| `<leader>ca`, `<leader>cr`, `<leader>cf` | Code actions, rename, format |
| `<leader>xx`, `<leader>xX`, `[d`, `]d` | Diagnostics and navigation |
| `<leader>qs`, `<leader>qS`, `<leader>ql` | Restore / select / last session |
| `<leader>ft`, `<C-/>` | Terminal at the project root |
| `<leader>uf`, `<leader>uF` | Toggle global / buffer autoformat |

Custom aliases now use LazyVim's default shortcuts whenever there is an
alternative. The complete before/after report is in `KEYMAPS.md`. For example,
formatting uses `<leader>cf`, declaration uses `gD`, recent files use
`<leader>fr`, and closing a tab uses `<leader><Tab>d`. The old `<leader>pa`
force-close alias is removed; the default tab command respects unsaved work.
Normal `;` and `:` have their native meanings again. Undo history is
`<leader>su`, picker resume is `<leader>sR`, relative numbers are `<leader>uL`,
and search/replace is `<leader>sr` through grug-far.

Unique custom sourcing, tmux, Perforce, journal, and register-0 paste actions
remain available. Shared global mappings have descriptions for `<leader>sk`.
The `<leader>gQ` stop-LSP action remains custom. Use `<leader>fe` and
`<leader>fb` to avoid the prefix waits caused by longer custom `<leader>e*`
and `<leader>,*` sequences.

Conform formats on save using StyLua, Alejandra, shfmt, Ruff, or prettierd
according to filetype, falling back to an attached LSP formatter. The Nix
module supplies these tools. `:ConformInfo` shows the active formatter.
The shared Lua save formatter is disabled in this profile to avoid formatting
twice; `:LuaFormat`, `:LuaLint`, and Luacheck diagnostics remain available.
Use either autoformat toggle to pause formatting. Sessions, undo data, and
picker history live under Neovim's XDG data/state directories, outside this
repository. Keep machine-specific credentials in environment variables or
ignored local overrides, never in plugin configuration.

## Lua tooling

The shared configuration uses:

- [StyLua](https://github.com/JohnnyMorganz/StyLua) for formatting;
- [Luacheck](https://github.com/lunarmodules/luacheck) for linting; and
- `lua-language-server` plus `lazydev.nvim` for Neovim API completion and type
  information.

Install the executables through Home Manager or mise. StyLua formats Lua
buffers before they are written; Luacheck publishes diagnostics on buffer
entry and after each write. Use `:LuaFormat` or `:LuaLint` to run either action
manually. Project policies live in `.stylua.toml` and `.luacheckrc`.
