  -- Useful plugin to show pending keybinds.
  -- Uses `desc` attribute of your mapping as label
return {
    {
        'folke/which-key.nvim',
        event = 'VimEnter', -- Sets the loading event to 'VimEnter'
        config = function() -- This is the function that runs, AFTER loading
            which_key = require('which-key')
          which_key.setup()

          -- Document existing key chains
          which_key.register {
                ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
                ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
                ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
                ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
                ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
                ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
                ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
                ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
          }
            which_key.register(
                {
                  ['<leader>'] = { name = 'VISUAL <leader>' },
                  ['<leader>h'] = { 'Git [H]unk' },
                },
                { mode = 'v' }
            )
        end,
    },
}
