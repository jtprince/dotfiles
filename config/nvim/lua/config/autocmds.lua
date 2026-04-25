-- Global autocmds (filetype-specific autocmds live in ftplugin/<ft>.lua).

local aug = vim.api.nvim_create_augroup("user_autocmds", { clear = true })

-- Markers that define a project root (checked walking UP from the initial path).
local PROJECT_MARKERS = { ".git", "pyproject.toml", "package.json", "Cargo.toml", "go.mod" }

local function find_project_root(path)
	local dir = vim.fn.isdirectory(path) == 1 and path or vim.fn.fnamemodify(path, ":h")
	local current = vim.fn.fnamemodify(dir, ":p"):gsub("/$", "")
	while true do
		for _, marker in ipairs(PROJECT_MARKERS) do
			if vim.uv.fs_stat(current .. "/" .. marker) then
				return current
			end
		end
		local parent = vim.fn.fnamemodify(current, ":h")
		if parent == current then break end
		current = parent
	end
	return vim.fn.fnamemodify(dir, ":p"):gsub("/$", "")
end

-- py2nb cell-marker comments.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = aug,
	pattern = "*.py",
	callback = function()
		vim.cmd([[
			syntax match Comment "#|.*$"
			syntax match Special "#!.*$"
			syntax match Delimiter "#-.*$"
		]])
	end,
})

-- Auto-restore session: detect project root from argv/cwd, cd there, then restore.
vim.api.nvim_create_autocmd("VimEnter", {
	group = aug,
	nested = true,
	callback = function()
		if vim.o.diff then return end
		local initial = vim.fn.argc() > 0
			and vim.fn.fnamemodify(vim.fn.argv(0), ":p")
			or vim.fn.getcwd()
		local root = find_project_root(initial)
		vim.cmd("cd " .. vim.fn.fnameescape(root))
		require("persistence").load()
		vim.notify("Session: " .. vim.fn.fnamemodify(root, ":~"), vim.log.levels.INFO)
		-- Re-open files passed on cmdline (session restore wipes them).
		if vim.fn.argc() > 0 then
			vim.schedule(function()
				for i = 0, vim.fn.argc() - 1 do
					vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.argv(i)))
				end
			end)
		end
	end,
})

-- Auto-format Lua on save (LSP).
vim.api.nvim_create_autocmd("BufWritePre", {
	group = aug,
	pattern = "*.lua",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})
