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