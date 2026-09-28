-- @description Rename Items to Match Closest Preceding Marker.
-- @author ewan
-- @version 0.7
-- @about
--   Looks for the closest marker before each selected items and renames each after that.


-- note: quick scripting, bit messy
count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items > 0 then
    for i = 0, count_sel_items - 1 do
      item = reaper.GetSelectedMediaItem(0, i)
      take = reaper.GetActiveTake(item)
      takeName = reaper.GetTakeName(take)
      itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      bestPos = 0
      bestMarker = ""
      
      markerCount, regionCount = reaper.CountProjectMarkers(0)
      -- find closest preceding marker
      for i = 0, regionCount -1 do
      
      local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, i)
        if retval > 0 and not isrgn then
        -- is a marker not a region
          if pos < itemPos and pos > bestPos then
            bestPos = pos
            bestMarker = i
        
          end
        end
      end
    
     retval, isrgn, pos, rgnend, bestMarkerName, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, bestMarker)
      
    reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME",bestMarkerName,true)

    end
  end