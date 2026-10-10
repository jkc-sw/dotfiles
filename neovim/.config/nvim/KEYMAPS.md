# Shortcut migration to LazyVim defaults

The leader is Space. Old aliases are removed from the shared configuration;
LazyVim supplies its own defaults and Home Manager supplies the equivalents.
Uppercase keys are distinct. This report covers the custom actions and the
Home Manager differences found in the previous audit.

## Relocated actions and restored defaults

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>h/j/k/l | <C-h/j/k/l> | Window navigation |  |
| <leader>U | <leader>su | Undo history | Uses the Snacks undo picker instead of the unavailable UndotreeShow command. |
| <leader>pv | <leader>e / <leader>fe | File explorer | Uses Snacks explorer instead of a netrw split. |
| <C-p> | <leader><space> / <leader>ff | Find files | Normal Ctrl-p returns to native line movement. |
| <leader>po | <leader>fr | Recent files |  |
| <leader>/ (old buffer search) | <leader>sb | Search current-buffer lines | <leader>/ remains project grep. |
| <leader>b | <leader>, / <leader>fb | Buffer picker |  |
| Q | <leader>sw | Search current word / selection | Normal Q returns to native macro replay. |
| <leader>ps | <leader>sg / <leader>/ | Project contents search |  |
| <leader>qf | <leader>sq | Quickfix picker |  |
| <leader>pa | <leader><Tab>d / <leader>qq | Close tab / quit all | Standard tabclose / qa replace force-closing. Hidden unsaved buffers are retained; quitting refuses unsaved work. Closing the last tab does not quit. |
| <leader><C-]> | gd | LSP definition |  |
| <leader>gd | gD | LSP declaration | <leader>gd now opens Git diff hunks. |
| <leader>gf | <leader>cf | Format buffer / selection | <leader>gf now opens current-file Git history. |
| <leader>gD | gI | LSP implementation | <leader>gD now opens the Git diff against origin. |
| <leader>gr | gr | LSP references |  |
| <leader>gR | <leader>cr | LSP rename |  |
| <leader>1gD | gy | LSP type definition |  |
| <leader>ga | <leader>ca | LSP code action |  |
| <leader>K | K | LSP hover | <leader>K now uses keywordprg help. |
| <leader>go | <leader>ss | Document symbols |  |
| <leader>gO | <leader>sd / <leader>sD | Diagnostics list | Uses diagnostics pickers instead of populating a location list. |
| <leader>gs (old LSP health) | <leader>cl | LSP information | Uses the LSP configuration picker. Exact health check remains :checkhealth lsp; <leader>gs is Git status. |
| <leader>gn / <leader>gp | ]e / [e | Next / previous error | Uses default wrapping, counts, and diagnostic floats. <leader>gp is now the open-PR picker. |
| <leader>gN / <leader>gP | ]w / [w | Next / previous warning | Warnings only; use ]e / [e for errors. Default wrapping replaces no-wrap. <leader>gP is now the all-PR picker. |
| <leader>Hh | <leader>ui | Inspect highlight / position |  |
| <C-j> / <C-k> (old quickfix) | ]q / [q | Next / previous quickfix entry | Normal Ctrl-j / Ctrl-k focus windows. Insert Ctrl-k still provides signature help. |
| ; / : (swapped) | : / ; | Command line / repeat character find | Native roles restored in Normal and Visual mode. |
| <C-c> (Insert Esc alias) | <Esc> | Leave Insert normally | Insert Ctrl-c has its native cancellation behavior. |
| n / N (custom centering) | n / N | Next / previous search result | Uses LazyVim's forward/backward semantics and opens folded matches; removes automatic centering. |
| ]c / [c (custom centering) | ]c / [c | Next / previous diff change | Native diff navigation restored; removes automatic centering. |
| <leader>sr (picker resume) | <leader>sR | Resume picker | <leader>sr now opens search and replace through grug-far. |
| <leader>ur (relative numbers) | <leader>uL | Toggle relative numbers | <leader>ur now redraws, clears search highlights, and updates diff. |
| <leader>xq / <leader>xl (Trouble) | <leader>xQ / <leader>xL | Trouble quickfix / location list | Lowercase xq / xl toggle native list windows. |
| <leader>cF (formatter info) | :ConformInfo | Formatter information | <leader>cF now formats embedded languages. |
| <leader>gL (LSP health) | :checkhealth lsp / <leader>cl | LSP health / configuration information | <leader>gL now opens Git log for cwd. |
| <leader>gb (branches) | No retained branch alias | Git line blame at <leader>gb | Branch picker remains callable as :lua Snacks.picker.git_branches(). |
| <leader>w- / <leader>w\| | <leader>- / <leader>\| | Split below / right |  |

## Custom actions retained

These have no matching default shortcut for the exact custom action:

- `<leader>pp`: toggle paste mode.
- `<leader>r`: switch tmux session using tswitch.
- `<leader>,.` / `<leader>,p`: evaluate a Vimscript / Lua line or selection.
- `<leader>T`: send a line or selection to a Neovim terminal.
- `<leader>oe/ou/oa/oo`: repeat a command in another tmux pane/window.
- `<leader>ty/ti/tp`: source marked Lua/Vimscript blocks or mark a region.
- `<leader>gQ`: stop all LSP clients; formerly `<leader>gg`.
- `<leader>Hl`: run the runtime syntax highlight test.
- Visual `<leader>p`: paste register 0 (last yank).
- `<leader>fm`: align a pipe-separated paragraph with Tabular.
- `<leader>te/to/tu/ta/t./t,`: send lines, selections, blocks, or words to tmux.
- `<leader>e*`: Perforce operations, unchanged.
- Markdown buffer shortcuts: journal navigation, snippet copying, timestamped
  entries, fenced-code yanking, and table formatting, unchanged.

The shared global mappings now have descriptions for the keymap picker
(`<leader>sk`). Native `;` and `:` are restored: type `:` to enter commands.

## Remaining differences

- Home Manager uses Nix to manage plugins; it has no lazy.nvim manager at
  `<leader>l`. The LazyVim integrator retains that distribution's manager.
- `<leader>e` shares a prefix with custom Perforce commands. Use
  `<leader>fe` to open the explorer without waiting for the key timeout.
- `<leader>,` shares a prefix with code evaluation and Markdown `<leader>,u`.
  Use `<leader>fb` for an immediate buffer picker.
- Perforce defines `<leader>ep` twice. Its later patch action wins over the
  earlier sync action; this migration leaves that existing behavior unchanged.
- `<leader>pa` no longer force-quits on the last tab. Use `<leader>qq`
  to quit normally, or the explicit `:qa!` command to discard changes.

## Upstream reference

Compared with the LazyVim core, Snacks picker, LSP, formatting, and editor
sources. Optional extras can define additional shortcuts.

https://raw.githubusercontent.com/LazyVim/LazyVim/main/lua/lazyvim/config/keymaps.lua

https://raw.githubusercontent.com/LazyVim/LazyVim/main/lua/lazyvim/plugins/extras/editor/snacks_picker.lua

https://raw.githubusercontent.com/LazyVim/LazyVim/main/lua/lazyvim/plugins/editor.lua

https://raw.githubusercontent.com/LazyVim/LazyVim/main/lua/lazyvim/plugins/lsp/init.lua

https://raw.githubusercontent.com/LazyVim/LazyVim/main/lua/lazyvim/plugins/formatting.lua
