return {
  {
    "tris203/precognition.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>uh",
        function()
          require("precognition").toggle()
        end,
        desc = "Toggle motion hints",
      },
    },
  },
}
