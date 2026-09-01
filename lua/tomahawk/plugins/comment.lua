return {
	{
		"numToStr/Comment.nvim",
		commit = "e30b7f2008e52442154b66f7c519bfd2f1e32acb",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		enabled = vim.fn.has("nvim-0.10.0") == 1,
		opts = {},
	},
}
