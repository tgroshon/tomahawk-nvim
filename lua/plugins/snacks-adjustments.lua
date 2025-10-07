return {
  "folke/snacks.nvim",
  keys = {
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
