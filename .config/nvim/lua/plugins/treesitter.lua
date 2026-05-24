return {
    -- nvim-treesitter (main branch)
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            -- Minimal setup (no configuration table needed)
            require("nvim-treesitter").setup()

            -- Auto-enable highlighting for filetypes
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                callback = function(args)
                    local ft = vim.bo[args.buf].filetype
                    local lang = vim.treesitter.language.get_lang(ft)
                    if lang and vim.treesitter.language.add(lang) then
                        vim.treesitter.start(args.buf, lang)
                    end
                end,
            })
        end,
    },

    -- Auto-install parsers
    {
        "mks-h/treesitter-autoinstall.nvim",
        lazy = false,
        config = function()
            require("treesitter-autoinstall").setup({
                highlight = true,
                ignore = {},
                regex = {},
            })
        end,
    },

    -- Textobjects
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = "VeryLazy",
        branch = "main",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        init = function()
            -- Disable entire built-in ftplugin mappings to avoid conflicts.
            -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
            vim.g.no_plugin_maps = true
        end,
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,
                    -- You can choose the select mode (default is charwise 'v')
                    --
                    -- Can also be a function which gets passed a table with the keys
                    -- * query_string: eg '@function.inner'
                    -- * method: eg 'v' or 'o'
                    -- and should return the mode ('v', 'V', or '<c-v>') or a table
                    -- mapping query_strings to modes.
                    selection_modes = {
                        ["@parameter.outer"] = "v", -- charwise
                        ["@function.outer"] = "V", -- linewise
                        ["@class.outer"] = "V", -- linewise
                    },
                    -- If you set this to `true` (default is `false`) then any textobject is
                    -- extended to include preceding or succeeding whitespace. Succeeding
                    -- whitespace has priority in order to act similarly to eg the built-in
                    -- `ap`.
                    --
                    -- Can also be a function which gets passed a table with the keys
                    -- * query_string: eg '@function.inner'
                    -- * selection_mode: eg 'v'
                    -- and should return true of false
                    include_surrounding_whitespace = false,
                },
                move = {
                    -- whether to set jumps in the jumplist
                    set_jumps = true,
                },
            })

            local textobjects = {
                ["m"] = "function",
                ["a"] = "parameter",
                ["c"] = "class",
                ["k"] = "block",
                ["e"] = "comment",
                ["f"] = "call",
                ["g"] = "assignment",
                ["y"] = "assignment.lhs/rhs",
                ["z"] = "statement",
                ["x"] = "number",
                ["o"] = "loop",
                ["u"] = "conditional",
                ["r"] = "return",
            }

            for key, obj in pairs(textobjects) do
                local obj_outer = "@" .. obj .. ".outer"
                local obj_inner = "@" .. obj .. ".inner"
                if obj == 'assignment.lhs/rhs' then
                    obj_inner = "@assignment.lhs"
                    obj_outer = "@assignment.rhs"
                end
                if obj == 'statement' then
                    obj_inner = "@statement.outer"
                end
                if obj == 'number' then
                    obj_outer = "@number.inner"
                end

                vim.keymap.set({ "x", "o" }, "a" .. key, function()
                    require("nvim-treesitter-textobjects.select").select_textobject(obj_outer, "textobjects")
                end, { desc = "Select " .. obj_outer })
                vim.keymap.set({ "x", "o" }, "i" .. key, function()
                    require("nvim-treesitter-textobjects.select").select_textobject(obj_inner, "textobjects")
                end, { desc = "Select " .. obj_inner })

                vim.keymap.set("n", "gsl" .. key, function()
                    require("nvim-treesitter-textobjects.swap").swap_next(obj_inner)
                end)
                vim.keymap.set("n", "gsh" .. key, function()
                    require("nvim-treesitter-textobjects.swap").swap_previous(obj_inner)
                end)
                vim.keymap.set("n", "gsj" .. key, function()
                    require("nvim-treesitter-textobjects.swap").swap_next(obj_outer)
                end)
                vim.keymap.set("n", "gsk" .. key, function()
                    require("nvim-treesitter-textobjects.swap").swap_previous(obj_outer)
                end)

                local key_upper = key:upper()
                vim.keymap.set({ "n", "x", "o" }, "]" .. key, function()
                    require("nvim-treesitter-textobjects.move").goto_next_start(obj_outer, "textobjects")
                end)
                vim.keymap.set({ "n", "x", "o" }, "[" .. key, function()
                    require("nvim-treesitter-textobjects.move").goto_previous_start(obj_outer, "textobjects")
                end)
                vim.keymap.set({ "n", "x", "o" }, "]" .. key_upper, function()
                    require("nvim-treesitter-textobjects.move").goto_next_end(obj_outer, "textobjects")
                end)
                vim.keymap.set({ "n", "x", "o" }, "[" .. key_upper, function()
                    require("nvim-treesitter-textobjects.move").goto_previous_end(obj_outer, "textobjects")
                end)
                vim.keymap.set({ "n", "x", "o" }, "g]" .. key, function()
                    require("nvim-treesitter-textobjects.move").goto_next_start(obj_inner, "textobjects")
                end)
                vim.keymap.set({ "n", "x", "o" }, "g[" .. key, function()
                    require("nvim-treesitter-textobjects.move").goto_previous_start(obj_inner, "textobjects")
                end)
                vim.keymap.set({ "n", "x", "o" }, "g]" .. key_upper, function()
                    require("nvim-treesitter-textobjects.move").goto_next_end(obj_inner, "textobjects")
                end)
                vim.keymap.set({ "n", "x", "o" }, "g[" .. key_upper, function()
                    require("nvim-treesitter-textobjects.move").goto_previous_end(obj_inner, "textobjects")
                end)
            end
        end,
    },
}
