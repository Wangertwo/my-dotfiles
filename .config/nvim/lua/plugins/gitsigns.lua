return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        signcolumn = true,
        signs_staged_enable = true,
        watch_gitdir = {
            follow_files = true,
        },
    },
}
