-- Clipboard autocmd
local toClipBoard = vim.api.nvim_create_augroup("toClipBoard", { clear = true })
if #vim.g.clip_supplier > 0 then
    vim.api.nvim_create_autocmd("TextYankPost", {
        group = toClipBoard,
        pattern = "*",
        callback = function()
            local event = vim.v.event
            if event.operator == "y" and event.regname == "" then
                local ret = vim.fn.system(vim.g.clip_supplier, vim.fn.getreg('"'))
                if vim.g.toclip_verbose then
                    vim.api.nvim_echo({
                        { table.concat(vim.g.clip_supplier, " ") .. " (" .. vim.v.shell_error .. "): " .. ret }
                    }, false, {})
                end
            end
        end,
    })
else
    vim.api.nvim_echo({
        { "No clipboard tool found. Need to be toclip, win32yank.exe or clip.exe", "WarningMsg" }
    }, false, {})
end

-- Trim whitespace on save
vim.api.nvim_create_augroup("nowhitespaceattheend", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
    group = "nowhitespaceattheend",
    pattern = "*",
    callback = function()
        vim.fn["jerry#common#TrimWhitespace"]()
    end,
})

-- Highlight on yank
vim.api.nvim_create_augroup("LuaHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = "LuaHighlight",
    pattern = "*",
    callback = function()
        pcall(function() require("vim.hl").on_yank() end)
    end,
})

-- indentConfig
vim.api.nvim_create_augroup("indentConfig", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
    group = "indentConfig",
    pattern = "*",
    callback = function()
        vim.cmd [[iabbrev vimet vim:et ts=4 sts=4 sw=4]]
    end,
})

-- markdownFenceHighlight
vim.api.nvim_create_augroup("markdownFenceHighlight", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
    group = "markdownFenceHighlight",
    pattern = "*.md",
    callback = function()
        vim.cmd [[
            iabbrev ats <c-r>=strftime('%Y-%m-%d %A')<cr>
            iabbrev #T # <c-r>=strftime('%Y-%m-%d %A')<cr>
            iabbrev #t # <c-r>=strftime('%Y-%m-%d %A')<cr>
            iabbrev ##T ## <c-r>=strftime('%Y-%m-%d %A')<cr>
            iabbrev ##t ## <c-r>=strftime('%Y-%m-%d %A')<cr>
            iabbrev ###T ### <c-r>=strftime('%Y-%m-%d %A')<cr>
            iabbrev ###t ### <c-r>=strftime('%Y-%m-%d %A')<cr>
            iabbrev ####T #### <c-r>=strftime('%Y-%m-%d %A')<cr>
            iabbrev ####t #### <c-r>=strftime('%Y-%m-%d %A')<cr>
            let g:markdown_fenced_languages += ['python', 'ps1', 'cpp', 'bash', 'vim', 'matlab']
            silent! exec 'edit'
        ]]
    end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
    group = "markdownFenceHighlight",
    pattern = "*.ps1",
    callback = function()
        vim.cmd [[
            iabbrev nfor <c-r>=jerry#common#JiraNoFormat()<cr><up>
            iabbrev code; <c-r>=jerry#common#JiraCodeFormat()<cr><up>
        ]]
    end,
})

-- sourcerTheseCode
vim.api.nvim_create_augroup("sourcerTheseCode", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
    group = "sourcerTheseCode",
    pattern = "*",
    callback = function()
        vim.cmd [[
            iabbrev tit SOURCE_THESE_VIMS_START<cr><cr>echom 'Sourced'<cr>SOURCE_THESE_VIMS_END<Up><Up>
            iabbrev tyt SOURCE_THESE_LUAS_START<cr><cr>print('Sourced')<cr>SOURCE_THESE_LUAS_END<Up><Up>
        ]]
    end,
})

-- markerTheseCode
vim.api.nvim_create_augroup("markerTheseCode", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
    group = "markerTheseCode",
    pattern = "*",
    callback = function()
        vim.cmd [[iabbrev tpt MARK_THIS_PLACE]]
    end,
})

-- DisableSomeSyntax
vim.api.nvim_create_augroup("DisableSomeSyntax", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
    group = "DisableSomeSyntax",
    pattern = { "*.groovy", "*.html" },
    command = "syntax sync fromstart",
})
