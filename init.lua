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

{"L3MON4D3/LuaSnip", version = "v2.*", lazy=true,
    dependencies = { "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,}},

{"hrsh7th/nvim-cmp", version = false, -- last release is way too old
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-cmdline",
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

{'Vigemus/iron.nvim'},

{
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  opts = {
    -- add any opts here
    -- for example
    providers = {
      openai = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-20250219", -- your desired model (or use gpt-4o, etc.)
        timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
        extra_request_body = {
          max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
          temperature = 0,
        },
        --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
    },

    },
    mappings = {
      ---@class AvanteConflictMappings
      diff = {
        ours = "ao",
        theirs = "at",
        all_theirs = "aa",
        both = "ab",
        cursor = "ac",
      },
  },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = false,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
},

{'mhartington/oceanic-next'},
{ "EdenEast/nightfox.nvim" },
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
vim.opt.mouse = ""

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

vim.keymap.set('n', '<leader>b', ':!black %<CR>', { noremap = true, silent = true })

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
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  },
  {
    { name = 'cmdline' }
  })
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
            "clangd", "--background-index", "--pch-storage=memory",
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

map('n', '<space>,', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
map('n', '<space>;', '<cmd>lua vim.diagnostic.goto_next()<CR>')
map('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>')
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
map('n', '<space>f', '<cmd>lua vim.lsp.buf.format()<CR>')
map('n', '<space>h', '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', '<space>m', '<cmd>lua vim.lsp.buf.rename()<CR>')
map('n', '<space>r', '<cmd>lua vim.lsp.buf.references()<CR>')
map('n', '<space>s', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')

map('n', '<M-o>', "<cmd>ClangdSwitchSourceHeader<cr>")

-------------------- COMMANDS ------------------------------
cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'  -- disabled in visual mode

-------------------- REPL ----------------------------------
local iron = require("iron.core")
local view = require("iron.view")
local common = require("iron.fts.common")

iron.setup {
  config = {
    -- Whether a repl should be discarded or not
    scratch_repl = true,
    -- Your repl definitions come here
    repl_definition = {
      sh = {
        -- Can be a table or a function that
        -- returns a table (see below)
        command = {"zsh"}
      },
      python = {
        command = { "ipython", "--no-autoindent" },  -- or { "ipython", "--no-autoindent" }
        format = common.bracketed_paste_python,
        block_dividers = { "# %%", "#%%" },
      }
    },
    -- set the file type of the newly created repl to ft
    -- bufnr is the buffer id of the REPL and ft is the filetype of the
    -- language being used for the REPL.
    repl_filetype = function(bufnr, ft)
      return ft
      -- or return a string name such as the following
      -- return "iron"
    end,
    -- How the repl window will be displayed
    -- See below for more information
    repl_open_cmd = view.split.rightbelow("30%", {
	    winfixwidth = false,
	    winfixheight = false,
		  -- any window-local configuration can be used here
		number = true
	})

    -- repl_open_cmd can also be an array-style table so that multiple
    -- repl_open_commands can be given.
    -- When repl_open_cmd is given as a table, the first command given will
    -- be the command that `IronRepl` initially toggles.
    -- Moreover, when repl_open_cmd is a table, each key will automatically
    -- be available as a keymap (see `keymaps` below) with the names
    -- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
    -- For example,
    --
    -- repl_open_cmd = {
    --   view.split.vertical.rightbelow("%40"), -- cmd_1: open a repl to the right
    --   view.split.rightbelow("%25")  -- cmd_2: open a repl below
    -- }

  },
  -- Iron doesn't set keymaps by default anymore.
  -- You can set them here or manually add keymaps to the functions in iron.core
  keymaps = {
    toggle_repl = "<space>rr", -- toggles the repl open and closed.
    -- If repl_open_command is a table as above, then the following keymaps are
    -- available
    -- toggle_repl_with_cmd_1 = "<space>rv",
    -- toggle_repl_with_cmd_2 = "<space>rh",
    restart_repl = "<space>rR", -- calls `IronRestart` to restart the repl
    send_motion = "<space>sv",
    visual_send = "<space>sv",
    send_file = "<space>sf",
    send_line = "<space>sl",
    send_paragraph = "<space>sp",
    send_until_cursor = "<space>su",
    send_mark = "<space>sm",
    send_code_block = "<space>sb",
    send_code_block_and_move = "<space>sn",
    mark_motion = "<space>mc",
    mark_visual = "<space>mc",
    remove_mark = "<space>md",
    cr = "<space>s<cr>",
    interrupt = "<space>s<space>",
    exit = "<space>sq",
    clear = "<space>cl",
  },
  -- If the highlight is on, you can change how it looks
  -- For the available options, check nvim_set_hl
  highlight = {
    italic = true
  },
  ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
}

-- iron also has a list of commands, see :h iron-commands for all available commands
vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')
-- vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true }) -- breaking Esc in telescope windows
-- Map Ctrl+h/j/k/l to switch buffers in Terminal mode
vim.keymap.set('t', '<C-h>', '<C-\\><C-n>:wincmd h<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<C-j>', '<C-\\><C-n>:wincmd j<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<C-k>', '<C-\\><C-n>:wincmd k<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<C-l>', '<C-\\><C-n>:wincmd l<CR>', { noremap = true, silent = true })
