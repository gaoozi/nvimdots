local check_file_size = function(lang, bufnr)
  return vim.api.nvim_buf_line_count(bufnr) > 100000
end

---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    use_languagetree = true,
    disable = check_file_size,
  },
  indent = {
    enable = true,
  },
  playground = {
    enable = false,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
  },
  autotag = {
    enable = true,
    disable = check_file_size,
  },
  ensure_installed = {
    "bash",
    "c",
    "css",
    "diff",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "regex",
    "toml",
    "tsx",
    "typescript",
    "vue",
    "vim",
    "vimdoc",
    "scss",
    "sql",
    "rust",
    "yaml",
  },
})
