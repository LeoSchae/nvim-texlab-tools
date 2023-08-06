local M = {}

local function VIEWERS()
  local servername = vim.v.servername
  return {
    zathura = {
      executable = "zathura",
      args = {
        "--synctex-editor-command",
        [[nvim --server ]] ..
        servername .. [[ --remote-send "<Cmd>:e %%{input}<CR><Cmd>call cursor(%%{line}, 0)<CR>"]],
        "--synctex-forward",
        "%l:1:%f",
        "%p"
      },
    },
    okular = {
      executable = "okular",
      args = {
        --"--editor-cmd", [[nvim --server ]] .. servername .. [[ --remote-send "<Cmd>:e %%f<CR><Cmd>call cursor(%%l, 0)<CR>"]],
        "--unique",
        "file:%p#src:%l%f"
      },
    },
  }
end

local function viewer_opts(viewer)
  local opts = viewer
  if viewer.app then
    local _opts = VIEWERS()[viewer.app]
    if not opts then
      error("Viewer not supported: " .. viewer)
    end

    opts = vim.tbl_extend("force", _opts, viewer)
    opts.app = nil
  end
  return { settings = { texlab = { forwardSearch = opts } } }
end

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
  local viewer = opts.viewer
  local builder = opts.builder
  local texlab_opts = opts.texlab_lsp

  if texlab_opts and texlab_opts.disable == true then
    return
  end

  local server_opts = texlab_opts or {}

  if viewer then
    server_opts = vim.tbl_deep_extend("error", server_opts, viewer_opts(viewer))
  end
  if builder then
    server_opts = vim.tbl_deep_extend("error", server_opts, build_opts(builder))
  end

  require("lspconfig").texlab.setup(server_opts)
end

return M
