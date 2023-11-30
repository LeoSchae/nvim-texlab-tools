local M = {}

local Job = require('plenary.job')

-- opts: {line, file, pdf, inverse_cmd({file, line})}
M.forward = function(opts)
  Job:new({
    command = 'zathura',
    args = {
      "--synctex-editor-command",
      opts.inverse_cmd({ file = "%{input}", line = "%{line}" }),
      "--synctex-forward",
      opts.line .. ":1:" .. opts.file,
      opts.pdf,
    },
  }):start()
end

return M
