return {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        {
            "malewicz1337/oil-git.nvim",
            opts = {
                show_ignored_files = true,
            },
        },
    },
    keys = {
        { "-", "<cmd>Oil<cr>", desc = "Open oil file explorer" },
    },
    opts = {
        default_file_explorer = true,
        columns = { "icon" },
        view_options = {
            show_hidden = false,
        },
        skip_confirm_for_simple_edits = true,
        keymaps = {
            ["q"] = "actions.close",
            ["<leader>w"] = {
                callback = function()
                    require("oil").save({ confirm = false })
                end,
                desc = "Save oil changes",
            },
            ["<leader>yp"] = {
                "actions.yank_entry",
                desc = "Yank absolute path",
            },
            ["<leader>yP"] = {
                callback = function()
                    require("oil.actions").yank_entry.callback({ modify = ":." })
                end,
                desc = "Yank relative path",
            },
            ["<leader>yn"] = {
                callback = function()
                    local entry = require("oil").get_cursor_entry()
                    if entry then
                        vim.fn.setreg(vim.v.register, entry.name)
                    end
                end,
                desc = "Yank filename",
            },
        },
    },
}
