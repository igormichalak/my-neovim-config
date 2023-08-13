set encoding=utf-8
set nobackup
set nowritebackup
set number relativenumber
set scrolloff=5
set updatetime=300
set signcolumn=yes

call plug#begin()

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.2' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'tpope/vim-fugitive'
Plug 'windwp/nvim-autopairs'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'folke/tokyonight.nvim'
Plug 'ziglang/zig.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'onsails/lspkind.nvim'

call plug#end()

colorscheme tokyonight-storm

let mapleader = "\<Space>"

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>

lua << EOF
require("evil_lualine")
require("nvim-autopairs").setup {}

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require'cmp'

cmp.event:on(
	'confirm_done',
	cmp_autopairs.on_confirm_done()
)

cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	window = {},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				local entry = cmp.get_selected_entry()
				if not entry then
					cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				else
					cmp.confirm()
				end
			else
				fallback()
			end

		end, {'i', 's', 'c'}),
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

local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig')['zls'].setup {
	capabilities = capabilities
}
EOF

