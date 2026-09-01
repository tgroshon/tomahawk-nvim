require("tomahawk.core.options")
require("tomahawk.core.keymaps")

-- Setup Expert - Elixir Language Server
vim.lsp.config("expert", {
	cmd = { "expert", "--stdio" },
	root_markers = { "mix.exs", ".git" },
	filetypes = { "elixir", "eelixir", "heex" },
})

vim.lsp.enable("expert")

-- Ensure Tree-sitter highlighting is enabled for Elixir files
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "elixir", "eelixir", "heex" },
	callback = function()
		vim.treesitter.start()
	end,
})
