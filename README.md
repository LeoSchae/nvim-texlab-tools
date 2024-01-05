# nvim-texlab-tools

Some tooling around the texlab language server and LaTeX.

## Requirements

* [texlab](https://github.com/latex-lsp/texlab) v5.7.0 or later.
* [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) or a pre-configured texlab language server.
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
* A snippet plugin (e.g. [luasnip](https://github.com/L3MON4D3/LuaSnip) or [snippy](https://github.com/dcampos/nvim-snippy))
* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for table of contents

### Recommended

* Install [nvim-tree-sitter](https://github.com/nvim-treesitter/nvim-treesitter) and set up latex syntax highlighting. !Note: not all themes support latex. [Everforest](https://github.com/sainnhe/everforest) works for me, but many others should as well.

* Use [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) for auto-complete
## Configuration

To use the example keybindings:
```lua
require("texlab-tools").setup.with_example_config({
  snippet = "vsnip",
  viewer = "zathura",
  builder = "latexmk"
})
```
An example config might look like:
```lua
  local tex = require("texlab-tools")

  tex.setup({
    -- To use snippets, set either `snippet` or `snippet.expand`.
    snippet = "vsnip", -- "snippy", "luasnip", "vsnip", "ultisnips"

    -- zathura and okular should have working forward and inverse search out of the box!
    viewer = "zathura", -- "zathura", "okular"

    -- builder = "latexmk",
    builder = {
      "latexmk",
      on_save = true,
      forward_search_after = false,
    },

    -- For some possible functions see |TexLab.action| and |TexLab.snippet|.
    mappings = tex.Keymap:new({
      -- table with: ["(input keys)"] = (action)
      ["<F5>"] = tex.action.build(),
      ["<F6>"] = tex.action.forward_search(),
      ["<A-t>"] = tex.action.open_toc({ of = "workspace" }),
      ["<A-a>"] = tex.action.map_environment_names({
        map = {
          ["equation"] = "align",
          ["equation*"] = "align*",
          ["align*"] = "equation*",
          ["align"] = "equation",
        },
        strategy = "first-match",
      }),
      ["<A-s>"] = tex.action.toggle_environment_star({
        only = { "equation", "align" },
        strategy = "first-match",
      }),
    }, {
      { mode = { "i", "n" } }, -- Set mode to apply to all mappings in this table. Default is {"n"}
      -- ["<opts>"] the 4th parameter to |vim.keymap.set()|, default: {}
      ["<A-e>"] = tex.snippet.equation(),
      ["<A-b>"] = tex.snippet.begin_end(),
    }, {
      { mode = "v" },
      -- For now, the following snippets only work with vsnip
      ["<A-e>"] = tex.snippet.surround_selection("equation"),
      ["<A-b>"] = tex.snippet.surround_selection(), -- Same as passing "$1"
    }),
  })
```

To get more info about the config and features, use:
```
:h TexLab
:h TexLab.configuration
:h TexLab.action
:h TexLab.snippet
:h TexLab.Keymap
```

## Documentation

To generate the documentation you can use `nix` with the command `nix run .#doc`.

## TODO

* Documentation
* Cleaning up the code
* Get other viewers working
