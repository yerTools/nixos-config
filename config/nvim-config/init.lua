local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 and not string.find(vim.env.PATH or "", mason_bin, 1, true) then
	vim.env.PATH = mason_bin .. ":" .. (vim.env.PATH or "")
end

-- Compatibility helper: provide :LspInfo even when plugin command names change.
vim.api.nvim_create_user_command("LspInfo", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	if #clients == 0 then
		vim.notify("Keine LSP-Clients im aktuellen Buffer. Nutze :checkhealth vim.lsp fuer Details.", vim.log.levels.WARN)
		return
	end

	local lines = { "Aktive LSP-Clients:" }
	for _, client in ipairs(clients) do
		table.insert(lines, string.format("- %s", client.name))
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "Show active LSP clients for current buffer" })

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
