-- =====================================================================================
-- Global NeoVim options.
-- =====================================================================================

-- Helps shorten commands typed here
local set = vim.opt

-- Line numbering and signcolumn visualization:
--  - Show line numbers (number = true)
--  - Do not use relative line numbers from cursor line (relativenumber = false).
--  - Keep signcolumn always on (signcolumn = "yes").
set.number = true
set.relativenumber = false
set.signcolumn = "yes"

-- Cursor line visualization:
--  - Highlight the line where thecursor is (cursorline = true).
--    Highlight the line number only of the cursor line (cursorlineopt = "number").
set.cursorline = true
set.cursorlineopt = "number"

-- Whitespace character display visualization:
--  - Show whitespace characters (tabs , trailing spaces, non-breakable space characters)
--    by default (list = true).
--  - Use sppecified list of strings to show these whitespace characters (listcars = {...}).
--    Helps visualize the presence of tabs, trailing spaces and non-breakable space chars.
set.list = true
set.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Screen column highlighting:
--  - Do not Highlight any columns (colorcolumn = "").
-- set.colorcolumn = "100"
set.colorcolumn = ""

-- Line text display options:
--  - Do not wrap lines (wrap = false).
set.wrap = false

-- Scrolling cursor line behavior:
--  - Keep 10 lines above/below cursor line (scrolloff = 10).
--  - KEep 8 columns left/right of cursor (sidescrolloff = 8).
set.scrolloff = 10
set.sidescrolloff = 8

--Systrem clipboard interractions:
-- - Always use the system clipboard for ALL operations (instead of interacting with
--   the "+" and/or "*" registers explicitly).
set.clipboard:append("unnamedplus")

-- Indentation and tabs settings:
--  - Tabwidth is 4 (tabstop = 4).
--  - Indentation width i2 4 (shiftwidth = 4).
--  - Soft tab stops and not tabs on tab/backspace (softtabstop = 4)
--  - Use spaces for tabs (expandtab = true)
--  - Use smart auto-indent (smartindent = true).
--  - Copy indent from current line (autindent = true).
set.tabstop = 4
set.shiftwidth = 4
set.softtabstop = 4
set.expandtab = true
set.smartindent = true
set.autoindent = true

-- Search settings:
--  - Use case insensiitive search (ignorecase = true).
--  - Use case sensitive search if search word contains uppercase characters (smartcase = true).
--    Note that regardless of the "ignorecase" and "smartcase" options, including "\c" in the
--    search pattern forces a case insensitive search, and including "\C" in the
--    search pattern forces a case sensitive search.
--  - Highlight search matches (hlsearch = true).
--  - Highlight matches as search string is being typed (incsearch = true).
set.ignorecase = true
set.smartcase = true
set.hlsearch = true
set.incsearch = true

-- Substitution result visualization settings:
--  - Show substitution effect incrementally in the buffer and also show
--    partial off-screen results in a previous window (inccommand = "split").
--  Possible values are:
--   "nosplit": Shows the effects of a command incrementally in the buffer.
--   "split": Like "nosplit", but also shows partial off-screen results in a preview window.
set.inccommand = "split"

-- Keyword determination behavior:
--  - Include the '-' character as part of a keyword (iskeyword:append("-").\
--    This makes the dw/diw/ciw motion controls works on full-words
set.iskeyword:append("-")

-- Color settings:
--  - Enables 24-bit RGB color in the terminal UI (termguicolors = true).
--  - Adjust the default color groups for the dark background type (background = "dark").
--    Note that the "background" option does not change the background color,
--    but it tells nvim what the "inherited" (terminal/GUI) background looks like.
--  - Use the builtin color scheme  'unokai' (:colorscheme "unokai")
--    No need for colorscheme plugins.
set.termguicolors = true
set.background = "dark"
vim.cmd.colorscheme("unokai")

-- Borders for floating windows:
--  - Use borders with rounded corners (winborder = "rounded").
--    The default value is empty, which is equivalent to "none".
--    Valid values include:
--    - "bold": Bold line box.
--    - "double": Double-line box.
--    - "none": No border.
--    - "rounded": Like "single", but with rounded corners ("╭" etc.).
--    - "shadow": Drop shadow effect, by blending with the background.
--    - "single": Single-line box.
--    - "solid": Adds padding by a single whitespace cell.
--  - Override the FloatBorder highlight group to use a subtle grey foreground
--    with no background (fg = '#888888', bg = 'none'). Without this, the border
--    inherits a background color from the colorscheme that makes it appear as a
--    thick colored band rather than a thin border line.
--    The override is applied on startup and re-applied on every colorscheme
--    change via a ColorScheme autocmd, since :colorscheme resets all highlights.
set.winborder = "rounded"
local function apply_float_border_hl()
    vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#888888', bg = 'none' })
end
apply_float_border_hl()
vim.api.nvim_create_autocmd('ColorScheme', { callback = apply_float_border_hl })

-- Backspacing (<BS>, <Del>, <C-W>, <C--U>) behavior in insert mode:
--  - Allow backspacing over autoindent, line breaks, and the start of insert.
set.backspace = "indent,eol,start"

-- Window splitting behavior:
--  - Open the new window below the current window when splitting horizontally 
--    with :split (splitbelow = true).
--  - Open the new window to the right of the current window when splitting vertically
--    with :vsplit (splitright = true).
set.splitbelow = true
set.splitright = true

-- Backup settings:
--   - Disable creation of swap (*.swp) files for all buffers (swapfile = false).
--   - Disable creation of permanent backup files ( *~) when saving (backupp == false).
--   - Make a backup before overwriting a file (writebackup = true).
--     The backup is removed after the file is successfully written, unless 'backup'
--     option is also on.
--   - Do not automatically write modifeid files on certain commands (autowrite = false).
--   - Wait 500ms after nothing is typed before writing swap file to disk (updatetime = 500).
--     This is also used for the CursorHold autocommand event (default is 4000 ms).
set.swapfile = false
set.backup = false
set.writebackup = true
set.autowrite = false
set.updatetime = 500

-- Persistent (cross-session) undo history
--   - Disable persistent undo history across nvim editing sessions (undofile = false).
--   - If enabled, store undo files in ~/.vim/undo/ (undodir = ...).
--     The default behavior is to store them in the same directory as the file being adited.
set.undofile = false
set.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Handling of externally modified files:
--  - Enable automatic detection and re-reading of externally changed files (autoread = true).
set.autoread = true

-- File search behavior:
--  - Include subfolders when searching for files by appending "**" to path (path:append("**")).
--    This changes how commands like :find, gf (go to file), and :tabfind behave. Instead of
--    just checking the current working directory, nvim will traverse the entire directory
--    tree to locate the file being looked for.
set.path:append("**")

-- Inter-session data sharing:
--  - Disable the generation and use of the old viminfo file entirely (viminfo = "").
--  - Disable Neovim's Shada (Shared Data) file (shadafile = "NONE").
--    No shada file is ever read or written.
set.viminfo = ""
set.shadafile = "NONE"

-- Handle ANSI escape codes properly when invoked as a pager:
-- THe following autocommand triggers automatically when nvim is invoked as a pager (i.e.
-- with the - arg). This allows using nvim to properly handle ANSI escape codes in the contents
-- being ingested and avoid the display 'garbage' characters.
-- Calling vim.api.nvim_open_term(0, {}) on the current buffer is the documented way to colorize
-- raw ANSI termcodes in Neovim. In 0.12 specifically, nvim_open_term() can now be called on a
-- non-empty buffer.
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      -- If reading from stdin (i.e. used as a pager), colorize ANSI codes
      if vim.fn.argc() == 0 and not vim.o.insertmode then
          local buf = vim.api.nvim_get_current_buf()
          if vim.api.nvim_buf_line_count(buf) > 1 then
              vim.api.nvim_open_term(buf, {})
          end
      end
    end,
})

-- Enable the experimental UI2 core:
-- UI2 is the native redesign of Neovim’s messaging and command-line architecture.
-- WHat we gain:
--   - Get rid of the pesky "Press ENTER to continue" prompts in messages.
--   - The command line is more "buffer-like," providing syntax highlighting and better
--     integration with other UI elements.
--   - Allows Neovim core to be restarted or reconnected without losing the UI state.
require('vim._core.ui2').enable()

