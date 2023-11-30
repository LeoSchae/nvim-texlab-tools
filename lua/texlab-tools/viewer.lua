local Job = require('plenary.job')

local M = {}

-- Returns a command that the viewer can execute to jump to the correct file
-- opts = { file, line } where:
--   file = the placeholeder for the filename (e.g. "%f" for okular or "%{input}" for zathura)
--   line = the placeholder for the line number (e.g. "%l" for okular or "%{line}" for zathura)
local function __inverse_cmd(opts)
  return "nvim --server " ..
      vim.v.servername ..
      " --remote-send \"<cmd>lua require('texlab-tools').__inverse_search({file=[[" ..
      opts.file .. "]],line=" .. opts.line .. "})<cr>\""
end

-- Has the form
-- { forward } where:
--   forward = function(opts) where opts = { line, file, pdf, inverse_cmd({line, file}) }
local _viewer = nil

function M._set_viewer(viewer)
  if viewer == "okular" then
    _viewer = require("texlab-tools.viewer.okular")
  elseif viewer == "zathura" then
    _viewer = require("texlab-tools.viewer.zathura")
  else
    print("Unknown viewer: " .. viewer)
  end
end

function M._setup_from_config(main_config)
  if not main_config or not main_config.viewer then
    return
  end

  local config = main_config.viewer

  if type(config) == "string" then
    M._set_viewer(config)
  elseif type(config) == "table" then
    if #config ~= 0 then
      M.set_viewer(config[1])
    end
  end
end

-- { line, file, pdf }
function M.__forward(opts)
  if not _viewer then
    print("No viewer set")
    return
  end
  _viewer.forward({
    line = opts.line,
    file = opts.file,
    pdf = opts.pdf,
    inverse_cmd = __inverse_cmd
  })
end

-- { line, file } called from __inverse_cmd
function M.__inverse(opts)
  vim.cmd("e " .. opts.file)
  vim.cmd("" .. opts.line)
end

return M
