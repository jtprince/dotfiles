-- NOTE: `{<plugin>, opts = {}}` is the same as calling `require('<plugin>').setup({})`
require('lazy').setup({
        -- [[ No config ]]

        -- Git commands
        'tpope/vim-fugitive',
        -- Github commands
        'tpope/vim-rhubarb',

        -- Detect tabstop and shiftwidth automatically
        'tpope/vim-sleuth',

        'svermeulen/vimpeccable',

        -- Minimap (compact representation of whole doc in the right)
        -- Requires code-minimap `yay -S code-minimap`
        -- :Minimap
        'wfxr/minimap.vim',


        -- TODO: need less dark vertical lines!
        -- 'shaunsingh/moonlight.nvim'

        -- [[ With config ]]

        -- better lua experience
        { "folke/neodev.nvim", opts = {} },


        {
            'rmagatti/auto-session',
            lazy = false,
            dependencies = {
                'nvim-telescope/telescope.nvim',
            },
            config = function()
                require('auto-session').setup({
                    auto_session_suppress_dirs = { '~/', '~/tmp', '~/Downloads', '/' },
                })
            end,
        },

        -- "gc" to comment visual regions/lines
        {
            'numToStr/Comment.nvim',
            opts = {
                ---Add a space b/w comment and the line
                padding = true,
                ---Whether the cursor should stay at its position
                sticky = true,
                ---Lines to be ignored while (un)comment
                ignore = nil,
                ---LHS of toggle mappings in NORMAL mode
                toggler = {
                    ---Line-comment toggle keymap
                    line = 'gcc',
                    ---Block-comment toggle keymap
                    block = 'gbc',
                },
                ---LHS of operator-pending mappings in NORMAL and VISUAL mode
                opleader = {
                    ---Line-comment keymap
                    line = 'gc',
                    ---Block-comment keymap
                    block = 'gb',
                },
                ---LHS of extra mappings
                extra = {
                    ---Add comment on the line above
                    above = 'gcO',
                    ---Add comment on the line below
                    below = 'gco',
                    ---Add comment at the end of line
                    eol = 'gcA',
                },
                ---Enable keybindings
                ---NOTE: If given `false` then the plugin won't create any mappings
                mappings = {
                    ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
                    basic = true,
                    ---Extra mapping; `gco`, `gcO`, `gcA`
                    extra = true,
                },
                ---Function to call before (un)comment
                pre_hook = nil,
                ---Function to call after (un)comment
                post_hook = nil,
            }
        },

        require 'kickstart/plugins/rainbow-csv',

        require 'kickstart/plugins/cmp',

        -- require 'kickstart/plugins/conform',

        require 'kickstart/plugins/gitsigns',


        -- THEME --
        require 'kickstart/plugins/theme-onedark',
        -- require 'kickstart/plugins/theme-moonlight',

        -- CORE --
        require 'kickstart/plugins/lualine',

        -- require 'kickstart/plugins/lspconfig',

        -- require 'kickstart/plugins/mini',

        require 'kickstart/plugins/telescope',

        -- require 'kickstart/plugins/todo-comments',

        -- require 'kickstart/plugins/tokyonight',

        require 'kickstart/plugins/treesitter',

        require 'kickstart/plugins/debug',

        require 'kickstart/plugins/lsp',
        -- require 'kickstart/plugins/which-key',

        -- require 'kickstart.plugins.indent_line',

    },

    {
        ui = {
            -- If Nerd Font, set icons to an empty table (uses nerd font defaults)
            -- otherwise define a unicode icons table
            icons = vim.g.have_nerd_font and {} or {
                cmd = '⌘',
                config = '🛠',
                event = '📅',
                ft = '📂',
                init = '⚙',
                keys = '🗝',
                plugin = '🔌',
                runtime = '💻',
                require = '🌙',
                source = '📄',
                start = '🚀',
                task = '📌',
                lazy = '💤 ',
            },
        },
    })
