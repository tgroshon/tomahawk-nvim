-- Transparent background, re-applied on every colorscheme change.
--
-- A colorscheme sets these highlight groups when it loads, so clearing their
-- backgrounds once at startup accomplishes nothing -- the colorscheme that loads
-- afterwards simply paints over it. This is doubly true on Omarchy, where
-- `omarchy theme set` swaps the colorscheme at runtime (see core/omarchy.lua).
-- Hooking ColorScheme is what makes it stick.
--
-- Set `vim.g.tomahawk_transparent = false` in core/options.lua to opt out, or
-- toggle it for the session with <leader>tT.

if vim.g.tomahawk_transparent == nil then
	vim.g.tomahawk_transparent = true
end

-- Groups whose background should follow the terminal rather than the
-- colorscheme. Only groups belonging to plugins this config actually loads.
local GROUPS = {
	-- editor
	"Normal",
	"NormalNC",
	"NormalFloat",
	"FloatBorder",
	"EndOfBuffer",
	"FoldColumn",
	"Folded",
	"SignColumn",
	"Pmenu",
	"Terminal",
	-- which-key
	"WhichKeyFloat",
	-- telescope
	"TelescopeBorder",
	"TelescopeNormal",
	"TelescopePromptBorder",
	"TelescopePromptTitle",
	-- nvim-tree
	"NvimTreeNormal",
	"NvimTreeNormalNC",
	"NvimTreeVertSplit",
	"NvimTreeWinSeparator",
	"NvimTreeEndOfBuffer",
}

local function apply()
	if not vim.g.tomahawk_transparent then
		return
	end

	for _, group in ipairs(GROUPS) do
		-- Clear only the background, keeping whatever colours the current
		-- colorscheme chose for the foreground.
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
		if ok then
			hl.bg = nil
			hl.ctermbg = nil
			pcall(vim.api.nvim_set_hl, 0, group, hl)
		end
	end
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("tomahawk_transparency", { clear = true }),
	callback = apply,
})

-- A colorscheme may already have loaded by the time this file is sourced.
apply()

vim.keymap.set("n", "<leader>tT", function()
	vim.g.tomahawk_transparent = not vim.g.tomahawk_transparent
	if vim.g.tomahawk_transparent then
		apply()
	else
		-- Reloading the colorscheme is the only way to get the backgrounds back.
		if vim.g.colors_name then
			pcall(vim.cmd.colorscheme, vim.g.colors_name)
		end
	end
	vim.notify("Transparent background " .. (vim.g.tomahawk_transparent and "enabled" or "disabled"))
end, { desc = "Toggle transparent background" })
