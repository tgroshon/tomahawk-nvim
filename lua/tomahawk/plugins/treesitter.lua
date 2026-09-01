return {
	"nvim-treesitter/nvim-treesitter",
	-- The `main` branch is a full, incompatible rewrite. `master` is frozen (last
	-- commit Mar 2026) and only supports Nvim <= 0.11. `main` requires Nvim 0.12+,
	-- the `tree-sitter` CLI (>= 0.26.1, from your package manager -- NOT npm), curl,
	-- tar and a C compiler.
	branch = "main",
	commit = "19071296d3d643b48615ee574a20e8a03ac40872",
	-- The rewrite does not support lazy-loading, and parsers must be rebuilt whenever
	-- the plugin is updated -- hence `lazy = false` + `build`.
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		-- autotag is no longer configured through nvim-treesitter; it has its own setup.
		{ "windwp/nvim-ts-autotag", commit = "88c1453db4ba7dd24131086fe51fdf74e587d275", opts = {} },
	},
	config = function()
		local ts = require("nvim-treesitter")

		-- Prepends install_dir to runtimepath so parsers and queries are found.
		ts.setup()

		-- treat livebook files as markdown (must be registered before install/start)
		vim.treesitter.language.register("markdown", "livebook")

		-- The rewrite has no `ensure_installed` option; installation is an explicit,
		-- asynchronous call that no-ops for parsers already present.
		ts.install({
			"bash",
			"c",
			"cpp",
			"css",
			"dockerfile",
			"eex",
			"elixir",
			"gitignore",
			"go",
			"graphql",
			"heex",
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"prisma",
			"python",
			"query",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		})

		-- Highlighting and indentation are no longer plugin options -- they are Neovim
		-- features that have to be switched on per buffer. This turns them on for any
		-- filetype that has a parser available, which covers the list above plus the
		-- parsers Neovim ships with.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("TomahawkTreesitter", { clear = true }),
			callback = function(ev)
				local lang = vim.treesitter.language.get_lang(ev.match)
				if not lang or not pcall(vim.treesitter.language.add, lang) then
					return
				end

				vim.treesitter.start(ev.buf, lang)
				-- treesitter indentation is still marked experimental upstream
				vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
