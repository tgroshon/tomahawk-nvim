require("tomahawk.core.options")
require("tomahawk.core.keymaps")

-- Expert -- the official Elixir language server (https://github.com/elixir-lang/expert)
--
-- Installed as a Mason package ("expert" in mason-tool-installer's ensure_installed),
-- which puts the `expert` binary on PATH. The cmd/filetypes/root_dir table that used
-- to live here is now nvim-lspconfig's bundled `lsp/expert.lua`, so all that is left
-- is turning it on. Completion capabilities come from the "*" config in
-- plugins/lsp/lspconfig.lua.
--
-- Elixir is served by Expert alone: elixirls, lexical, nextls and expert itself are
-- all excluded from mason-lspconfig's `automatic_enable` so that nothing can start a
-- second Elixir server alongside this one.
vim.lsp.enable("expert")
