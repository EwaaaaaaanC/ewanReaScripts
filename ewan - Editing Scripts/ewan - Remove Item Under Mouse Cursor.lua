-- @description Remove Item Under mouse Cursor
-- @author ewan
-- @version 0.7
-- @about
--   Remove Item Under mouse Cursor

-- Behaves nicer than the built in command, as it ignores selection.
mouseX, mouseY = reaper.GetMousePosition()
local editItem = reaper.GetItemFromPoint(mouseX,mouseY,false)
if editItem == nil then
--reaper.MB("ERROR","NO ITEM HERE",0)
return
else
local editItemTrack = reaper.GetMediaItemTrack(editItem)

reaper.DeleteTrackMediaItem(editItemTrack,editItem)

reaper.UpdateArrange()

reaper.Undo_EndBlock("Delete Item Under Mouse", -1)
end
