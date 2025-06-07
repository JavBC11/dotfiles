vim.g.mapleader = " "
--vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- NvimTree
vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<C-h>", vim.cmd.NvimTreeFocus)

-- Exit vim, save file & source
vim.keymap.set("n", "<leader>q", vim.cmd.exit)
vim.keymap.set("n", "<C-s>", vim.cmd.write)
vim.keymap.set("n", "<leader><leader>", vim.cmd.source)
