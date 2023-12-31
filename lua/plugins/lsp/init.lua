return {
  --  Automatic package management
  {
    'williamboman/mason.nvim',
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require("mason-registry")

      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      -- auto install
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
            vim.notify("Install " .. tostring(tool) .. "...")
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- Lspconfig
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPost",
    dependencies = {
      { "folke/neodev.nvim", opts = {} },
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "simrat39/rust-tools.nvim",
    },
    opts = {
      -- options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
          -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
          -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
          -- prefix = "icons",
        },
        severity_sort = true,
      },
      -- lsp servers
      servers = {
        lua_ls = require("plugins.lsp.servers.lua_ls"),
        cssls = require("plugins.lsp.servers.cssls"),
        jsonls = require("plugins.lsp.servers.jsonls"),
        rust_analyzer = require("plugins.lsp.servers.rust_analyzer"),
      },
    },
    config = function(_, opts)
      -- keymaps
      local function lsp_keymaps(bufnr)
        local builtin = require 'telescope.builtin'

        local map_opts = { buffer = bufnr, silent = true }
        vim.keymap.set('n', 'gd', function() builtin.lsp_definitions({ reuse_win = true }) end, map_opts)
        vim.keymap.set('n', 'gI', function() builtin.lsp_implementations({ reuse_win = true }) end, map_opts)
        vim.keymap.set('n', 'gy', function() builtin.lsp_type_definitions({ reuse_win = true }) end, map_opts)
        vim.keymap.set('n', 'gr', builtin.lsp_references, map_opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, map_opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, map_opts)
        vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, map_opts)
        vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help, map_opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, map_opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>cA', function()
          vim.lsp.buf.code_action({
            context = {
              only = {
                "source",
              },
              diagnostics = {},
            },
          })
        end, map_opts)
      end

      -- diagnostic
      for name, icon in pairs(require("config").icons.diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- capabilities
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        opts.capabilities or {}
      )

      -- setup servers
      local servers = opts.servers
      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          on_attach = function(_, bufnr)
            lsp_keymaps(bufnr)
          end,
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        require("lspconfig")[server].setup(server_opts)
      end

      -- get all the servers that are available through mason-lspconfig
      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mslp_servers = {}
      if have_mason then
        all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local ensure_installed = {}
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup 
          -- 1. if mason=false 
          -- 2. if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      -- auto install servers by 'mason-lspconfig'
      if have_mason then
        mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
      end
    end
  },
}
