# Isolated Neovim previews

Run these commands from the shared dotfiles checkout. Docker and network access
are required. Arch also needs the laptop's chezmoi source checkout. Ubuntu needs
an existing Home Manager generation containing Neovim's plugin pack, a user
profile with Neovim and its tools, and the host's `/nix` store.

```sh
bash neovim/tests/start-arch.sh /path/to/dotfiles2026
bash neovim/tests/start-home-manager.sh
```

The launchers create persistent containers named `nvim-lazyvim-arch` and
`nvim-home-manager-ubuntu`, install their prerequisites, and run integration
checks. They refuse to replace an existing container. Choose another name with
`NVIM_PREVIEW_NAME=my-nvim-preview bash neovim/tests/start-home-manager.sh`.
If setup fails, the container remains available for inspection and a setup retry.

The source checkout is mounted read-only at `/source`; Arch also mounts the
chezmoi checkout at `/chezmoi-source`, and Ubuntu mounts `/nix` read-only.
Configuration, editor state, plugins downloaded by LazyVim/Mason, and samples
live inside the containers. Nothing activates Home Manager or builds Nix packages.

## Try the editors

```sh
docker exec -it -w /root/workspace nvim-lazyvim-arch bash -l
docker exec -it -w /root/workspace nvim-home-manager-ubuntu bash -l
```

Inside either shell, run `nvim sample.lua` or `nvim journal.md`. Try formatting,
Lua diagnostics, Markdown date abbreviations, custom mappings, and the file
picker. Replace the container name in all commands if you chose a custom name.

Arch uses the laptop's rendered LazyVim configuration and lockfile. It selects
Lua 5.1 for LuaRocks because Mason's Luacheck 1.1.0 cannot use Arch's default
Lua 5.5. An empty Omarchy theme fixture selects LazyVim's fallback theme; desktop
theme generation is outside this preview.

Ubuntu resolves the current Home Manager generation from
`${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager`, falling back to
`/nix/var/nix/profiles/per-user/$USER/home-manager`. It resolves `~/.nix-profile`
for executables. It copies the generation's plugin pack, preserves generated
Lua package paths and provider flags, and runs this checkout's configuration
instead of its old Nix source copy. These resolved store paths are fixed when
the container starts; create a fresh container after changing the host generation.

## Refresh after editing

Host changes are visible in the read-only mounts, but active configurations are
copies. Close open editor sessions, then refresh and rerun checks:

```sh
docker exec nvim-lazyvim-arch bash /source/neovim/tests/inside-arch-container.sh
docker exec nvim-home-manager-ubuntu bash /source/neovim/tests/inside-home-manager-container.sh
```

These repeat setup, reset sample files, and (for Arch) restore the LazyVim
lockfile. For deleted configuration files, recreate the container to get a clean
copy. Start a new `nvim` process to load the refreshed configuration.

## Rerun checks without refreshing

Both setups run `shared.lua`, `legacy.lua`, and `perforce.lua`; Arch additionally
runs `lazyvim.lua`, while Ubuntu runs `home-manager.lua` and `file-picker.lua`.
The integration checks exercise real formatting, diagnostics, and language-server
attachment. Perforce uses a fake executable and does not contact a server.

In either container's login shell, run the shared checks with:

```sh
cd /tmp
for test in shared legacy perforce; do
  nvim --headless -u NONE -l "/source/neovim/tests/$test.lua"
done
```

For integration checks, run this in the Ubuntu login shell (use `lazyvim` as the
only loop value in Arch):

```sh
cd /tmp
for test in home-manager file-picker; do
  rm -f "/tmp/jerry-$test-result"
  timeout 120 nvim --headless "+lua vim.defer_fn(function() local ok, err = pcall(dofile, '/source/neovim/tests/$test.lua'); if not ok then io.stderr:write(tostring(err), string.char(10)); vim.cmd('cquit 1') else vim.cmd('qa!') end end, 1000)"
  cat "/tmp/jerry-$test-result"
done
```

Results are written to `/tmp/jerry-lazyvim-result`,
`/tmp/jerry-home-manager-result`, and `/tmp/jerry-file-picker-result` in their
respective containers. Check the command's exit status as well as its result file.

## Cleanup

Remove only previews you no longer need; this deletes their writable state:

```sh
docker rm -f nvim-lazyvim-arch nvim-home-manager-ubuntu
```

For the original disposable Ubuntu/LazyVim check, which removes its container
on exit, use `bash neovim/tests/container.sh /path/to/dotfiles2026`.
