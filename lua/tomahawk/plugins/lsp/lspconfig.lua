return {
	"neovim/nvim-lspconfig",
	commit = "16286347bdba1333c7d124d9de9fe6630731b2b2",
	-- Not lazy-loaded: mason.lua depends on this plugin so that mason-lspconfig can
	-- enable installed servers, which pulls it in at startup anyway.
	dependencies = {
		{ "hrsh7th/cmp-nvim-lsp", commit = "cbc7b02bb99fae35cb42f514762b89b5126651ef" },
		{
			"antosha417/nvim-lsp-file-operations",
			config = true,
			commit = "b9c795d3973e8eec22706af14959bc60c579e771",
		},
		-- Replaces the deprecated folke/neodev.nvim, which hooked lspconfig's old
		-- `.setup()` path and is inert now that servers are configured with
		-- vim.lsp.config.
		{
			"folke/lazydev.nvim",
			commit = "ff2cbcba459b637ec3fd165a2be59b7bbaeedf0d",
			ft = "lua",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
	},
	config = function()
		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>mx", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "<leader>mk", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>mr", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer errors "
				keymap.set("n", "<leader>el", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "<leader>ep", function()
					vim.diagnostic.jump({ count = -1 })
				end, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "<leader>en", function()
					vim.diagnostic.jump({ count = 1 })
				end, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>ee", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})

		-- Diagnostic symbols in the sign column (gutter). vim.fn.sign_define() with
		-- DiagnosticSign* names is no longer how this is configured.
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
		})

		-- Capabilities applied to every server, including Expert (enabled in
		-- core/init.lua). This replaces mason-lspconfig's old default `setup_handlers`
		-- entry; the "*" key is merged into every config vim.lsp resolves, and setting
		-- it invalidates any config already resolved, so ordering does not matter.
		local capabilities = vim.tbl_deep_extend(
			"force",
			require("cmp_nvim_lsp").default_capabilities(),
			require("lsp-file-operations").default_capabilities()
		)

		vim.lsp.config("*", { capabilities = capabilities })

		-- Per-server overrides. Everything not listed here runs on nvim-lspconfig's
		-- bundled defaults from its `lsp/<server>.lua` files.

		vim.lsp.config("ruby_lsp", {
			init_options = {
				addonSettings = {
					["Ruby LSP Rails"] = {
						enablePendingMigrationsPrompt = false,
					},
				},
			},
		})

		vim.lsp.config("svelte", {
			on_attach = function(client, _bufnr)
				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx)
						-- Here use ctx.match instead of ctx.file
						client:notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
					end,
				})
			end,
		})

		vim.lsp.config("graphql", {
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		})

		vim.lsp.config("emmet_ls", {
			filetypes = {
				"html",
				"typescriptreact",
				"javascriptreact",
				"css",
				"heex",
				"sass",
				"scss",
				"less",
				"svelte",
			},
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})
	end,
}
