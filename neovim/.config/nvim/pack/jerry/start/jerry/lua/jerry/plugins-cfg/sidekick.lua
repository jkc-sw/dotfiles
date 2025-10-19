-- Setup
require("sidekick").setup({
  -- add any options here
  cli = {
    mux = {
      backend = "tmux",
      enabled = true,
    },
  },
})

-- Keymaps
local map = vim.keymap.set

-- If there is a next edit, jump to it, otherwise return <Tab>
map({ "n", "i" }, "<Tab>", function()
  if not require("sidekick").nes_jump_or_apply() then
    return "<Tab>"
  end
end, { expr = true, desc = "Goto/Apply Next Edit Suggestion" })

-- Sidekick Toggle (CLI)
map({ "n", "t", "i", "x" }, "<C-.>", function()
  require("sidekick.cli").toggle()
end, { desc = "Sidekick Toggle" })

-- Sidekick Toggle CLI (same as above but on <leader>aa)
map("n", "<leader>aa", function()
  require("sidekick.cli").toggle()
end, { desc = "Sidekick Toggle CLI" })

-- Select CLI
map("n", "<leader>as", function()
  require("sidekick.cli").select()
  -- Or only installed:
  -- require("sidekick.cli").select({ filter = { installed = true } })
end, { desc = "Select CLI" })

-- Detach/Close a CLI Session
map("n", "<leader>ad", function()
  require("sidekick.cli").close()
end, { desc = "Detach a CLI Session" })

-- Send This
map({ "x", "n" }, "<leader>at", function()
  require("sidekick.cli").send({ msg = "{this}" })
end, { desc = "Send This" })

-- Send File
map("n", "<leader>af", function()
  require("sidekick.cli").send({ msg = "{file}" })
end, { desc = "Send File" })

-- Send Visual Selection
map("x", "<leader>av", function()
  require("sidekick.cli").send({ msg = "{selection}" })
end, { desc = "Send Visual Selection" })

-- Prompt
map({ "n", "x" }, "<leader>ap", function()
  require("sidekick.cli").prompt()
end, { desc = "Sidekick Select Prompt" })

-- Example: open Claude directly
map("n", "<leader>ac", function()
  require("sidekick.cli").toggle({ name = "claude", focus = true })
end, { desc = "Sidekick Toggle Claude" })
