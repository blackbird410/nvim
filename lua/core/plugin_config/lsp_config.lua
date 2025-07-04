require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "solargraph", "ts_ls", "gopls", "tailwindcss", "pyright", "clangd", "jdtls",}
})

local lspconfig = require('lspconfig')

local lsp_defaults = lspconfig.util.default_config

lsp_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lsp_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

require("lspconfig").lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.stdpath "config" .. "/lua"] = true,
        },
      },
    },
  }
}

lspconfig.solargraph.setup({})
-- lspconfig.tsserver.setup({})
lspconfig.ts_ls.setup({})
lspconfig.gopls.setup({})
lspconfig.tailwindcss.setup({})
lspconfig.pyright.setup({})
lspconfig.clangd.setup({})
lspconfig.jdtls.setup({})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  float = {
    border = "rounded",
    focusable = false,
  },
})

-- Show diagnostic popup on cursor hold
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})


-- Java LSP (`jdtls`) Setup
vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname == "" then return end

        local root_markers = { "pom.xml", ".git" }
        local root_dir = require("jdtls.setup").find_root(root_markers) or vim.fn.getcwd()

        if not root_dir then
            vim.notify("jdtls: No project root found", vim.log.levels.WARN)
            return
        end

        local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
        local workspace_dir = os.getenv("HOME") .. "/.local/share/eclipse/" .. project_name

        if not vim.fn.isdirectory(workspace_dir) then
            vim.fn.mkdir(workspace_dir, "p")
            vim.notify("jdtls: Created workspace directory at " .. workspace_dir, vim.log.levels.INFO)
        end

        require("jdtls").start_or_attach({
            cmd = { "jdtls" },
            root_dir = root_dir,
            capabilities = capabilities, -- Added capabilities
            workspace_folders = { { name = project_name, uri = vim.uri_from_fname(workspace_dir) } }, -- Changed to use uri
            settings = {
                java = {
                    project = {
                        sourcePaths = { "src/main/java" },
                    },
                },
            },
        })
    end,
})
