-- ---------------------------------------------------------
-- Version guard: this configuration requires Neovim 0.12+.
--
-- It relies on APIs and commands introduced in Neovim 0.12 that do not
-- exist in earlier versions:
--
--   vim.pack           — built-in package manager (replaces lazy.nvim)
--   vim.lsp.config     — built-in LSP server configuration (replaces nvim-lspconfig)
--   vim.lsp.completion — built-in LSP completion (replaces blink.cmp / nvim-cmp)
--   :restart           — clean process restart command
--
-- If you need to run this config on an older Neovim, check out the `main`
-- branch, which uses lazy.nvim, Mason, and blink.cmp instead.
-- ---------------------------------------------------------
if vim.fn.has('nvim-0.12') == 0 then
    vim.notify(
        'This Neovim configuration requires Neovim 0.12 or later.\n' ..
        'You are running ' .. vim.version().major .. '.' .. vim.version().minor .. '.' .. vim.version().patch .. '.\n' ..
        'No options, keymaps, or plugins have been loaded.\n' ..
        'Upgrade Neovim or switch to the `main` branch of this config, which supports older versions.',
        vim.log.levels.ERROR
    )
    return
end

-- --------------------------------------------------------
-- Setup options (prior to plugins load/config).
-- ---------------------------------------------------------
require('config.options')

-- ---------------------------------------------------------
-- Setup key mappings (prior to plugins load/config).
-- ---------------------------------------------------------
require('config.keymappings')

-- ---------------------------------------------------------
-- Plugin installation and setup via vim.pack (Neovim 0.12+)
-- ---------------------------------------------------------
require('config.packages')
