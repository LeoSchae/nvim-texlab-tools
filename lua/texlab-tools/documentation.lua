local M = {}

---@tag TexLab.configuration
---@text EXAMPLE CONGIFURATION
--- To try this config call
--- >lua
---  TexLab.setup.with_example_config({
---    -- no_example_warning = true,
---    snippet = { app = "snippy" },
---    viewer = { app = "zathura" },
---    builder = { app = "latexmk" },
---  })
--- <
--- in your `init.lua`. This will setup the keybindings from the example config.
--- If you want to try from vimscript, use `lua require("texlab-tools").setup.with_example_config`().
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section, "lua")
--minidoc_replace_start local tex = require("texlab-tools")
local tex = vim.tbl_extend("force", {}, require("texlab-tools"))
tex.setup = function(config)
  M.config = config
end
--minidoc_replace_end

tex.setup({
  -- To use snippets, set either `snippet` or `snippet.expand`.
  -- snippet = "vsnip", -- "snippy", "luasnip", "vsnip", "ultisnips"
  -- snippet = {
  --   expand = function(body) vim.fn["vsnip#anonymous"](body) end,
  --   -- Optional:
  --   cut_text = function()
  --     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-cut-text)',true,false,true),"x",false)
  --   end,
  --   cut_text_placeholder = function() return "${TM_SELECTED_TEXT}" end,
  -- },

  -- viewer = "zathura", -- "zathura", "okular"

  builder = {
    "latexmk",
    on_save = true,
    forward_search_after = false,
  },

  -- For some possible functions see |TexLab.action| and |TexLab.snippet|.
  mappings = tex.Keymap:new({
    { mode = {"n", "i"} },
    -- table with: ["(input keys)"] = (action)
    ["<F5>"] = { tex.action.build(), desc = "[TexLab] Build the current tex file"},
    ["<F6>"] = { tex.action.forward_search(), desc = "[TexLab] Forward search in pdf" },
    ["<A-t>"] = { tex.action.open_toc({ of = "document" }), desc="[TexLab] Show section list" },
    ["<A-a>"] = { tex.action.map_environment_names({
      map = {
        ["equation"] = "align",
        ["equation*"] = "align*",
        ["align*"] = "equation*",
        ["align"] = "equation",
      },
      strategy = "first-match",
    }), desc = "[TexLab] Toggle between align and equation" },
    ["<A-s>"] = { tex.action.toggle_environment_star({
      only = { "equation", "align" },
      strategy = "first-match",
    }), desc = "[TexLab] Add * to closest equation or align" },
  }, {
    { mode = {"i", "n"} }, -- Set mode to apply to all mappings in this table.
    ["<A-e>"] = { tex.snippet.environment("equation*"), desc = "[TexLab] Insert equation* environment" },
    ["<A-b>"] = { tex.snippet.begin_end(), desc = "[TexLab] Insert new environent" },
  },
  {
    { mode = "v" }, -- Only visual mode
    -- For now, these only work with vsnip.
    ["<A-e>"] = { tex.snippet.surround_selection("equation*"), desc = "[TexLab] Surround selection with equation*"},
    ["<A-b>"] = { tex.snippet.surround_selection(), desc = "[TexLab] Surround selection with environment" },
  }):set({ silent = true }),
})
--minidoc_afterlines_end


--- Using only the default mappings and custom ones
--- >lua
---  TexLab.setup({
---    -- ...
---    mappings = TexLab.example_config().mappings:extend({
---         -- Add your own mappings here
---    })
---  })
--- <

return M
