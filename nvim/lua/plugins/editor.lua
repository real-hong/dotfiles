local function explorer_file_hl(item)
  local function has(prop)
    local node = item
    while node do
      if node[prop] then
        return true
      end
      node = node.parent
    end
    return false
  end

  if has('ignored') then
    return 'SnacksPickerPathIgnored'
  end
  if item.filename_hl then
    return item.filename_hl
  end
  if has('hidden') then
    return 'SnacksPickerPathHidden'
  end
  return item.dir and 'SnacksPickerDirectory' or 'SnacksPickerFile'
end

local function explorer_git_badge(item)
  if not item.status then
    return nil
  end

  local status = require('snacks.picker.source.git').git_status(item.status)
  if status.status == 'ignored' then
    return nil
  end

  local key = status.unmerged and 'unmerged' or status.status
  local icon = ({
    added = '+',
    copied = '~',
    deleted = '-',
    modified = '~',
    renamed = '~',
    unmerged = '-',
    untracked = '?',
  })[key]
  local hl = ({
    added = 'SnacksPickerGitStatusAdded',
    copied = 'SnacksPickerGitStatusCopied',
    deleted = 'SnacksPickerGitStatusDeleted',
    modified = 'SnacksPickerGitStatusModified',
    renamed = 'SnacksPickerGitStatusRenamed',
    unmerged = 'SnacksPickerGitStatusUnmerged',
    untracked = 'SnacksPickerGitStatusUntracked',
  })[key] or 'SnacksPickerGitStatus'

  if status.staged then
    icon = '+'
    hl = 'SnacksPickerGitStatusStaged'
  end

  return icon and { icon, hl } or nil
end

local function explorer_diagnostic_badge(item)
  local severity = item.severity
  severity = type(severity) == 'number' and vim.diagnostic.severity[severity] or severity
  if type(severity) ~= 'string' then
    return nil
  end

  local name = severity:sub(1, 1):upper() .. severity:sub(2):lower()
  local icon = ({
    Error = 'E',
    Warn = 'W',
    Info = 'I',
    Hint = 'H',
  })[name]
  return icon and { icon, 'Diagnostic' .. name } or nil
end

local function explorer_width(chunks)
  local width = 0
  for _, chunk in ipairs(chunks) do
    if type(chunk[1]) == 'string' then
      width = width + vim.api.nvim_strwidth(chunk[1])
    end
  end
  return width
end

local function explorer_status_chunks(item, picker, content_width)
  local git = explorer_git_badge(item)
  local diagnostic = explorer_diagnostic_badge(item)
  if not git and not diagnostic then
    return nil
  end
  if not git then
    return { diagnostic }
  end
  if not diagnostic then
    return { git }
  end

  local combined = {
    git,
    { ' ' },
    diagnostic,
  }

  local list_win = picker.list and picker.list.win
  if not (list_win and list_win:valid()) then
    return combined
  end

  local win_width = vim.api.nvim_win_get_width(list_win.win)
  if content_width + explorer_width(combined) <= win_width then
    return combined
  end
  return { diagnostic }
end

local function explorer_format(item, picker)
  local ret = {} ---@type snacks.picker.Highlight[]

  if item.parent then
    vim.list_extend(ret, require('snacks.picker.format').tree(item, picker))
  end

  if item.dir then
    ret[#ret + 1] = { item.open and '-' or '+', 'SnacksPickerTree' }
    ret[#ret + 1] = { ' ' }
  end

  ret[#ret + 1] = { item.name, explorer_file_hl(item), field = 'file' }

  local status = explorer_status_chunks(item, picker, explorer_width(ret))
  if status then
    ret[#ret + 1] = {
      col = 0,
      virt_text = status,
      virt_text_pos = 'right_align',
      hl_mode = 'combine',
    }
  end

  return ret
end

return {
  {
    'kylechui/nvim-surround',
    version = '^3.0.0', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },

  {
    'folke/snacks.nvim',
    lazy = false,
    ---@type snacks.Config
    opts = {
      explorer = {
        replace_netrw = true,
      },
      picker = {
        sources = {
          explorer = {
            format = explorer_format,
          },
        },
      },
    },
    keys = {
      -- find
      {
        '<leader>fb',
        function()
          Snacks.picker.buffers()
        end,
        desc = 'Buffers',
      },
      {
        '<leader>ff',
        function()
          Snacks.picker.files()
        end,
        desc = 'Find Files',
      },
      {
        '<leader>fg',
        function()
          Snacks.picker.grep()
        end,
        desc = 'Grep',
      },
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '┃' },
          change = { text = '┃' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        signs_staged = {
          add = { text = '┃' },
          change = { text = '┃' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        signs_staged_enable = true,
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          follow_files = true,
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
          -- Options passed to nvim_open_win
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1,
        },
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gitsigns.nav_hunk('next')
            end
          end)

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gitsigns.nav_hunk('prev')
            end
          end)

          -- Actions
          map('n', '<leader>hs', gitsigns.stage_hunk)
          map('n', '<leader>hr', gitsigns.reset_hunk)

          map('v', '<leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end)

          map('v', '<leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end)

          map('n', '<leader>hS', gitsigns.stage_buffer)
          map('n', '<leader>hR', gitsigns.reset_buffer)
          map('n', '<leader>hp', gitsigns.preview_hunk)
          map('n', '<leader>hi', gitsigns.preview_hunk_inline)

          map('n', '<leader>hb', function()
            gitsigns.blame_line({ full = true })
          end)

          map('n', '<leader>hd', gitsigns.diffthis)

          map('n', '<leader>hD', function()
            gitsigns.diffthis('~')
          end)

          map('n', '<leader>hQ', function()
            gitsigns.setqflist('all')
          end)
          map('n', '<leader>hq', gitsigns.setqflist)

          -- Toggles
          map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
          map('n', '<leader>td', gitsigns.toggle_deleted)
          map('n', '<leader>tw', gitsigns.toggle_word_diff)

          -- Text object
          map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
        end,
      })
    end,
  },

  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
      {
        '<c-s>',
        mode = { 'c' },
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
  },
}
