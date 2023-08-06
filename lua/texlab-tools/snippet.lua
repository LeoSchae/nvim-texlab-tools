

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

local snippet_expand

function TexLab.snippet.__apply_setup(snippet)
  if snippet.expand then
    snippet_expand = snippet.expand
  elseif snippet.app then
    if snippet.app == "snippy" then
      snippet_expand = require("snippy").expand_snippet
    elseif snippet.app == "luasnip" then
      snippet_expand = require("luasnip").lsp_expand
    elseif snippet.app == "vsnip" then
      snippet_expand = function(body) vim.fn["vsnip#anonymous"](body) end
    elseif snippet.app == "ultisnips" then
      snippet_expand = function(body) vim.fn["UltiSnips#Anon"](body) end
    else
      error("Unknown snippet application: " .. snippet.app)
    end
  end
end

function TexLab.snippet._set_snippet_expand(expand)
  print("SNIPPET ENGINE SET")
  snippet_expand = expand
end

--- Create a new snippet.
---@param body string The body of the snippet in lsp snippet format.
---@example `TexLab.snippet.new_snippet("\\label{eq:$1}")` is a snippet for:
--- >tex
---  \label{eq:|}
--- <
function TexLab.snippet.new_snippet(body)
  return function()
    if snippet_expand == nil then
      error("Snippet engine not set.")
      return
    end
    snippet_expand(body)
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
function TexLab.snippet.begin_end()
  return TexLab.snippet.environment("$1")
end

--- Snippet that inserts an `equation` environment.
function TexLab.snippet.equation()
  return TexLab.snippet.environment("equation")
end

--- Snippet inserts an `enumerate` environment.
function TexLab.snippet.enumerate()
  return TexLab.snippet.environment("enumerate", "\t\\item $0")
end

--- Snippet inserts an `itemize` environment.
function TexLab.snippet.itemize()
  return TexLab.snippet.environment("itemize", "\t\\item $0")
end

return TexLab.snippet
