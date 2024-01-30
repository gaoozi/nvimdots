local actions = require("telescope.actions")

local open_with_trouble = function(...)
  return require("trouble.providers.telescope").open_with_trouble(...)
end
local open_selected_with_trouble = function(...)
  return require("trouble.providers.telescope").open_selected_with_trouble(...)
end
local find_files_no_ignore = function()
  local action_state = require("telescope.actions.state")
  local line = action_state.get_current_line()
  require("telescope.builtin").find_files({ no_ignore = true, default_text = line })
  -- Util.telescope("find_files", { no_ignore = true, default_text = line })()
end
local find_files_with_hidden = function()
  local action_state = require("telescope.actions.state")
  local line = action_state.get_current_line()
  require("telescope.builtin").find_files({ hidden = true, default_text = line })
  -- Util.telescope("find_files", { hidden = true, default_text = line })()
end

require("telescope").setup({
  defaults = {
    prompt_prefix = " ",
    selection_caret = " ",
    -- open files in the first window that is an actual file.
    -- use the current window if no other window is available.
    get_selection_window = function()
      local wins = vim.api.nvim_list_wins()
      table.insert(wins, 1, vim.api.nvim_get_current_win())
      for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "" then
          return win
        end
      end
      return 0
    end,
    mappings = {
      i = {
        ["<c-t>"] = open_with_trouble,
        ["<a-t>"] = open_selected_with_trouble,
        ["<a-i>"] = find_files_no_ignore,
        ["<a-h>"] = find_files_with_hidden,
        ["<C-Down>"] = actions.cycle_history_next,
        ["<C-Up>"] = actions.cycle_history_prev,
        ["<C-f>"] = actions.preview_scrolling_down,
        ["<C-b>"] = actions.preview_scrolling_up,
      },
      n = {
        ["q"] = actions.close,
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
    },
    ["ui-select"] = {
      require("telescope.themes").get_cursor({}),
    },
  },
})

require("telescope").load_extension("fzf")
require("telescope").load_extension("ui-select")
require("telescope").load_extension("noice")
