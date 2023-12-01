local M = {}

M.config = function(config)
  local Job = require("plenary.job")
  local is_okular_running = false

  return {
    forward = function(opts)
      local target = 'file:' .. opts.pdf .. '#src:' .. opts.line .. '' .. opts.file

      if not is_okular_running then
        Job:new({
          command = "okular",
          args = {
            "--unique",
            "--editor-cmd",
            opts.inverse_cmd({ file = "%f", line = "%l" }),
            target
          },
          on_exit = function()
            is_okular_running = false
          end,
        }):start()
        is_okular_running = true
      else
        Job:new({
          command = "okular",
          args = { "--unique", target },
        }):start()
      end
    end
  }
end

return M
