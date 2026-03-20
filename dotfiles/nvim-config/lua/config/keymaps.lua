-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Terminal mappings
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true })

-- Normal mappings
vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer", silent = true })

-- tmux-sessionizer mappings
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")
vim.keymap.set("n", "<M-t>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>")
vim.keymap.set("n", "<M-n>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>")
vim.keymap.set("n", "<M-s>", "<cmd>silent !tmux neww tmux-sessionizer -s 3<CR>")

-- Visual mappings
vim.keymap.set("v", "<leader>csl", ":sort<CR>", { desc = "Sort lines", silent = true })

-- Typst mappings
vim.keymap.set("n", "<leader>tc", function()
	require("overseer").run_template({
		name = "Typst Build/Watch",
		params = { mode = "compile" },
	})
end, { desc = "Typst: Compile", silent = true })

vim.keymap.set("n", "<leader>tw", function()
	require("overseer").run_template({
		name = "Typst Build/Watch",
		params = { mode = "watch" },
	})
end, { desc = "Typst: Watch", silent = true })
