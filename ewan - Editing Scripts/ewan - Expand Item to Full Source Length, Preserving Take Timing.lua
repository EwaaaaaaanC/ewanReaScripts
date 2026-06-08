-- @description Expand item to full source length, preserving take timing.
-- @author ewan
-- @version 0.8

-- @about
--    Expands the selected take to the full length of the source recording, whilst making sure to not move the selected take in time.

local item = reaper.GetSelectedMediaItem(0,0)
local take = reaper.GetActiveTake(item)
local itemStartOffset = reaper.GetMediaItemTakeInfo_Value(take,"D_STARTOFFS")
local pos = reaper.GetMediaItemInfo_Value(item,'D_POSITION')
local itemLen = reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
local source = reaper.GetMediaItemTake_Source(take)
local sourceLen = reaper.GetMediaSourceLength(source)

reaper.SetMediaItemInfo_Value(item,'D_LENGTH',sourceLen)
reaper.SetMediaItemInfo_Value(item,'D_POSITION',pos-itemStartOffset)
reaper.SetMediaItemTakeInfo_Value(take,'D_STARTOFFS',0)