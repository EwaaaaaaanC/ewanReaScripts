-- @description Rename Items From Clipboard with Find and Replace
-- @author ewan
-- @version 1.0
-- @about
--   Rename Items From Clipboard with Find and Replace

Remove Extensions from Item Name

clipboard = reaper.CF_GetClipboard('')

local retval, inputs_csv = reaper.GetUserInputs("ewan: Rename Items from Clipboard", 2, "Find and Replace Clipboard Text :)","Str4b,StrInt4b")

if retval then
    local inputs = {}
    for value in inputs_csv:gmatch("([^,]+)") do
        table.insert(inputs, value)
    end

    find = inputs[1]
    replace = inputs[2]

--find = "Str4b"
--replace = "StrInt4b"
-- use above to hard-code your find and replace, delete everything before find.

if replace == nil then
replace = ""
end

newID = string.gsub(clipboard, find, replace)

for i = 0, reaper.CountSelectedMediaItems()-1 do
  
  -- Get item and take
  item = reaper.GetSelectedMediaItem(0, i)

  active_take = reaper.GetActiveTake(item)
  
  
  -- Apply new name
  reaper.GetSetMediaItemTakeInfo_String(active_take, 'P_NAME', newID, true)
end
end
