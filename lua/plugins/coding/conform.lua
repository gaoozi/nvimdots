local status, conform = pcall(require, "conform")
if not status then
  vim.notify("not found conform")
end

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
  },
})
