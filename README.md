# Neovim Configuration

Personal Neovim configuration using Neovim 0.12+ built-in APIs for plugin
management, LSP, and completion. No third-party plugin manager required.

---

## Philosophy

The guiding principle of this configuration — specifically the `neovim-0.12`
branch — is to **minimise the number of third-party plugins** by using
Neovim's built-in capabilities wherever possible.

Neovim 0.12 introduced three major built-in features that historically
required external plugins:

- **`vim.pack`** — a built-in package manager, replacing lazy.nvim
- **`vim.lsp.config` / `vim.lsp.enable`** — built-in LSP server configuration, replacing nvim-lspconfig and Mason
- **`vim.lsp.completion`** — built-in LSP completion, replacing nvim-cmp and blink.cmp

Fewer plugins means fewer moving parts, fewer compatibility issues between
plugin versions, and less reliance on the third-party ecosystem keeping pace
with Neovim's own development. The `main` branch (using lazy.nvim, Mason,
and blink.cmp) is retained as a reference and for use with older Neovim
versions.

---

## Branches

| Branch | Neovim version | Plugin manager | LSP | Completion |
|---|---|---|---|---|
| `neovim-0.12` | 0.12+ required | `vim.pack` (built-in) | `vim.lsp` (built-in) | `vim.lsp.completion` (built-in) |
| `main` | legacy (< 0.12) | lazy.nvim | nvim-lspconfig + Mason | blink.cmp |

---

## Requirements

The version requirement depends on which branch you are using:

- **`neovim-0.12` branch** — requires Neovim 0.12 or later. The configuration
  will exit immediately with an error message if an older version is detected.
- **`main` branch** — targets older Neovim versions. No minimum version is
  enforced at startup.

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

In keeping with the philosophy of minimising plugin dependencies, this
configuration does **not** use Mason to manage LSP server installations.
Mason is a Neovim plugin that downloads and manages LSP server binaries from
within the editor — convenient, but it adds a layer of indirection and
couples your LSP binary versions to Mason's registry rather than to your
system's toolchain.

Instead, each LSP server is treated like any other development tool: installed
once via the appropriate package manager or installer for your language
toolchain and made available on `PATH`. This keeps LSP binaries consistent
with the rest of your development environment (the same `gopls` used by your
editor is the one on your PATH), and removes a class of "works in editor,
broken in CI" discrepancies.

Each LSP server binary must be installed independently. The server for each
language is only active when its binary is found on `PATH` — missing servers
are silently skipped at startup (use `:checkhealth nvimconfig` to verify).

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
| Verilog, SystemVerilog | `veridian` | Prebuilt binary: [github.com/vivekmalneedi/veridian/releases](https://github.com/vivekmalneedi/veridian/releases); or `cargo install --git https://github.com/vivekmalneedi/veridian.git --all-features` |
| VHDL | `vhdl_ls` | Prebuilt binary: [github.com/VHDL-LS/rust_hdl/releases](https://github.com/VHDL-LS/rust_hdl/releases) |
| Markdown | `marksman` | Prebuilt binary: [github.com/artempyanykh/marksman/releases](https://github.com/artempyanykh/marksman/releases) |

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
