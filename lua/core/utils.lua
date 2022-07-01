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

return utils
