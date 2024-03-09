
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

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim', opts = {} },

    require 'kickstart/plugins/rainbow-csv',

    require 'kickstart/plugins/cmp',

    -- require 'kickstart/plugins/conform',

    require 'kickstart/plugins/gitsigns',

    require 'kickstart/plugins/theme-onedark',

    require 'kickstart/plugins/lualine',

    -- require 'kickstart/plugins/lspconfig',

    -- require 'kickstart/plugins/mini',

    -- require 'kickstart/plugins/telescope',

    -- require 'kickstart/plugins/todo-comments',

    -- require 'kickstart/plugins/tokyonight',

    require 'kickstart/plugins/treesitter',

    require 'kickstart/plugins/lsp',
    -- require 'kickstart/plugins/which-key',

    -- require 'kickstart.plugins.debug',
    -- require 'kickstart.plugins.indent_line',

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    This is the easiest way to modularize your config.
    --
    --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
    -- { import = 'custom.plugins' },
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

