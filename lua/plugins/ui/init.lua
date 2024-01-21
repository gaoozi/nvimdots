return {
  -- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("plugins.ui.noice")
    end,
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = "VeryLazy",
    config = function()
      require("plugins.ui.lualine")
    end
  },

  -- Hyperextensible plugin for Neovim's 'statusline', 'tabline' and 'winbar'.
  {
    "MunifTanjim/nougat.nvim",
    enabled = false,
    event = "VeryLazy",
    config = function()
      require("plugins.ui.nougat")
    end,
  },
}
