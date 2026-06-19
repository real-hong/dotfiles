-- https://neovim.io/doc/user/diagnostic/
local diagnostic_config = {
  underline = true,
  virtual_text = false,
  virtual_lines = false,
  signs = true,
  update_in_insert = false,
  severity_sort = false,
}

local server_configs = {
  clangd = {},

  -- https://docs.astral.sh/ty/reference/editor-settings/
  ty = {
    settings = {
      ty = {
        disableLanguageServices = false,
        diagnosticMode = 'openFilesOnly',
        showSyntaxErrors = true,
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
        },
        completions = {
          autoImport = true,
        },
      },
    },
  },

  -- https://docs.astral.sh/ruff/editors/setup/#neovim
  ruff = {
    init_options = {
      settings = {
        logLevel = 'error',
      },
    },
  },

  -- https://rust-analyzer.github.io/book/configuration.html
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        cargo = {
          features = 'all',
          targetDir = true,
        },
        check = {
          command = 'clippy',
          allTargets = true,
        },
      },
    },
  },
}

local server_order = {
  'clangd',
  'ty',
  'ruff',
  'rust_analyzer',
}

local function disable_ruff_hover(args)
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if client == nil then
    return
  end
  if client.name == 'ruff' then
    client.server_capabilities.hoverProvider = false
  end
end

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      local blink = require('blink.cmp')

      vim.diagnostic.config(diagnostic_config)

      vim.lsp.config('*', {
        capabilities = blink.get_lsp_capabilities(),
      })

      for server, opts in pairs(server_configs) do
        vim.lsp.config(server, opts)
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
        callback = disable_ruff_hover,
        desc = 'LSP: Disable hover capability from Ruff',
      })

      for _, server in ipairs(server_order) do
        vim.lsp.enable(server)
      end
    end,
  },

  {
    'saghen/blink.cmp',
    dependencies = {
      'saghen/blink.lib',
    },

    build = function()
      require('blink.cmp').build():pwait()
    end,

    opts = {
      keymap = {
        preset = 'enter',
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      },

      completion = { documentation = { auto_show = false } },

      sources = { default = { 'lsp', 'path', 'buffer' } },

      fuzzy = { implementation = 'rust' },
    },
  },

  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
  },

  {
    'stevearc/conform.nvim',
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<A-f>',
        function()
          require('conform').format({
            async = true, -- If true the method won't block. Defaults to false. If the buffer is modified before the formatter completes, the formatting will be discarded.
            lsp_format = 'never', -- never use the LSP for formatting (default)
          })
        end,
        mode = { 'n', 'x' },
        desc = 'Format code',
      },
    },
    opts = {
      notify_on_error = true,
      notify_no_formatters = false,

      log_level = vim.log.levels.ERROR,

      formatters_by_ft = {
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        python = { 'ruff_organize_imports', 'ruff_format' },
        lua = { 'stylua' },
        rust = { 'rustfmt' },

        sh = { 'shfmt' },
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
        fish = { 'fish_indent' },

        cmake = { 'cmake_format' },
      },
    },
  },
}
