set encoding=utf-8
set nobackup
set nowritebackup
set number relativenumber
set scrolloff=5
set updatetime=250
set signcolumn=yes

call plug#begin()

" Visual
Plug 'folke/tokyonight.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lualine/lualine.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'onsails/lspkind.nvim'

" Functional
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.2' }
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': 'TSUpdate' }
Plug 'windwp/nvim-autopairs'
Plug 'tpope/vim-fugitive'
Plug 'numToStr/Comment.nvim'

" Languages
Plug 'ziglang/zig.vim'

" LSP and completion
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

call plug#end()

colorscheme tokyonight-storm

let mapleader = "\<Space>"

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
" nnoremap <leader>fb <cmd>Telescope buffers<cr>

tnoremap <Esc> <C-\><C-n>

" Window navigation
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l

inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l

nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

lua << EOF
vim.o.hlsearch = false
-- vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true

require("telescope").setup {
	extensions = {
    		file_browser = {
			theme = "ivy",
			hijack_netrw = true,
		}
	}
}

require("telescope").load_extension "file_browser"

vim.api.nvim_set_keymap(
	"n",
	"<leader>fb",
	":Telescope file_browser path=%:p:h select_buffer=true<CR>",
	{ noremap = true }
)

require("evil_lualine")
require('gitsigns').setup()

require("nvim-autopairs").setup {}
require('Comment').setup()

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require'cmp'

cmp.event:on(
	'confirm_done',
	cmp_autopairs.on_confirm_done()
)

cmp.setup({
	enabled = function()
		local ctx = require 'cmp.config.context'
		if vim.api.nvim_get_mode().mode == 'c' then
			return true
		else
			return not ctx.in_treesitter_capture("comment")
				and not ctx.in_syntax_group("Comment")
		end
	end,
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				-- local entry = cmp.get_selected_entry()
				-- if not entry then
				-- 	cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				-- else
				-- 	cmp.confirm()
				-- end
			else
				fallback()
			end

		end, {'i', 's'}),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
				-- local entry = cmp.get_selected_entry()
				-- if not entry then
				-- 	cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				-- else
				-- 	cmp.confirm()
				-- end
			else
				fallback()
			end

		end, {'i', 's'}),
		['<CR>'] = cmp.mapping(function(fallback)
			if cmp.visible() and cmp.get_active_entry() then
				cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
			else
				fallback()
			end
		end, {'i', 's', 'c'})
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' },
	}, {
		{ name = 'buffer' },
	}),
	formatting = {
		format = function(entry, vim_item)
			if vim.tbl_contains({ 'path' }, entry.source_name) then
				local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item().label)
				if icon then
					vim_item.kind = icon
					vim_item.kind_hl_group = hl_group
					return vim_item
				end
			end
			return require('lspkind').cmp_format({ with_text = false })(entry, vim_item)
		end
	}
})

cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})

local lspconfig = require'lspconfig'
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig['zls'].setup {
	capabilities = capabilities
}
lspconfig['ccls'].setup {
	capabilities = capabilities
}

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set('n', '<space>f', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end,
})
EOF

