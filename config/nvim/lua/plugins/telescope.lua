-- Telescope setup, fzf-native extension, custom buffer-picker mappings,
-- and the :LiveGrepGitRoot user command.

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")

local function delete_buffer_and_refresh(prompt_bufnr)
	local entry = action_state.get_selected_entry()
	if not entry then return end
	vim.api.nvim_buf_delete(entry.bufnr, { force = false })
	actions.close(prompt_bufnr)
	builtin.buffers()
end

local function safe_close(prompt_bufnr)
	local picker = action_state.get_current_picker(prompt_bufnr)
	if picker then actions.close(prompt_bufnr) end
end

local function open_buffer_in_vsplit(prompt_bufnr)
	local entry = action_state.get_selected_entry()
	if entry then
		vim.cmd("vsplit | buffer " .. entry.bufnr)
		safe_close(prompt_bufnr)
	end
end

local function open_buffer_in_split(prompt_bufnr)
	local entry = action_state.get_selected_entry()
	if entry then
		vim.cmd("split | buffer " .. entry.bufnr)
		safe_close(prompt_bufnr)
	end
end

require("telescope").setup({
	defaults = {
		prompt_prefix = "> ",
		selection_caret = " ",
		path_display = { "smart" },
		layout_config = {
			horizontal   = { width = 0.9, height = 0.9, prompt_position = "bottom", preview_cutoff = 120 },
			vertical     = { width = 0.9, height = 0.9, prompt_position = "bottom", preview_cutoff = 40 },
			center       = { width = 0.5, height = 0.4, prompt_position = "top",    preview_cutoff = 40 },
			cursor       = { width = 0.8, height = 0.9,                             preview_cutoff = 40 },
			bottom_pane  = { height = 25,                prompt_position = "top",   preview_cutoff = 120 },
		},
	},
	pickers = {
		buffers = {
			mappings = {
				i = { ["<C-d>"] = delete_buffer_and_refresh },
				n = {
					["dd"]      = delete_buffer_and_refresh,
					["<Space>"] = actions.toggle_selection + actions.move_selection_worse,
					["v"]       = open_buffer_in_vsplit,
					["s"]       = open_buffer_in_split,
				},
			},
		},
	},
})

pcall(require("telescope").load_extension, "fzf")

local function find_git_root()
	local file = vim.api.nvim_buf_get_name(0)
	local dir = (file == "") and vim.fn.getcwd() or vim.fn.fnamemodify(file, ":h")
	local root = vim.fn.systemlist("git -C " .. vim.fn.escape(dir, " ") .. " rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 then return vim.fn.getcwd() end
	return root
end

vim.api.nvim_create_user_command("LiveGrepGitRoot", function()
	builtin.live_grep({ search_dirs = { find_git_root() } })
end, {})

-- Keymaps.
local map = vim.keymap.set
map("n", "<leader>?",  builtin.oldfiles,    { desc = "[?] Recently opened files" })
map("n", "<leader>ff", builtin.buffers,     { desc = "[F]ind existing buffers" })
map("n", "<leader>fb", builtin.find_files,  { desc = "[F]ind [B]y name" })
map("n", "<leader>fh", builtin.help_tags,   { desc = "[F]ind [H]elp" })
map("n", "<leader>fs", builtin.grep_string, { desc = "[F]ind [S]tring under cursor" })
map("n", "<leader>gf", builtin.git_files,   { desc = "[G]it [F]iles" })
map("n", "<leader>sd", builtin.diagnostics, { desc = "[S]how [D]iagnostics" })
map("n", "<leader>sr", builtin.resume,      { desc = "[S]earch [R]esume" })
map("n", "<leader>sG", "<cmd>LiveGrepGitRoot<CR>", { desc = "[S]earch [G]rep in Git root" })

map("n", "<leader>/", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzy search current buffer" })

map("n", "<leader>ss", builtin.builtin, { desc = "[S]elect Telescope picker" })
map("n", "<leader>s/", function()
	builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
end, { desc = "[S]earch [/] in Open Files" })
