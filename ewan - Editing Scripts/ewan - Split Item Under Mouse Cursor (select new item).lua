-- @description Split item Under Mouse Cursor
-- @author ewan
-- @version 0.7
-- @about
--   Split item Under Mouse Cursor

-- Splits the Item Under the Mouse. 
-- The old item is deselected.
-- Set the below variable to true to deselect ALL items except the new cut.
-- False makes it so item selections not involved in the edit remain selected.

onlyNewSelected = true

mouseX, mouseY = reaper.GetMousePosition()
local autoxFade = true
local xfadeLength = 50 -- crossfade time in milliseconds
local context = ""
local editItem = reaper.GetItemFromPoint(mouseX,mouseY,false)
local mouseTime = reaper.BR_PositionAtMouseCursor(true)

if editItem == nil then
--reaper.MB("ERROR","NO ITEM HERE",0)
return
else

reaper.Undo_BeginBlock()
local editItemTrack = reaper.GetMediaItemTrack(editItem)

followingItem = reaper.SplitMediaItem(editItem,mouseTime)

if onlyNewSelected then
reaper.Main_OnCommand(40289,-1)
else
reaper.SetMediaItemSelected(editItem,false)
end

reaper.SetMediaItemSelected(followingItem,true)

-- Add Fades
 local editPos = reaper.GetMediaItemInfo_Value(editItem, "D_POSITION")
 local editLen = reaper.GetMediaItemInfo_Value(editItem, "D_LENGTH")
 local editEnd = editPos + editLen
 
 local followingPos = reaper.GetMediaItemInfo_Value(followingItem, "D_POSITION")
 local followingLen = reaper.GetMediaItemInfo_Value(followingItem, "D_LENGTH")
 local followingEnd = followingPos + followingLen
 local followingTake = reaper.GetActiveTake(followingItem,0)
 local followingOffset = reaper.GetMediaItemTakeInfo_Value(followingTake, "D_STARTOFFS")
 
 reaper.SetMediaItemInfo_Value(editItem,"D_FADEOUTLEN_AUTO",xfadeLength*0.001)
 reaper.SetMediaItemInfo_Value(editItem,"D_LENGTH",editLen + (xfadeLength*0.0005))
 reaper.SetMediaItemInfo_Value(followingItem,"D_LENGTH",followingLen + (xfadeLength*0.0005))
 reaper.SetMediaItemInfo_Value(followingItem,"D_FADEINLEN_AUTO",xfadeLength*0.001)
 reaper.SetMediaItemInfo_Value(followingItem,"D_POSITION",followingPos - (xfadeLength*0.0005))
 reaper.SetMediaItemTakeInfo_Value(followingTake,"D_STARTOFFS",followingOffset - (xfadeLength*0.0005))

reaper.UpdateArrange()

if autoxFade == true then
context = " & Auto xfade "..xfadeLength.."ms"
else
context = ""
end

end

reaper.Undo_EndBlock("Split Item Under Mouse"..context, -1)
