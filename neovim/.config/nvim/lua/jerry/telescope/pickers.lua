
local M = {}

M.vimrc_files = function()
    require("telescope.builtin").find_files({
        prompt_title = "< VimRC >",
        cwd = "$HOME/repos/dotfiles/neovim/.config/nvim",
    })
end

return M

-- vim:et ts=2 sw=2
