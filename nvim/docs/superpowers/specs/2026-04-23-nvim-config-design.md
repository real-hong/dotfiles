# Neovim Config Design

Date: 2026-04-23

## Goal

Refine the current Neovim config into a restrained modern IDE for `C++`, `Python`, `Rust`, and Markdown work.

The config should:

- target the latest Neovim in active use without adding backward-compatibility work
- stay visually simple and low-noise
- prefer newer long-term directions when they are defensible
- avoid overlapping plugins and duplicated UI

## Current State Summary

The current config already has a solid structure:

- thin entrypoint in `init.lua`
- clear separation between `config/` and `plugins/`
- modern LSP setup using `vim.lsp.config()` and `vim.lsp.enable()`
- modern completion and picker choices with `blink.cmp` and `snacks.nvim`

The main problems are not architecture failures. They are mostly:

- overlapping UI signals
- mixed navigation paradigms
- one plugin choice that is ahead of the current Neovim version strategy

## Design Direction

Adopt a `Snacks-first restrained IDE` direction.

This means:

- keep the core editing and language features
- unify file search and file browsing under `snacks.nvim`
- keep the interface quiet by default
- remove plugins that mainly add persistent status noise

## Approved Plugin Decisions

### Keep

- `saghen/blink.cmp`
- `stevearc/conform.nvim`
- `folke/trouble.nvim`
- `lewis6991/gitsigns.nvim`
- `akinsho/bufferline.nvim`
- `folke/flash.nvim`
- `MeanderingProgrammer/render-markdown.nvim`
- `nvim-treesitter/nvim-treesitter-context`
- `nvim-treesitter/nvim-treesitter-textobjects`
- `kylechui/nvim-surround`
- `EdenEast/nightfox.nvim`
- `nvim-lualine/lualine.nvim`

### Remove

- `nvim-tree/nvim-tree.lua`
- `j-hui/fidget.nvim`

### Replace

- replace `nvim-tree` with `Snacks.explorer`

Implementation rule:

- keep the existing `<M-e>` explorer entrypoint, but remap it from `NvimTreeToggle` to `Snacks.explorer`
- enable `Snacks.explorer` with `replace_netrw = true` so directory opening is handled by the same navigation stack

## Interaction Model

### File Navigation

Use `snacks.nvim` as the single navigation family:

- `Snacks.picker.files()` for file finding
- `Snacks.picker.grep()` for content search
- `Snacks.picker.buffers()` for buffer switching
- `Snacks.explorer` for directory browsing and file operations

The purpose is consistency, not feature expansion.

### Buffer Navigation

Keep `bufferline.nvim` as the visible multi-file buffer strip.

This keeps the editor in modern IDE territory while still allowing picker-based buffer switching when needed.

## LSP Status Strategy

After removing `fidget.nvim`, LSP status should follow a quiet-by-default model.

Default signals:

- diagnostics in the buffer and statusline
- LSP actions working normally (`hover`, `references`, `rename`, `code action`)
- `Trouble` for structured inspection

Explicit inspection:

- use `:checkhealth vim.lsp` when LSP attachment or server state needs verification

Future option:

- if progress feedback is still wanted later, prefer a very small statusline integration based on builtin Neovim LSP progress instead of reintroducing a dedicated progress UI plugin

## UI Cleanup Rules

The final UI should avoid duplicated status surfaces.

### Keep

- `lualine` as the main statusline
- `bufferline` as the main buffer strip

### Remove Redundancy

Do not show the same information in multiple places.

In practice this means the implementation should reduce or remove overlap between:

- builtin `showmode` and lualine mode display
- builtin tabline visibility and bufferline
- any statusline options that recreate information already shown elsewhere

Concrete decisions:

- set builtin `showmode` off
- set builtin `showtabline` off
- keep `lualine` as the only statusline
- keep `bufferline` as the only persistent buffer strip
- do not use lualine's tabline feature as a second tab/buffer surface

## Version Strategy

### LSP

Keep the current Neovim-native LSP direction based on `vim.lsp.config()` and `vim.lsp.enable()`.

This is aligned with current Neovim documentation and should remain the preferred path.

### Treesitter

The current config tracks `nvim-treesitter` `main` while Neovim is currently `0.11.6`.

That is only reasonable if the Neovim version strategy also moves toward the newer upstream expectations. Otherwise the Treesitter branch choice should be adjusted to match the active Neovim version more conservatively.

Design rule:

- if staying on Neovim `0.11.x`, switch to a Treesitter strategy compatible with that line as part of the cleanup
- if moving to Neovim `0.12/nightly`, keeping the newer Treesitter direction is acceptable

## Non-Goals

This design does not add:

- dashboard plugins
- notification frameworks
- AI-specific plugins
- heavy project/session frameworks
- extra visual decorations that do not directly improve editing or navigation

## Testing Expectations For Implementation

When implementation starts, verification should at minimum cover:

- headless startup without config errors
- key navigation flows still working
- file explorer replacement working correctly
- LSP attachment for `C++`, `Python`, and `Rust`
- formatting commands still working
- no obvious duplicated UI remains in the default layout

## Result

The intended end state is a Neovim setup that feels:

- modern, but not novelty-driven
- simple, but not stripped down
- IDE-like for systems and language work
- internally consistent in navigation and status behavior
