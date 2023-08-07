---@tag TexLab texlab-tools
---@text TEXLAB TOOLS
--- ============
---
--- The texlab-tools plugin creates functionality around the texlab language server.
--- The plugin does nothing without being set up.
--- To set up the plugin, call |TexLab.setup()| with your prefered options.
---
---
--- REQUIREMENTS
---
--- - [texlab](https://github.com/latex-lsp/texlab) language server installed (at least v5.7.0)
--- - [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
--- - [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
---   and [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) (optional for toc)
--- 




local TexLab = {}

TexLab.snippet = require("texlab-tools.snippet")
TexLab.action = require("texlab-tools.action")
TexLab.mappings = require("texlab-tools.mappings")

-- Setup the functions that handle forward and inverse search
local __viewer = require("texlab-tools.viewer")
TexLab.__forward_search = __viewer.__forward
TexLab.__inverse_search = __viewer.__inverse


--- Setup the texlab-tools plugin
--- See |TexLab.configuration.example| for an example config.
---
---@param opts table | nil Important keys:
---
---  - `snippet.app` string|nil: The application to use for snippet insertion.
---    Available options: "snippy", "vsnip", "luasnip", "ultisnips"
---
---  - `viewer.app` string|nil: The application to use for pdf viewing.
---    For now only "zathura" and "okular" are supported.
---
---  - `builder.app` (string)|nil: The application to use for building. (default: "latexmk")
---    For now only "latexmk" is supported.
---
---  - `mappings` table|nil: Mappings that are added once TexLab attaches to a buffer.
---    See |TexLab.mappings()| for more info.
---
---  - `texlab_opts` table|false|nil: Additional options that are passed to the texlab language server.
---    If false, the server is not started. An existing server can be used if it is set up.
function TexLab.setup(opts)
  opts = opts or {}

  local mappings = opts.mappings or {}

  local lsp_attach = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name ~= "texlab" then
      return
    end
    TexLab.mappings.__apply(mappings, { buffer = 0 })
  end

  local group = vim.api.nvim_create_augroup("texlabtools", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", { callback = lsp_attach, group = group })

  -- Snippets
  if opts.snippet then
    TexLab.snippet.__apply_setup(opts.snippet)
  end

  -- LSP setup
  require("texlab-tools.lsp-setup").setup(opts)

  -- Inverse search
  __viewer._setup_viewer(opts.viewer)
end

TexLab.setup = setmetatable({ __setup = TexLab.setup }, {
  __call = function(self, ...) self.__setup(...) end,
})

--- Setup the texlab-tools plugin with the exact example config from |TexLab.configuration.example|.
--- If you want to customize it is recommended to copy/paste the example config and change it.
---
---@param opts table | nil See |TexLab.setup()|.
--- ! The behaviour of this function is subject to change.
function TexLab.setup.with_example_config(opts)
  opts = vim.tbl_extend("force", require("texlab-tools.example-config").config, opts or {})
  TexLab.setup(opts)
end


return TexLab
