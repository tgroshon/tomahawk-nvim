-- Every colorscheme the stock Omarchy themes can ask for, pre-installed but not
-- loaded.
--
-- `omarchy theme set` rewrites the generated spec and this config re-applies the
-- colorscheme live (see core/omarchy.lua). That only works if the colorscheme's
-- plugin is already on disk -- lazy.nvim cannot fetch a new plugin mid-session,
-- and without this list every theme switch to an unvisited theme would need a
-- :Lazy sync and a restart. Omarchy's own Neovim config keeps the same list for
-- the same reason.
--
-- Derived from /usr/share/omarchy/themes/*/neovim.lua. If a theme switch reports
-- a missing colorscheme, a new stock theme has been added upstream: add its
-- plugin here.

local omarchy = require("tomahawk.core.omarchy")

if not omarchy.is_available() then
	return {}
end

local function theme(spec)
	spec.lazy = true
	spec.priority = 1000
	return spec
end

return {
	-- Omarchy 4 generates most themes from default/themed/neovim.lua.tpl on top
	-- of aether. Name and branch must match that template, or lazy builds the
	-- plugin into a directory the generated spec does not point at.
	theme({ "bjarneo/aether.nvim", branch = "v3", name = "aether" }),

	theme({ "catppuccin/nvim", name = "catppuccin" }),
	theme({ "rose-pine/neovim", name = "rose-pine" }),
	theme({ "folke/tokyonight.nvim" }),
	theme({ "neanias/everforest-nvim" }),
	theme({ "kepano/flexoki-neovim" }),
	theme({ "ellisonleao/gruvbox.nvim" }),
	theme({ "bjarneo/hackerman.nvim" }),
	theme({ "rebelot/kanagawa.nvim" }),
	theme({ "omacom-io/lumon.nvim" }),
	theme({ "tahayvr/matteblack.nvim" }),
	theme({ "EdenEast/nightfox.nvim" }),
	theme({ "ribru17/bamboo.nvim" }),
	theme({ "OldJobobo/retro-82.nvim" }),
	theme({ "ficcdaf/ashen.nvim" }),
}
