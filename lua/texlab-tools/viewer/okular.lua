local M = {}

local Job = require("plenary.job")

local _is_okular_running = false
M.forward = function(opts)
  local target = 'file:' .. opts.pdf .. '#src:' .. opts.line .. '' .. opts.file

  if not _is_okular_running then
    Job:new({
      command = "okular",
      args = {
        "--unique",
        "--editor-cmd",
        opts.inverse_cmd({ file = "%f", line = "%l" }),
        target
      },
      on_exit = function()
        _is_okular_running = false
      end,
    }):start()
    _is_okular_running = true
  else
    Job:new({
      command = "okular",
      args = { "--unique", target },
    }):start()
  end
end

return M
