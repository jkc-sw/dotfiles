
# Neovim configuration

I want this neovim configuration to support 2 dotfiles integrations, which I call integrators: one is to integrate with home-manager which provides neovim executable, language-server executables and neovim plugins; another is to integrate with lazyvim distribution which uses mason.nvim, lazy.nvim and mise to fetch plugins and executables.

For all third-party plugin configurations will be home-manager specific, and should be enabled by setting a specific feature flag.

All the custom options, keymaps, lua configurations/plugins implemented here should be avaliable as a plugin and be enabled with `.setup()` call by the integrator.
