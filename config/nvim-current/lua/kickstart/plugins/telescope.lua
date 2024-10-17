-- See `:help telescope` and `:help telescope.setup()`

return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',

      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      local builtin = require('telescope.builtin')

      local function delete_buffer_and_refresh(prompt_bufnr)
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        local selected_buf = action_state.get_selected_entry()

        -- Close the selected buffer
        vim.api.nvim_buf_delete(selected_buf.bufnr, { force = false })

        -- Close the current picker
        actions.close(prompt_bufnr)

        -- Reopen the buffer picker to refresh the list
        require('telescope.builtin').buffers()
      end

      require('telescope').setup {
        defaults = {
          layout_config = {
            bottom_pane = {
              height = 25,
              preview_cutoff = 120,
              prompt_position = "top"
            },
            center = {
              height = 0.4,
              preview_cutoff = 40,
              prompt_position = "top",
              width = 0.5
            },
            cursor = {
              height = 0.9,
              preview_cutoff = 40,
              width = 0.8
            },
            horizontal = {
              height = 0.9,
              preview_cutoff = 120,
              prompt_position = "bottom",
              width = 0.9
            },
            vertical = {
              height = 0.9,
              preview_cutoff = 40,
              prompt_position = "bottom",
              width = 0.9
            }
          },

          mappings = {
            n = {
            },
          },
        },
        -- specific mappings for the buffer picker
        pickers = {
          buffers = {
            mappings = {
              -- insert mode (default mode in telescope)
              i = {
                ['<C-d>'] = delete_buffer_and_refresh,
              },
              n = {
                ['<C-d>'] = delete_buffer_and_refresh,
              },
            }
          }
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')

      -- Telescope live_grep in git root
      -- Function to find the git root directory based on the current buffer's path
      local function find_git_root()
        -- Use the current buffer's path as the starting point for the git search
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir
        local cwd = vim.fn.getcwd()
        -- If the buffer is not associated with a file, return nil
        if current_file == '' then
          current_dir = cwd
        else
          -- Extract the directory from the current file's path
          current_dir = vim.fn.fnamemodify(current_file, ':h')
        end

        -- Find the Git root directory from the current file's path
        local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')
            [1]
        if vim.v.shell_error ~= 0 then
          print 'Not a git repository. Searching on current working directory'
          return cwd
        end
        return git_root
      end

      -- Custom live_grep function to search in git root
      local function live_grep_git_root()
        local git_root = find_git_root()
        if git_root then
          require('telescope.builtin').live_grep {
            search_dirs = { git_root },
          }
        end
      end

      vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

      -- See `:help telescope.builtin`
      vim.keymap.set('n', ',?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', ',ff', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', ',/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      local function telescope_live_grep_open_files()
        require('telescope.builtin').live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end
      vim.keymap.set('n', ',s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
      vim.keymap.set('n', ',ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', ',gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
      -- vim.keymap.set('n', ',sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', ',fb', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
      -- vim.keymap.set('n', ',sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', ',fh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
      -- vim.keymap.set('n', ',sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', ',fs', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
      -- vim.keymap.set('n', ',sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', ',fg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', ',sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
      vim.keymap.set('n', ',sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', ',sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
    end
  }
}
