# Shortcut migration to LazyVim defaults

The leader is Space. Old aliases are removed from the shared configuration;
LazyVim supplies its own defaults and Home Manager supplies the equivalents.
Uppercase keys are distinct. This report covers the custom actions and the
Home Manager differences found in the previous audit.

## Find shortcuts by category

Open `<leader>sk` (Space s k), then search a category name or an action.
The list includes a category column and sorts by category when the query is
empty. Shared custom mappings, including tmux, Perforce, and Markdown buffer
mappings, also show `Category: action` in which-key. Existing key sequences
and actions are unchanged by this categorization.

## Relocated actions and restored defaults

### Appearance

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>ur (relative numbers) | <leader>uL | Toggle relative numbers | <leader>ur now redraws, clears search highlights, and updates diff. |

### Buffers

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>b | <leader>, / <leader>fb | Buffer picker |  |

### Diagnostics

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>gO | <leader>sd / <leader>sD | Diagnostics list | Uses diagnostics pickers instead of populating a location list. |
| <leader>gn / <leader>gp | ]e / [e | Next / previous error | Uses default wrapping, counts, and diagnostic floats. <leader>gp is now the open-PR picker. |
| <leader>gN / <leader>gP | ]w / [w | Next / previous warning | Warnings only; use ]e / [e for errors. Default wrapping replaces no-wrap. <leader>gP is now the all-PR picker. |

### Editing

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| ; / : (swapped) | : / ; | Command line / repeat character find | Native roles restored in Normal and Visual mode. |
| <C-c> (Insert Esc alias) | <Esc> | Leave Insert normally | Insert Ctrl-c has its native cancellation behavior. |

### Files

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>pv | <leader>e / <leader>fe | File explorer | Uses Snacks explorer instead of a netrw split. |
| <C-p> | <leader><space> / <leader>ff | Find files | Normal Ctrl-p returns to native line movement. |
| <leader>po | <leader>fr | Recent files |  |

### Formatting

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>gf | <leader>cf | Format buffer / selection | <leader>gf now opens current-file Git history. |
| <leader>cF (formatter info) | :ConformInfo | Formatter information | <leader>cF now formats embedded languages. |

### Git

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>gb (branches) | No retained branch alias | Git line blame at <leader>gb | Branch picker remains callable as :lua Snacks.picker.git_branches(). |

### Highlights

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>Hh | <leader>ui | Inspect highlight / position |  |

### LSP

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader><C-]> | gd | LSP definition |  |
| <leader>gd | gD | LSP declaration | <leader>gd now opens Git diff hunks. |
| <leader>gD | gI | LSP implementation | <leader>gD now opens the Git diff against origin. |
| <leader>gr | gr | LSP references |  |
| <leader>gR | <leader>cr | LSP rename |  |
| <leader>1gD | gy | LSP type definition |  |
| <leader>ga | <leader>ca | LSP code action |  |
| <leader>K | K | LSP hover | <leader>K now uses keywordprg help. |
| <leader>go | <leader>ss | Document symbols |  |
| <leader>gs (old LSP health) | <leader>cl | LSP information | Uses the LSP configuration picker. Exact health check remains :checkhealth lsp; <leader>gs is Git status. |
| <leader>gL (LSP health) | :checkhealth lsp / <leader>cl | LSP health / configuration information | <leader>gL now opens Git log for cwd. |

### Navigation

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| ]c / [c (custom centering) | ]c / [c | Next / previous diff change | Native diff navigation restored; removes automatic centering. |

### Quickfix

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>qf | <leader>sq | Quickfix picker |  |
| <C-j> / <C-k> (old quickfix) | ]q / [q | Next / previous quickfix entry | Normal Ctrl-j / Ctrl-k focus windows. Insert Ctrl-k still provides signature help. |
| <leader>xq / <leader>xl (Trouble) | <leader>xQ / <leader>xL | Trouble quickfix / location list | Lowercase xq / xl toggle native list windows. |

### Search

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>/ (old buffer search) | <leader>sb | Search current-buffer lines | <leader>/ remains project grep. |
| Q | <leader>sw | Search current word / selection | Normal Q returns to native macro replay. |
| <leader>ps | <leader>sg / <leader>/ | Project contents search |  |
| n / N (custom centering) | n / N | Next / previous search result | Uses LazyVim's forward/backward semantics and opens folded matches; removes automatic centering. |
| <leader>sr (picker resume) | <leader>sR | Resume picker | <leader>sr now opens search and replace through grug-far. |

### Tabs

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>pa | <leader><Tab>d / <leader>qq | Close tab / quit all | Standard tabclose / qa replace force-closing. Hidden unsaved buffers are retained; quitting refuses unsaved work. Closing the last tab does not quit. |

### Undo

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>U | <leader>su | Undo history | Uses the Snacks undo picker instead of the unavailable UndotreeShow command. |

### Windows

| Previous binding | Use now | Action | Behavior change |
| --- | --- | --- | --- |
| <leader>h/j/k/l | <C-h/j/k/l> | Window navigation |  |
| <leader>w- / <leader>w\| | <leader>- / <leader>\| | Split below / right |  |

## Custom actions retained

These 52 key sequences have no matching default for the exact action.
Normal and Visual variants are combined; Markdown mappings apply only in
Markdown buffers. Categories describe the action even when a prefix is shared.

### Evaluation

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space ,. | Normal / Visual | Evaluate Vimscript line / Evaluate Vimscript selection |
| Space ,p | Normal / Visual | Evaluate Lua line / Evaluate Lua selection |

### Formatting

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space fm | Normal | Align pipe-separated paragraph |
| Space tf | Normal / Visual · Markdown | Format markdown table under cursor / Format selection as markdown table |

### Highlights

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space Hl | Normal | Show syntax highlight test |

### Journal

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space ,u | Normal · Markdown | Copy line to timestamped journal entry |
| Space .b | Normal · Markdown | Insert timestamped break entry |
| Space .u | Normal · Markdown | Insert timestamped journal entry |
| Space th | Normal · Markdown | Jump to previous journal heading |
| Space tn | Normal · Markdown | Jump to next journal heading |

### LSP

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space gQ | Normal | Stop all LSP clients |

### Paste

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space p | Visual | Paste last yank (register 0) |
| Space pp | Normal | Toggle paste mode |

### Perforce

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space ea | Normal | Add current file to Perforce |
| Space eA | Normal | Show Perforce history |
| Space eb | Normal | Show Perforce blame |
| Space ec | Normal | Submit changelist and close subtasks |
| Space eC | Normal | Submit changelist and close subtasks |
| Space ed | Normal | Get Perforce diff |
| Space eD | Normal | Filter Perforce diff output |
| Space ee | Normal | Open current file for Perforce edit |
| Space ef | Normal | Turn diff off and force-close windows |
| Space el | Normal | List pending changelists |
| Space en | Normal | Get changelist with Jira tags |
| Space eN | Normal | New changelist spec in a tab |
| Space eo | Normal | Picker for opened Perforce files |
| Space eO | Normal | Show p4 opened output |
| Space ep | Normal | Create patch from edited files |
| Space eR | Normal | Revert current file in Perforce |
| Space es | Normal | Shelve Perforce spec from buffer |
| Space eS | Normal | Submit Perforce spec from buffer |
| Space eu | Normal | Remove current diff entry |

### Snippets

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space ne | Normal · Markdown | Yank fenced code contents |
| Space pf | Normal · Markdown | Copy Vim jump snippet |
| Space ph | Normal · Markdown | Copy shell jump snippet |
| Space pn | Normal · Markdown | Copy single-line jump snippet |
| Space pt | Normal · Markdown | Copy multiline jump snippet |

### Sourcing

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space ti | Normal | Source marked Vimscript block |
| Space ty | Normal | Source marked Lua block |

### Terminal

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space T | Normal / Visual | Send line to Neovim terminal / Send selection to Neovim terminal |

### Text tools

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space tp | Normal | Mark text region |

### Tmux

| Binding | Mode / scope | Action |
| --- | --- | --- |
| Space oa | Normal | Repeat command in previous tmux window |
| Space oe | Normal | Repeat command in next tmux pane |
| Space oo | Normal | Repeat command in next tmux window |
| Space ou | Normal | Repeat command in previous tmux pane |
| Space r | Normal | Switch tmux session |
| Space t, | Normal | Send WORD to previous tmux pane |
| Space t. | Normal | Send WORD to next tmux pane |
| Space ta | Normal | Send text block to previous tmux pane |
| Space te | Normal / Visual | Send line / selection to next tmux pane |
| Space to | Normal / Visual | Send line / selection to previous tmux pane |
| Space tu | Normal | Send text block to next tmux pane |

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
