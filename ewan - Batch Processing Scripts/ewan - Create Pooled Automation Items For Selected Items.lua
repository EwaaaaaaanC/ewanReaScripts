-- @description Create Pooled Automation Items For Selected Items
-- @author ewan
-- @version 1.0
-- @about
--   Run this script to create pooled automation items for all of your selected media items.


-- HOW TO USE: Select items and then select an envelope lane.
-- The duplicated automation items are scaled in length to conform to the first item.
-- In this way both fade-ins and fade-out will align with item starts and ends.
-- To disable this stretching/squashing behaviour, delete lines 74 and 75


numberOfSelectedItems = reaper.CountSelectedMediaItems(activeProjectIndex)
if numberOfSelectedItems == 0 then
reaper.ShowMessageBox("NO ITEMS SELECTED. \n Better luck next time! :)", "womp womp", 1)
else

SourceTrack = reaper.GetMediaItem_Track(reaper.GetSelectedMediaItem(activeProjectIndex, 0))
reaper.SetTrackSelected(SourceTrack,1)
local retval, env = reaper.GetSelectedTrackEnvelope(0)
env = reaper.GetSelectedTrackEnvelope(0)
  
if retval then -- only start the script if a track envelope is selected.
  
  retval, automationItemName = reaper.GetUserInputs("Name The Automation Item",1,"Blank for default numbering :)","")
  
reaper.Undo_BeginBlock()

-- begin Function
for i = 0, 0 do  -- this block creates the first automation item and stores its length.

  local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
  local selectedItemPosition = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")
  local selectedItemLength = reaper.GetMediaItemInfo_Value(selectedItem, "D_LENGTH")
  local selectedItemTake = reaper.GetTake(selectedItem, 0)
  local selectedItemTakeStartOffset = reaper.GetMediaItemTakeInfo_Value(selectedItemTake, "D_STARTOFFS")
  reaper.GetSet_LoopTimeRange(1,0,selectedItemPosition,selectedItemPosition+selectedItemLength,0); -- Sets Time Selection to Item

  reaper.Main_OnCommand(42082,0) -- Create Automation Item
  
  local AutomationItemCount = reaper.CountAutomationItems(env)
  
    for i = 0, AutomationItemCount-1 do -- for the new automation item, get the length
  
       local IsSelected = reaper.GetSetAutomationItemInfo(env, i, 'D_UISEL', 0, 0) -- checks for the selected automation item
  
        if IsSelected == 1 then
        initialItemLength =  reaper.GetSetAutomationItemInfo(env, i,"D_LENGTH",0,0)
        end
  
     end
end 


for i = 1, numberOfSelectedItems-1 do   -- This block creats the duplicate pooled automation items and positions them to match media items.

selectedItemTrack = reaper.GetMediaItem_Track(reaper.GetSelectedMediaItem(activeProjectIndex, i))

if selectedItemTrack == SourceTrack then

  -- find the specs of the media item
  local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
  local selectedItemPosition = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")
  local selectedItemLength = reaper.GetMediaItemInfo_Value(selectedItem, "D_LENGTH")
  
  
  reaper.Main_OnCommand(42085,0) -- Duplicate and Pool Automation Item
  
  automationItemCount = reaper.CountAutomationItems(env)
    
  for i = 0, automationItemCount-1 do -- setting the specs to match for the automation items
  
  local IsSelected = reaper.GetSetAutomationItemInfo(env, i, 'D_UISEL', 0, 0)
  
  if IsSelected == 1 then
    --positioning and size of automation items.
    reaper.GetSetAutomationItemInfo(env, i,"D_POSITION",selectedItemPosition,1)
    newRate = initialItemLength / selectedItemLength
    reaper.GetSetAutomationItemInfo(env, i,"D_PLAYRATE",newRate,1) -- If you do not want the "stretch" behaviour delete this line and the next.
    reaper.GetSetAutomationItemInfo(env, i,"D_LENGTH",selectedItemLength,1)
    
    --naming. This names the pooled items based on the user input. If no user input, it does not name it, and so it has the default number count.
    if automationItemName == "" then
      else
      reaper.GetSetAutomationItemInfo_String(env, i,"P_POOL_NAME",automationItemName,1)
      end
    
    end
  
  end

end

end

reaper.Undo_EndBlock("Create Pooled Automation Items for Selected Items", -1)

else
reaper.ShowMessageBox("NO ENVELOPE SELECTED. \n Better luck next time! :)", "womp womp", 1)

end

end
