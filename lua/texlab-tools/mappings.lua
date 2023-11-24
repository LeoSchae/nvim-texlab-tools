local TexLab = {}

--- Create keymaps
---@param ... table Keys:
--- - ["<mode>"]: the mode in which the mapping works. (default: {"n"})
--- - ["<opts>"]: the options for the mapping. (default: {})
--- - [lhr]=rhs: the mappings. All mappings of a table use the same <mode> and <opts>.
---@return table That contains the mappings. Use `TexLab.mappings.__apply` to apply the mappings.
function TexLab.mappings(...)
  return TexLab.mappings.extend({}, ...)
end

TexLab.mappings = setmetatable({ __mappings = TexLab.mappings }, {
  __call = function(self, ...)
    return self.__mappings(...)
  end
})

--- Entend a list of keymaps
--- @param keymap table The already existing keymap
--- @param ... table See `TexLab.mappings`
function TexLab.mappings.extend(keymap, ...)
  local args = {...}
  for _, mappings in ipairs(args) do
    local mode = mappings["<mode>"] or { "n" }
    local opts = mappings["<opts>"] or {}

    for key, mapping in pairs(mappings) do
      if key ~= "<mode>" and key ~= "<opts>" then
        table.insert(keymap, {mode, key, mapping, opts})
      end
    end
  end

  return keymap
end

function TexLab.mappings.__apply(keymap_args, opts_override)
  opts_override = opts_override or {}
  for _, mapping in ipairs(keymap_args) do
    vim.keymap.set(mapping[1], mapping[2], mapping[3], vim.tbl_extend("force", mapping[4], opts_override))
  end
end




return TexLab.mappings
