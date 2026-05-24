return {
    -- Mason: LSP installer
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            })
        end,
    },

    -- Mason tool installer (for non-LSP tools)
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        lazy = false,
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            if vim.fn.executable('tree-sitter') ~= 1 then
                require("mason-tool-installer").setup({
                    ensure_installed = {
                        "tree-sitter-cli",
                    },
                })
            end
        end,
    },

    -- Mason LSP config integration
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            local servers = {
                "lua_ls",
                "bashls",
                "pyright",
                "rust_analyzer",
                "ts_ls",
                "html",
                "cssls",
                "jsonls",
                "yamlls",
                "fish_lsp",
                "clangd",
            }

            require("mason-lspconfig").setup({
                automatic_installation = true,
                ensure_installed = servers,
            })

            vim.keymap.set(
                "n",
                "gd",
                vim.lsp.buf.definition,
                { noremap = true, silent = true, desc = "Go to definition" }
            )
            vim.keymap.set(
                "n",
                "grd",
                vim.lsp.buf.declaration,
                { noremap = true, silent = true, desc = "Go to declaration" }
            )
            vim.keymap.set(
                "n",
                "grt",
                vim.lsp.buf.type_definition,
                { noremap = true, silent = true, desc = "Go to type definition" }
            )
            vim.keymap.set(
                "n",
                "gri",
                vim.lsp.buf.implementation,
                { noremap = true, silent = true, desc = "Go to implementation" }
            )
            vim.keymap.set(
                "n",
                "grr",
                vim.lsp.buf.references,
                { noremap = true, silent = true, desc = "Show references" }
            )
            vim.keymap.set("n", "grn", vim.lsp.buf.rename, { noremap = true, silent = true, desc = "Rename symbol" })
            vim.keymap.set("n", "gra", vim.lsp.buf.code_action, { noremap = true, silent = true, desc = "Code action" })
            vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true, desc = "Hover documentation" })
            vim.keymap.set(
                "n",
                "<C-k>",
                vim.lsp.buf.signature_help,
                { noremap = true, silent = true, desc = "Signature help" }
            )
            vim.keymap.set(
                "n",
                "<leader>gwa",
                vim.lsp.buf.add_workspace_folder,
                { noremap = true, silent = true, desc = "Add workspace folder" }
            )
            vim.keymap.set(
                "n",
                "<leader>gwr",
                vim.lsp.buf.remove_workspace_folder,
                { noremap = true, silent = true, desc = "Remove workspace folder" }
            )
            vim.keymap.set("n", "<leader>gwl", function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, { noremap = true, silent = true, desc = "List workspace folders" })
            vim.keymap.set("n", "<leader>gf", function()
                vim.lsp.buf.format({ async = true })
            end, { noremap = true, silent = true, desc = "Format buffer" })

            -- Setup LSP keymaps and capabilities
            local on_attach = function(client, bufnr)
                -- Enable completion triggered by <c-x><c-o>
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            end

            -- Capabilities for nvim-cmp
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Enable servers
            for _, server in ipairs(servers) do
                vim.lsp.config(server, {
                    on_attach = on_attach,
                    capabilities = capabilities,
                    -- 增加文件大小限制到 10MB
                    settings = {
                        Lua = {
                            workspace = {
                                -- 允许更大的工作空间
                                maxPreload = 5000,
                                preloadFileSize = 10000,
                            },
                            -- 只显示警告级别的日志，过滤掉信息级别
                            diagnostics = {
                                enable = true,
                                globals = { "vim" },
                                workspaceDelay = 100,
                                disable = { "lower-global" },
                                severityThreshold = {
                                    min = vim.lsp.protocol.DiagnosticSeverity.Warning,
                                    max = vim.lsp.protocol.DiagnosticSeverity.Error,
                                },
                            },
                        },
                    },
                })
                vim.lsp.enable(server)
            end
        end,
    },

    -- nvim-lspconfig (provides configs, but we use vim.lsp.config)
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            -- Nothing to configure here, configs are automatically loaded
            -- We can add custom configs using vim.lsp.config()
        end,
    },

    -- Cmp LSP capabilities
    {
        "hrsh7th/cmp-nvim-lsp",
        event = 'VeryLazy',
    },

    {
        'smjonas/inc-rename.nvim',
        event = 'VeryLazy',
        cmd = 'IncRename',
        opts = {},
    },
}
