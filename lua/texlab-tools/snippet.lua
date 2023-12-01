

---@tag TexLab.snippet
---@text SNIPPETS
---
--- Snippets are small pieces of code that can be inserted into the document.
--- To use snippets the `snippet` option must be set in |TexLab.setup()|.
---
---@example An example with snippet engine `snippy` and mapping `<A-e>` to the snippet `equation` is:
--- >lua
---  local tex = require("texlab-tools")
---  tex.setup({
---    snippet = { engine = "snippy" },
---    -- ...,
---    mappings = tex.mappings {
---      ["<mode>"] = { "n", "i" },
---      ["<A-e>"] = tex.snippet.equation(),
---      -- ...
---    },
---  })
--- <
---
--- Any function in this module can be used as in the above example.
--- However, some may require additional arguments. For example:
--- >lua
--- tex.snippet.environment("test", "Test: $0")
--- <
--- creates a snippet that expands to:
--- >tex
--- \begin{test}
---     Test: |
--- \end{test}
--- <

local TexLab = {}
TexLab.snippet = {}

local snippet_engine = {}

function TexLab.snippet._setup(config)
  snippet_engine = {}
  if not config or not config.snippet then
    return
  end

  config = config.snippet

  if type(config) == "string" then
    config = {config}
  elseif type(config) ~= "table" then
    error("Invalid snippet config.")
    return
  end

  if #config ~= 0 then
    local engine = config[1]

    if engine == "snippy" then
      snippet_engine = {
        expand = require("snippy").expand_snippet,
      }
    elseif engine == "luasnip" then
      snippet_engine = {
        expand = require("luasnip").lsp_expand,
      }
    elseif engine == "vsnip" then
      local _cut_keys = vim.api.nvim_replace_termcodes('<Plug>(vsnip-cut-text)',true,false,true)
      snippet_engine = {
        expand = function(body) vim.fn["vsnip#anonymous"](body) end,
        cut_text = function()
          vim.api.nvim_feedkeys(_cut_keys, "x", false)
        end,
        cut_text_placeholder = function()
          return "${TM_SELECTED_TEXT}"
        end,
      }
    elseif engine == "ultisnips" then
      snippet_engine = {
        expand = function(body) vim.fn["UltiSnips#Anon"](body) end,
      }
    else
      error("Unknown snippet engine: " .. engine)
    end
  end

  if config.expand then
    snippet_engine.expand = config.expand
  end
  if config.cut_text then
    snippet_engine.cut_text = config.cut_text
  end
  if config.cut_text_placeholder then
    snippet_engine.cut_text_placeholder = config.cut_text_placeholder
  end
end

--- Create a new snippet.
---@param body string The body of the snippet in lsp snippet format.
---@example `TexLab.snippet.new_snippet("\\label{eq:$1}")` is a snippet for:
--- >tex
---  \label{eq:|}
--- <
function TexLab.snippet.new_snippet(body)
  return function()
    if not snippet_engine.expand then
      error("Snippet engine not set.")
      return
    end
    snippet_engine.expand(body)
  end
end

--- Snippet that inserts an environment.
---@param name string The name of the environment.
---@param body string | nil The body of the environment. Defaults to "\t$0".
---@example >
--- \begin{<name>}
---     <body>
--- \end{<name>}
--- <
function TexLab.snippet.environment(name, body)
  body = body or "\t$0"
  return TexLab.snippet.new_snippet("\\begin{" .. name .. "}\n" .. body .. "\n\\end{" .. name .. "}")
end

--- Snippet that inserts an environment. This snippet has a placeholder for the environment name.
--- @param body string | nil The body of the environment. See |TexLab.snippet.environment()|.
function TexLab.snippet.begin_end(body)
  return TexLab.snippet.environment("$1", body)
end

--- Snippet that inserts an `equation` environment.
--- @param body string | nil The body of the environment. See |TexLab.snippet.environment()|.
function TexLab.snippet.equation(body)
  return TexLab.snippet.environment("equation", body)
end

--- Snippet inserts an `enumerate` environment.
--- @param body string | nil The body of the environment. Defaults to "\t\\item $0" See |TexLab.snippet.environment()|.
function TexLab.snippet.enumerate(body)
  body = body or "\t\\item $0"
  return TexLab.snippet.environment("enumerate", body)
end

--- Snippet inserts an `itemize` environment.
--- @param body string | nil The body of the environment. Defaults to "\t\\item $0"
function TexLab.snippet.itemize(body)
  body = body or "\t\\item $0"
  return TexLab.snippet.environment("itemize", body)
end

--- Snippet that surrounds the current selection with an environment.
--- @param name string | nil The name of the environment. (Defaults to "$1").
function TexLab.snippet.surround_selection(name)
  return function()
    if not snippet_engine.cut_text or not snippet_engine.cut_text_placeholder then
      error("Snippet engine is not configured for cut text.")
    end
    snippet_engine.cut_text()
    TexLab.snippet.environment(name or "$1", "\t" .. snippet_engine.cut_text_placeholder() .. "$0")()
  end
end


return TexLab.snippet
