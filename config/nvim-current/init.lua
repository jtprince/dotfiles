-- TODO:
-- [x] break out config into individual files
--      [x] get basic functionality running
--      [ ] clean and tidy things up
--
-- [ ] integrate chatgpt or copilot
-- [ ] colorscheme switcher
--    [ ] make vertical lines much lighter in in moonlight scheme
-- [ ] faster cursor movement
-- [x] get telescope functions mapped how I like (e.g., ",fs" ",ff", ",fb" etc)
-- [ ] get all my ftplugins ported over
--    [ ] python
--    [ ] markdown
-- [ ] get similar markdown functionality ported
--    [ ] gitlinker.nvim
--    [ ] godlygeek/tabular
--    [ ] plasticboy/vim-markdown
--    [ ] vim-markdown-folding
-- [ ] vim-json
-- [ ] pre-commit.nvim
-- [AND ALL THE OTHER FUNC in init.vim!!!!!]
-- [[ FILL THIS IN, STILL ]]
-- [ ] figure out how to call ruff format whole file
-- [ ] remove ctags from archup since func provided by lsp
-- [ ] either install nerdcommenter or figure out how to do in lsp
-- [ ] figure out equivalent of chadtree
-- [ ] figure out pytest framework, especially something that lets me jump to an error
--
-- Set <space> as the leader key
-- See `:help mapleader`
--
-- =========== DONE ===========
-- [x] get highlight color right
-- [x] bring over preferred options from nvim-new
-- [x] fix telescope breakage
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'lazy-bootstrap'

require 'lazy-plugins'

--   {
--     -- Add indentation guides even on blank lines
--     'lukas-reineke/indent-blankline.nvim',
--     -- Enable `lukas-reineke/indent-blankline.nvim`
--     -- See `:help ibl`
--     main = 'ibl',
--     opts = {},
--   },
--
--   -- { 'ggandor/leap.nvim' },
--
--   -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
--   --       These are some example plugins that I've included in the kickstart repository.
--   --       Uncomment any of the lines below to enable them.
--   -- require 'kickstart.plugins.autoformat',
--   -- require 'kickstart.plugins.debug',
--
--   -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
--   --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
--   --    up-to-date with whatever is in the kickstart repo.
--   --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
--   --
--   --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
--   -- { import = 'custom.plugins' },
-- }, {})

-- require('moonlight').set()

-- require('leap').create_default_mappings()
-- require('leap').opts.special_keys.prev_target = '<bs>'
-- require('leap').opts.special_keys.prev_group = '<bs>'
-- require('leap.user').set_repeat_keys('<cr>', '<bs>')

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = true })
  end,
})

require 'options'

require 'keymaps'

require 'treesitter-config'

require 'lsp-config'

-- [[ Configure nvim-cmp ]]
-- TODO: remove from init.lua
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}
