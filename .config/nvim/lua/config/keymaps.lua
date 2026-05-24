-- Basic keymaps

-- Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true, desc = "Move to window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true, desc = "Move to window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true, desc = "Move to window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true, desc = "Move to window right" })

-- Resize windows
vim.keymap.set("n", "<S-Up>", ":resize +2<CR>", { noremap = true, silent = true, desc = "Increase window height" })
vim.keymap.set("n", "<S-Down>", ":resize -2<CR>", { noremap = true, silent = true, desc = "Decrease window height" })
vim.keymap.set(
    "n",
    "<S-Left>",
    ":vertical resize +2<CR>",
    { noremap = true, silent = true, desc = "Increase window width" }
)
vim.keymap.set(
    "n",
    "<S-Right>",
    ":vertical resize -2<CR>",
    { noremap = true, silent = true, desc = "Decrease window width" }
)

-- Better indenting
vim.keymap.set("v", "<leader><", function()
    vim.cmd("normal! " .. vim.v.count1 .. "<gv")
    vim.fn["repeat#set"]("<leader><", vim.v.count)
end, { noremap = true, silent = true, desc = "Indent left" })
vim.keymap.set("v", "<leader>>", function()
    vim.cmd("normal! " .. vim.v.count1 .. ">gv")
    vim.fn["repeat#set"]("<leader>>", vim.v.count)
end, { noremap = true, silent = true, desc = "Indent right" })

-- Move selected line/block
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection up" })

-- Clear search highlights
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { noremap = true, silent = true, desc = "Clear search highlights" })

-- Terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Exit terminal mode" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -vim.v.count1 })
end, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = vim.v.count1 })
end, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show diagnostic error messages" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })

-- LSP keymaps will be set up in lsp.lua

-- Save files
vim.keymap.set("n", "<leader>s", "<cmd>w<CR>", { noremap = true, silent = true, desc = "Save current file" })
vim.keymap.set({ "n", "v" }, "<leader>w", "<cmd>wa<CR>", { noremap = true, silent = true, desc = "Save all files" })

-- Edit shortcuts
vim.keymap.set("n", "<leader>z", "u", { noremap = true, silent = true, desc = "Undo" })
vim.keymap.set("v", "<leader>c", "y", { noremap = true, silent = true, desc = "Copy selection" })
vim.keymap.set("n", "<leader>v", "p", { noremap = true, silent = true, desc = "Paste" })
vim.keymap.set("v", "<leader>v", "p", { noremap = true, silent = true, desc = "Paste over selection" })

-- function vim.list_wins()
--     local function is_floating(winnr)
--         local config = vim.api.nvim_win_get_config(winnr)
--         -- Floating windows have a 'relative' attribute that is not empty
--         -- or a 'zindex' attribute.
--         return config.relative ~= "" or config.zindex ~= nil
--     end
--
--     local win_list = {}
--     for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
--         if vim.api.nvim_win_get_height(win) ~= -1 and vim.api.nvim_win_get_width(win) ~= -1 and not is_floating(win) then
--             win_list[#win_list+1] = win
--         end
--     end
--
--     return win_list
-- end

-- Smart close with 'q'
vim.keymap.set("n", "q", function()
    local function is_floating(winnr)
        local config = vim.api.nvim_win_get_config(winnr)
        -- Floating windows have a 'relative' attribute that is not empty
        -- or a 'zindex' attribute.
        return config.relative ~= "" or config.zindex ~= nil
    end

    local win_list = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if
            vim.api.nvim_win_get_height(win) ~= -1
            and vim.api.nvim_win_get_width(win) ~= -1
            and not is_floating(win)
        then
            win_list[#win_list + 1] = win
        end
    end
    local win_count = #win_list
    local listed_bufs = #vim.tbl_filter(function(b)
        return vim.bo[b].buflisted and vim.api.nvim_buf_is_loaded(b)
    end, vim.api.nvim_list_bufs())

    local function is_modifiable(bufnr)
        return vim.bo[bufnr].modifiable and vim.bo[bufnr].buftype == ""
    end

    local function is_modified(bufnr)
        return vim.bo[bufnr].modified and is_modifiable(bufnr)
    end

    if win_count > 1 or is_floating(0) then
        vim.cmd("hide")
    elseif listed_bufs > 1 then
        if is_modified(0) then
            vim.cmd("write")
        end
        vim.cmd("bnext")
        vim.cmd("bdelete #")
    else
        if is_modified(0) then
            vim.cmd("write")
        end
        vim.cmd("quit")
    end
end, { desc = "Smart close window/buffer/quit with save" })

vim.keymap.set("v", "q", "<Esc>", { noremap = true, desc = "Quit visual mode" })

-- Map gq to original q (macro record)
vim.keymap.set("n", "gq", "q", { noremap = true, silent = true, desc = "Start macro recording" })

-- Buffer navigation
vim.keymap.set("n", "[b", function()
    for _ = 1, vim.v.count1 do
        vim.cmd.bprevious()
    end
end, { desc = "Previous buffer" })
vim.keymap.set("n", "]b", function()
    for _ = 1, vim.v.count1 do
        vim.cmd.bnext()
    end
end, { desc = "Next buffer" })
vim.keymap.set("n", "[B", function()
    local bufs = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())
    local idx = math.min(vim.v.count1, #bufs)
    vim.cmd.buffer(bufs[idx])
end, { desc = "First buffer" })
vim.keymap.set("n", "gb", "<cmd>buffer #<CR>", { desc = "Alternate buffer" })
vim.keymap.set("n", "gB", "<cmd>buffer #<CR>", { desc = "Alternate buffer" })
vim.keymap.set("n", "]B", function()
    local bufs = vim.tbl_filter(function(b)
        return vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())
    local idx = math.max(#bufs - vim.v.count1 + 1, 1)
    vim.cmd.buffer(bufs[idx])
end, { desc = "Last buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

vim.keymap.set("n", "<f1>", "", { desc = "Do nothing" })

vim.keymap.set("i", "aa", "<Esc>", {
    noremap = true,
    silent = true,
    desc = "Exit insert mode",
})
