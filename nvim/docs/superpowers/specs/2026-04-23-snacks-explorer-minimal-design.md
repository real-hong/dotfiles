# Snacks Explorer Minimal Design

Date: 2026-04-23

## Goal

Refine `Snacks.explorer` so it feels more like a restrained terminal file tree and less like a colorful GUI file manager.

## Problem

The current explorer presentation is too visually busy:

- file type icons add too much color and decoration
- folder icons are more expressive than needed
- diagnostics/status symbols read as noisy visual accents

This clashes with the intended minimalist direction of the Neovim setup.

## Approved Direction

Use a `minimal character-based explorer` approach.

This means:

- remove file type icons
- remove folder icons
- remove colorful diagnostic/status icons
- keep the tree structure readable
- keep git state visible using simple text characters

## Scope

### In Scope

- `Snacks.explorer` visual markers
- tree expand/collapse markers
- git state markers
- diagnostic marker simplification

### Out of Scope

- changing bufferline
- changing lualine
- changing colorscheme
- changing core explorer behavior or keybindings
- changing picker behavior

## Chosen Visual Strategy

Replace decorative icons with a very small, neutral character set.

The implementation should:

- remove language/filetype icons entirely
- remove folder icons entirely
- replace explorer structure affordances with plain directional characters
- keep git state markers with compact ASCII-like symbols
- simplify diagnostics to a single low-noise character

Concrete implementation target:

- implement the visual overrides in `lua/plugins/editor.lua`
- apply them through the `picker.sources.explorer` configuration path
- customize explorer row rendering enough to remove file icons completely, instead of only changing fallback icon values
- use an explicit row-render / format override for explorer entries instead of relying only on `icons.files`

## Concrete Character Set

### Tree Structure

- expanded directory: `-`
- collapsed directory: `+`

### File And Folder Presentation

- no file type icon
- no folder icon
- no empty placeholder icon column for files
- directories should show only `+` or `-` plus the directory name
- regular files should show only the filename

### Git State

- added: `+`
- modified: `~`
- deleted: `-`
- untracked: `?`

Extended git mapping:

- renamed: `~`
- copied: `~`
- unmerged: `-`
- ignored: hidden

Git precedence rule:

- when more than one git state applies, prefer `-` over `~` over `+` over `?`

### Diagnostics

- error: `E`
- warning: `W`
- info: `I`
- hint: `H`

### Right-Side Status Layout

- show git status first
- show diagnostics after git status
- keep one space between them
- if space is too tight, preserve diagnostics and drop git first

## Design Rules

### Keep

- indentation and tree hierarchy
- clear open/closed directory affordance
- simple git visibility

### Remove

- colorful filetype glyphs
- decorative folder glyphs
- multi-shape diagnostic icons
- fake empty icon spacing for regular files

### Aesthetic Constraint

The explorer should remain sparse and utility-first.

It should feel closer to:

- terminal tree tools
- code-oriented file browsers

and less like:

- IDE resource panes with asset icons everywhere

## Expected Result

After implementation:

- the explorer should look calmer and less distracting
- file and folder entries should be distinguished mostly by structure and naming, not icons
- directories should read as `+ name` or `- name`
- regular files should read as plain filenames
- git changes should still be scannable
- diagnostics should remain noticeable without drawing too much attention

## Verification Expectations

Implementation should be checked with:

- nested directories
- a mix of tracked and untracked files
- at least one file with diagnostics

The success condition is a quieter explorer that still preserves fast scanning of tree structure and git state.
