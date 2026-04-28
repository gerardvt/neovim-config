-- ------------------------------------------------------------------------------
-- Only proceed if we are using Neovim version 0.12+.
-- This configuration relies on new APIs and commands introduced in Neovim 0.12:
--   vim.pack           — The built-in package manager
--   vim.lsp.config     — The built-in LSP server configuration
--   vim.lsp.completion — THe built-in LSP completion.
--   :restart           — The new clean process restart command.
-- ------------------------------------------------------------------------------
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
