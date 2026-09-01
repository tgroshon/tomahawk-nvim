# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A personal Neovim configuration built on lazy.nvim. It is a hand-rolled config (not a
distribution) forked from `davidkhanks-nvim` and renamespaced under `lua/tomahawk/`,
with a Spacemacs-style leader layer layered on top.

## Load order

1. `init.lua` requires `tomahawk.core`, then `tomahawk.lazy`.
2. `core/init.lua` loads `options.lua` and `keymaps.lua`, then configures the Expert
   Elixir LSP and a FileType autocmd that starts treesitter for elixir/eelixir/heex.
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
  mason-tool-installer (formatters/linters).
- `plugins/lsp/lspconfig.lua` — `setup_handlers()`: a default handler applying
  cmp capabilities to every installed server, plus per-server overrides. LSP keybinds
  are set in an `LspAttach` autocmd, so they exist only on attached buffers.
- `core/init.lua` — the Expert Elixir server, configured with the native
  `vim.lsp.config()` / `vim.lsp.enable()` API. `elixirls` is deliberately stubbed to a
  no-op handler in `lspconfig.lua` so Mason does not start a competing Elixir server.
  Do not "fix" that empty handler.

To add a server: add it to `ensure_installed` in `mason.lua`, and add a handler in
`setup_handlers()` only if it needs non-default settings.

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

conform.nvim formats on save (`lsp_fallback`, 3s timeout); prettier for web filetypes,
stylua for Lua. Manual format is `<leader>mp`.

Note the mismatch: this repo's Lua is tab-indented (inherited from upstream) while
`stylua.toml` specifies 2 spaces. Running stylua over the tree would reformat
everything — match surrounding tab indentation when editing instead.

## Verifying changes

No test suite. Validate with `nvim --headless "+qa"` to surface startup errors, then
`:Lazy` for plugin state, `:Mason` for server installs, `:checkhealth`, and by
exercising the affected keymaps.
