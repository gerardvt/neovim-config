-- =====================================================================================
-- LSP configuration using Neovim 0.12+ built-in APIs
-- =====================================================================================
--
-- External tool dependencies (replaces Mason)
-- -----------------------------------------------------------------------
-- On the main branch, Mason installed and managed LSP server binaries
-- automatically from within Neovim. That plugin has been removed in favour
-- of the built-in vim.lsp.config / vim.lsp.enable APIs.
--
-- As a result, each LSP server binary must be installed manually via the
-- appropriate tool for your OS and language toolchain, and must be present
-- on PATH when Neovim starts:
--
--   haskell-language-server-wrapper  via GHCup
--   clangd                           via your system's LLVM/clang package
--   gopls                            go install golang.org/x/tools/gopls@latest
--   pyright-langserver               pip install pyright
--   rust-analyzer                    rustup component add rust-analyzer
--   lua-language-server              via your system package manager
--   elm-language-server              npm install -g elm @elm-tooling/elm-language-server
--   typescript-language-server       npm install -g typescript typescript-language-server
--   veridian                         cargo install --git https://github.com/vivekmalneedi/veridian.git --all-features
--   vhdl_ls                          prebuilt binary from github.com/VHDL-LS/rust_hdl
--
-- If a binary is missing, Neovim will silently skip attaching that server
-- (no error on startup). Run :checkhealth to verify which servers are found.
-- =====================================================================================

-- -----------------------------------------------------------------------
-- Function to setup key mappings related to the LSP provided services.
-- Called from the LspAttach autocommand callback.
-- -----------------------------------------------------------------------
local setupLspBufferKeyBindings = function(buffer)

    -- Rename the variable under your cursor.
    vim.keymap.set('n', 'grn',
        vim.lsp.buf.rename,
        { buffer = buffer, desc = 'LSP: [R]e[n]ame' })

    -- Execute a code action (cursor needs to be on top of an LSP error/suggestion).
    vim.keymap.set({ 'n', 'x' }, 'gra',
        vim.lsp.buf.code_action,
        { buffer = buffer, desc = 'LSP: [G]oto Code [A]ction' })

    -- Find references for the word under your cursor.
    vim.keymap.set('n', 'grr',
        require('telescope.builtin').lsp_references,
        { buffer = buffer, desc = 'LSP: [G]oto [R]eferences' })

    -- Jump to the implementation of the word under your cursor.
    vim.keymap.set('n', 'gri',
        require('telescope.builtin').lsp_implementations,
        { buffer = buffer, desc = 'LSP: [G]oto [I]mplementation' })

    -- Jump to the definition of the word under your cursor.
    --  To jump back, press <C-t>.
    vim.keymap.set('n', 'grd',
        require('telescope.builtin').lsp_definitions,
        { buffer = buffer, desc = 'LSP: [G]oto [D]efinition' })

    -- Jump to the declaration of the word under cursor.
    vim.keymap.set('n', 'grD',
        vim.lsp.buf.declaration,
        { buffer = buffer, desc = 'LSP: [G]oto [D]eclaration' })

    -- Jump to the type of the word under your cursor.
    vim.keymap.set('n', 'grt',
        require('telescope.builtin').lsp_type_definitions,
        { buffer = buffer, desc = 'LSP: [G]oto [T]ype Definition' })

    -- Fuzzy find all the LSP reported symbols in current document.
    --  Symbols are things like variables, functions, types, etc.
    vim.keymap.set('n', 'gsd',
        require('telescope.builtin').lsp_document_symbols,
        { buffer = buffer, desc = 'LSP: Open Document Symbols' })

    -- Fuzzy find all the symbols in your current workspace.
    --  Similar to document symbols, except searches over your entire project.
    vim.keymap.set('n', 'gsw',
        require('telescope.builtin').lsp_dynamic_workspace_symbols,
        { buffer = buffer, desc = 'LSP: Open Workspace Symbols' })

    -- Show hover documentation for symbol under cursor.
    -- Border is set explicitly because the built-in hover handler does not
    -- inherit the global winborder option. vim.lsp.with() is deprecated in
    -- 0.13, so passing options directly to hover() is the correct approach.
    vim.keymap.set('n', 'K', function()
        vim.lsp.buf.hover({ border = 'rounded' })
    end, { buffer = buffer, desc = 'LSP: Hover Documentation' })

end

-- -----------------------------------------------------------------------
-- Setup autocommands to highlight references of the word/symbol
-- under the cursor when the cursor rests there for a little while,
-- and clear the highlights when the cursor is moved again.
-- See `:help CursorHold` for information about when this is executed
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

vim.lsp.config('elmls', {
    cmd = { 'elm-language-server' },
    filetypes = { 'elm' },
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local filetype = vim.bo[bufnr].filetype
        if filetype == 'elm' or (filetype == 'json' and fname:match 'elm%.json$') then
            on_dir(vim.fs.root(fname, 'elm.json'))
            return
        end
        on_dir(nil)
    end,
    init_options = {
        elmReviewDiagnostics = 'off',
        skipInstallPackageConfirmation = false,
        disableElmLSDiagnostics = false,
        onlyUpdateDiagnosticsOnSave = false,
    },
    capabilities = {
        offsetEncoding = { 'utf-8', 'utf-16' },
    },
})

-- ts_ls cmd prefers a project-local typescript-language-server if present
-- in node_modules/.bin, falling back to the global install on PATH.
-- root_dir excludes Deno projects (detected via deno.json / deno.lock)
-- to avoid attaching ts_ls to files managed by the Deno LSP.
vim.lsp.config('ts_ls', {
    init_options = { hostInfo = 'neovim' },
    cmd = function(dispatchers, config)
        local cmd = 'typescript-language-server'
        if (config or {}).root_dir then
            local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin', cmd)
            if vim.fn.executable(local_cmd) == 1 then
                cmd = local_cmd
            end
        end
        return vim.lsp.rpc.start({ cmd, '--stdio' }, dispatchers)
    end,
    filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
    },
    root_dir = function(bufnr, on_dir)
        local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
        root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers, { '.git' } }
            or vim.list_extend(root_markers, { '.git' })
        local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
        local deno_lock_root = vim.fs.root(bufnr, { 'deno.lock' })
        local project_root = vim.fs.root(bufnr, root_markers)
        if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
            return
        end
        if deno_root and (not project_root or #deno_root >= #project_root) then
            return
        end
        on_dir(project_root or vim.fn.getcwd())
    end,
    handlers = {
        ['_typescript.rename'] = function(_, result, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            vim.lsp.util.show_document({
                uri = result.textDocument.uri,
                range = {
                    start = result.position,
                    ['end'] = result.position,
                },
            }, client.offset_encoding)
            vim.lsp.buf.rename()
            return vim.NIL
        end,
    },
    commands = {
        ['editor.action.showReferences'] = function(command, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            local file_uri, position, references = unpack(command.arguments)
            local quickfix_items = vim.lsp.util.locations_to_items(references, client.offset_encoding)
            vim.fn.setqflist({}, ' ', {
                title = command.title,
                items = quickfix_items,
                context = { command = command, bufnr = ctx.bufnr },
            })
            vim.lsp.util.show_document({
                uri = file_uri,
                range = { start = position, ['end'] = position },
            }, client.offset_encoding)
            vim.cmd('botright copen')
        end,
    },
    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, 'LspTypescriptSourceAction', function()
            local source_actions = vim.tbl_filter(function(action)
                return vim.startswith(action, 'source.')
            end, client.server_capabilities.codeActionProvider.codeActionKinds)
            vim.lsp.buf.code_action({
                context = { only = source_actions, diagnostics = {} },
            })
        end, {})
        vim.api.nvim_buf_create_user_command(bufnr, 'LspTypescriptGoToSourceDefinition', function()
            local win = vim.api.nvim_get_current_win()
            local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
            client:exec_cmd({
                command = '_typescript.goToSourceDefinition',
                title = 'Go to source definition',
                arguments = { params.textDocument.uri, params.position },
            }, { bufnr = bufnr }, function(err, result)
                if err then
                    vim.notify('Go to source definition failed: ' .. err.message, vim.log.levels.ERROR)
                    return
                end
                if not result or vim.tbl_isempty(result) then
                    vim.notify('No source definition found', vim.log.levels.INFO)
                    return
                end
                vim.lsp.util.show_document(result[1], client.offset_encoding, { focus = true })
            end)
        end, { desc = 'Go to source definition' })
    end,
})

-- Covers both Verilog and SystemVerilog
vim.lsp.config('veridian', {
    cmd = { 'veridian' },
    filetypes = { 'systemverilog', 'verilog' },
    root_markers = { '.git' },
})

-- vhdl_ls requires a vhdl_ls.toml library mapping file in the project root
-- or a .vhdl_ls.toml in the home directory. See: https://github.com/VHDL-LS/rust_hdl
vim.lsp.config('vhdl_ls', {
    cmd = { 'vhdl_ls' },
    filetypes = { 'vhd', 'vhdl' },
    root_markers = { 'vhdl_ls.toml', '.vhdl_ls.toml' },
})

-- -----------------------------------------------------------------------
-- Enable all configured servers
-- -----------------------------------------------------------------------
vim.lsp.enable({
    'hls',          -- Haskell (haskell-language-server)
    'clangd',       -- C, C++, Objective-C
    'gopls',        -- Go
    'pyright',      -- Python
    'rust_analyzer',-- Rust
    'lua_ls',       -- Lua
    'elmls',        -- Elm
    'ts_ls',        -- JavaScript, TypeScript
    'veridian',     -- Verilog, SystemVerilog
    'vhdl_ls',      -- VHDL
})

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

        -- Toggle inlay hints if the language server supports them.
        -- This may be unwanted, since they displace some of your code
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, buffer) then
            vim.keymap.set('n', '<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buffer }))
            end, { buffer = buffer, desc = 'LSP: [T]oggle Inlay [H]ints' })
        end

        -- Setup autocommands to highlight symbol under cursor in buffer if client supports it
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, buffer) then
            setupWordHighlightAutocommand(buffer)
        end

        -- Enable built-in LSP completion for this buffer if the server supports it
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion, buffer) then
            vim.lsp.completion.enable(true, client.id, buffer, { autotrigger = true })
        end
    end,
})
