-- TODO: get telescope working to list breakpoints
--
-- Function to configure Python DAP settings
local function setup_python_dap(dap)
  dap.adapters.python = {
    type = 'executable',
    command = 'python',
    args = { '-m', 'debugpy.adapter' }
  }

  -- Configurations for Python
  dap.configurations.python = {
    {
      name = "Attach remote",
      type = "python",
      request = "attach",
      connect = {
        host = "127.0.0.1",
        port = 5678,
      },
      justMyCode = false, -- include 3rd party libraries in debugging
    },
  }
end

-- Set up key mappings for debugging
local function setup_debug_keymaps(dap, dapui)
  local keymap = vim.keymap.set
  local opts = { desc = 'Debug' }

  keymap('n', '<F5>', dap.continue, { desc = 'Start/Continue' })
  keymap('n', '<F1>', dap.step_over, { desc = 'Step Over' })
  keymap('n', '<F2>', dap.step_into, { desc = 'Step Into' })
  keymap('n', '<F3>', dap.step_out, { desc = 'Step Out' })
  keymap('n', ',b', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint' })
  -- Currently using ,B in python plugins to add breakpoint for ipython debgugging
  -- keymap('n', ',B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
     -- { desc = 'Set Conditional Breakpoint' })
  keymap('n', '<F7>', dapui.toggle, { desc = 'Toggle DAP UI' })
  keymap('n', '<F6>', function()
    dap.run({
      type = 'python',
      request = 'attach',
      connect = { host = '127.0.0.1', port = 5678 },
      justMyCode = false,
    })
  end, { desc = 'Attach Remote' })
  keymap('n', ',db', function() require("dap").list_breakpoints() end, { desc = 'DAP Breakpoints' })
end

-- Main plugin configuration
return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'mfussenegger/nvim-dap-python',
      'jonathan-elize/dap-info.nvim',
      { 'daic0r/dap-helper.nvim', dependencies = { "rcarriga/nvim-dap-ui", "mfussenegger/nvim-dap" } },
      {
        "Willem-J-an/visidata.nvim",
        dependencies = {
          "mfussenegger/nvim-dap",
          "rcarriga/nvim-dap-ui"
        },
        config = function()
          local dap = require("dap")
          -- External terminal setup for visidata.nvim
          dap.defaults.fallback.external_terminal = {
            -- command = 'kitty',
            -- args = { '--hold' } -- kitty
            command = 'alacritty',
            args = { '--hold', '--command' } -- alacritty
          }

          -- Keymap to visualize pandas dataframe with visidata
          vim.keymap.set("v", ",vp", require('visidata').visualize_pandas_df, { desc = "[v]isualize [p]andas df" })
        end,
      },
    },

    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      -- Set up Python DAP configurations
      setup_python_dap(dap)


      vim.api.nvim_set_hl(0, 'DapStoppedLineHLColor', { bg = '#496076' })

      vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'LspDiagnosticsSignError', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition',
        { text = '♦️', texthl = 'LspDiagnosticsSignHint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = '▶', texthl = 'LspDiagnosticsSignInfo', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped',
        {
          text = '👉',
          texthl = 'DapStoppedLineHLColor',
          linehl = 'DapStoppedLineHLColor',
          numhl = 'DapStoppedLineHLColor'
        })
      -- { text = '👉', texthl = 'LspDiagnosticsSignWarning', linehl = 'Visual', numhl = 'LspDiagnosticsSignWarning' })

      -- Set up key mappings for debugging
      setup_debug_keymaps(dap, dapui)

      -- Set up DAP UI with custom icons
      dapui.setup {
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = '⏪',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
        -- using dap-helper instead
        -- persist_breakpoints = false, -- Enable persistence of breakpoints etc
      }

      -- Open DAP UI automatically on start and close on exit
      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      require('dap-python').setup('python') -- Adjust Python path if needed
      require("dap-info").setup({})
      require("dap-helper").setup()
    end,
  }
}
