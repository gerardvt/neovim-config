-- -------------------------------------------------------------
-- Bootstrap lazy.nvim
-- -------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- -------------------------------------------------------------
-- Setup lazy.nvim:
-- We will create create all our plugin specs install
-- ~/.config/nvim/lua/plugins/, wherein each file returns a
-- table with the plugins we want to install (and configure).
-- -------------------------------------------------------------
require("lazy").setup({
    -- Import our plugin specs from plugins directory
    spec = {
        { import = "plugins" },
    },
    -- Automatically check for plugin updates
    checker = { enabled = true },
})
