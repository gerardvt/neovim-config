-- =====================================================================================
-- Plugin management via vim.pack (built-in Neovim 0.12+)
-- =====================================================================================

vim.pack.add({
    { src = 'https://github.com/nvim-telescope/telescope.nvim' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
    { src = 'https://github.com/folke/which-key.nvim' },
    { src = 'https://github.com/echasnovski/mini.icons' },
    { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
    { src = 'https://github.com/j-hui/fidget.nvim' },
    { src = 'https://github.com/mikesmithgh/kitty-scrollback.nvim' },
})

-- Plugin setup
require('plugins.telescope')
require('plugins.lualine')
require('plugins.whichkey')
require('plugins.indentblankline')
require('plugins.kitty-scrollback')
require('plugins.fidget')

-- LSP servers + completion
require('plugins.lsp')
