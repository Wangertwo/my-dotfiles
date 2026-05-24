return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "tsakirist/telescope-lazy.nvim",
            config = function()
                require("telescope").load_extension("lazy")
            end,
        },
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            config = function()
                require("telescope").load_extension("fzf")
            end,
            -- optional = true,
        },
    },
    keys = {
        { "<leader>ff", "<cmd>Telescope fd<cr>", desc = "Find files" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
        { "<leader>fs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
        { "<leader>fF", "<cmd>Telescope git_files<cr>", desc = "Git Files" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
        { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
        { "<leader>fo", "<cmd>Telescope resume<cr>", desc = "Diagnostics" },
    },
    opts = {
        defaults = {
            mappings = {
                i = {},
            },
        },
        pickers = {
            find_files = {
                hidden = true,
            },
        },
    },
    config = function(_, opts)
        require("telescope").setup(opts)
        require("telescope").load_extension("fzf")
        require("telescope").load_extension("lazy")
    end,
}
