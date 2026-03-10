-- @description Find and Replace Item Names
-- @author ewan
-- @version 1.0
-- @about
--   Find and Replace Item Names


reaper.Undo_BeginBlock()

local retval, inputs_csv = reaper.GetUserInputs("ewan: Find and Replace Item Names", 2, "Case Sensitive :)","Warrior,Str4b")

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

for i = 0, reaper.CountSelectedMediaItems()-1 do
  
  -- Get item and take
  item = reaper.GetSelectedMediaItem(0, i)

  active_take = reaper.GetActiveTake(item)
  take_name = reaper.GetTakeName(active_take)

if replace == nil then
replace = ""
  end
  
  newID = string.gsub(take_name, find, replace)
  newID = string.gsub(take_name, find, replace)
  
  -- Apply new name
  reaper.GetSetMediaItemTakeInfo_String(active_take, 'P_NAME', newID, true)
end

reaper.Undo_EndBlock("Find and Replace Item Names", 0)
end
