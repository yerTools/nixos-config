return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts = opts or {}
      opts.servers = opts.servers or {}

      local util = require("lspconfig.util")
      opts.servers.tinymist = vim.tbl_deep_extend("force", opts.servers.tinymist or {}, {
        single_file_support = true,
        root_dir = function(fname)
          return util.root_pattern("typst.toml", ".git")(fname) or vim.fs.dirname(fname)
        end,
      })

      local grammar_server = {
        filetypes = { "typst", "markdown", "text", "gitcommit" },
        settings = {
          ltex = {
            language = "auto",
            enabled = { "typst", "markdown", "text", "gitcommit" },
            additionalRules = {
              motherTongue = "de-DE",
              enablePickyRules = false,
            },
          },
        },
      }

      if pcall(require, "lspconfig.server_configurations.ltex_plus") then
        grammar_server.cmd = { "ltex-cli-plus" }
        opts.servers.ltex_plus = vim.tbl_deep_extend("force", opts.servers.ltex_plus or {}, grammar_server)
      elseif pcall(require, "lspconfig.server_configurations.ltex") then
        grammar_server.cmd = { "ltex-ls" }
        opts.servers.ltex = vim.tbl_deep_extend("force", opts.servers.ltex or {}, grammar_server)
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        typst = { "typstyle" },
      },
      formatters = {
        typstyle = {
          command = "typstyle",
          stdin = true,
        },
      },
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == "typst" then
          return { timeout_ms = 500, lsp_fallback = true }
        end
      end,
    },
  },
  {
    "chomosuke/typst-preview.nvim",
    version = "1.*",
    ft = "typst",
    cmd = { "TypstPreview", "TypstPreviewStop" },
    keys = {
      { "<leader>tp", "<cmd>TypstPreview<cr>", desc = "Typst: Preview" },
    },
    opts = {},
  },
}