return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "bash",
      "css",
      "html",
      "javascript",
      "latex",
      "lua",
      "norg",
      "regex",
      "scss",
      "svelte",
      "tsx",
      "typst",
      "vue",
    },
    indent = {
      enable = true,
      disable = { "typescript", "tsx", "javascript" },
    },
  },
}
