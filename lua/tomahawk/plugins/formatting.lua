return {
	"stevearc/conform.nvim",
	commit = "f5bd8419f8a29451e20bdb1061a54fe13d5c8de3",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				-- Disable Black for the time being
				-- python = { "isort", "black" },
			},
			-- Opt-in: conform skips the buffer unless autoformat is switched on,
			-- buffer-locally first, then globally. <leader>tf toggles it.
			format_on_save = function(bufnr)
				local enabled = vim.b[bufnr].autoformat
				if enabled == nil then
					enabled = vim.g.autoformat
				end
				if not enabled then
					return nil
				end
				return { lsp_format = "fallback", async = false, timeout_ms = 3000 }
			end,
		})

		vim.keymap.set("n", "<leader>tf", function()
			local buf = vim.api.nvim_get_current_buf()
			local enabled = vim.b[buf].autoformat
			if enabled == nil then
				enabled = vim.g.autoformat
			end
			vim.b[buf].autoformat = not enabled
			vim.notify("Format on save " .. (vim.b[buf].autoformat and "enabled" or "disabled") .. " (buffer)")
		end, { desc = "Toggle format on save (buffer)" })

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 3000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
