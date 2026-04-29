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
		-- Resolve all argv paths to absolute BEFORE cd changes cwd.
		local files = {}
		for i = 0, vim.fn.argc() - 1 do
			files[#files + 1] = vim.fn.fnamemodify(vim.fn.argv(i), ":p")
		end
		local root = find_project_root(initial)
		vim.cmd("cd " .. vim.fn.fnameescape(root))
		require("persistence").load()
		vim.notify("Session: " .. vim.fn.fnamemodify(root, ":~"), vim.log.levels.INFO)
		-- Re-open files passed on cmdline (session restore wipes them).
		-- :args restores the arglist so :n/:prev navigate cmdline files;
		-- subsequent :edit calls load the rest into the buffer list, then
		-- we switch back to the first file. Mirrors `nvim f1 f2 f3`.
		if #files > 0 then
			vim.schedule(function()
				local escaped = {}
				for _, f in ipairs(files) do
					escaped[#escaped + 1] = vim.fn.fnameescape(f)
				end
				local ok, err = pcall(vim.cmd, "silent! args " .. table.concat(escaped, " "))
				if not ok then
					vim.notify("Failed to set arglist: " .. tostring(err), vim.log.levels.WARN)
				end
				for i = 2, #escaped do
					pcall(vim.cmd, "edit " .. escaped[i])
				end
				if #escaped > 1 then
					pcall(vim.cmd, "buffer " .. escaped[1])
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
