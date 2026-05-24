return {
    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
        keys = {
            {
                "<leader>bm",
                function ()
                    require'snacks'.picker.buffers()
                end,
                desc = "Pick buffers",
            },
        },
    },
}
