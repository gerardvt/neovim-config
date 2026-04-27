-- Custom :checkhealth provider for this Neovim configuration.
-- Run with: :checkhealth nvimconfig
--
-- Checks for all external tools this configuration depends on and reports
-- their status with install guidance for missing tools.

local health = vim.health

local M = {}

local function check_executable(cmd, label, required, advice)
    if vim.fn.executable(cmd) == 1 then
        health.ok(label .. ' found')
    elseif required then
        health.error(label .. ' not found', advice)
    else
        health.warn(label .. ' not found', advice)
    end
end

function M.check()

    -- -----------------------------------------------------------------------
    -- Core tools
    -- -----------------------------------------------------------------------
    health.start('Core tools')

    check_executable('git', 'git',
        true,
        'git is required by vim.pack to download and update plugins.\n' ..
        '  macOS:  brew install git\n' ..
        '  Linux:  install via your system package manager')

    local has_clang = vim.fn.executable('clang') == 1
    local has_gcc   = vim.fn.executable('gcc') == 1
    if has_clang or has_gcc then
        health.ok('C compiler found (' .. (has_clang and 'clang' or 'gcc') .. ')')
    else
        health.error('No C compiler found (clang or gcc)',
            'A C compiler is required as a fallback for compiling treesitter parsers.\n' ..
            '  macOS:  xcode-select --install\n' ..
            '  Linux:  install clang or gcc via your system package manager')
    end

    -- -----------------------------------------------------------------------
    -- Treesitter
    -- -----------------------------------------------------------------------
    health.start('Treesitter')

    check_executable('tree-sitter', 'tree-sitter CLI',
        false,
        'The tree-sitter CLI is the preferred tool for compiling parsers during :TSInstall.\n' ..
        'Without it, nvim-treesitter falls back to clang/gcc.\n' ..
        '  macOS:  brew install tree-sitter\n' ..
        '  Linux:  cargo install tree-sitter-cli  (requires Rust toolchain)\n' ..
        '          or install via your system package manager if available')

    -- -----------------------------------------------------------------------
    -- Telescope dependencies
    -- -----------------------------------------------------------------------
    health.start('Telescope')

    check_executable('rg', 'ripgrep (rg)',
        true,
        'ripgrep is required by telescope for live_grep (<leader>fg).\n' ..
        '  macOS:  brew install ripgrep\n' ..
        '  Linux:  install via your system package manager')

    check_executable('fd', 'fd',
        false,
        'fd is optional but recommended for faster telescope file search.\n' ..
        '  macOS:  brew install fd\n' ..
        '  Linux:  install via your system package manager (may be called fd-find)')

    -- -----------------------------------------------------------------------
    -- LSP servers
    -- LSP servers are warnings (not errors) since not all languages are used
    -- by every user. See lua/plugins/lsp.lua for install instructions.
    -- -----------------------------------------------------------------------
    health.start('LSP servers')

    local servers = {
        { cmd = 'haskell-language-server-wrapper', label = 'hls (Haskell)',
          advice = 'Install via GHCup: https://www.haskell.org/ghcup' },
        { cmd = 'clangd',                          label = 'clangd (C, C++)',
          advice = 'macOS: xcode-select --install  or  brew install llvm\n' ..
                   '          Linux: install via your system package manager' },
        { cmd = 'gopls',                           label = 'gopls (Go)',
          advice = 'go install golang.org/x/tools/gopls@latest  (requires Go toolchain)' },
        { cmd = 'pyright-langserver',              label = 'pyright (Python)',
          advice = 'pip install pyright' },
        { cmd = 'rust-analyzer',                   label = 'rust-analyzer (Rust)',
          advice = 'rustup component add rust-analyzer  (requires Rust toolchain)' },
        { cmd = 'lua-language-server',             label = 'lua-language-server (Lua)',
          advice = 'macOS: brew install lua-language-server\n' ..
                   '          Linux: install via your system package manager or build from source' },
        { cmd = 'elm-language-server',             label = 'elmls (Elm)',
          advice = 'npm install -g elm @elm-tooling/elm-language-server  (requires Node.js)' },
        { cmd = 'typescript-language-server',      label = 'ts_ls (JavaScript, TypeScript)',
          advice = 'npm install -g typescript typescript-language-server  (requires Node.js)' },
        { cmd = 'veridian',                        label = 'veridian (Verilog, SystemVerilog)',
          advice = 'Option 1 - Prebuilt binary (Linux only, nightly build):\n' ..
                   '          curl -L https://github.com/vivekmalneedi/veridian/releases/download/nightly/veridian-ubuntu-22.04.tar.gz | tar xz\n' ..
                   'Option 2 - Build from source, all platforms (requires Rust toolchain):\n' ..
                   '          cargo install --git https://github.com/vivekmalneedi/veridian.git --all-features\n' ..
                   '          (omit --all-features if a C++17 compiler is not available)' },
        { cmd = 'vhdl_ls',                         label = 'vhdl_ls (VHDL)',
          advice = 'Download prebuilt binary from:\n' ..
                   '          https://github.com/VHDL-LS/rust_hdl/releases' },
        { cmd = 'marksman',                        label = 'marksman (Markdown)',
          advice = 'Download prebuilt binary from:\n' ..
                   '          https://github.com/artempyanykh/marksman/releases' },
    }

    for _, s in ipairs(servers) do
        check_executable(s.cmd, s.label, false, s.advice)
    end

end

return M
