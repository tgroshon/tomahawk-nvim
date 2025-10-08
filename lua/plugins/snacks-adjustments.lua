return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>sp", LazyVim.pick("live_grep"), desc = "Grep Project" },
    { "<leader>pf", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    {
      "<leader>bb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffers",
    },
  },
  opts = {
    scroll = {
      enabled = false, -- Disable scrolling animations
    },
  },
}
