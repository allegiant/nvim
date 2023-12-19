local utils = {}
utils.merge_table = function (origin_tbl, ...)
  local tabs = {...}
    if not tabs then
        return utils.clone(origin_tbl)
    end
  local new_table = utils.clone(origin_tbl)
  for _, table in pairs(tabs) do
    for key, value in pairs(table) do
      new_table[key] = value
    end
  end
    return new_table
end

-- Lua table deep copy
utils.clone = function(obj)
    if type(obj) ~= "table" then
        return obj
    end
    local newtable = {}

    for key,value in pairs(obj) do
        newtable[key] = utils.clone(value)
    end
    setmetatable(newtable,getmetatable(obj))
    return newtable
end

utils.print_table = function(table)
  for key, value in pairs(table) do
    print(key, '=', value)
  end
end


utils.table_to_string = function(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..utils.table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

local fast_event_aware_notify = function(msg, level, opts)
  if vim.in_fast_event() then
    vim.schedule(function()
      vim.notify(msg, level, opts)
    end)
  else
    vim.notify(msg, level, opts)
  end
end

function utils.info(msg)
  fast_event_aware_notify(msg, vim.log.levels.INFO, {})
end

function utils.warn(msg)
  fast_event_aware_notify(msg, vim.log.levels.WARN, {})
end

function utils.err(msg)
  fast_event_aware_notify(msg, vim.log.levels.ERROR, {})
end

function utils.is_root()
  return (vim.loop.getuid() == 0)
end

function utils.is_darwin()
  return vim.loop.os_uname().sysname == "Darwin"
end

function utils.is_NetBSD()
  return vim.loop.os_uname().sysname == "NetBSD"
end

function utils.is_win()
  return vim.loop.os_uname().sysname == "Windows_NT"
end

return utils
