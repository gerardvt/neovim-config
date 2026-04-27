-- ------------------------------------------------------------
-- General keymappings
-- ------------------------------------------------------------

-- Set the "leader key" used as a prefix for custom key mappings.
-- <LocalLeader> is just like <Leader>, except that it is used for mappings
-- which are local to a buffer.
-- If they are different, there is a smaller chance of mappings from global
-- plugins to clash with mappings for filetype plugins.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Open built-in file explorer
vim.keymap.set("n", "<leader>cd", vim.cmd.Explore)

-- Move highlighted lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor in place while moving up/down page
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Center screen when looping search results
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste and don't replace clipboard over deleted text
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Sometimes in insert mode, control-c doesn't exactly work like escape
vim.keymap.set("i", "<C-c>", "<Esc>")

-- ???
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

-- What the heck is Ex mode?
vim.keymap.set("n", "Q", "<nop>")

-- ???
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Replace all instances of whatever is under cursor (on line)
vim.keymap.set("n", "<leader>s", [[:s/\<<C-r><C-w>\>//gI<Left><Left><Left>]])

-- Restart Neovim (clean process restart, preserving argv)
vim.keymap.set("n", "<leader>rl", "<cmd>restart<cr>")

-- Search for file
vim.keymap.set('n', '<leader>F', '<cmd>cexpr system("find -type f -name vim.fn.input("Grep > ") | copen<cr>')

-- Remap joining lines
-- It checks if a count was provided; if so, it applies it to J,
-- otherwise it just does a standard join, all while keeping your cursor still.
-- Using this instead of: vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "J", function()
  local count = vim.v.count
  if count == 0 then count = 1 end -- Default to 1 if no count
  
  -- Join (v.count + 1) lines total to match default J behavior
  vim.cmd('normal! mz' .. (count + 1) .. 'J`z')
end, { desc = "Join lines and keep cursor in place" })

