set shell := ["bash", "-ueo", "pipefail", "-c"]

test_neovim_abbreviations:
    #!/usr/bin/env bash
    set -euo pipefail
    config_dir="$(mktemp -d)"
    trap 'rm -rf "$config_dir"' EXIT
    ln -s '{{justfile_directory()}}/neovim/.config/nvim' "$config_dir/nvim"
    XDG_CONFIG_HOME="$config_dir" nvim --headless -c "luafile {{justfile_directory()}}/neovim/tests/abbreviations.lua"

test_neovim_recovery:
    #!/usr/bin/env bash
    set -euo pipefail
    config_dir="$(mktemp -d)"
    trap 'rm -rf "$config_dir"' EXIT
    ln -s '{{justfile_directory()}}/neovim/.config/nvim' "$config_dir/nvim"
    mkdir "$config_dir/fixtures"
    printf 'DESCRIPTION = "fixture"\n' > "$config_dir/fixtures/startup.inc"
    XDG_CONFIG_HOME="$config_dir" NVIM_TEST_FIXTURES="$config_dir/fixtures" nvim --headless "$config_dir/fixtures/startup.inc" -c "luafile {{justfile_directory()}}/neovim/tests/recovery.lua"

test_neovim_date_resolver:
    nvim --headless -c "lua R('jerry.date_resolver').run_tests()" -c 'q'; cat result
