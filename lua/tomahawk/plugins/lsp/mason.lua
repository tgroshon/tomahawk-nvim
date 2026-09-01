return {
	-- mason.nvim moved orgs: williamboman/* -> mason-org/*. Mason 2.x also dropped
	-- mason-lspconfig's `setup_handlers()`; per-server settings now live in
	-- `vim.lsp.config()` calls in lspconfig.lua.
	"mason-org/mason.nvim",
	commit = "2a6940af80375532e5e9e7c1f2fc6319a1b7a69d",
	dependencies = {
		{ "mason-org/mason-lspconfig.nvim", commit = "40276c4df7e6bdce6801d6c035c6227f9115a855" },
		{ "WhoIsSethDaniel/mason-tool-installer.nvim", commit = "443f1ef8b5e6bf47045cb2217b6f748a223cf7dc" },
		-- mason-lspconfig 2.x calls vim.lsp.enable() for installed servers, which needs
		-- nvim-lspconfig's `lsp/` directory on the runtimepath. Declaring it here also
		-- guarantees lspconfig.lua's config (capabilities + per-server settings) has
		-- already run by the time anything is enabled below.
		"neovim/nvim-lspconfig",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"clangd",
				"cssls",
				"emmet_ls",
				"graphql",
				"html",
				"lua_ls",
				"prismals",
				"pyright",
				"ruby_lsp",
				"svelte",
				"tailwindcss",
				"terraformls",
				"ts_ls",
			},
			-- Installed servers are enabled automatically. Elixir is served by Expert
			-- alone, enabled by hand in lua/tomahawk/core/init.lua, so every Elixir
			-- server is excluded here: that is what stops a second one ever starting
			-- alongside Expert. This list replaces the empty `setup_handlers` entries
			-- that used to do the same job -- do not remove it.
			automatic_enable = {
				exclude = {
					"elixirls",
					"expert",
					"lexical",
					"nextls",
				},
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"clang-format", -- c/c++ formatter
				"expert", -- elixir language server (installed here, not via mason-lspconfig,
				-- so that mason-lspconfig's automatic_enable never starts a second copy)
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				-- "isort", -- python formatter
				-- "black", -- python formatter
				-- "pylint",
				"eslint_d",
			},
		})
	end,
}
