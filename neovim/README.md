# Neovim

Shared Neovim plugins and the Home Manager configuration live in `.config/nvim`.
The laptop's LazyVim configuration consumes the shared plugins from its separate
chezmoi checkout.

Preview changes in isolated, persistent Docker containers:

```sh
bash neovim/tests/start-arch.sh /path/to/dotfiles2026
bash neovim/tests/start-home-manager.sh
```

See [the container guide](tests/README.md) for prerequisites, interactive shells,
refreshing configuration, rerunning checks, and cleanup. These commands do not
activate Home Manager or change the host's editor configuration.
