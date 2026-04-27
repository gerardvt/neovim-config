-- LSP Plugins

-- -----------------------------------------------------------------------
-- This function resolves a difference between neovim nightly (version 0.11)
-- and stable (version 0.10)
---@param client vim.lsp.Client
---@param method vim.lsp.protocol.Method
---@param bufnr? integer some lsp support methods only in specific files
---@return boolean
-- -----------------------------------------------------------------------
local function clientSupportsLspMethod(client, method, bufnr)
  if vim.fn.has 'nvim-0.11' == 1 then
    return client:supports_method(method, bufnr)
  else
    return client.supports_method(method, { bufnr = bufnr })
  end
end

-- -----------------------------------------------------------------------
-- Function to setup key mappings related to the LSP provided services
--  This is called from the callback registered 
-- -----------------------------------------------------------------------
local setupLspBufferKeyBindings = function (buffer)

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


end

-- -----------------------------------------------------------------------
-- Setup autocommands to highlight references of the word/symbol
-- under the cursor when the cursor rests there for a little while,
-- and clear the highlights when the cursor is moved again.
-- See `:help CursorHold` for information about when this is executed
-- -----------------------------------------------------------------------
 local setupWordHighlightAutocommand = function (buffer)

    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })

    vim.api.nvim_create_autocmd(
      { 'CursorHold', 'CursorHoldI' },
      {
        buffer = buffer,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      }
    )

    vim.api.nvim_create_autocmd(
      { 'CursorMoved', 'CursorMovedI' },
      {
        buffer = buffer,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      }
    )

    vim.api.nvim_create_autocmd(
      'LspDetach',
      {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      }
    )

  end

-- -----------------------------------------------------------------------
-- Create keymap to toggle inlay hints in code if the language server supports them.
-- This may be unwanted, since they displace some of your code
-- -----------------------------------------------------------------------
local setupInlayHintsToggleKeyBinding = function (buffer)
  vim.keymap.set(
    'n',
    '<leader>th',
    function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buffer })
    end,
    { buffer = buffer, desc = 'LSP: [T]oggle Inlay [H]ints' })
end

return {

  -- -----------------------------------------------------------------------------
  -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
  -- used for completion, annotations and signatures of Neovim apis
  -- -----------------------------------------------------------------------------
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- -----------------------------------------------------------------------------
  -- Main LSP Configuration
  -- -----------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',

    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      { 'saghen/blink.cmp', dependencies = { 'saghen/blink.lib' } },
    },

    -- -----------------------------------------------------------------------------
    -- Configuration upon loading nvim-lspconfig plugin
    -- -----------------------------------------------------------------------------
    config = function()

      -- -----------------------------------------------------------------------------
      -- Setup autocommand to be ran when LSP attacheds to buffer
      -- -----------------------------------------------------------------------------
      vim.api.nvim_create_autocmd(
        'LspAttach',
        {
          group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),

          --  This function gets run when an LSP attaches to a particular buffer.
          --  That is to say, every time a new file is opened that is associated with
          --  an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
          --  function will be executed to configure the current buffer
          callback = function(event)

            local client = vim.lsp.get_client_by_id(event.data.client_id)
            local buffer = event.buf

            -- Setup buffer specific LSP features key mappings.
            setupLspBufferKeyBindings (buffer)

            -- Setup keymap to toggle inlay hints in code if the language server supports them.
            -- This may be unwanted, since they displace some of your code
            if client and clientSupportsLspMethod(client, vim.lsp.protocol.Methods.textDocument_inlayHint, buffer) then
              setupInlayHintsToggleKeyBinding (buffer)
            end

            -- Setup autocommands to highlight symbol under cursor in buffer if client support it
            if client and clientSupportsLspMethod(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, buffer) then
              setupWordHighlightAutocommand (buffer)
            end

          end,
        }
      )

      -- -----------------------------------------------------------------------------
      -- Diagnostic configuration.
      -- See :help vim.diagnostic.Opts
      -- -----------------------------------------------------------------------------
      vim.diagnostic.config (
        {
          severity_sort = true,
          float = { border = 'rounded', source = 'if_many' },
          underline = { severity = vim.diagnostic.severity.ERROR },
          signs = vim.g.have_nerd_font and {
            text = {
              [vim.diagnostic.severity.ERROR] = '󰅚 ',
              [vim.diagnostic.severity.WARN] = '󰀪 ',
              [vim.diagnostic.severity.INFO] = '󰋽 ',
              [vim.diagnostic.severity.HINT] = '󰌶 ',
            },
          } or {},
          virtual_text = {
            source = 'if_many',
            spacing = 2,
            format = function(diagnostic)
              local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
              }
              return diagnostic_message[diagnostic.severity]
            end,
          },
          virtual_line = true,
        }
      )

      -- -----------------------------------------------------------------------------
      -- LSP servers and clients are able to communicate to each other what features they support.
      -- By default, Neovim doesn't support everything that is in the LSP specification.
      -- Other plugins such as blink.cmp, luasnip, etc. provide additional LSP client capabilities.
      -- Hence, make sure to communicate these capabilities to LSP servers.
      -- -----------------------------------------------------------------------------
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- -----------------------------------------------------------------------------
      -- Enable the following language servers
      -- Ensure the servers listed in required_lsp_servers here above are installed
      -- using mason (setup as a dependency for this nvim-lspconfig plugin).
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      -- -----------------------------------------------------------------------------
      local required_lsp_servers = {
        hls = {},
        clangd = {},
        gopls = {},
        pyright = {},
        rust_analyzer = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace', },
              -- Uncomment line below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- -----------------------------------------------------------------------------
      -- Add other tools besides the lsp servers above that we want Mason to install
      -- -----------------------------------------------------------------------------
      local ensure_installed = vim.tbl_keys(required_lsp_servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      

      -- -----------------------------------------------------------------------------
      -- Use mason to install all the lsp and additional tools binaries we defined for us.
      -- -----------------------------------------------------------------------------
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = required_lsp_servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
