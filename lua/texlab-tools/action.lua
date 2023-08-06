local TexLab = {}

--- There are different actions that can be performed.
--- An example, that maps `<F5>` to build and `<F6>` to forward search is:
--- >lua
---  local tex = require("texlab-tools")
---  tex.setup({
---    mappings = tex.mappings({
---      ["<F5>"] = tex.action.build(),
---      ["<F6>"] = tex.action.forward_search(),
---    }),
---  })
--- <
--- To make the mapping available in insert mode set `["<mode>"] = { "n", "i" }` table.
TexLab.action = {}

local tex_lsp = require("texlab-tools.lsp")

--- Starts a build.
function TexLab.action.build()
  return function() tex_lsp.__build() end
end

--- Performs a forward search. (This has to be configured in the texlab server)
function TexLab.action.forward_search()
  return function() tex_lsp.__forward_search() end
end

--- Opens the table of contents in a telescope picker.
---@param opts table Keys:
--- - `from`: "document" or "workspace" (default: "document")
---   Controls whether to show the symbols from the current document or from the entire workspace.
function TexLab.action.open_toc(opts)
  opts = opts or {}

  local _requester = tex_lsp.__document_symbols
  if opts.of == "workspace" then
    _requester = tex_lsp.__workspace_symbols
  elseif opts.of ~= "document" then
    print("Unknown option for 'of': " .. opts.from)
  end

  return function()
    _requester(tex_lsp.__show_sections_callback)
  end
end

--- Modify environment names around the cursor.
---@param opts table Keys:
--- - `map`: (function(name):name)|table Function that maps the old name to the new name. (required)
--- - `filter`: (function(name):boolean)|nil Function to filter the environments. (default: nil)
--- - `strategy`: "first"|"first-match" (default: "first")
function TexLab.action.map_environment_names(opts)
  opts = opts or {}
  local map = opts.map
  local filter = function(_) return true end
  if opts.filter then
    filter = opts.filter
  end

  if type(map) ~= "function" then
    local table_map = map
    map = function(name) return table_map[name] end
    filter = function(name) return table_map[name] ~= nil end
  end

  return function()
    tex_lsp.__environments(function(err, envs)
      if err then
        return print("Request failed: " .. err)
      end

      for _, env in ipairs(envs) do
        if filter(env.name) then
          env.rename(map(env.name))
        end
      end
    end)
  end
end

local function _strip_star(str)
  if str:sub(-1) == "*" then
    return str:sub(1, -2)
  end
  return str
end

local function _toggle_star(name)
  if name:sub(-1) == "*" then
    return name:sub(1, -2)
  end
  return name .. "*"
end

--- Modify the star on an environment.
---@param opts table|nil Keys:
--- - 'only': table|nil List of environments to modify. (default: nil)
--- - 'except': table|nil List of environments to not modify. (default: nil)
--- - 'strategy': "first"|"first-match" (default: "first")
--- Only set one of `only` or `except`.
function TexLab.action.toggle_environment_star(opts)
  opts = opts or {}
  local filter = function(_) return true end
  if opts.only then
    local only = opts.only
    filter = function(name) return vim.tbl_contains(only, _strip_star(name)) end
  elseif opts.except then
    local except = opts.except
    filter = function(name) return not vim.tbl_contains(except, _strip_star(name)) end
  end

  return TexLab.action.map_environment_names({
    filter = filter,
    map = _toggle_star,
    strategy = opts.strategy,
  })
end

return TexLab.action
