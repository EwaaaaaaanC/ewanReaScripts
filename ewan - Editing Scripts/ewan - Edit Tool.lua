-- @description ewan's Edit Tool
-- @author ewan
-- @version 0.7
-- @about
--   ewan's edit tool for fades and cuts


-- README:
-- This script allows access to several quick editing moves, designed with dialogue in mind.
-- However, this script can be useful for many editing tasks and styles.
-- The script acts on whatever track is under the mouse. This ensures you only edit the specific track intended.



-- THE FUNCTIONS:

-- Fade-in: if you time-select the start of an item, a fade-in will be set to reach the end of the selected time.

-- Fade-out: if you time-select the end of an item, a fade-out will be set starting from the beginning of the selected time.

-- Smart Crossfade: if you time-select an area with two touching or overlapping items, a crossfade will be set.
    -- If possible, the crossfade will be set to match the time selection length.
    -- If either item is fully covered by the time selection, only the already overlapping areas of each item will be crossfaded.
          -- Note: Pre-existing Fade-ins and outs will be reducted to accomodate the duration of the crossfade, if necessary.
          
-- Breath Trim: if you have an area in the middle of a single item selected, this area will be sliced and gain-trimmed down.
          -- The amount of gain change can be specified on the variable on the line below:
      breathGain = -9       -- in dB. Feel free to set to positive values if you want to turn up, instead of trimming.
          -- Crossfades are added on either side of the trimmed area. The duration of these can be defined on the line below:
      breathFadeTime = 50   -- value in milliseconds



-- The script behaves the same regardless of item selection.
-- This speeds up workflow as you never waste time controlling selection or focus.

-- Edit below at your own risk!


function doItemsTouch(item1,item2)-- Checks if two items touch/overlap.
-- Returns true or false, as well as the start and end time of the overlap.
       local touching = false
       local startPos = 0
       local endPos = 0
       local item1Track = reaper.GetMediaItem_Track(item1)
       local item2Track = reaper.GetMediaItem_Track(item2)
       if item1Track == item2Track then
       local item1Pos = reaper.GetMediaItemInfo_Value(item1, "D_POSITION")
       local item1Len = reaper.GetMediaItemInfo_Value(item1, "D_LENGTH")
       local item1End = item1Pos + item1Len
       local item2Pos = reaper.GetMediaItemInfo_Value(item2, "D_POSITION")
       local item2Len = reaper.GetMediaItemInfo_Value(item2, "D_LENGTH")
       local item2End = item2Pos + item2Len
                        
          if (item1Pos >= item2Pos and item1Pos <= item2End) or (item1End >= item2Pos and item1End < item2End) then
              touching = true
              if item1Pos<item2Pos then
              startPos = item2Pos
              endPos = item1End
              else
              startPos = item1Pos
              endPos = item2End
              end
           -- the item overlaps the razor region 
             if (item1Pos > item2Pos and item1End < item2End) or (item2Pos > item1Pos and item2End < item1End) then
              touching = false -- returns false because one is completely covered.
              end
          end
        end
      return touching, startPos, endPos
end


function fadeContext (item, startBounds, endBounds)
    -- performs a fade in or fade out depending on whether the start or end of the item is within bounds.
      local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local itemLen = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      local itemEnd = itemPos + itemLen
      local itemIn = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
      local fadeType
      
      if itemPos>=startBounds and itemEnd>endBounds then
      reaper.SetMediaItemInfo_Value(item,"D_FADEINLEN",endBounds-itemPos)
      reaper.SetMediaItemInfo_Value(item,"D_FADEINLEN_AUTO",endBounds-itemPos)
      fadeType = "In"
      --fade in
      end
      if itemPos<startBounds and itemEnd<endBounds then
      
      if itemPos + itemIn > startBounds then
      -- if there is a long fade in that gets in the way of your new fade-out, shorten it.
      reaper.SetMediaItemInfo_Value(item,"D_FADEINLEN",startBounds-itemPos) 
      reaper.SetMediaItemInfo_Value(item,"D_FADEINLEN_AUTO",startBounds-itemPos)
      end
      reaper.SetMediaItemInfo_Value(item,"D_FADEOUTLEN",itemEnd-startBounds)
      reaper.SetMediaItemInfo_Value(item,"D_FADEOUTLEN_AUTO",itemEnd-startBounds)
      fadeType = "Out"
      --fade out
      end
return fadeType
end


function xfadeItemsToFitBounds(item1,item2,startBounds,endBounds)
       local boundsLen = endBounds - startBounds
       local item1Pos = reaper.GetMediaItemInfo_Value(item1, "D_POSITION")
       local item2Pos = reaper.GetMediaItemInfo_Value(item2, "D_POSITION")
       local firstItem
       local secondItem
       local firstPos
       local secondPos
        if item1Pos < item2Pos then
          firstItem = item1
          secondItem = item2
          firstPos = item1Pos
          secondPos = item2Pos
          else
          firstItem = item2
          secondItem = item1
          firstPos = item2Pos
          secondPos = item1Pos
          end
              
       local firstLen = reaper.GetMediaItemInfo_Value(firstItem, "D_LENGTH")
       local firstEnd = firstPos + firstLen
       local firstTake = reaper.GetActiveTake(firstItem)
       local firstFadeIn = reaper.GetMediaItemInfo_Value(firstItem,"D_FADEINLEN")
       local firstOffset = reaper.GetMediaItemTakeInfo_Value(firstTake, "D_STARTOFFS")
       local secondLen = reaper.GetMediaItemInfo_Value(secondItem, "D_LENGTH")
       
       local secondEnd = secondPos + secondLen
       local secondTake = reaper.GetActiveTake(secondItem)
       local secondOffset = reaper.GetMediaItemTakeInfo_Value(secondTake, "D_STARTOFFS")
       local secondFadeOut = reaper.GetMediaItemInfo_Value(secondItem,"D_FADEOUTLEN")
       
       --shorten Fade in or Out if it clashes with bounds.
       if firstPos + firstFadeIn > startBounds then
       reaper.SetMediaItemInfo_Value(firstItem,"D_FADEINLEN",startBounds-firstPos)
       reaper.SetMediaItemInfo_Value(firstItem,"D_FADEINLEN_AUTO",startBounds-firstPos)
       end
       
       if secondEnd - secondFadeOut < endBounds then
       reaper.SetMediaItemInfo_Value(secondItem,"D_FADEOUTLEN",secondEnd-endBounds)
       reaper.SetMediaItemInfo_Value(firstItem,"D_FADEOUTLEN_AUTO",secondEnd-endBounds)
       end
       
       -- Now we have info, let's XFADE THIS MOTHER
       --firstItem
       reaper.SetMediaItemInfo_Value(firstItem,"D_LENGTH",firstLen + (endBounds-firstEnd))
       reaper.SetMediaItemInfo_Value(firstItem,"D_FADEOUTLEN_AUTO",boundsLen)
       
       --secondItem
       reaper.SetMediaItemInfo_Value(secondItem,"D_POSITION",startBounds)
       reaper.SetMediaItemInfo_Value(secondItem,"D_LENGTH", secondLen + (secondPos-startBounds))
       reaper.SetMediaItemTakeInfo_Value(secondTake,"D_STARTOFFS",secondOffset - (secondPos - startBounds))
       reaper.SetMediaItemInfo_Value(secondItem,"D_FADEINLEN",boundsLen)
       reaper.SetMediaItemInfo_Value(secondItem,"D_FADEINLEN_AUTO",boundsLen)
end


function doesItemOverlapBounds(item,startBounds,endBounds)
       local overlap = false
       local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
       local itemLen = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
       local itemEnd = itemPos + itemLen
                        
          if (itemPos >= startBounds and itemPos < endBounds) or (itemEnd > startBounds and itemEnd < endBounds) or (itemPos<= startBounds and itemEnd>= endBounds) then
           -- the item overlaps the razor region 
            overlap = true
          end
      return overlap
end


function doesItemCoverBounds (item,startBounds,endBounds)
-- the error range makes it so that the script does not trigger if the item area pre or post the bounds is less than the range.
-- the intention is to prevent miniscule edits that are likely errors.
      local covers = false
      local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local itemLen = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      local itemEnd = itemPos + itemLen
      
        if( (itemPos - startBounds) <= 0 and (itemEnd - endBounds) > 0 ) then
        covers = true
        end
      return covers
end


function doBoundsCoverItem (item,startBounds,endBounds)
      local covers = false
      local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local itemLen = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      local itemEnd = itemPos + itemLen
      
        if(itemPos >= startBounds and itemEnd <= endBounds ) then
        covers = true
        end
      return covers
end


function breathTrim (item, startBounds,endBounds,trim,fadeTimeMS)
local fadeTime = fadeTimeMS / 1000
local trimMult = 10^(trim/20)
local simpleStart = false
local breathItem
local followingItem
local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

breathItem = reaper.SplitMediaItem(item,startBounds)
followingItem = reaper.SplitMediaItem(breathItem,endBounds)

          --get breath values
            local breathInitVol = reaper.GetMediaItemInfo_Value(breathItem,"D_VOL")
            local breathPos = reaper.GetMediaItemInfo_Value(breathItem, "D_POSITION")
            local breathLen = reaper.GetMediaItemInfo_Value(breathItem, "D_LENGTH")
            local breathTake = reaper.GetActiveTake(breathItem)
            --local breathEnd = breathPos + breathLen
            local breathTakeName = reaper.GetTakeName(breathTake)
            local breathOffset = reaper.GetMediaItemTakeInfo_Value(breathTake,"D_STARTOFFS")
          -- get following values 
            local followingPos = reaper.GetMediaItemInfo_Value(followingItem, "D_POSITION")
            local followingLen = reaper.GetMediaItemInfo_Value(followingItem, "D_LENGTH")
            local followingTake = reaper.GetActiveTake(followingItem)
            local followingOffset = reaper.GetMediaItemTakeInfo_Value(followingTake,"D_STARTOFFS")
              
  -- set new values for initial item
  reaper.SetMediaItemInfo_Value(item,"D_LENGTH",startBounds-itemPos+(fadeTime/2))
  reaper.SetMediaItemInfo_Value(item,"D_FADEOUTLEN",fadeTime)
  reaper.SetMediaItemInfo_Value(item,"D_FADEOUTLEN_AUTO",fadeTime)
  
  --set new values for breath Item
  reaper.SetMediaItemInfo_Value(breathItem,"D_VOL",breathInitVol*trimMult)
  reaper.SetMediaItemInfo_Value(breathItem,"D_LENGTH",breathLen+fadeTime)
  reaper.SetMediaItemInfo_Value(breathItem,"D_POSITION",startBounds-(fadeTime/2))
  reaper.SetMediaItemTakeInfo_Value(breathTake,"D_STARTOFFS",breathOffset-(fadeTime/2))
  reaper.SetMediaItemInfo_Value(breathItem,"D_FADEINLEN",fadeTime)
  reaper.SetMediaItemInfo_Value(breathItem,"D_FADEINLEN_AUTO",fadeTime)
  reaper.SetMediaItemInfo_Value(breathItem,"D_FADEOUTLENO",fadeTime)
  reaper.SetMediaItemInfo_Value(breathItem,"D_FADEOUTLEN_AUTO",fadeTime)
  reaper.GetSetMediaItemTakeInfo_String(breathTake,"P_NAME","BreathTrim: "..breathTakeName,true)
  
  
  --set new values for following Item
  reaper.SetMediaItemInfo_Value(followingItem,"D_LENGTH",followingLen+(fadeTime/2))
  reaper.SetMediaItemInfo_Value(followingItem,"D_POSITION",endBounds-(fadeTime/2))
  reaper.SetMediaItemTakeInfo_Value(followingTake,"D_STARTOFFS",followingOffset-(fadeTime/2))
  reaper.SetMediaItemInfo_Value(followingItem,"D_FADEINLEN",fadeTime)
  reaper.SetMediaItemInfo_Value(followingItem,"D_FADEINLEN_AUTO",fadeTime)

end



function getItemsInBoundsForTrack(track,startBounds,endBounds)

     local itemCount = 0
     local itemList = {}

for i = 0, reaper.CountTrackMediaItems(track)-1 do
     local item = reaper.GetTrackMediaItem(track, i)
     local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
     local itemLen = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
     local itemEnd = itemPos + itemLen
     
     if doesItemOverlapBounds(item,startBounds,endBounds) then
     itemCount = itemCount + 1
     table.insert(itemList,item)
     end
end

return itemCount, itemList
end


-- START DOING STUFF


mouseX, mouseY = reaper.GetMousePosition()
editTrack = reaper.GetTrackFromPoint(mouseX,mouseY)

if editTrack == nil then
reaper.MB("No Track Under Mouse", "Where are you trying to edit?",0)
return
end

reaper.Undo_BeginBlock()

startTime, endTime = reaper.GetSet_LoopTimeRange2(activeProjectIndex,false,0,0,0,0)

local whatHappened = ""
-- STUFF GETS DONE

itemCounter, itemsInBounds = getItemsInBoundsForTrack(editTrack,startTime,endTime)

if itemCounter == 1 then
      
      -- If the time selection is a section within one item, breath trim.
      if doesItemCoverBounds (itemsInBounds[1],startTime,endTime) then
      breathTrim (itemsInBounds[1],startTime,endTime,breathGain,breathFadeTime)
      whatHappened = "Breath Trim "..breathGain.."dB"
      else
        -- If the time selection covers the beginning or end of an item (and nothing else), then fade in or out smartly.
        if doBoundsCoverItem(itemsInBounds[1],startTime,endTime) then
         else
         local fadeType = fadeContext(itemsInBounds[1],startTime,endTime)
         whatHappened = "Fade "..fadeType
         end
      end
end


if itemCounter == 2 then
    touching, overlapStart,overlapEnd = doItemsTouch(itemsInBounds[1],itemsInBounds[2])
     --check if they touch
     if touching then
       --check if either item exists fully in Bounds
       if doBoundsCoverItem(itemsInBounds[1],startTime,endTime) or doBoundsCoverItem(itemsInBounds[2],startTime,endTime) then
        xfadeItemsToFitBounds(itemsInBounds[1],itemsInBounds[2],overlapStart,overlapEnd)
        whatHappened = "xFade Overlapping Items"
        else
        xfadeItemsToFitBounds(itemsInBounds[1],itemsInBounds[2],startTime,endTime)
        whatHappened = "xFade Time Sel"
       end
     end
end

-- STUFF FINISHED


reaper.UpdateArrange()

reaper.Undo_EndBlock("ewanEdit: "..whatHappened, -1)

