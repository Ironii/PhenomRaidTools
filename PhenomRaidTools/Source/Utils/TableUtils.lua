local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local TableUtils = {}
PRT.TableUtils = TableUtils


-------------------------------------------------------------------------------
-- String Utils

function TableUtils.Tableify(x)
  if type(x) == "string" then
    return {x}
  elseif type(x) == "table" then
    return x
  end
end

function TableUtils.Remove(t, pred)
  for i = #t, 1, -1 do
    if pred(t[i], i) then
      table.remove(t, i)
    end
  end

  return t
end

function TableUtils.Count(t)
  if t and type(t) == "table" then
    local count = 0
    for _, _ in pairs(t) do
      count = count + 1
    end
    return count
  end
end

function TableUtils.IsEmpty(t)
  if t then
    if next(t) == nil then
      return true
    end
  else
    return true
  end

  return false
end

function TableUtils.GetBy(t, key, expectedValue)
  if t then
    for idx, v in ipairs(t) do
      if v[key] == expectedValue then
        return idx, v
      end
    end
  end
end

function TableUtils.Clone(orig, copies)
  copies = copies or {}
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    if copies[orig] then
      copy = copies[orig]
    else
      copy = {}
      copies[orig] = copy
      for orig_key, orig_value in next, orig, nil do
        copy[TableUtils.Clone(orig_key, copies)] = TableUtils.Clone(orig_value, copies)
      end
      setmetatable(copy, TableUtils.Clone(getmetatable(orig), copies))
    end
  else
    copy = orig
  end
  return copy
end

function TableUtils.OverwriteValues(t1, t2)
  if t1 and t2 then
    for k, _ in pairs(t1) do
      if t2[k] then
        t1[k] = t2[k]
      end
    end

    for k, _ in pairs(t2) do
      if not t1[k] then
        t1[k] = t2[k]
      end
    end
  end
end

function TableUtils.SortByKey(t, k)
  table.sort(t,
    function(t1, t2)
      local a, b = t1[k], t2[k]
      if a and b then
        if type(a) == "string" or type(b) == "string" then
          return string.lower(t1[k]) < string.lower(t2[k])
        else
          return a < b
        end
      else
        return false
      end
    end)
end

function TableUtils.Distinct(t)
  local existingTarget = {}
  local distinctTargets = {}

  for _, entry in ipairs(t) do
    if (not existingTarget[entry]) then
      table.insert(distinctTargets, entry)
      existingTarget[entry] = true
    end
  end

  return distinctTargets
end
