-- [[ Keymaps ]]
-- See `:help vim.keymap.set()`

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
-- Disabling for now until figure out compatibility with left-hand navigation
-- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

local vimp = require('vimp')

-- use semicolon for all colon commands
vimp.nnoremap(";", ":")

-- example function
-- vimp.nnoremap('<leader>hw', function()
--  print('hello')
--  print('world')
-- end)

-- netrw
--
local function set_netrw_keymap(key, action)
  --   vim.api.nvim_command(string.format('autocmd FileType netrw noremap <buffer> %s %s', key, action))
  vim.api.nvim_command(string.format('autocmd FileType netrw nmap <buffer> %s %s', key, action))
end

set_netrw_keymap('d', '<Up>')


-- Toggle line numbers ??


vimp.noremap("s", "h")
vimp.noremap("g", "l")
vimp.noremap("d", "k")
vimp.noremap("f", "j")
vimp.noremap("h", "g")
vimp.noremap("l", "s")
vimp.noremap("k", "d")
vimp.noremap("j", "f")
vimp.noremap("F", "<PAGEDOWN>M")
vimp.noremap("D", "<PAGEUP>M")


vim.keymap.set('n', ',j', ':bnext<CR>', { noremap = true, silent = true, desc = 'go to next buffer' })
vim.keymap.set('n', ',k', ':bprev<CR>', { noremap = true, silent = true, desc = 'go to next buffer' })
vim.keymap.set('n', ',fo', ':Explore<CR>', { noremap = true, silent = true, desc = 'open netrw file explorer' })

-- TODO: make all the keyboard stuff consistent
vim.keymap.set('n', ',y', '"*y', { noremap = true, silent = true, desc = 'yank to primary clipboard' })
vim.keymap.set('n', ',Y', '"+y', { noremap = true, silent = true, desc = 'yank to secondary clipboard' })
vim.keymap.set('n', '<leader>y', '"*y', { noremap = true, silent = true, desc = 'yank to primary clipboard' })
vim.keymap.set('n', '<leader>Y', '"+y', { noremap = true, silent = true, desc = 'yank to secondary clipboard' })
vim.api.nvim_set_keymap('n', 'hh', 'gg', { noremap = true, silent = true, desc = 'jump to top of file' })
-- vim.api.nvim_set_keymap('n', 'gg', 'G', { noremap = true, silent = true, desc = 'jump to bottom of file' })

vim.api.nvim_set_keymap('n', ',mm', ':MinimapToggle<CR>', { noremap = true, silent = true, desc = 'Toggle Minimap' })

vimp.nnoremap(',mn', function()
  vim.wo.number = not vim.wo.number
end)


vim.g.minimap_auto_start = 1
vim.g.minimap_auto_start_win_enter = 1
vim.g.minimap_git_colors = 1
-- vim.g.minimap_width = 2
