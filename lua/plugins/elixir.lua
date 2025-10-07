return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and elixir to treesitter
      vim.list_extend(opts.ensure_installed, {
        "tsx",
        "typescript",
        "elixir",
        "heex",
        "eex",
        "graphql",
      })
      vim.treesitter.language.register("markdown", "livebook")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        expert = {},
      },
    },
  },
}
