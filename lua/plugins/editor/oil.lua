local oil = require("oil")
oil.setup({
  delete_to_trash = true,
  prompt_save_on_select_new_entry = false,
  restore_win_options = false,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    is_always_hidden = function(name, _)
      local always_hidden = {
        "..",
        ".git",
        "node_modules",
      }
      for _, a in ipairs(always_hidden) do
        if a == name then
          return true
        end
      end
    end,
  },
  float = {
    max_width = 60,
    max_height = 20,
  },
  keymaps = {
    ["gd"] = {
      desc = "toggle detail view",
      callback = function()
        local config = require("oil.config")
        if #config.columns == 1 then
          oil.set_columns({ "icon", "permissions", "size", "mtime" })
        else
          oil.set_columns({ "icon" })
        end
      end,
    },
  },
})
