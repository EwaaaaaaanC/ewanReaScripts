-- @description Creates Regions from Item Names (file extensions removed)
-- @author ewan
-- @version 1.0
-- @about
--   Creates Regions from Item Names (file extensions removed)

replace = ""

for i = 0, reaper.CountSelectedMediaItems()-1 do
  
  -- Get item and take
  item = reaper.GetSelectedMediaItem(0, i)

  active_take = reaper.GetActiveTake(item)
  take_name = reaper.GetTakeName(active_take)
  removeogg = string.gsub(take_name, ".ogg", replace)
  newID = string.gsub(removeogg, ".wav", replace)
  -- Apply new name
  reaper.GetSetMediaItemTakeInfo_String(active_take, 'P_NAME', newID, true)
end


reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_REGIONSFROMITEMS"), 0) --Create Named Regions from Items
