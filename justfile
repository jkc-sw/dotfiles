set shell := ["bash", "-ueo", "pipefail", "-c"]

test_neovim_date_resolver:
    nvim --headless -c "lua R('jerry.date_resolver').run_tests()" -c 'q'; cat result
