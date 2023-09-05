local M = {}

---@tag TexLab.configuration
---@text EXAMPLE CONGIFURATION
--- To try this config call
--- >lua
---  TexLab.setup.with_example_config({
---    snippet = { app = "snippy" },
---    viewer = { app = "zathura" },
---    builder = { app = "latexmk" },
---  })
--- <
--- in your `init.lua`. This will setup the keybindings from the example config.
--- If you want to try from vimscript, use `lua require("texlab-tools").setup.with_example_config`().
---@eval return MiniDoc.code_lang(MiniDoc.afterlines_to_code(MiniDoc.current.eval_section), "lua")
--minidoc_replace_start local tex = require("texlab-tools")
local tex = vim.tbl_extend("force", {}, require("texlab-tools"))
tex.setup = function(config)
  M.config = config
end
--minidoc_replace_end

tex.setup({
  -- To use snippets, set either `snippet.engine` or `snippet.expand`.
  -- snippet = { app = "snippy" }, -- "snippy", "luasnip", "vsnip", "ultisnips"
  -- snippet = { expand = function(body) [expand-fn](body) end },

  -- viewer = { app = "zathura" }, -- "zathura", "okular"

  builder = {
    app = "latexmk",
    on_save = true,
    forward_search_after = false,
  },
  -- Or set the builder manually, with
  -- builder = { executeable = ... , args = {...} }

  -- For some possible functions see |TexLab.action| and |TexLab.snippet|.
  mappings = tex.mappings({
    ["<mode>"] = {"n", "i"},
    -- table with: ["(input keys)"] = (action)
    ["<F5>"] = tex.action.build(),
    ["<F6>"] = tex.action.forward_search(),
    ["<A-t>"] = tex.action.open_toc({ of = "document" }),
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
    ["<mode>"] = { "i" }, -- Set mode to apply to all mappings in this table.
    -- ["<opts>"] the 4th parameter to |vim.keymap.set()|, default: {}
    ["<A-e>"] = tex.snippet.equation(),
    ["<A-b>"] = tex.snippet.begin_end(),
  }),
})
--minidoc_afterlines_end

return M
