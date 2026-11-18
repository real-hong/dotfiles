local parsers = {
  'c',
  'cpp',
  'rust',
  'python',
  'lua',
  'go',
  'bash',
  'make',
  'cmake',
  'systemverilog',
  'markdown',
  'markdown_inline',
  'html', -- render-markdown: inline HTML
  'regex', -- snacks picker: regex highlighting
  'gitignore',
  'gitcommit',
  'diff',
  'json',
  'toml',
  'yaml',
  'vim',
  'vimdoc',
}

-- Parser names are not filetype names (e.g. bash -> sh, vimdoc -> help),
-- so expand each parser into the filetypes registered for it.
local function parser_filetypes()
  local filetypes = {}
  for _, lang in ipairs(parsers) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      filetypes[ft] = true
    end
  end
  return vim.tbl_keys(filetypes)
end

local function start_treesitter_for_filetype(args)
  if not pcall(vim.treesitter.start, args.buf) then
    return
  end
  vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

local function textobject_keymaps()
  local select = require('nvim-treesitter-textobjects.select')
  local move = require('nvim-treesitter-textobjects.move')
  local swap = require('nvim-treesitter-textobjects.swap')
  local map = vim.keymap.set

  -- select
  local selections = {
    af = '@function.outer',
    ['if'] = '@function.inner',
    ac = '@class.outer',
    ic = '@class.inner',
    aa = '@parameter.outer',
    ia = '@parameter.inner',
  }
  for lhs, query in pairs(selections) do
    map({ 'x', 'o' }, lhs, function()
      select.select_textobject(query, 'textobjects')
    end, { desc = 'Select ' .. query })
  end

  -- move
  local moves = {
    [']m'] = { move.goto_next_start, '@function.outer' },
    [']M'] = { move.goto_next_end, '@function.outer' },
    ['[m'] = { move.goto_previous_start, '@function.outer' },
    ['[M'] = { move.goto_previous_end, '@function.outer' },
    [']]'] = { move.goto_next_start, '@class.outer' },
    [']['] = { move.goto_next_end, '@class.outer' },
    ['[['] = { move.goto_previous_start, '@class.outer' },
    ['[]'] = { move.goto_previous_end, '@class.outer' },
  }
  for lhs, spec in pairs(moves) do
    map({ 'n', 'x', 'o' }, lhs, function()
      spec[1](spec[2], 'textobjects')
    end, { desc = 'Move to ' .. spec[2] })
  end

  -- swap
  map('n', '<leader>a', function()
    swap.swap_next('@parameter.inner')
  end, { desc = 'Swap with next parameter' })
  map('n', '<leader>A', function()
    swap.swap_previous('@parameter.inner')
  end, { desc = 'Swap with previous parameter' })
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    opts = {},
    config = function(_, opts)
      local ts = require('nvim-treesitter')

      ts.setup(opts)
      ts.install(parsers)

      local group = vim.api.nvim_create_augroup('UserTreesitterMain', { clear = true })

      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = parser_filetypes(),
        callback = start_treesitter_for_filetype,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    lazy = false,
    init = function()
      -- Built-in ftplugins define buffer-local ]] / [[ / ]m maps that would shadow ours.
      vim.g.no_python_maps = true
      vim.g.no_rust_maps = true
      vim.g.no_go_maps = true
    end,
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      })
      textobject_keymaps()
    end,
  },
}
