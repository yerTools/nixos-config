return {
  name = "Typst Build/Watch",
  builder = function(params)
    local input = vim.fn.expand("%:p")
    local output = vim.fn.expand("%:p:r") .. ".pdf"
    local action = params.mode or "compile"

    return {
      cmd = "typst",
      args = { action, input, output },
      components = {
        "default",
      },
    }
  end,
  params = {
    mode = {
      type = "enum",
      choices = { "compile", "watch" },
      default = "compile",
      desc = "Run typst compile once or keep typst watch running",
    },
  },
  condition = {
    filetype = { "typst" },
  },
}