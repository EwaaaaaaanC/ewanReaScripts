-- @description Deprecated but here for fun
-- @author ewan
-- @version 1.0
-- @about
--   Deprecated but here for fun
-- @noindex
-- NoIndex: true

reaper.Undo_BeginBlock()

reaper.Main_OnCommand(40061,0)

reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVETIME5"),0) -- remembers time selection so it can be recalled.

local fadetimems = 50
local fadetimesecs = fadetimems/2000

local item_cnt = reaper.CountSelectedMediaItems(0)

  for i = 0, item_cnt-1 do
  
  local item = reaper.GetSelectedMediaItem( 0, i )
  
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVEALLSELITEMS1"),0) -- remembers selected items
  reaper.Main_OnCommand(40289,0) -- deseelect all items
  
  reaper.SetMediaItemSelected(item, 1) -- select one item only
  
  SourceTrack = reaper.GetMediaItem_Track(reaper.GetSelectedMediaItem(activeProjectIndex, 0))
  reaper.SetTrackSelected(SourceTrack,1) -- select correct track
  
  -- Define the items area to later determine xfades
  local itemPosition = reaper.GetMediaItemInfo_Value(item,"D_POSITION")
  local itemLength = reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
  local start_time = itemPosition
  local end_time = itemPosition + itemLength
  
  
  reaper.Main_OnCommand(41924,0) -- Gain item down 1dB
  reaper.Main_OnCommand(41924,0) -- Gain item down 1dB
  reaper.Main_OnCommand(41924,0) -- Gain item down 1dB
  reaper.Main_OnCommand(41924,0) -- Gain item down 1dB
  
  reaper.GetSet_LoopTimeRange2(0,true,false,start_time-fadetimesecs,start_time+fadetimesecs,0) -- set time sel to xfade area
  reaper.Main_OnCommand(40718,0) -- select items in time sel
  reaper.Main_OnCommand(40916,0) -- xfade them
  
  reaper.GetSet_LoopTimeRange2(0,true,false,end_time-fadetimesecs,end_time+fadetimesecs,0) -- set time sel to xfade area
  reaper.Main_OnCommand(40718,0) -- select items in time sel
  reaper.Main_OnCommand(40916,0) -- xfade them
  
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTALLSELITEMS1"),0)
  
  end

reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTTIME5"),0)

reaper.UpdateArrange()

reaper.Undo_EndBlock("Gain Trim Selection and Crossfade",0)
