# Tomahawk Neovim Config

A from-scratch Neovim configuration (lazy.nvim + nvim-cmp + mason/lspconfig),
based on davidkhanks-nvim, with a Spacemacs-style leader layer.

## Layout

```
init.lua                      -- entry point
lua/tomahawk/core/            -- options, keymaps, Elixir (expert) LSP setup
lua/tomahawk/lazy.lua         -- lazy.nvim bootstrap and setup
lua/tomahawk/plugins/         -- one file per plugin spec
lua/tomahawk/plugins/lsp/     -- mason + lspconfig
plugin/after/transparency.lua -- transparent background overrides
```

Plugin versions are pinned in `lazy-lock.json`.

## Leader layers (leader = `SPC`)

| Prefix    | Layer                                                     |
| --------- | --------------------------------------------------------- |
| `SPC SPC` | M-x (Telescope commands)                                   |
| `SPC /`   | Search project · `SPC *` search word under cursor          |
| `SPC ;`   | Toggle comment · `SPC '` terminal                          |
| `SPC b`   | Buffers (`bb` list, `bn`/`bp` cycle, `bd` kill, `bs` scratch) |
| `SPC f`   | Files (`ff` find, `fr` recent, `fs` save, `fj` reveal in tree, `fed` edit config) |
| `SPC w`   | Windows (`w/` `w-` split, `whjkl` focus, `wm` maximize, `wd` close) |
| `SPC p`   | Project / file tree (`pf` find file, `pt` focus tree)      |
| `SPC s`   | Search (`sp` grep, `ss` in buffer, `sc` clear highlight)   |
| `SPC g`   | Git (`gs` Neogit status, gitsigns hunk actions)            |
| `SPC e`   | Errors / diagnostics (`ee` line, `el` list, `en`/`ep` cycle) |
| `SPC m`   | Major mode / LSP (`mk` hover, `mr` rename, `mx` code action, `mp` format) |
| `SPC t`   | Toggles (`tt` tree, `tn` numbers, `tw` wrap, `th` clear highlight) |
| `SPC T`   | Tabs (`Tc` new, `Td` close, `Tn`/`Tp` cycle)               |
| `SPC q`   | Quit (`qq` prompt, `qQ` force, `qs` save and quit)         |
| `SPC h`   | Harpoon menu · `SPC a` add file · `SPC 1-4` jump           |
