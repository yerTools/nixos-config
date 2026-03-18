return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = opts.ensure_installed or {}

      local wanted = {
        "vtsls",
        "eslint-lsp",
        "eslint_d",
        "prettier",
        "gopls",
        "goimports",
        "lua-language-server",
        "stylua",
        "tinymist",
        "marksman",
      }

      for _, tool in ipairs(wanted) do
        if not vim.tbl_contains(opts.ensure_installed, tool) then
          table.insert(opts.ensure_installed, tool)
        end
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts = opts or {}
      opts.servers = opts.servers or {}

      -- nil is installed via Nix; ensure Nix files still get LSP even without Mason.
      opts.servers.nil_ls = opts.servers.nil_ls or {
        cmd = { "nil" },
      }
    end,
  },
}
