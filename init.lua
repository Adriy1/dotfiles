-------------------- HELPERS -------------------------------
local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= 'o' then scopes['o'][key] = value end
end

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

g.mapleader = ","

-------------------- PLUGINS -------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath})
end
vim.opt.rtp:prepend(lazypath)

plugins = {

{'neovim/nvim-lspconfig'},
{"williamboman/mason.nvim", config = function() require("mason").setup{} end},

{'nvim-treesitter/nvim-treesitter', version=false, build=":TSUpdate",
    config = function ()
        require("nvim-treesitter.configs").setup{
            highlight = {enable = true},
            auto_install = true,}
        end},

{"L3MON4D3/LuaSnip", version = "v2.*",
    dependencies = { "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,}},

{"hrsh7th/nvim-cmp", version = false, -- last release is way too old
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "saadparwaiz1/cmp_luasnip",
  },},

{"simrat39/rust-tools.nvim"},
{'saecki/crates.nvim', config = function() require('crates').setup() end},

{'junegunn/fzf'},
{'junegunn/fzf.vim'},
{'ojroques/nvim-lspfuzzy', config = function() require("lspfuzzy").setup{} end},
{'nvim-lua/plenary.nvim'},
{"nvim-telescope/telescope.nvim"},

{"nvim-lualine/lualine.nvim", config = function() require("lualine").setup{} end},

{"lewis6991/gitsigns.nvim", config = function() require("gitsigns").setup{} end},
{"FabijanZulj/blame.nvim"},
{'ntpeters/vim-better-whitespace'},

{'echasnovski/mini.comment', version = '*', config = function() require("mini.comment").setup{} end},
{'echasnovski/mini.pairs', version = '*', config = function() require("mini.pairs").setup{} end},
{'echasnovski/mini.surround', version = '*', config = function() require("mini.surround").setup{} end},

{"folke/trouble.nvim"},

{'goolord/alpha-nvim', dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
        require'alpha'.setup(require'alpha.themes.startify'.config)
    end
};

{'mhartington/oceanic-next'},
{"folke/tokyonight.nvim"},
{"tiagovla/tokyodark.nvim"},
{ "catppuccin/nvim"},

}

require("lazy").setup(plugins)

-------------------- OPTIONS -------------------------------
local indent = 4
cmd 'colorscheme tokyonight-moon'                         -- Put your favorite colorscheme here
opt('b', 'expandtab', true)                           -- Use spaces instead of tabs
opt('b', 'shiftwidth', indent)                        -- Size of an indent
opt('b', 'smartindent', true)                         -- Insert indents automatically
opt('b', 'tabstop', indent)                           -- Number of spaces tabs count for
opt('o', 'hidden', true)                              -- Enable modified buffers in background
opt('o', 'ignorecase', true)                          -- Ignore case
opt('o', 'completeopt', "menuone,noinsert,noselect")   -- Completion
opt('o', 'joinspaces', false)                         -- No double spaces with join after a dot
opt('o', 'scrolloff', 4 )                             -- Lines of context
opt('o', 'shiftround', true)                          -- Round indent
opt('o', 'sidescrolloff', 8 )                         -- Columns of context
opt('o', 'smartcase', true)                           -- Don't ignore case with capitals
opt('o', 'splitbelow', true)                          -- Put new windows below current
opt('o', 'splitright', true)                          -- Put new windows right of current
opt('o', 'termguicolors', true)                       -- True color support
opt('w', 'list', false)                                -- Show some invisible characters (tabs...)
opt('w', 'number', true)                              -- Print line number
opt('w', 'relativenumber', false)                      -- Relative line numbers
-- opt('w', 'wrap', false)                               -- Disable line wrap
vim.opt.swapfile = false

g["netrw_banner"] = 0
g["netrw_liststyle"] = 3

g.strip_whitespace_on_save=1
g.strip_whitespace_confirm=0

-------------------- MAPPINGS ------------------------------
map('', '<leader>c', '"+y')       -- Copy to clipboard in normal, visual, select and operator modes
map('i', '<C-u>', '<C-g>u<C-u>')  -- Make <C-u> undo-friendly
map('i', '<C-w>', '<C-g>u<C-w>')  -- Make <C-w> undo-friendly

map('n', '<leader>,', '<cmd>noh<CR>')    -- Clear highlights
map('n', '<C-p>', '<cmd>tabe<CR>')    -- Open tab
map('n', '<leader>o', 'm`o<Esc>``')  -- Insert a newline in normal mode

map('n', 'gr', 'gT')  -- Switch Tab

map('', '<C-f>', ':GFiles<CR>')  -- FZF
map('', '<leader>f', ':History<CR>')  -- FZF

map('', '<C-j>', '<C-W>j')
map('', '<C-k>', '<C-W>k')
map('', '<C-h>', '<C-W>h')
map('', '<C-l>', '<C-W>l')

map('n', '<C-b>', ':SwitchBuffer<CR>')
map('n', '<leader>n', ':Vexplore<CR>')

-------------------- CMP -----------------------------------
local cmp = require'cmp'
vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  completion = {
    completeopt = "menuone,noinsert,noselect",
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
  experimental = {
        ghost_text = {
          hl_group = "CmpGhostText",
        },
    },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-------------------- LSP -----------------------------------
local lsp = require 'lspconfig'

lsp.pylsp.setup {
    capabilities = capabilities,
    handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
                underline = false
            }
        ),
    },
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "off",
            }
        },
        pylsp = {
            plugins = {
                pycodestyle = {
                    ignore = {"E126", "E203", "E302", "E305", "E501", "W391"},
                    enabled = false
                }
            }
        }
    }
}

lsp.clangd.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    default_config = {
        cmd = {
            "clangd-12", "--background-index", "--pch-storage=memory",
            "--clang-tidy", "--suggest-missing-includes"
        },
        filetypes = {"c", "cpp", "objc", "objcpp"},
    }
}

require("rust-tools").setup{
    tools = {
    	runnables = {
      	    use_telescope = true,
    	},
        inlay_hints = {
            auto = true,
            show_parameter_hints = false,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },
    server = {
        capabilities = capabilities,
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy",
                },
            },
        },
    },
}

map('n', '<space>,', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
map('n', '<space>;', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
map('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>')
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
map('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>')
map('n', '<space>h', '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', '<space>m', '<cmd>lua vim.lsp.buf.rename()<CR>')
map('n', '<space>r', '<cmd>lua vim.lsp.buf.references()<CR>')
map('n', '<space>s', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')

map('n', '<M-o>', "<cmd>ClangdSwitchSourceHeader<cr>")

-------------------- COMMANDS ------------------------------
cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'  -- disabled in visual mode
