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
  'gitignore',
  'gitcommit',
  'diff',
  'json',
  'toml',
  'yaml',
  'vim',
  'vimdoc',
}

local function start_treesitter_for_filetype(args)
  pcall(vim.treesitter.start, args.buf)
  pcall(function()
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end)
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
        pattern = parsers,
        callback = start_treesitter_for_filetype,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    main = 'nvim-treesitter-textobjects',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    lazy = false,
    opts = {},
  },
}
