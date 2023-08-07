local M = {}

local function BUILDERS()
  return {
    latexmk = {
      executeable = "latexmk",
      args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
    }
  }
end

local function build_opts(builder)
  local opts = builder
  if builder.app then
    local _opts = BUILDERS()[builder.app]
    if not opts then
      error("Builder not supported: " .. builder)
    end

    opts = vim.tbl_extend("force", _opts, builder)
    opts.app = nil
  end
  -- onsave defaults to true
  opts.onSave = not (opts.onSave == false or opts.on_save == false)
  -- forward search after defaults false
  opts.forwardSearchAfter = opts.forwardSearchAfter or opts.forward_search_after
  return { settings = { texlab = { build = opts } } }
end

function M.setup(opts)
  local builder = opts.builder
  local texlab_opts = opts.texlab_lsp

  if texlab_opts and texlab_opts.disable == true then
    return
  end

  local server_opts = texlab_opts or {}
  server_opts = vim.tbl_deep_extend("force", {
    settings = {
      texlab = {
        -- Handle forward search from lua when the server wants to
        forwardSearch = {
          executable = "nvim",
          args = { "--server", vim.v.servername, "--remote.send",
            "<cmd>lua require(\"texlab-tools\").__forward_search({line=[[%l]],file=[[%f]],pdf=[[%p]]})<cr>" }
        }
      }
    }
  }, server_opts)

  if builder then
    server_opts = vim.tbl_deep_extend("error", server_opts, build_opts(builder))
  end

  require("lspconfig").texlab.setup(server_opts)
end

function M.__do_fwd_search(line, file, pdf)
  print(vim.inspect({
    line = line,
    file = file,
    pdf = pdf,
  }))
end

return M
