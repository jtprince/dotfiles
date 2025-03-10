return {
  {
    'shaunsingh/moonlight.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      require('moonlight').set()
    end,
  },
}
