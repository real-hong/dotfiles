return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require('nvim-treesitter')

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
        'verilog',
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

      ts.setup({})
      ts.install(parsers)

      local group = vim.api.nvim_create_augroup('UserTreesitterMain', { clear = true })

      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = parsers,
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
          pcall(function()
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end)
        end,
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
    config = function()
      require('nvim-treesitter-textobjects').setup({})
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('treesitter-context').setup({
        enable = true,
        multiwindow = false,
        max_lines = 0,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = 'outer',
        mode = 'cursor',
        separator = nil,
        zindex = 20,
        on_attach = nil,
      })
    end,
  },
}
