-- =====================================================================================
-- Explorer split
-- =====================================================================================
-- Opens netrw in a horizontal split at the top of the editor. When a file is
-- selected, the split closes and the file opens in the window that was active
-- before the explorer was opened. Directory navigation within netrw works normally.
--
-- No plugins required — uses Neovim's built-in netrw and split/window APIs.
-- Does not modify g:netrw_browse_split or any other global netrw setting.
--
-- Keymaps / commands:
--   <leader>e  (normal mode)  toggle the explorer split
--   :Explorer                 same
-- =====================================================================================

local state = {
    win      = -1,   -- explorer window id
    prev_win = -1,   -- window that was active before the explorer was opened
    augroup  = nil,  -- augroup id for the redirect autocmd (cleaned up on close)
}

local function close_explorer()
    if state.augroup then
        vim.api.nvim_del_augroup_by_id(state.augroup)
        state.augroup = nil
    end
    if vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.win = -1
end

local function open_explorer()
    state.prev_win = vim.api.nvim_get_current_win()

    vim.cmd('topleft split')
    vim.cmd('resize ' .. math.floor(vim.o.lines * 0.3))
    state.win = vim.api.nvim_get_current_win()
    vim.cmd('Explore')

    -- Watch for netrw opening a file in the explorer window.
    -- BufEnter fires after netrw runs :edit on the selected file.
    -- Directory navigation keeps filetype = 'netrw', so those are ignored.
    -- When the buffer is a real file (filetype ~= 'netrw'), redirect it to
    -- prev_win and close the explorer split.
    state.augroup = vim.api.nvim_create_augroup('explorer-redirect', { clear = true })
    vim.api.nvim_create_autocmd('BufEnter', {
        group = state.augroup,
        callback = function(ev)
            if vim.api.nvim_get_current_win() ~= state.win then return end
            if vim.bo[ev.buf].filetype == 'netrw' then return end

            local buf      = ev.buf
            local prev_win = state.prev_win

            close_explorer()

            if vim.api.nvim_win_is_valid(prev_win) then
                vim.api.nvim_set_current_win(prev_win)
                vim.api.nvim_win_set_buf(prev_win, buf)
            end
        end,
    })
end

local function toggle_explorer()
    if vim.api.nvim_win_is_valid(state.win) then
        close_explorer()
        if vim.api.nvim_win_is_valid(state.prev_win) then
            vim.api.nvim_set_current_win(state.prev_win)
        end
    else
        open_explorer()
    end
end

vim.api.nvim_create_user_command('Explorer', toggle_explorer, {})
vim.keymap.set('n', '<leader>e', toggle_explorer, { desc = 'Toggle explorer split' })
