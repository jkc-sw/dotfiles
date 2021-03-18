
local M = {}

M.find_dotfiles = function()
    require("telescope.builtin").find_files({
        prompt_title = "< dotfiles >",
        cwd = "$HOME/repos/dotfiles",
        find_command = vim.split(vim.env.FZF_DEFAULT_COMMAND, ' ')
    })
end

return M

-- vim:et ts=2 sw=2
