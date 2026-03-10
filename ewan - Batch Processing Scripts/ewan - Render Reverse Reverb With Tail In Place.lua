-- @description Render Reverse Reverb With Tail In Place
-- @author ewan
-- @version 1.0
-- @about
--   Renders the reverb on the selected items and handles reverse and un-reverse logic to create reverse reverb effects.

local numberOfSelectedItems = reaper.CountSelectedMediaItems(activeProjectIndex)
local retval, inputs_csv = reaper.GetUserInputs("ewan: ReverseVerber", 2, "Fade Durations (ms)","50,50")
local retval, tailDuration = reaper.GetUserInputs("Set Tail Length",1,"Reverb Time (s)","2")


if retval then
    local inputs = {}
    for value in inputs_csv:gmatch("([^,]+)") do
        table.insert(inputs, value)
    end
    fade_in_length = inputs[1]/1000
    fade_out_length = inputs[2]/1000

    ReverbTailLength = tailDuration
    ItemCounter = 0

reaper.Undo_BeginBlock()

--Prep. Selects the Correct Track
reaper.Main_OnCommand(40297,0)
SourceTrack = reaper.GetMediaItem_Track(reaper.GetSelectedMediaItem(activeProjectIndex, 0))
reaper.SetTrackSelected(SourceTrack,1)


--Below creates Render Track
trackID = reaper.GetSelectedTrack(0,0)
trackIndex = reaper.GetMediaTrackInfo_Value(trackID, "IP_TRACKNUMBER")
reaper.InsertTrackAtIndex(trackIndex-1,1)
prev_trackIndex = reaper.GetMediaTrackInfo_Value(trackID, "IP_TRACKNUMBER") - 2
prev_track = reaper.GetTrack(0, prev_trackIndex)
reaper.GetSetMediaTrackInfo_String(prev_track, "P_NAME", "RenderTrack", true)


-- begin Function
for i = 0, numberOfSelectedItems - 1 do

reaper.Main_OnCommand(41051,0)

--Deselect All Tracks except the Track Desired
local track_count = reaper.CountTracks(0)
for i = 0, track_count - 1 do
    -- Get the track object
    local track = reaper.GetTrack(0, i)
    reaper.SetTrackSelected(track, false)
end
reaper.SetTrackSelected(trackID,1) -- Select the Original Track


reaper.SetMediaTrackInfo_Value(trackID, "B_MUTE",0) -- Unmute the Original Track

  local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
  local selectedItemPosition = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")
  local selectedItemLength = reaper.GetMediaItemInfo_Value(selectedItem, "D_LENGTH")
  local selectedItemTake = reaper.GetTake(selectedItem, 0)
  local selectedItemTakeStartOffset = reaper.GetMediaItemTakeInfo_Value(selectedItemTake, "D_STARTOFFS")
  
  reaper.SetMediaItemInfo_Value(selectedItem, "D_POSITION", selectedItemPosition)
  reaper.SetMediaItemInfo_Value(selectedItem, "B_LOOPSRC", 0)
  
  reaper.GetSet_LoopTimeRange(1,0,selectedItemPosition,selectedItemPosition+selectedItemLength+ReverbTailLength,0); -- Sets Time Selection to Item + Render

reaper.Main_OnCommand(40719,0) -- Mute all items

reaper.SetMediaItemInfo_Value(selectedItem, "B_MUTE", 0) -- unmute the item being rendered

reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWRENDERSTEREOSMART"),0) -- Render

reaper.Main_OnCommand(40718,0)-- Select the Render on the created track

-- Deselect Original Item, move the Render to the RenderTrack
reaper.SetMediaItemSelected(selectedItem,0)
RenderedItem = reaper.GetSelectedMediaItem(0, 0)
reaper.MoveMediaItemToTrack(RenderedItem,prev_track);
reaper.SetMediaItemInfo_Value(RenderedItem, "D_LENGTH", selectedItemLength) -- Make Render Match original Item Length 


--ReverseRenderedItem ONLY
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVEALLSELITEMS1"),0)
reaper.Main_OnCommand(40289,0)
reaper.SetMediaItemSelected(RenderedItem,1)
reaper.Main_OnCommand(41051,0)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTALLSELITEMS1"),0)


--Cleanup
reaper.SetMediaItemSelected(RenderedItem,0)
reaper.SetMediaItemSelected(selectedItem,1)
reaper.Main_OnCommand(40005, 0) --Remove the BIP Track


  -- Set the fade in length
  reaper.SetMediaItemInfo_Value(RenderedItem, "D_FADEINLEN", fade_in_length)
  -- Set the fade out length
  reaper.SetMediaItemInfo_Value(RenderedItem, "D_FADEOUTLEN", fade_out_length)
  


reaper.SetTrackSelected(trackID,1) -- Select the Original Track

reaper.SetMediaItemInfo_Value(selectedItem, "B_MUTE", 1) -- mute the original item

reaper.Main_OnCommand(41051,0)

end 

reaper.Undo_EndBlock("Render With Tails In Place", -1)


end
