return {
    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
            { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "Open LazyGit for current file" },
            { "<leader>gl", "<cmd>LazyGitFilter<cr>", desc = "Open LazyGit commits" },
            { "<leader>gb", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "Open LazyGit commits for current file" },
        },
        config = function()
            local ok, _ = pcall(require, "telescope")
            if ok then
                require("telescope").load_extension("lazygit")
            end
        end,
    },
}
