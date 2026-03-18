-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local typst_group = vim.api.nvim_create_augroup("typst_local_options", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = typst_group,
	pattern = "typst",
	callback = function()
		vim.opt_local.textwidth = 100
		vim.opt_local.colorcolumn = "100"
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "de,en"
	end,
})
