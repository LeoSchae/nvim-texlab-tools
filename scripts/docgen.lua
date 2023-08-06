
local MiniDoc = require('mini.doc')
MiniDoc.setup()

MiniDoc.code_lang = function(code, lang)
  return code:gsub('^>\n', '>' .. lang .. '\n')
end

local files = {
  "lua/texlab-tools.lua",
  "lua/texlab-tools/example-config.lua",
  "lua/texlab-tools/mappings.lua",
  "lua/texlab-tools/snippet.lua",
  "lua/texlab-tools/action.lua",
}

MiniDoc.generate(files, "doc/texlab-tools.txt")


