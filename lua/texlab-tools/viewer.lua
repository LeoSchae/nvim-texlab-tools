local Job = require('plenary.job')

local M = {}

local function __inverse_cmd(opts)
  return "nvim --server " ..
      vim.v.servername ..
      " --remote-send \"<cmd>lua require('texlab-tools').__inverse_search({file=[[" ..
      opts.file .. "]],line=" .. opts.line .. "})<cr>\""
end

-- okular is a bot more complicated
-- the --unique flag will not work if okular is already running
-- and the --editor-cmd is set.
-- So first set --editor-cmd on the first launch and then
-- use --unique.
local __okular_is_running = false
local function okular_forward(opts)
  local target = 'file:' .. opts.pdf .. '#src:' .. opts.line .. ' ' .. opts.file
  if not __okular_is_running then
    Job:new({
      command = 'okular',
      args = {
        "--unique",
        "--editor-cmd",
        __inverse_cmd({ file = "%f", line = "%l" }),
        target
      },
      on_exit = function()
        __okular_is_running = false
      end,
    }):start()
    __okular_is_running = true
  else
    Job:new({
      command = 'okular',
      args = {
        "--unique",
        target
      },
    }):start()
  end
end

local function zathura_forward(opts)
  Job:new({
    command = 'zathura',
    args = {
      "--synctex-editor-command",
      __inverse_cmd({ file = "%{input}", line = "%{line}" }),
      "--synctex-forward",
      opts.line .. ":1:" .. opts.file,
      opts.pdf
    },
  }):start()
end

local current_forward = nil

function M._setup_viewer(viewer)
  if not viewer then
    return
  end

  if viewer.app == "okular" then
    current_forward = okular_forward
  elseif viewer.app == "zathura" then
    current_forward = zathura_forward
  else
    print("Unknown viewer: " .. viewer.app)
  end
end

-- { line, file, pdf }
function M.__forward(opts)
  if not current_forward then
    print("No viewer set")
    return
  end
  current_forward(opts)
end

-- { line, file }
function M.__inverse(opts)
  vim.cmd("e " .. opts.file)
  vim.cmd("" .. opts.line)
end

return M
