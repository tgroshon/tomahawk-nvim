-- Omarchy integration.
--
-- Omarchy themes editors by writing a lazy.nvim spec to a well-known path and
-- rewriting it on every `omarchy theme set`. The generated file always has the
-- same shape: one or more colorscheme plugin specs, plus a `LazyVim/LazyVim`
-- entry whose `opts.colorscheme` names the colorscheme to apply.
--
--   return {
--     { "folke/tokyonight.nvim", priority = 1000 },
--     { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight-night" } },
--   }
--
-- We are not LazyVim, so that last entry is read for its name and dropped; the
-- rest are handed to lazy.nvim as ordinary specs. That keeps `omarchy theme set`
-- driving Neovim's colorscheme without this config knowing anything about which
-- themes exist.
--
-- On a machine without Omarchy every function here is a no-op and the config
-- falls back to its own colorscheme.

local M = {}

-- Omarchy has used both of these; aether.nvim watches both, so we do too.
local THEME_PATHS = {
	vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua"),
	vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua"),
}

local uv = vim.uv or vim.loop

---Path of the active generated theme spec, or nil when Omarchy is not installed.
---@return string|nil
function M.theme_file()
	for _, path in ipairs(THEME_PATHS) do
		local stat = uv.fs_stat(path)
		if stat then
			return path
		end
	end
end

---@return boolean
function M.is_available()
	return M.theme_file() ~= nil
end

---Read the generated spec.
---@return table specs  plugin specs, with the LazyVim entry removed
---@return string|nil colorscheme  the colorscheme it asks for
function M.read_theme()
	local file = M.theme_file()
	if not file then
		return {}, nil
	end

	local ok, spec = pcall(dofile, file)
	if not ok or type(spec) ~= "table" then
		vim.schedule(function()
			vim.notify("Omarchy: could not read theme spec at " .. file, vim.log.levels.WARN)
		end)
		return {}, nil
	end

	local specs, colorscheme = {}, nil
	for _, entry in ipairs(spec) do
		if type(entry) == "table" then
			if entry[1] == "LazyVim/LazyVim" then
				-- Not a plugin we want; it is only carrying the colorscheme name.
				colorscheme = type(entry.opts) == "table" and entry.opts.colorscheme or colorscheme
			else
				specs[#specs + 1] = entry
			end
		end
	end

	-- Omarchy 4 generates most themes from a template on top of aether.nvim,
	-- which carries no LazyVim entry to name the colorscheme.
	if not colorscheme then
		for _, entry in ipairs(specs) do
			if entry.name == "aether" or entry[1] == "bjarneo/aether.nvim" then
				colorscheme = "aether"
			end
		end
	end

	return specs, colorscheme
end

---Apply the colorscheme Omarchy currently asks for.
---@return boolean applied
function M.apply()
	local _, colorscheme = M.read_theme()
	if not colorscheme then
		return false
	end

	local ok = pcall(vim.cmd.colorscheme, colorscheme)
	if not ok then
		-- The theme names a colorscheme whose plugin this config has never
		-- installed. Nothing to do until lazy.nvim has fetched it.
		vim.schedule(function()
			vim.notify(
				("Omarchy theme wants colorscheme %q, which is not installed. Run :Lazy sync, then restart.")
					:format(colorscheme),
				vim.log.levels.WARN
			)
		end)
		return false
	end

	return true
end

---Re-apply the theme whenever Omarchy rewrites the spec file.
---
---The file is replaced rather than edited, so the watch is re-armed after every
---event. Events arrive in bursts (Omarchy writes the theme directory a piece at
---a time), hence the debounce.
function M.watch()
	local file = M.theme_file()
	if not file then
		return
	end

	local handle, timer

	local function rearm()
		if handle then
			handle:stop()
		end
		handle = uv.new_fs_event()
		if not handle then
			return
		end
		handle:start(file, {}, function()
			if timer then
				timer:stop()
				timer:close()
			end
			timer = uv.new_timer()
			timer:start(150, 0, function()
				timer:stop()
				timer:close()
				timer = nil
				vim.schedule(function()
					M.apply()
					rearm()
				end)
			end)
		end)
	end

	rearm()

	-- aether.nvim watches the same file and fires this when it is installed.
	vim.api.nvim_create_autocmd("User", {
		pattern = "LazyReload",
		callback = function()
			vim.schedule(M.apply)
		end,
	})
end

return M
