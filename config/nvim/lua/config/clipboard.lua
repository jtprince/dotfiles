-- Always use system clipboard, plus Neovide Cmd-key bindings.

vim.opt.clipboard:append("unnamedplus")

if not vim.g.neovide then return end

local opts = { noremap = true, silent = true }

vim.keymap.set("v", "<D-c>", '"+y',  vim.tbl_extend("force", opts, { desc = "Copy (system clipboard)" }))
vim.keymap.set("n", "<D-c>", '"+yy', vim.tbl_extend("force", opts, { desc = "Copy line (system clipboard)" }))

vim.keymap.set({ "n", "v" }, "<D-v>", '"+p',   vim.tbl_extend("force", opts, { desc = "Paste (system clipboard)" }))
vim.keymap.set("i",          "<D-v>", "<C-r>+", vim.tbl_extend("force", opts, { desc = "Paste (system clipboard)" }))
vim.keymap.set("c",          "<D-v>", "<C-R>+", vim.tbl_extend("force", opts, { desc = "Paste (system clipboard)" }))

vim.keymap.set("v", "<D-x>", '"+d',  vim.tbl_extend("force", opts, { desc = "Cut (system clipboard)" }))
vim.keymap.set("n", "<D-x>", '"+dd', vim.tbl_extend("force", opts, { desc = "Cut line (system clipboard)" }))
