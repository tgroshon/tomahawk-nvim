local omarchy = require("tomahawk.core.omarchy")

-- On Omarchy the colorscheme is whatever `omarchy theme set` last chose; the
-- generated spec names both the plugin and the colorscheme. Off Omarchy, fall
-- back to onedark.
local theme_specs, _ = omarchy.read_theme()
local on_omarchy = omarchy.is_available()

local specs = {}

for _, spec in ipairs(theme_specs) do
	-- The active theme has to be loaded at startup, before anything draws.
	spec.lazy = false
	spec.priority = 1000
	specs[#specs + 1] = spec
end

if on_omarchy then
	-- A small pseudo-plugin whose only job is to apply the colorscheme once the
	-- theme plugin above has loaded, and to keep it in step with the system.
	specs[#specs + 1] = {
		"tomahawk-omarchy-theme",
		dir = vim.fn.stdpath("config"),
		name = "tomahawk-omarchy-theme",
		lazy = false,
		priority = 999,
		config = function()
			omarchy.apply()
			omarchy.watch()
		end,
	}
else
	specs[#specs + 1] = {
		"navarasu/onedark.nvim",
		commit = "fae34f7c635797f4bf62fb00e7d0516efa8abe37",
		priority = 1000,
		config = function()
			require("onedark").setup({
				style = "deep",
				transparent = false,
				term_colors = true,
				ending_tildes = true,
			})

			vim.cmd("colorscheme onedark")
		end,
	}
end

return specs
