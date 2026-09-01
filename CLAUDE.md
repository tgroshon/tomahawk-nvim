# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A personal Neovim configuration built on lazy.nvim. It is a hand-rolled config (not a
distribution) forked from `davidkhanks-nvim` and renamespaced under `lua/tomahawk/`,
with a Spacemacs-style leader layer layered on top.

## Load order

1. `init.lua` requires `tomahawk.core`, then `tomahawk.lazy`.
2. `core/init.lua` loads `options.lua` and `keymaps.lua`, then enables the Expert
   Elixir LSP.
3. `lazy.lua` bootstraps lazy.nvim and imports two specs: `tomahawk.plugins` and
   `tomahawk.plugins.lsp`.

Because core keymaps load before plugins, any keymap set inside a plugin's `config`
function silently overrides a same-key mapping in `core/keymaps.lua`. When adding a
binding, check both places.

## Plugin specs

One file per plugin under `lua/tomahawk/plugins/`, each returning a lazy.nvim table.
Plugins are pinned to explicit `commit` hashes — preserve the pin when editing a spec,
and expect `lazy-lock.json` to be the second source of truth. `lazy.lua` enables the
update `checker` with notifications off, so `:Lazy` may show pending updates that are
intentionally not applied.

Plugin-local keymaps live in the plugin's own `config` function rather than in
`core/keymaps.lua` (telescope, nvim-tree, harpoon, gitsigns, conform, nvim-lint).

## LSP

Two files, plus one server configured outside Mason:

- `plugins/lsp/mason.lua` — `ensure_installed` lists for mason-lspconfig (servers) and
  mason-tool-installer (formatters/linters), plus the `automatic_enable` exclusions.
- `plugins/lsp/lspconfig.lua` — `vim.lsp.config("*", …)` applying cmp +
  lsp-file-operations capabilities to every server, then one `vim.lsp.config(<name>, …)`
  per server that needs non-default settings. LSP keybinds are set in an `LspAttach`
  autocmd, so they exist only on attached buffers.
- `core/init.lua` — `vim.lsp.enable("expert")` for the Expert Elixir server.

Everything runs on the native `vim.lsp.config()` / `vim.lsp.enable()` API. mason-lspconfig
2.x removed `setup_handlers()`; it now calls `vim.lsp.enable()` itself for each installed
server, and per-server settings are merged from three sources at `FileType` time — the
`"*"` config, nvim-lspconfig's bundled `lsp/<server>.lua`, then our `vim.lsp.config(<name>)`
call, in that order. Because resolution is deferred and setting `"*"` invalidates every
cached config, the order these calls run in does not matter.

`mason.lua` lists `neovim/nvim-lspconfig` as a dependency: mason-lspconfig needs the
`lsp/` runtime directory on the runtimepath before it enables anything. That makes
nvim-lspconfig load eagerly, so it deliberately has no `event =` trigger.

Elixir is served by **Expert only**. `elixirls`, `lexical`, `nextls` and `expert` itself
are all listed under `automatic_enable.exclude` in `mason.lua` so mason-lspconfig can
never start a second Elixir server alongside Expert — do not remove that list. (It
replaces the empty `setup_handlers` stubs the old config used for the same purpose.)
Expert's binary is installed through mason-tool-installer (package `expert`) rather than
mason-lspconfig's `ensure_installed`, for the same reason.

Lua workspace types come from `lazydev.nvim`, which replaced the deprecated
`neodev.nvim` — neodev hooked lspconfig's old `.setup()` path and is inert under
`vim.lsp.config`.

To add a server: add it to `ensure_installed` in `mason.lua`, and add a
`vim.lsp.config(<name>, …)` call in `lspconfig.lua` only if it needs non-default
settings.

## Treesitter

`plugins/treesitter.lua` tracks nvim-treesitter's `main` branch — a full, incompatible
rewrite. `master` is frozen and only supports Nvim <= 0.11. Consequences worth knowing
before editing that file:

- It requires Nvim 0.12+, the `tree-sitter` CLI (>= 0.26.1, from your package manager,
  **not** npm), `curl`, `tar` and a C compiler.
- It cannot be lazy-loaded (`lazy = false`), and parsers must be rebuilt whenever the
  plugin updates — hence `build = ":TSUpdate"`.
- There is no `ensure_installed` option and no `require("nvim-treesitter.configs")`.
  Parsers are installed with `require("nvim-treesitter").install({...})`, which is
  asynchronous and no-ops for parsers already present.
- Highlighting and indentation are Neovim features, not plugin options: a `FileType`
  autocmd calls `vim.treesitter.start()` and sets `indentexpr` for any filetype with an
  available parser. That single autocmd covers Elixir, which is why `core/init.lua` no
  longer has its own.
- `autotag` is no longer a nvim-treesitter option; `nvim-ts-autotag` has its own
  `opts = {}` setup in the dependency list.
- The rewrite dropped `incremental_selection`, so the old `<C-space>` expand /
  `<BS>` shrink bindings are gone with no in-plugin replacement.

## Omarchy integration

These machines all run Omarchy, and three pieces of this config exist to fit it.

**Theming.** `core/omarchy.lua` reads the lazy.nvim spec Omarchy regenerates on every
`omarchy theme set` (`~/.local/state/omarchy/current/theme/neovim.lua`, with the older
`~/.config/omarchy/current/...` path also checked). That file always has the same shape:
colorscheme plugin specs plus a `LazyVim/LazyVim` entry whose `opts.colorscheme` names
the colorscheme. We read the name, drop the LazyVim entry, and hand the rest to
lazy.nvim — so the system theme drives Neovim without this config knowing the theme
list. `plugins/colorscheme.lua` loads the active theme at `priority = 1000` and adds a
`dir`-based pseudo-plugin that applies the colorscheme and starts a `libuv` watch on the
spec file for live switching. Off Omarchy the whole path is skipped and onedark loads
instead — keep that fallback working.

`plugins/omarchy-themes.lua` pre-installs (lazy, unloaded) every colorscheme the stock
themes can name. lazy.nvim cannot clone a plugin mid-session, so without it a switch to
an unvisited theme would need `:Lazy sync` and a restart. If a switch ever reports a
missing colorscheme, Omarchy has added a stock theme: add its plugin to that list.

There is a user template at `~/.config/omarchy/themed/neovim.lua.tpl` (outside this
repo) that renders an aether.nvim spec with the theme's palette. **It only applies to
themes that do not ship their own `neovim.lua`** — `omarchy-theme-set-templates` skips
any output path that already exists, and most stock themes ship one. The reader above,
not the template, is what makes theming work in general.

**Clipboard.** `core/remote_clipboard.lua` is vendored verbatim from Omarchy's stock
config, below a provenance header, so it can be diffed against upstream after an
`omarchy update`. It only engages inside tmux/SSH/herdr, where it routes yanks through
OSC 52. Re-sync it rather than editing it locally.

**Format on save is opt-in.** `vim.g.autoformat = false` in `core/options.lua`, and
conform's `format_on_save` is a function honouring `vim.b.autoformat` then
`vim.g.autoformat`. `<leader>tf` toggles the buffer. This matches the Omarchy config
this replaced; do not "restore" unconditional format-on-save.

## Keymap layout

Leader is `<Space>`. Prefixes: `b` buffers, `f` files, `w` windows, `p` project/file
tree, `s` search, `g` git (Neogit + gitsigns hunks), `e` diagnostics, `m` LSP actions,
`t` toggles, `T` tabs, `q` quit, `k` marks, `h`/`a`/`1-4` harpoon. See the README table
for the specific keys.

Two prefixes diverge from upstream `davidkhanks-nvim` and should stay that way:
`SPC t` is toggles (upstream uses it for tabs, which moved to `SPC T`), and `SPC ff` is
Telescope find-file (upstream uses it for nvim-tree reveal, which moved to `SPC fj`).

Always give a keymap a `desc` — which-key surfaces it.

## Formatting

conform.nvim handles formatting; prettier for web filetypes, stylua for Lua. Manual
format is `<leader>mp`. Format on save is off by default — see the Omarchy section.

Note the mismatch: this repo's Lua is tab-indented (inherited from upstream) while
`stylua.toml` specifies 2 spaces. Running stylua over the tree would reformat
everything — match surrounding tab indentation when editing instead.

## Verifying changes

No test suite. This repo is symlinked to `~/.config/nvim`, so validate with
`nvim --headless "+qa"` to surface startup errors, then `:Lazy`
for plugin state, `:Mason` for server installs, `:checkhealth`, and by exercising the
affected keymaps.

After a nvim-treesitter update run `:TSUpdate` and confirm parsers still build. To check
LSP wiring without a UI, open a file of the relevant type and inspect
`vim.lsp.config[<name>]` (the fully merged config) and `vim.lsp._enabled_configs` (which
servers are enabled at all — useful for confirming only `expert` is enabled for Elixir).

To check the theme wiring without a UI:
`nvim --headless -c 'lua print(vim.g.colors_name)' -c qa` should print the colorscheme
matching `omarchy theme current`.
