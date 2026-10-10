-- @description Rename Selected Items to Match Closest Preceding Marker.
-- @author ewan
-- @version 1.1
-- @changelog
--   Now only renames items on selected tracks. This ensures only top-level items are renamed, and not children.
-- @about
--   Looks for the closest marker before each selected items and renames each after that.


-- note: quick scripting, bit messy

reaper.Undo_BeginBlock()

track = reaper.GetSelectedTrack(0, 0)

count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items > 0 then
    for i = 0, count_sel_items - 1 do
      item = reaper.GetSelectedMediaItem(0, i)
      take = reaper.GetActiveTake(item)
      if take then
      takeName = reaper.GetTakeName(take)
      end
      itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      bestPos = 0
      bestMarker = ""
      itemTrack = reaper.GetMediaItem_Track(item)
      markerCount, regionCount = reaper.CountProjectMarkers(0)
      -- find closest preceding marker
      for i = 0, regionCount -1 do
      
      local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, i)
        if retval > 0 and not isrgn then
        -- is a marker not a region
          if pos < itemPos and pos > bestPos and name ~= "" then
            bestPos = pos
            bestMarker = i
            TESTING = name
          end
        end
      end
    
     retval, isrgn, pos, rgnend, bestMarkerName, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, bestMarker)
      if itemTrack == track then
          if take then
        reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME",bestMarkerName,true)
          else
        reaper.GetSetMediaItemInfo_String(item,"P_NAME",bestMarkerName,true)  
        reaper.GetSetMediaItemInfo_String(item,"P_NOTES",bestMarkerName,true) 
          end
      end
    end
  end
  
reaper.UpdateArrange()
reaper.Undo_EndBlock("Rename Selected Items to Match Closest Preceding Marker",1)