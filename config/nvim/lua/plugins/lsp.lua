-- Completion (nvim-cmp + LuaSnip), Lua dev (lazydev),
-- and LSP servers (mason + mason-lspconfig + native vim.lsp).

-- ----------------------------------------------------------------------
-- Completion
-- ----------------------------------------------------------------------
local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<Tab>"]   = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<CR>"]    = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
	}),
})

-- ----------------------------------------------------------------------
-- LSP
-- ----------------------------------------------------------------------
require("lazydev").setup({})
require("mason").setup()

local servers = {
	pylsp = {
		settings = {
			pylsp = {
				plugins = {
					ruff = {
						enabled = true,
						formatEnabled = true,
						extendSelect = { "I" },
						targetVersion = "py310",
					},
				},
			},
		},
	},

	lua_ls = (function()
		local function optional_path(path)
			local stat = vim.uv.fs_stat(path)
			if stat and stat.type == "directory" then return path end
			return nil
		end

		local hammerspoon_paths = vim.tbl_filter(function(p) return p ~= nil end, {
			optional_path(vim.fn.expand("~/.local/share/hammerspoon-api/extensions")),
			optional_path(vim.fn.expand("~/.local/share/hammerspoon-api/extensions/hs")),
			optional_path(vim.fn.expand("~/.local/share/hammerspoon-api/extensions/hs/alert")),
		})

		return {
			settings = {
				Lua = {
					diagnostics = { globals = { "hs" } },
					workspace = {
						checkThirdParty = false,
						library = hammerspoon_paths,
					},
					telemetry = { enable = false },
				},
			},
		}
	end)(),

	marksman = {},
}

-- Shared defaults for every server (capabilities from cmp).
vim.lsp.config("*", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

for name, config in pairs(servers) do
	vim.lsp.config(name, config)
end

-- mason-lspconfig will install missing servers and (via automatic_enable)
-- call vim.lsp.enable() for each, picking up our configs above.
require("mason-lspconfig").setup({
	ensure_installed = vim.tbl_keys(servers),
})

-- Per-buffer LSP setup runs once, when any client attaches.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then return end

		vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
			vim.lsp.buf.format({ async = false })
		end, { desc = "Format buffer with LSP" })

		local group = vim.api.nvim_create_augroup("LspOnSave_" .. bufnr, { clear = false })

		if client:supports_method("textDocument/formatting") then
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = group,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({
						async = false,
						bufnr = bufnr,
						filter = function(c) return c.id == client.id end,
					})
				end,
			})
		end

		-- Ruff fixAll on save (only when the ruff LSP itself is attached).
		if client.name == "ruff" then
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = group,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.code_action({
						context = { only = { "source.fixAll.ruff" }, diagnostics = {} },
						apply = true,
					})
				end,
			})
		end
	end,
})
