local TexLab = {}
TexLab.Keymap = {}
TexLab.Keymap.__index = TexLab.Keymap

local function modify_mapping(mapping, ...)
    local opts = vim.tbl_extend("force", mapping[4], ...)
    local mode = mapping[1]
    if opts.mode then
        mode = opts.mode
    end
    opts.mode = nil
    return {mode, mapping[2], mapping[3], opts}
end

--- Create a new keymap.
---@param ... table A list of different keymaps.
--- A keymap takes the following form:
--- >
---   {
---     { mode = <mode>, <def-opts> }, -- This is optional
---     ["<lhs>"] = <rhs>,
---     ["<lhs>"] = {<rhs>, <opts>},
---     -- ...
---   }
--- <
--- where:
--- - <mode>: string | table is a string or list of strings (e.g. "n" or {"n", "v"}). This is the first argument to |vim.keymap.set|.
--- - <def-opts>: table is a table of options that will be used for all mappings. This is the 4-th argument to |vim.keymap.set|.
--- - <lhs>: string is the left-hand side of the mapping. This is the 2-nd argument to |vim.keymap.set|.
--- - <rhs>: function | string is the right-hand side of the mapping. This is the 3-rd argument to |vim.keymap.set|.
--- - <opts>: table is a table of options that will be used for this mapping. Overrides any options including the mode.
---@return table The new keymap.
function TexLab.Keymap:new(...)
    local keymap = setmetatable({}, TexLab.Keymap)
    return keymap:extend(...)
end

--- Extend a keymap.
---@param ... table A list of different keymaps.
--- See `TexLab.Keymap:new` for the format of the keymaps.
---@return table The extended keymap.
function TexLab.Keymap:extend(...)
    for _, mappings in ipairs({...}) do
        local default_options = mappings[1] or {}
        for lhs, mapping in pairs(mappings) do
            if type(lhs) ~= "number" then
                local rhs = mapping
                local opts = {}
                if type(rhs) == "table" then
                    rhs = table.remove(mapping)
                    opts = mapping
                end
                table.insert(self, modify_mapping({"n", lhs, rhs, {}}, default_options, opts))
            end
        end
    end
    return self
end

--- Set options for a keymap.
---@param opts table Overrides mode or options of all mappings in the keymap.
--- The map is modified in-place.
--- Example: `keymap:set({silent = true})`
---@return table The modified keymap
function TexLab.Keymap:set(opts)
    for i, mapping in ipairs(self) do
        self[i] = modify_mapping(mapping, opts)
    end
    return self
end

--- Apply the keymap using |vim.keymap.set|.
---@param opts table Overrides mode or options of all mappings in the keymap.
--- Example: `keymap:apply({buffer = 0})`
function TexLab.Keymap:apply(opts)
    for _, mapping in ipairs(self) do
        if opts then mapping = modify_mapping(mapping, opts) end
        vim.keymap.set(mapping[1], mapping[2], mapping[3], mapping[4])
    end
end

return TexLab.Keymap
