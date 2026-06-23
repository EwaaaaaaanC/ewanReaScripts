-- @description Toggle Show Take Volume Envelope for All Items
-- @author ewan
-- @version 1
-- @about
--   Shows or Hides Volume Take Envelopes for All Items in the Project.

-- For Patricia :)

reaper.Undo_BeginBlock()

-- the below ext state is used to keep track of item envelope toggling.
currentVisibility = reaper.GetExtState("ewanScriptStates","TakeEnvVisible")

reaper.PreventUIRefresh(1)

-- make a list of all selected items by integer
itemCount = reaper.CountMediaItems(0)
selectedItems = {}
for i = 0, itemCount - 1 do 
  local item = reaper.GetMediaItem(0,i)
  local selected = reaper.IsMediaItemSelected(item)
  
  if selected then
  table.insert(selectedItems,i)
  end
end
  
  -- select all items
  reaper.SelectAllMediaItems(0,true)

  -- if take envelopes are visible, hide them, otherwise show them.
  if currentVisibility == "true" then
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENVSHOW4"),-1)
    reaper.SetExtState("ewanScriptStates","TakeEnvVisible","false",false)
    toggleState = "Hide"
  else
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENVSHOW1"),-1)
    reaper.SetExtState("ewanScriptStates","TakeEnvVisible","true",false)
    toggleState = "Show"
  end
  
  -- deselect all the items
  reaper.SelectAllMediaItems(0,false)
  
  -- reselect the items that were selected before the script was executed.
  for i = 1, #selectedItems do
  item = reaper.GetMediaItem(0,selectedItems[i])
  reaper.SetMediaItemSelected(item, true)
  end
  
  -- update the arrange view so you can see what items you have selected.
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
  
  reaper.Undo_EndBlock(toggleState.." Take Volume Envelope for All Items",-1)
