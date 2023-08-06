--- Internal use only.
--- This module contains functions that may change in the future.

local M = {}

--- Get texlab for the given or current buffer
---@param bufnr number | nil
---@return table | nil: The texlab client
function M.get_texlab(bufnr)
  bufnr = bufnr or 0
  for _, client in pairs(vim.lsp.get_active_clients { bufnr = bufnr }) do
    if client.name == "texlab" then
      return client
    end
  end
  return nil
end

local log_error_callback = function(err)
  if err then
    print(err)
  end
end


local BUILD_STATUS = {
  Success = 0,
  Error = 1,
  Failure = 2,
  Cancelled = 3,
}
--- @param callback function | nil: Callback to call with the result
function M.__build(callback)
  callback = callback or function(err)
    if err then
      print(err)
    else
      print("Build successful")
    end
  end

  local params = vim.lsp.util.make_position_params()
  local client = M.get_texlab()

  if not client then
    callback("No texlab client found")
    return
  end

  client.request("textDocument/build", params, function(err, result)
    if err then
      return print("Error building: " .. err)
    end
    if result.status == BUILD_STATUS.Success then
      callback(nil)
    elseif result.status == BUILD_STATUS.Error then
      callback("Build error")
    elseif result.status == BUILD_STATUS.Failure then
      callback("Build failed")
    elseif result.status == BUILD_STATUS.Cancelled then
      callback("Build cancelled")
    else
      callback("Build status unknown (" .. result.status .. ")")
    end
  end)
end

local SEARCH_STATUS = {
  Success = 0,
  Error = 1,
  Failure = 2,
  Unconfigured = 3,
}
--- @param callback function | nil: Callback to call with the result
function M.__forward_search(callback)
  callback = callback or log_error_callback
  local params = vim.lsp.util.make_position_params()
  local client = M.get_texlab()

  if not client then
    callback("No texlab client found")
    return
  end

  client.request("textDocument/forwardSearch", params, function(err, result)
    if err then
      callback("Error building: " .. err)
      return
    end
    if result.status == SEARCH_STATUS.Success then
      callback(nil)
    elseif result.status == SEARCH_STATUS.Error then
      callback("Forward search error")
    elseif result.status == SEARCH_STATUS.Failure then
      callback("Forward search failed")
    elseif result.status == SEARCH_STATUS.Unconfigured then
      callback("Forward search not configured")
    else
      callback("Forward search status unknown (" .. result.status .. ")")
    end
  end)
end

local function __environment_rename(callback, opts)
  callback = callback or log_error_callback
  local params = opts.params
  local client = M.get_texlab()

  if not client then
    callback("No texlab client found")
    return
  end

  client.request("workspace/executeCommand", {
    command = "texlab.changeEnvironment",
    arguments = { params },
  }, function(err, _)
    if err then
      callback("Error renaming environment: " .. vim.inspect(err))
      return
    end
    callback(nil)
  end)
end

local function hydrate_environment(find_params, environment)
  return {
    name = environment.name.text,
    rename = function(newName)
      __environment_rename(nil, {
        params = {
          textDocument = find_params.textDocument,
          position = environment.name.range.start,
          newName = newName,
        }
      })
    end
  }
end

--- @param callback function: Callback to call with the result
function M.__environments(callback)
  local params = vim.lsp.util.make_position_params()
  local client = M.get_texlab(0)
  if not client then
    return callback("No texlab client found")
  end

  client.request("workspace/executeCommand", {
    command = "texlab.findEnvironments",
    arguments = { params },
  }, function(err, envs)
    if err then
      return callback(err)
    end

    local environments = {}

    -- Reverse the returned list and hydrate
    for i = #envs, 1, -1 do
      table.insert(environments, hydrate_environment(params, envs[i]))
    end

    callback(nil, environments)
  end)
end

--[[ Sections ]]
-- TODO this needs some cleanup

function M.__workspace_symbols(callback)
  local client = M.get_texlab(0)
  local params = { query = "" }
  if not client then
    callback("No texlab client found")
    return
  end

  client.request("workspace/symbol", params, callback)
end

function M.__document_symbols(callback)
  local client = M.get_texlab(0)
  local params = vim.lsp.util.make_position_params()
  if not client then
    callback("No texlab client found")
    return
  end

  client.request("textDocument/documentSymbol", params, callback)
end

local SECTION_KINDS = { 2 }
-- is only called for symbols with kind in SECTION_KINDS
local function symbol_to_section(symbol, ctx)
  -- print keys
  if symbol.location then
    return {
      text = symbol.name,
      bufnr = vim.uri_to_bufnr(symbol.location.uri),
      filename = vim.uri_to_fname(symbol.location.uri),
      lnum = symbol.location.range.start.line + 1,
    }
  else
    return {
      text = symbol.name,
      bufnr = vim.uri_to_bufnr(ctx.params.textDocument.uri),
      filename = vim.uri_to_fname(ctx.params.textDocument.uri),
      lnum = symbol.range.start.line + 1,
    }
  end
end

local function insert_all_sections(sections, symbols, ctx)
  for _, symbol in ipairs(symbols) do
    if vim.tbl_contains(SECTION_KINDS, symbol.kind) then
      table.insert(sections, symbol_to_section(symbol, ctx))
    end
    if symbol.children then
      insert_all_sections(sections, symbol.children, ctx)
    end
  end
  return sections
end

function M.__show_sections_callback(err, result, ctx)
  if err then
    print(err)
    return
  end

  local sections = insert_all_sections({}, result, ctx)

  -- open a telescope picker
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local make_entry = require("telescope.make_entry")
  local conf = require("telescope.config").values

 local opts = {
    sorting_strategy = "ascending"
  }

 pickers.new(opts, {
          prompt_title = "Table of Contents",
          finder = finders.new_table {
            results = sections,
            entry_maker = make_entry.gen_from_buffer_lines(opts),
          },
          previewer = conf.grep_previewer(opts),
          sorter = conf.generic_sorter(opts),
        }):find()
end

return M
