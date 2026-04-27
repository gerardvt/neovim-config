# Neovim Configuration

Personal Neovim configuration using Neovim 0.12+ built-in APIs for plugin
management, LSP, and completion. No third-party plugin manager required.

## Branches

| Branch | Description |
|---|---|
| `neovim-0.12` | Current. Uses `vim.pack`, `vim.lsp`, `vim.lsp.completion` |
| `main` | Legacy. Uses lazy.nvim, Mason, blink.cmp |

---

## Requirements

**Neovim 0.12 or later.** The configuration will exit immediately with an
error message if an older version is detected.

---

## First Launch

On first launch, `vim.pack` downloads and installs all plugins automatically.
Subsequent launches load plugins from disk with no network access required.

The lock file `nvim-pack-lock.json` pins exact plugin versions for
reproducibility.

---

## External Dependencies

This configuration depends on a number of external tools that must be
installed manually and available on `PATH` when Neovim starts.

### Core tools

Required for basic functionality.

| Tool | Purpose | macOS | Linux |
|---|---|---|---|
| `git` | Plugin download via vim.pack | `brew install git` | system package manager |
| `clang` or `gcc` | Treesitter parser compilation (fallback) | `xcode-select --install` | system package manager |
| `rg` (ripgrep) | Telescope live grep (`<leader>fg`) | `brew install ripgrep` | system package manager |

### Treesitter

| Tool | Purpose | macOS | Linux |
|---|---|---|---|
| `tree-sitter` CLI | Compiling treesitter parsers (preferred over clang/gcc) | `brew install tree-sitter` | `cargo install tree-sitter-cli` |
| `fd` | Faster Telescope file search (optional) | `brew install fd` | system package manager (`fd-find` on Debian/Ubuntu) |

The `tree-sitter` CLI is the preferred build tool for parser compilation
during `:TSInstall`. Without it, nvim-treesitter falls back to `clang`/`gcc`.
After install, run `:TSUpdate` inside Neovim to compile all configured parsers.

### LSP servers

Each LSP server binary must be installed independently. The server for each
language is only active when its binary is found on `PATH` — missing servers
are silently skipped at startup (use `:checkhealth` to verify).

| Language | Server | Install |
|---|---|---|
| Haskell | `haskell-language-server-wrapper` | [GHCup](https://www.haskell.org/ghcup) |
| C, C++ | `clangd` | macOS: `xcode-select --install` or `brew install llvm`; Linux: system package manager |
| Go | `gopls` | `go install golang.org/x/tools/gopls@latest` (requires Go toolchain) |
| Python | `pyright-langserver` | `pip install pyright` |
| Rust | `rust-analyzer` | `rustup component add rust-analyzer` (requires Rust toolchain) |
| Lua | `lua-language-server` | macOS: `brew install lua-language-server`; Linux: system package manager or build from source |
| Elm | `elm-language-server` | `npm install -g elm @elm-tooling/elm-language-server` (requires Node.js) |
| JavaScript, TypeScript | `typescript-language-server` | `npm install -g typescript typescript-language-server` (requires Node.js) |
| Verilog, SystemVerilog | `verible-verilog-ls` | Prebuilt binary: [github.com/chipsalliance/verible/releases](https://github.com/chipsalliance/verible/releases) |
| VHDL | `vhdl_ls` | Prebuilt binary: [github.com/VHDL-LS/rust_hdl/releases](https://github.com/VHDL-LS/rust_hdl/releases) |
| Markdown | `marksman` | Prebuilt binary: [github.com/artempyanykh/marksman/releases](https://github.com/artempyanykh/marksman/releases) |
| Java | `jdtls` | Prebuilt binary: [download.eclipse.org/jdtls/snapshots](https://download.eclipse.org/jdtls/snapshots) (requires Java JDK) |

### Icons

A [Nerd Font](https://www.nerdfonts.com) is recommended for icons in
which-key and file pickers. Set `vim.g.have_nerd_font = true` in
`lua/config/options.lua` if one is configured in your terminal.

---

## Verifying your setup with `:checkhealth`

This configuration ships a custom health check provider that reports the
status of all required and optional external tools. Run it inside Neovim:

```
:checkhealth nvimconfig
```

This produces a report showing which tools are installed and which are
missing, with install instructions for each missing item. For example:

```
nvimconfig: Core tools
  - OK: git found
  - OK: C compiler found (clang)

nvimconfig: Treesitter
  - WARNING: tree-sitter CLI not found
    The tree-sitter CLI is the preferred tool for compiling parsers...

nvimconfig: Telescope
  - OK: ripgrep (rg) found
  - WARNING: fd not found

nvimconfig: LSP servers
  - OK: clangd (C, C++) found
  - WARNING: haskell-language-server-wrapper (hls) not found
    Install via GHCup: https://www.haskell.org/ghcup
  ...
```

You can also run the full Neovim health check (includes nvim-treesitter,
LSP, and other built-in checks) with:

```
:checkhealth
```
