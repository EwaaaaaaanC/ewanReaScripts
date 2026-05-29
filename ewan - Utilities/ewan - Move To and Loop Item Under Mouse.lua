-- @description Move To and Loop Item under Mouse (respects record state)
-- @author ewan
-- @version 0.9
-- @changelog
--    fixed issue where item became unselected when in record mode.

-- @about
--    Move To and Loop Item under Mouse. Respects the recording state of the project.
--    Allows quick maneuvering through projects for recording and auditioning.

-- Find the item under the mouse
mouseX, mouseY = reaper.GetMousePosition()
local editItem = reaper.GetItemFromPoint(mouseX,mouseY,false)
if editItem == nil then
--reaper.MB("ERROR","NO ITEM HERE",0)
return
else
local editItemTrack = reaper.GetMediaItemTrack(editItem)

-- get Play State of the project.
playState = reaper.GetPlayState()

-- select ONLY the intended item.
reaper.SelectAllMediaItems(0,false)
reaper.SetMediaItemSelected(editItem,true)
-- get the time info of the item.
pos = reaper.GetMediaItemInfo_Value(editItem,"D_POSITION")
len = reaper.GetMediaItemInfo_Value(editItem,"D_LENGTH") 
endPos = pos+len

--ensure looping transport mode is on and set loop time to match item.
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SETREPEAT"), -1) 
reaper.GetSet_LoopTimeRange(true,true,pos,endPos,true)

-- move playhead to item, and record if already in recording mode.
if playState == 1 or playState == 0 then
reaper.SetEditCurPos( pos, false, true )
end
if playState == 5 then
reaper.Main_OnCommand(1013,-1)
reaper.SetEditCurPos( pos, false, true )
reaper.Main_OnCommand(1013,-1)
end
reaper.SetMediaItemSelected(editItem,true)
reaper.UpdateArrange()

reaper.Undo_EndBlock("Move To and Loop Item under Mouse", -1)
end       