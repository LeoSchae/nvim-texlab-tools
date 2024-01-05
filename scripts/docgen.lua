
local MiniDoc = require('mini.doc')
MiniDoc.setup()

local _afterlines_to_code = MiniDoc.afterlines_to_code
MiniDoc.afterlines_to_code = function(afterlines, lang)
  return _afterlines_to_code(afterlines):gsub('^>\n', '>' .. lang .. '\n')
end

local files = {
  "lua/texlab-tools.lua",
  "lua/texlab-tools/documentation.lua",
  "lua/texlab-tools/keymap.lua",
  "lua/texlab-tools/snippet.lua",
  "lua/texlab-tools/action.lua",
}

MiniDoc.generate(files, "doc/texlab-tools.txt")


