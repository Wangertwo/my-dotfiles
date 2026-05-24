-- Lazy Bootstrapper (adapted from lazy.nvim bootstrap.lua)
local uv = vim.uv or vim.loop
if vim.env.LAZY_STDPATH then
    local root = vim.fn.fnamemodify(vim.env.LAZY_STDPATH, ":p"):gsub("[\\/]$", "")
    for _, name in ipairs({ "config", "data", "state", "cache" }) do
        vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
    end
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
    vim.api.nvim_echo({
        {
            "Cloning lazy.nvim\n\n",
            "DiagnosticInfo",
        },
    }, true, {})
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local ok, out = pcall(vim.fn.system, {
        "git",
        "clone",
        "--filter=blob:none",
        lazyrepo,
        lazypath,
    })
    if not ok or vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim\n", "ErrorMsg" },
            { vim.trim(out or ""), "WarningMsg" },
            { "\nPress any key to exit...", "MoreMsg" },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with options
require("lazy").setup({
    -- Import plugin specs from lua/plugins/*.lua
    { import = "plugins" },
}, {
    -- Lazy.nvim options
    defaults = {
        lazy = true, -- should plugins be lazy-loaded?
        version = false, -- use latest version
    },
    install = {
        colorscheme = { "tokyonight" },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
})
