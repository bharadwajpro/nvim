-- Basic Neovim Configuration
-- Set leader keys (must be set before any keymaps that use leader)
vim.g.mapleader = " " -- Global leader key (Space)
vim.g.maplocalleader = " " -- Local leader key for filetype-specific mappings

-- Enable relative line numbers
vim.opt.number = true -- Show absolute line number on current line
vim.opt.relativenumber = true -- Show relative line numbers on other lines

-- Indentation settings
vim.cmd("filetype plugin indent on") -- Enable filetype detection and plugins
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Number of spaces for each indentation level
vim.opt.tabstop = 4 -- Number of spaces a <Tab> displays as
vim.opt.smarttab = true -- Use shiftwidth when using <Tab> in insert mode
vim.opt.autoindent = true -- Copy indent from current line when starting new line

-- Enable true color support
vim.opt.termguicolors = true

-- Window splitting behavior
vim.opt.splitright = true -- New vertical splits open on the right
vim.opt.splitbelow = true -- New horizontal splits open below

-- Scroll mappings that keep screen centered
vim.keymap.set("n", "<C-f>", "<C-f>zz", { desc = "Scroll forward and center" })
vim.keymap.set("n", "<C-b>", "<C-b>zz", { desc = "Scroll backward and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half screen and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half screen and center" })

-- Search mappings that keep screen centered
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "*", "*zzzv", { desc = "Search word under cursor forward (centered)" })
vim.keymap.set("n", "#", "#zzzv", { desc = "Search word under cursor backward (centered)" })

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
require("lazy").setup({
	-- Tokyo Night colorscheme
	{
		"folke/tokyonight.nvim",
		priority = 1000, -- Load before other plugins
		config = function()
			require("tokyonight").setup({
				style = "night", -- Options: storm, moon, night, day
				transparent = false,
				terminal_colors = true,
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
				},
			})
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- Lualine statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "tokyonight",
					icons_enabled = true,
					component_separators = { left = "|", right = "|" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- Telescope fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							-- Insert mode mappings (consistent with nvim-cmp)
							["<C-n>"] = "move_selection_next",
							["<C-p>"] = "move_selection_previous",
							["<C-q>"] = "send_to_qflist",
							["<Esc>"] = "close",
						},
						n = {
							-- Normal mode mappings
							["q"] = "close",
						},
					},
					file_ignore_patterns = {
						"node_modules",
						".git/",
						"dist/",
						"build/",
						"target/",
					},
				},
			})

			-- Keybindings for Telescope
			local builtin = require("telescope.builtin")

			-- Find files
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })

			-- Search text in files (live grep)
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })

			-- Search through open buffers
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })

			-- Search help documentation
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help" })

			-- Search recent files
			vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent Files" })

			-- Search current buffer lines
			vim.keymap.set("n", "<leader>fl", builtin.current_buffer_fuzzy_find, { desc = "Find Lines" })

			-- Search keymaps
			vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })

			-- Search LSP symbols in current file
			vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find Symbols" })

			-- Search diagnostics (errors/warnings)
			vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find Diagnostics" })
		end,
	},

	-- Which-key: Shows available keybindings in a popup
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")

			wk.setup({
				plugins = {
					spelling = {
						enabled = true,
						suggestions = 20,
					},
				},
			})

			-- Register key groups with descriptions
			wk.add({
				{ "<leader>f", group = "Find (Telescope)" },
				{ "<leader>c", group = "Code" },
				{ "<leader>r", group = "Rename" },
			})
		end,
	},

	-- Auto pairs: Auto-close brackets, quotes, etc.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local autopairs = require("nvim-autopairs")
			autopairs.setup({
				check_ts = true, -- Use Tree-sitter for smart context detection
			})

			-- Integration with nvim-cmp (auto-add brackets on completion)
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	-- Comment.nvim: Easy commenting
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring", -- Tree-sitter aware commenting
		},
		config = function()
			require("Comment").setup({
				-- Toggler mappings in NORMAL mode
				toggler = {
					line = "gcc", -- Toggle line comment
					block = "gbc", -- Toggle block comment
				},
				-- Operator-pending mappings in NORMAL and VISUAL mode
				opleader = {
					line = "gc", -- Line comment with motion/visual
					block = "gb", -- Block comment with motion/visual
				},
				-- Tree-sitter integration for smart comment detection
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
		end,
	},

	-- Indent-blankline: Show indentation guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("ibl").setup({
				indent = {
					char = "│", -- Character for indent line
				},
				scope = {
					enabled = true, -- Highlight current scope
					show_start = true,
					show_end = false,
				},
			})
		end,
	},

	-- nvim-surround: Add/change/delete surrounding characters
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Default keybindings:
				-- ys{motion}{char} - Add surround
				-- cs{old}{new}     - Change surround
				-- ds{char}         - Delete surround
				-- Visual: S{char}  - Surround selection
			})
		end,
	},

	-- Neo-tree: File explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true, -- Close Neo-tree if it's the last window
				popup_border_style = "rounded",
				enable_git_status = true,
				enable_diagnostics = true,
				filesystem = {
					follow_current_file = {
						enabled = true, -- Find and focus the current file
					},
					filtered_items = {
						hide_dotfiles = false,
						hide_gitignored = false,
						hide_by_name = {
							"node_modules",
							".git",
							".DS_Store",
						},
					},
				},
				window = {
					position = "left",
					width = 30,
				},
			})

			-- Keybindings
			vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle File Explorer", silent = true })
			vim.keymap.set("n", "<leader>ge", ":Neotree git_status<CR>", { desc = "Git Explorer", silent = true })
			vim.keymap.set("n", "<leader>be", ":Neotree buffers<CR>", { desc = "Buffer Explorer", silent = true })
		end,
	},

	-- Gitsigns: Git integration (show changes in gutter)
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					-- Navigation between hunks
					vim.keymap.set("n", "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, buffer = bufnr, desc = "Next git hunk" })

					vim.keymap.set("n", "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, buffer = bufnr, desc = "Previous git hunk" })

					-- Actions
					vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
					vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
					vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo stage hunk" })
					vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
					vim.keymap.set("n", "<leader>hb", function()
						gs.blame_line({ full = true })
					end, { buffer = bufnr, desc = "Blame line" })
					vim.keymap.set("n", "<leader>hd", function()
						if vim.wo.diff then
							vim.cmd("diffoff") -- Exit diff mode
							vim.cmd("only") -- Close all windows except current
						else
							vim.cmd("vertical rightbelow Gitsigns diffthis") -- Open diff with proper positioning
						end
					end, { buffer = bufnr, desc = "Toggle diff" })

					-- Text object for hunks
					vim.keymap.set(
						{ "o", "x" },
						"ih",
						":<C-U>Gitsigns select_hunk<CR>",
						{ buffer = bufnr, desc = "Select hunk" }
					)
				end,
			})

			-- Code review workflow: Navigate hunks across all files
			vim.keymap.set("n", "<leader>hq", function()
				require("gitsigns").setqflist("all")
				vim.cmd("cfirst") -- Jump to first hunk
				vim.cmd("cclose") -- Close quickfix window
			end, { desc = "Review all hunks" })

			vim.keymap.set("n", "]q", ":cnext<CR>zz", { desc = "Next hunk (any file)" })
			vim.keymap.set("n", "[q", ":cprev<CR>zz", { desc = "Previous hunk (any file)" })
		end,
	},

	-- Tree-sitter for smart syntax-aware indentation and highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				-- Auto-install parsers for any file you open
				auto_install = true,

				-- Enable Tree-sitter based indentation
				indent = {
					enable = true,
				},

				-- Enable syntax highlighting
				highlight = {
					enable = true,
				},
			})
		end,
	},

	-- Fidget: LSP progress notifications
	{
		"j-hui/fidget.nvim",
		opts = {
			notification = {
				window = {
					winblend = 0, -- Transparency (0 = opaque, 100 = transparent)
					relative = "editor",
				},
			},
		},
	},

	-- Mason: Package manager for LSP servers, formatters, and linters
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	-- LSP Configuration (must be loaded before mason-lspconfig handlers)
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
	},

	-- Mason-LSPConfig: Bridge between mason and lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
		config = function()
			require("mason-lspconfig").setup({
				-- Automatically install these LSP servers
				ensure_installed = {
					"lua_ls", -- Lua
					"ts_ls", -- TypeScript/JavaScript
					"jdtls", -- Java
					"jsonls", -- JSON
				},
				automatic_installation = true,
				handlers = {
					-- Default handler for all servers
					function(server_name)
						local lspconfig = require("lspconfig")
						local cmp_nvim_lsp = require("cmp_nvim_lsp")

						lspconfig[server_name].setup({
							on_attach = function(client, bufnr)
								-- LSP Keybindings
								local opts = { buffer = bufnr, noremap = true, silent = true }

								-- Navigation
								vim.keymap.set(
									"n",
									"gd",
									vim.lsp.buf.definition,
									vim.tbl_extend("force", opts, { desc = "Go to definition" })
								)
								vim.keymap.set(
									"n",
									"gD",
									vim.lsp.buf.declaration,
									vim.tbl_extend("force", opts, { desc = "Go to declaration" })
								)
								vim.keymap.set(
									"n",
									"gi",
									vim.lsp.buf.implementation,
									vim.tbl_extend("force", opts, { desc = "Go to implementation" })
								)
								vim.keymap.set(
									"n",
									"gr",
									vim.lsp.buf.references,
									vim.tbl_extend("force", opts, { desc = "Show references" })
								)

								-- Information
								vim.keymap.set(
									"n",
									"K",
									vim.lsp.buf.hover,
									vim.tbl_extend("force", opts, { desc = "Hover documentation" })
								)
								vim.keymap.set(
									"n",
									"<C-k>",
									vim.lsp.buf.signature_help,
									vim.tbl_extend("force", opts, { desc = "Signature help" })
								)

								-- Actions
								vim.keymap.set(
									"n",
									"<leader>rn",
									vim.lsp.buf.rename,
									vim.tbl_extend("force", opts, { desc = "Rename symbol" })
								)
								vim.keymap.set(
									"n",
									"<leader>ca",
									vim.lsp.buf.code_action,
									vim.tbl_extend("force", opts, { desc = "Code action" })
								)

								-- Diagnostics
								vim.keymap.set(
									"n",
									"[d",
									vim.diagnostic.goto_prev,
									vim.tbl_extend("force", opts, { desc = "Previous diagnostic" })
								)
								vim.keymap.set(
									"n",
									"]d",
									vim.diagnostic.goto_next,
									vim.tbl_extend("force", opts, { desc = "Next diagnostic" })
								)
								vim.keymap.set(
									"n",
									"<leader>e",
									vim.diagnostic.open_float,
									vim.tbl_extend("force", opts, { desc = "Show diagnostic" })
								)
							end,
							capabilities = cmp_nvim_lsp.default_capabilities(),
						})
					end,

					-- Custom configuration for Lua LSP
					["lua_ls"] = function()
						local lspconfig = require("lspconfig")
						local cmp_nvim_lsp = require("cmp_nvim_lsp")

						lspconfig.lua_ls.setup({
							on_attach = function(client, bufnr)
								-- LSP Keybindings
								local opts = { buffer = bufnr, noremap = true, silent = true }

								-- Navigation
								vim.keymap.set(
									"n",
									"gd",
									vim.lsp.buf.definition,
									vim.tbl_extend("force", opts, { desc = "Go to definition" })
								)
								vim.keymap.set(
									"n",
									"gD",
									vim.lsp.buf.declaration,
									vim.tbl_extend("force", opts, { desc = "Go to declaration" })
								)
								vim.keymap.set(
									"n",
									"gi",
									vim.lsp.buf.implementation,
									vim.tbl_extend("force", opts, { desc = "Go to implementation" })
								)
								vim.keymap.set(
									"n",
									"gr",
									vim.lsp.buf.references,
									vim.tbl_extend("force", opts, { desc = "Show references" })
								)

								-- Information
								vim.keymap.set(
									"n",
									"K",
									vim.lsp.buf.hover,
									vim.tbl_extend("force", opts, { desc = "Hover documentation" })
								)
								vim.keymap.set(
									"n",
									"<C-k>",
									vim.lsp.buf.signature_help,
									vim.tbl_extend("force", opts, { desc = "Signature help" })
								)

								-- Actions
								vim.keymap.set(
									"n",
									"<leader>rn",
									vim.lsp.buf.rename,
									vim.tbl_extend("force", opts, { desc = "Rename symbol" })
								)
								vim.keymap.set(
									"n",
									"<leader>ca",
									vim.lsp.buf.code_action,
									vim.tbl_extend("force", opts, { desc = "Code action" })
								)

								-- Diagnostics
								vim.keymap.set(
									"n",
									"[d",
									vim.diagnostic.goto_prev,
									vim.tbl_extend("force", opts, { desc = "Previous diagnostic" })
								)
								vim.keymap.set(
									"n",
									"]d",
									vim.diagnostic.goto_next,
									vim.tbl_extend("force", opts, { desc = "Next diagnostic" })
								)
								vim.keymap.set(
									"n",
									"<leader>e",
									vim.diagnostic.open_float,
									vim.tbl_extend("force", opts, { desc = "Show diagnostic" })
								)
							end,
							capabilities = cmp_nvim_lsp.default_capabilities(),
							settings = {
								Lua = {
									diagnostics = {
										globals = { "vim" }, -- Recognize 'vim' global in Neovim configs
									},
								},
							},
						})
					end,
				},
			})
		end,
	},

	-- Autocompletion plugin
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP completion source
			"hrsh7th/cmp-buffer", -- Buffer words completion
			"hrsh7th/cmp-path", -- File path completion
			"L3MON4D3/LuaSnip", -- Snippet engine
			"saadparwaiz1/cmp_luasnip", -- Snippet completion source
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				mapping = cmp.mapping.preset.insert({
					-- Scroll documentation
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Trigger completion
					["<C-Space>"] = cmp.mapping.complete(),

					-- Close completion menu
					["<C-e>"] = cmp.mapping.abort(),

					-- Confirm selection
					["<CR>"] = cmp.mapping.confirm({ select = true }),

					-- Navigate completion menu with Tab/Shift-Tab
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),

					-- Alternative navigation with Ctrl+n/p (Vim-style)
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
				}),

				sources = cmp.config.sources({
					{ name = "nvim_lsp" }, -- LSP completions
					{ name = "luasnip" }, -- Snippet completions
					{ name = "buffer" }, -- Buffer word completions
					{ name = "path" }, -- File path completions
				}),
			})
		end,
	},

	-- Conform.nvim for auto-formatting on save
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		config = function()
			require("conform").setup({
				-- Auto-format on save
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true, -- Use LSP formatter (jdtls, ts_ls, jsonls) if available
				},

				-- Optional: Add standalone formatters here if needed
				formatters_by_ft = {
					lua = { "stylua" }, -- Standalone Lua formatter (optional)
					-- JS/TS/TSX/JSX/JSON use LSP formatters (ts_ls, jsonls)
					-- Java uses LSP formatter (jdtls)
				},
			})
		end,
	},
})
