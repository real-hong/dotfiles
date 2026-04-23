return {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      local blink = require('blink.cmp')

      -- https://neovim.io/doc/user/diagnostic/
      vim.diagnostic.config({
        underline = true,
        virtual_text = false,
        virtual_lines = false,
        signs = true,
        update_in_insert = false,
        severity_sort = false,
      })

      vim.lsp.config('*', {
        capabilities = blink.get_lsp_capabilities(),
      })

      vim.lsp.config('clangd', {})

      -- https://docs.astral.sh/ty/reference/editor-settings/
      vim.lsp.config('ty', {
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
      })

      -- https://docs.astral.sh/ruff/editors/setup/#neovim
      vim.lsp.config('ruff', {
        init_options = {
          settings = {
            logLevel = 'error',
          },
        },
      })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client == nil then
            return
          end
          if client.name == 'ruff' then
            client.server_capabilities.hoverProvider = false
          end
        end,
        desc = 'LSP: Disable hover capability from Ruff',
      })

      -- https://rust-analyzer.github.io/book/configuration.html
      vim.lsp.config('rust_analyzer', {
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
      })

      for _, server in ipairs({
        'clangd',
        'ty',
        'ruff',
        'rust_analyzer',
      }) do
        vim.lsp.enable(server)
      end
    end,
  },

  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = {
        preset = 'enter',
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = { documentation = { auto_show = false } },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
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

  {
    'j-hui/fidget.nvim',
    opts = {
      -- options
    },
  },
}
