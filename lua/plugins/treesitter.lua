-- =============================================================================
-- Treesitter: relationship between vim.treesitter, nvim-treesitter, and
-- external tools
-- =============================================================================
--
-- vim.treesitter (built into Neovim)
-- ------------------------------------
-- The engine. It can load a compiled parser (.so file) and parse a buffer
-- into a syntax tree, run treesitter queries (.scm files) against that tree
-- for highlighting/folding/etc., and expose the tree to Lua via APIs like
-- vim.treesitter.get_node() and :InspectTree.
-- It cannot download or compile parsers — it only uses them if they exist.
--
-- nvim-treesitter (this plugin)
-- ------------------------------------
-- Sits on top of vim.treesitter and provides two things:
--
--   1. Parser management: downloads grammar C source from GitHub and compiles
--      it into .so files that vim.treesitter can load. This is what :TSInstall
--      and ensure_installed do.
--
--   2. Bundled queries: ships .scm query files for every supported language.
--      vim.treesitter needs these to know how to highlight a file — which
--      nodes are keywords, strings, etc.
--
-- Without this plugin you would need to manually compile each parser .so and
-- source your own .scm query files. Neovim bundles a small set (lua, vim,
-- vimdoc, etc.) but relies on this plugin for everything else.
--
-- External tools (tree-sitter CLI / clang)
-- ------------------------------------
-- nvim-treesitter calls the tree-sitter CLI (or falls back to clang/gcc) to
-- compile downloaded grammar C source into .so files during :TSInstall.
-- Install via: brew install tree-sitter
--
-- The full chain for a new parser:
--   :TSInstall <lang>
--     -> nvim-treesitter downloads grammar C source from GitHub
--     -> calls tree-sitter CLI (or clang) to compile it into <lang>.so
--     -> places <lang>.so in the nvim-treesitter parser directory
--     -> vim.treesitter can now load <lang>.so and parse that filetype
--
-- =============================================================================
--
-- The pcall guard handles the first launch after vim.pack adds this plugin:
-- vim.pack.add() only puts the plugin on the runtimepath once it is downloaded,
-- so require() will fail until the next restart after the download completes.
local ok, configs = pcall(require, 'nvim-treesitter.configs')
if not ok then return end

configs.setup({

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
