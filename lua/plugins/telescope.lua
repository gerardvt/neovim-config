local actions = require('telescope.actions')
require('telescope').setup({
    defaults = {
        mappings = {
            i = {
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            }
        },
        scroll_strategy = 'limit',
        layout_strategy = 'vertical',
        layout_config = {
            vertical = {
                width = 0.8,
                preview_height = 0.7
            }
        },
    }
})

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files,  { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles,    { desc = 'Telescope old files' })
vim.keymap.set('n', '<leader>fq', builtin.quickfix,    { desc = 'Telescope quickfix list' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags,   { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fb', builtin.buffers,     { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fr', builtin.registers,   { desc = 'Telescope registers' })
vim.keymap.set('n', '<leader>fm', builtin.marks,       { desc = 'Telescope marks' })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Telescope diagnostics' })

vim.keymap.set('n', '<leader>fld', builtin.lsp_definitions,             { desc = 'Telescope lsp definitions' })
vim.keymap.set('n', '<leader>flt', builtin.lsp_type_definitions,        { desc = 'Telescope lsp type defs' })
vim.keymap.set('n', '<leader>flr', builtin.lsp_references,              { desc = 'Telescope lsp references' })
vim.keymap.set('n', '<leader>fli', builtin.lsp_implementations,         { desc = 'Telescope lsp implementations' })
vim.keymap.set('n', '<leader>fls', builtin.lsp_document_symbols,        { desc = 'Telescope lsp symbols (document)' })
vim.keymap.set('n', '<leader>flS', builtin.lsp_workspace_symbols,       { desc = 'Telescope lsp symbols (workspace)' })
vim.keymap.set('n', '<leader>flc', builtin.lsp_incoming_calls,          { desc = 'Telescope lsp calls (incoming)' })
vim.keymap.set('n', '<leader>flC', builtin.lsp_outgoing_calls,          { desc = 'Telescope lsp calls (outgoing)' })

vim.keymap.set('n', '<leader>ft', builtin.treesitter, { desc = 'Telescope treesitter' })

vim.keymap.set('n', '<leader>fg',
    function() builtin.live_grep() end,
    { desc = 'Telescope live grep' })

vim.keymap.set('n', '<leader>fG',
    function() builtin.grep_string({ search = vim.fn.input("Grep > ") }) end,
    { desc = 'Telescope fzf (prompted)' })

vim.keymap.set('n', '<leader>fs',
    function() builtin.grep_string({}) end,
    { desc = 'Telescope fzf (current symbol)' })

vim.keymap.set('n', '<leader>fv',
    function() builtin.find_files({ cwd = "~/.config/nvim/" }) end,
    { desc = 'Find vim config files' })
