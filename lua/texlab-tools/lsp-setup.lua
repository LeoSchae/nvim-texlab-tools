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

    if type(builder) == "string" then
        builder = { builder }
    end

    local lsp_opts = {}

    -- If has first element then use it as builder name
    if #builder ~= 0 then
        local _opts = BUILDERS()[builder[1]]
        if not _opts then
            error("Builder not supported: " .. builder[1])
        end

        lsp_opts = _opts
    end

    -- onsave defaults to true
    lsp_opts.onSave = not (builder.onSave == false or builder.on_save == false)
    -- forward search after defaults false
    lsp_opts.forwardSearchAfter = builder.forwardSearchAfter or builder.forward_search_after

    return { settings = { texlab = { build = lsp_opts } } }
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

return M
