-- Parser installation is handled by nvim-treesitter; built-in vim.treesitter
-- handles highlighting and other consumers of the installed parsers.
-- Run :TSUpdate after adding parsers to ensure_installed.
require('nvim-treesitter.configs').setup({

    ensure_installed = {
        'c', 'lua', 'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline',
        'asm', 'cpp', 'rust', 'haskell', 'python',
        'bash',
        'glsl', 'hlsl', 'wgsl',
        'javascript', 'typescript',
    },

    -- Do not install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Do not automatically install missing parsers when entering a buffer
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
})
