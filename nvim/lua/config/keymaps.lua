local map = vim.keymap.set

-- bufferline
map('n', '<M-p>', '<CMD>BufferLineCyclePrev<CR>')
map('n', '<M-n>', '<CMD>BufferLineCycleNext<CR>')
map('n', '<M-d>', '<CMD>bp|bd #<CR>')
map('n', '<M-D>', '<CMD>BufferLinePickClose<CR>')
map('n', '<M-1>', '<CMD>BufferLineGoToBuffer 1<CR>')
map('n', '<M-2>', '<CMD>BufferLineGoToBuffer 2<CR>')
map('n', '<M-3>', '<CMD>BufferLineGoToBuffer 3<CR>')
map('n', '<M-4>', '<CMD>BufferLineGoToBuffer 4<CR>')
map('n', '<M-5>', '<CMD>BufferLineGoToBuffer 5<CR>')
map('n', '<M-6>', '<CMD>BufferLineGoToBuffer 6<CR>')
map('n', '<M-7>', '<CMD>BufferLineGoToBuffer 7<CR>')
map('n', '<M-8>', '<CMD>BufferLineGoToBuffer 8<CR>')
map('n', '<M-9>', '<CMD>BufferLineGoToBuffer 9<CR>')

-- explorer
map('n', '<M-e>', function()
  Snacks.explorer()
end)
