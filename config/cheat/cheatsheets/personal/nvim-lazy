# some plugins do NOT require setup to be run. If they do, then you need to do
# one of these three things:

# Change no mappings but setup the plugin
{
  'echasnovski/mini.surround', opts = {}
},

# Equivalent (because of how lazy.nvim processes)
{
  'echasnovski/mini.surround',
  config = true
},

# Effectively, what this does is run this:
{
  'echasnovski/mini.surround',
  config = function()
    require('mini.surround').setup()
  end
},

# Can use the init function to make keymappings
{
  "Pocco81/auto-save.nvim",
  init = function()
    require('which-key').register({
      t = {
        a = { ':ASToggle<CR>', 'Autosave' },
      }
    }, { prefix = '<leader>' })
  end
},
