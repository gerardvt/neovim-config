-- =====================================================================================
-- Floating terminal toggle
-- =====================================================================================
-- Provides a toggleable floating terminal window. Nothing in Neovim 0.12+ replicates
-- this — the built-in :terminal always opens in a split or the current window.
--
-- Features:
--   - Floating window centered at 80% of screen dimensions
--   - Toggle show/hide via <leader>t or :Flterm without destroying the shell session
--     (nvim_win_hide preserves the buffer so the shell process survives across hides)
--   - Session persistence: the same buffer is reused across toggles so shell history
--     and state are maintained for the lifetime of the Neovim session
--   - <esc><esc> hides the floating window directly from terminal mode
--   - border = 'rounded' is set explicitly on the nvim_open_win call because
--     style = 'minimal' suppresses UI chrome inside the window but does not affect
--     the border, so winborder (options.lua) cannot be relied on here
-- =====================================================================================

local state = {
    floating = {
        buf = -1,
        win = -1,
    }
}

-- Function that opens the builtin terminal in a floating window
local function open_floating_terminal(opts)
    opts = opts or {}
    local width = opts.width or math.floor(vim.o.columns * 0.9)
    local height = opts.height or math.floor(vim.o.lines * 0.9)

    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true)
    end
    if not buf then
        error("Failed to create buffer")
    end

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    })

    return { buf = buf, win = win }
end

local toggle_terminal = function()
    if not vim.api.nvim_win_is_valid(state.floating.win) then
        state.floating = open_floating_terminal({ buf = state.floating.buf });
        if vim.bo[state.floating.buf].buftype ~= "terminal" then
            vim.cmd.terminal()
            vim.cmd("startinsert!")
        end
    else
        vim.api.nvim_win_hide(state.floating.win)
    end
end

vim.api.nvim_create_user_command("Flterm", toggle_terminal, {})
vim.api.nvim_set_keymap('n', '<leader>t', [[:Flterm<CR>]], { noremap = true, silent = true })

-- <esc><esc> in terminal mode hides the floating window directly, mirroring
-- what <leader>t does from normal mode outside the terminal.
vim.keymap.set("t", "<esc><esc>", function()
    vim.api.nvim_win_hide(state.floating.win)
end)
