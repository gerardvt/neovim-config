-- =====================================================================================
-- Plugin management via vim.pack (built-in Neovim 0.12+)
-- =====================================================================================

vim.pack.add({
    { src = 'https://github.com/nvim-telescope/telescope.nvim' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },          -- required by: telescope
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },     -- required by: telescope (file icons)
    { src = 'https://github.com/folke/which-key.nvim' },
    { src = 'https://github.com/echasnovski/mini.icons' },          -- required by: which-key
    { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
    { src = 'https://github.com/j-hui/fidget.nvim' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
})

-- Plugin setup
require('plugins.treesitter')
require('plugins.telescope')
require('plugins.whichkey')
require('plugins.indentblankline')
require('plugins.fidget')

-- LSP servers + completion
require('plugins.lsp')
