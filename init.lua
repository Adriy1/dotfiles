-------------------- PERFORMANCE ---------------------------
vim.loader.enable()

-------------------- HELPERS -------------------------------
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

g.mapleader = ","

-------------------- PLUGINS -------------------------------
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable",
        lazypath
    })
end
opt.rtp:prepend(lazypath)

local plugins = {
    -- Mason: Installs the binary tools (clangd, python-lsp-server, etc.)
    -- We still use Mason to DOWNLOAD the tools, but we configure them natively below.
    {
        "williamboman/mason.nvim",
        config = function() require("mason").setup() end
    },

    -- Treesitter (main branch API: no ensure_installed/highlight/auto_install options)
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup()

            local ts_config = require("nvim-treesitter.config")
            local ensure_installed = {
                "c", "cpp", "lua", "vim", "vimdoc", "query",
                "python", "rust", "markdown", "markdown_inline",
                "bash", "json", "yaml", "toml", "proto", "cmake",
            }
            local installed = ts_config.get_installed("parsers")
            local missing = vim.tbl_filter(function(lang)
                return not vim.tbl_contains(installed, lang)
            end, ensure_installed)
            if #missing > 0 then
                require("nvim-treesitter").install(missing)
            end

            -- main does not start the highlighter for you; master's `highlight.enable` is gone.
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                    if lang then pcall(vim.treesitter.start, args.buf, lang) end
                end,
            })
        end
    },

    -- Snippets & Completion
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
        },
    },

    -- Rust (Rustaceanvim handles its own native setup, so we keep it)
    {
        'mrcjkb/rustaceanvim',
        version = '^5',
        lazy = false,
    },
    {
        'saecki/crates.nvim',
        event = { "BufRead Cargo.toml" },
        config = function() require('crates').setup() end
    },

    -- Fuzzy Finding
    {'junegunn/fzf'},
    {'junegunn/fzf.vim'},
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    {'stevearc/oil.nvim', dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup({
                view_options = { show_hidden = true },
            })
            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        end,
    },

    -- UI
    { "nvim-lualine/lualine.nvim", config = function() require("lualine").setup{} end },
    { "lewis6991/gitsigns.nvim", config = function() require("gitsigns").setup{} end },
    { "folke/trouble.nvim", cmd = "Trouble" },

    -- Editing
    { 'echasnovski/mini.comment', version = '*', config = function() require("mini.comment").setup{} end },
    { 'echasnovski/mini.pairs', version = '*', config = function() require("mini.pairs").setup{} end },
    { 'echasnovski/mini.surround', version = '*', config = function() require("mini.surround").setup{} end },

    -- Formatting
    {'stevearc/conform.nvim',
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = {
                python = { "ruff_format", "ruff_organize_imports" }, -- Fast & combines black/isort logic
                rust = { "rustfmt" },
                lua = { "stylua" },
            },
            format_on_save = { timeout_ms = 500, lsp_fallback = true },
        },
    },

    -- Dashboard
    {
        'goolord/alpha-nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function() require'alpha'.setup(require'alpha.themes.startify'.config) end
    },

    -- REPL
    {'Vigemus/iron.nvim'},

    -- AI (Avante)
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        lazy = false,
        version = false,
        opts = {
            providers = {
                openai = {
                    endpoint = "https://api.anthropic.com",
                    model = "claude-3-7-sonnet-20250219",
                    timeout = 30000,
                    extra_request_body = { max_completion_tokens = 8192, temperature = 0 },
                },
            },
        },
        build = "make",
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            {
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = { default = { embed_image_as_base64 = false, prompt_for_file_name = false, drag_and_drop = { insert_mode = true }, use_absolute_path = false } },
            },
            {
                'MeanderingProgrammer/render-markdown.nvim',
                opts = { file_types = { "markdown", "Avante" } },
                ft = { "markdown", "Avante" },
            },
        },
    },

    -- Claude Code
    {
        "greggh/claude-code.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("claude-code").setup({ window = { split_ratio = 0.3, position = "vertical" } })
        end
    },

    -- Themes
    {'mhartington/oceanic-next'},
    { "EdenEast/nightfox.nvim" },
    {"folke/tokyonight.nvim"},
    {"tiagovla/tokyodark.nvim"},
    { "catppuccin/nvim"},
}

require("lazy").setup(plugins)

-------------------- OPTIONS -------------------------------
local indent = 4
cmd.colorscheme 'tokyonight-moon'

opt.expandtab = true
opt.shiftwidth = indent
opt.smartindent = true
opt.tabstop = indent
opt.hidden = true
opt.ignorecase = true
opt.completeopt = { "menuone", "noinsert", "noselect" }
opt.joinspaces = false
opt.scrolloff = 4
opt.shiftround = true
opt.sidescrolloff = 8
opt.smartcase = true
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.list = false
opt.number = true
opt.relativenumber = false
opt.swapfile = false
opt.mouse = ""

g.netrw_banner = 0
g.netrw_liststyle = 3
g.strip_whitespace_on_save = 1
g.strip_whitespace_confirm = 0

-------------------- MAPPINGS ------------------------------
local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end

map('', '<leader>c', '"+y')
map('i', '<C-u>', '<C-g>u<C-u>')
map('i', '<C-w>', '<C-g>u<C-w>')
map('n', '<leader>,', '<cmd>noh<CR>')
map('n', '<C-p>', '<cmd>tabe<CR>')
map('n', '<leader>o', 'm`o<Esc>``')

-- Unmap default gr mappings to make tab switching instant
-- Disable defaults
pcall(vim.keymap.del, "n", "gra")
pcall(vim.keymap.del, "n", "gri")
pcall(vim.keymap.del, "n", "grn")
pcall(vim.keymap.del, "n", "grr")
pcall(vim.keymap.del, "n", "grt")
pcall(vim.keymap.del, "n", "grx")

map('n', 'gr', 'gT')
map('n', '<C-f>', '<cmd>Telescope git_files<CR>') -- Replacement for :GFiles
map('n', '<leader>f', '<cmd>Telescope oldfiles<CR>') -- Replacement for :History
-- map('', '<C-f>', ':GFiles<CR>')
-- map('', '<leader>f', ':History<CR>')
map('', '<C-j>', '<C-W>j')
map('', '<C-k>', '<C-W>k')
map('', '<C-h>', '<C-W>h')
map('', '<C-l>', '<C-W>l')
map('n', '<C-b>', ':SwitchBuffer<CR>')
map('n', '<leader>b', ':!black %<CR>', { silent = true })

-- Native LSP Mappings
map('n', '<space>,', function() vim.diagnostic.jump({ count = -1, float = true }) end)
map('n', '<space>;', function() vim.diagnostic.jump({ count = 1, float = true }) end)
map('n', '<space>a', vim.lsp.buf.code_action)
map('n', 'gd', vim.lsp.buf.definition)
map('n', 'gD', vim.lsp.buf.declaration)
map('n', '<space>f', vim.lsp.buf.format)
map('n', '<space>h', vim.lsp.buf.hover)
map('n', '<space>m', vim.lsp.buf.rename)
map('n', '<space>r', vim.lsp.buf.references)

-------------------- CMP -----------------------------------
local cmp = require'cmp'
vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
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
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
  experimental = {
    ghost_text = { hl_group = "CmpGhostText" },
  },
})

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { { name = 'buffer' } }
})
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } })
})

-------------------- NATIVE 0.11 LSP -----------------------
-- Capabilities for completion, applied to every server defined below.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config('*', { capabilities = capabilities })

-- Resolve a binary from PATH, falling back to Mason's bin dir.
local function lsp_bin(name)
    if vim.fn.executable(name) == 1 then return name end
    local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", name)
    if vim.fn.executable(mason_bin) == 1 then return mason_bin end
    return name
end

-- 1. Clangd (C/C++)
-- NOTE: `filetypes` is mandatory. Omitting it means "attach to ALL filetypes"
-- (see :h lsp-config), which is how clangd used to end up in Python buffers.
vim.lsp.config.clangd = {
    cmd = {
        "clangd",
        "--background-index",
        "--pch-storage=memory",
        "--clang-tidy",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    -- Roots at whichever ancestor is closest; `.clangd` points clangd at build/.
    root_markers = { "compile_commands.json", ".clangd", ".git" },
}

-- 2a. ty (Astral) -- Python types: hover, go-to-definition, completion.
vim.lsp.config.ty = {
    cmd = { lsp_bin("ty"), "server" },
    filetypes = { "python" },
    root_markers = { "ty.toml", "pyproject.toml", ".git" },
}

-- 2b. Ruff -- Python lint + code actions only. ty owns hover/definition,
-- so silence ruff's overlapping hover to avoid duplicated popups.
vim.lsp.config.ruff = {
    cmd = { lsp_bin("ruff"), "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
    on_attach = function(client)
        client.server_capabilities.hoverProvider = false
        client.server_capabilities.definitionProvider = false
    end,
}

vim.lsp.enable({ "clangd", "ty", "ruff" })

-- 3. Rust
-- Note: Rust is unique. We rely on 'rustaceanvim' (the plugin).
-- It hooks into the 0.11 infrastructure automatically, so no vim.lsp.config definition needed here.
-- Just set the global config for the plugin to pick up.
vim.g.rustaceanvim = {
    server = {
        capabilities = capabilities,
        default_settings = {
            ['rust-analyzer'] = {
                checkOnSave = { command = "clippy" },
            },
        },
    },
}

-- 4. Diagnostics
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    severity_sort = true,
})

-------------------- REPL (Iron.nvim) ----------------------
local iron = require("iron.core")
local view = require("iron.view")

iron.setup {
  config = {
    scratch_repl = true,
    repl_definition = {
      sh = { command = {"zsh"} },
      python = {
        -- vi editing mode gives motions (b/w/dw/ciw...) at the ipython prompt itself,
        -- via prompt_toolkit -- <Esc> switches to its normal mode without leaving :terminal.
        command = { "ipython", "--no-autoindent", "--TerminalInteractiveShell.editing_mode=vi" },
        format = require("iron.fts.common").bracketed_paste_python,
      }
    },
    repl_filetype = function(bufnr, ft)
        return ft
    end,
    -- How the repl window will be displayed
    repl_open_cmd = view.split.rightbelow("30%", {
      winfixwidth = false,
      winfixheight = false,
      number = true,
    }),
  },

  keymaps = {
    toggle_repl = "<space>rr", -- toggles the repl open and closed.
    restart_repl = "<space>rR", -- calls `IronRestart` to restart the repl
    send_motion = "<space>sc",
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
    cr = "<space><cr>",
    interrupt = "<space><space>",
    exit = "<space>sq",
    clear = "<space>cl",
  },
  highlight = { italic = true },
  ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
}

-- iron also has a list of commands, see :h iron-commands for all available commands
vim.keymap.set("n", "<space>rf", "<cmd>IronFocus<cr>")
vim.keymap.set("n", "<space>rh", "<cmd>IronHide<cr>")
-- vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true })
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })
