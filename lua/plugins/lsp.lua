-- =====================================================================================
-- LSP configuration using Neovim 0.12+ built-in APIs
-- =====================================================================================

-- -----------------------------------------------------------------------
-- Function to setup key mappings related to the LSP provided services.
-- Called from the LspAttach autocommand callback.
-- -----------------------------------------------------------------------
local setupLspBufferKeyBindings = function(buffer)

    vim.keymap.set('n', 'grn',
        vim.lsp.buf.rename,
        { buffer = buffer, desc = 'LSP: [R]e[n]ame' })

    vim.keymap.set({ 'n', 'x' }, 'gra',
        vim.lsp.buf.code_action,
        { buffer = buffer, desc = 'LSP: [G]oto Code [A]ction' })

    vim.keymap.set('n', 'grr',
        require('telescope.builtin').lsp_references,
        { buffer = buffer, desc = 'LSP: [G]oto [R]eferences' })

    vim.keymap.set('n', 'gri',
        require('telescope.builtin').lsp_implementations,
        { buffer = buffer, desc = 'LSP: [G]oto [I]mplementation' })

    vim.keymap.set('n', 'grd',
        require('telescope.builtin').lsp_definitions,
        { buffer = buffer, desc = 'LSP: [G]oto [D]efinition' })

    vim.keymap.set('n', 'grD',
        vim.lsp.buf.declaration,
        { buffer = buffer, desc = 'LSP: [G]oto [D]eclaration' })

    vim.keymap.set('n', 'grt',
        require('telescope.builtin').lsp_type_definitions,
        { buffer = buffer, desc = 'LSP: [G]oto [T]ype Definition' })

    vim.keymap.set('n', 'gsd',
        require('telescope.builtin').lsp_document_symbols,
        { buffer = buffer, desc = 'LSP: Open Document Symbols' })

    vim.keymap.set('n', 'gsw',
        require('telescope.builtin').lsp_dynamic_workspace_symbols,
        { buffer = buffer, desc = 'LSP: Open Workspace Symbols' })

end

-- -----------------------------------------------------------------------
-- Setup autocommands to highlight references of the symbol under the
-- cursor on CursorHold, and clear highlights when the cursor moves.
-- -----------------------------------------------------------------------
local setupWordHighlightAutocommand = function(buffer)

    local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = buffer,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = buffer,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
    })

    vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event2.buf })
        end,
    })

end

-- -----------------------------------------------------------------------
-- Completion options
-- -----------------------------------------------------------------------
vim.opt.completeopt = 'menu,menuone,noselect,popup'

-- -----------------------------------------------------------------------
-- Global capabilities: advertise snippet support to all servers so they
-- can return richer completion items.
-- -----------------------------------------------------------------------
vim.lsp.config('*', {
    capabilities = {
        textDocument = {
            completion = {
                completionItem = {
                    snippetSupport = true,
                }
            }
        }
    }
})

-- -----------------------------------------------------------------------
-- Per-server LSP configurations
-- -----------------------------------------------------------------------

vim.lsp.config('hls', {
    cmd = { 'haskell-language-server-wrapper', '--lsp' },
    filetypes = { 'haskell', 'lhaskell', 'cabal' },
    root_markers = { '*.cabal', 'stack.yaml', 'cabal.project', 'package.yaml', 'hie.yaml', '.git' },
})

vim.lsp.config('clangd', {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', '.git' },
})

vim.lsp.config('gopls', {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
})

vim.lsp.config('pyright', {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'pyrightconfig.json', '.git' },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
            },
        },
    },
})

vim.lsp.config('rust_analyzer', {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
})

-- lua_ls workspace library replaces lazydev.nvim for Neovim config awareness
vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', 'stylua.toml', '.git' },
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
            },
            completion = { callSnippet = 'Replace' },
        },
    },
})

-- -----------------------------------------------------------------------
-- Enable all configured servers
-- -----------------------------------------------------------------------
vim.lsp.enable({ 'hls', 'clangd', 'gopls', 'pyright', 'rust_analyzer', 'lua_ls' })

-- -----------------------------------------------------------------------
-- Diagnostic configuration
-- -----------------------------------------------------------------------
vim.diagnostic.config({
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN]  = '󰀪 ',
            [vim.diagnostic.severity.INFO]  = '󰋽 ',
            [vim.diagnostic.severity.HINT]  = '󰌶 ',
        },
    } or {},
    virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
            return diagnostic.message
        end,
    },
    virtual_lines = true,
})

-- -----------------------------------------------------------------------
-- LspAttach: wire up keymaps, highlighting, and completion per buffer
-- -----------------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local buffer = event.buf

        setupLspBufferKeyBindings(buffer)

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, buffer) then
            vim.keymap.set('n', '<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buffer }))
            end, { buffer = buffer, desc = 'LSP: [T]oggle Inlay [H]ints' })
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, buffer) then
            setupWordHighlightAutocommand(buffer)
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion, buffer) then
            vim.lsp.completion.enable(true, client.id, buffer, { autotrigger = true })
        end
    end,
})
