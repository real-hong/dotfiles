# Bufferline Separator Design

Date: 2026-04-23

## Goal

Improve the visual separation between buffers in the top `bufferline` without changing the overall minimalist UI style.

## Problem

The current `bufferline.nvim` setup uses thin separator characters with low visual contrast against the active colorscheme.

Current state in `lua/plugins/ui.lua`:

- `separator_style = { '|', '|' }`
- no explicit separator highlight tuning

This keeps the UI minimal, but makes adjacent buffers blend together too easily.

## Approved Direction

Use the `clearer separator + targeted highlight` approach.

This means:

- keep the current `bufferline` layout and buffer-centric behavior
- do not introduce a heavier tab aesthetic
- make boundaries between buffers easier to read
- keep the current overall theme and visual restraint

## Scope

### In Scope

- `bufferline.nvim` separator style
- `bufferline.nvim` separator-related highlights
- small contrast adjustments specific to buffer boundaries

### Out of Scope

- changing `lualine`
- changing the colorscheme itself
- changing icons, labels, numbering, or layout structure
- emphasizing the active buffer as a large “pill” or block tab
- changing `Snacks.explorer` or any other plugin

## Chosen Visual Strategy

Apply a `clear` style rather than a `heavy` style.

The implementation should:

- replace the current very thin separator choice with a more legible separator style
- add explicit highlight tuning for separator groups so boundaries remain visible under the current colorscheme
- improve separation for both active and inactive neighboring buffers
- preserve the restrained aesthetic of the existing setup

Concrete decisions:

- set `separator_style = 'thick'`
- do not use `slant`, `slope`, or a custom separator pair
- limit highlight overrides to separator-specific groups only

## Design Rules

### Separator Shape

The separator should be more readable than a plain thin vertical bar, but still visually quiet.

It should:

- read clearly at a glance
- avoid decorative slants that dominate the tabline
- avoid turning each buffer into a boxed block

### Separator Contrast

Contrast should be raised through targeted highlight overrides rather than broad background changes.

The emphasis belongs on:

- the edge between neighboring buffers
- the edge around the active buffer

The emphasis should not come from making every buffer background dramatically darker or brighter.

Concrete highlight scope:

- override only `separator`
- override only `separator_visible`
- override only `separator_selected`
- do not override `background`
- do not override `buffer_visible`
- do not override `buffer_selected`

## Expected Result

After implementation:

- individual buffers should be easier to distinguish in the tabline
- the bufferline should still feel simple and low-noise
- the active buffer may become slightly easier to locate, but the main improvement should be boundary clarity

## Verification Expectations

Implementation should be reviewed visually with multiple open buffers, including:

- at least three adjacent buffers
- one active buffer between inactive neighbors
- long filenames and short filenames mixed together

The success condition is not “more colorful”. The success condition is that the separator boundaries become easier to parse while the line still feels minimal.
