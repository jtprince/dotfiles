
-- Do we need this anymore since in neovim stdlib ??
return {
    {
     'nvim-treesitter/nvim-treesitter',
     dependencies = {
       'nvim-treesitter/nvim-treesitter-textobjects',
     },
     build = ':TSUpdate',
   },
}

