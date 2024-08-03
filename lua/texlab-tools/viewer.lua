local M = {}

function M.setup(config)

    local viewer = {
        __forward = function()
            print("Forward search not configured")
        end,
        __inverse = function(options)
            vim.cmd("normal! m'")
            vim.cmd("keepjumps drop " .. options.file)
            vim.cmd("" .. options.line)
            vim.cmd("normal! zz")
        end,
    }

    if not config or not config.viewer then
        return viewer
    end

    config = config.viewer
    if type(config) == "string" then
        config = { config }
    elseif type(config) ~= "table" then
        print("Invalid viewer config")
        return viewer
    end

    -- set config defaults if editor is set by name
    if #config ~= 0 then
        config = require("texlab-tools.viewer." .. config[1]).config(config)
    end

    -- setup forward (and inverse) search
    if config.forward then
        local forward = config.forward
        local inverse_command = function(options)
            return "nvim --server " .. vim.v.servername .. " --remote-send \"<cmd>lua require('texlab-tools').__inverse_search({file=[[" .. options.file .. "]],line=" .. options.line .. "})<cr>\""
        end
        viewer.__forward = function(options)
            forward({
                line = options.line,
                file = options.file,
                pdf = options.pdf,
                inverse_cmd = inverse_command
            })
        end
    end

    return viewer
end

return M
