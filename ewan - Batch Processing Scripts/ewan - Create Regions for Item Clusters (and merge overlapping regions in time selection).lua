-- @description Create Regions for Item Clusters (and merge overlapping regions in time selection)
-- @author ewan
-- @version 0.9
-- @about
--   Creates Regions for Item Clusters — Sets of overlapping items.

-- ewan says HELLO!

-- GUIDE: Select items and run the script to create regions for each "Item Cluster"
-- Item clusters are sets of items that overlap in time, and can be assumed to be layers of the same sound.
-- The regions created will all be coloured to match eachother.

-- The colour used is chosen at random, and is guaranteed to not be the same as the preceeding region.
-- On the below line is where you can define your colour scheme with hex codes.
colourscheme = {"#FFBE0B", "#FB5607", "#FF006E", "#8338EC", "#3A86FF", "#329E32"} -- There is no max no. of colours.
-- By default, each region alternates slightly in brightness to make it easier to distinguish regions when zoomed out.
-- To disable this alternating dimming, set the below AltDim variable to 0. Leave the value as 1 if you want the alternating brightness.
AltDim = 1

-- Run this script with no items selected to merge overlapping regions within the time selection and re-colour them.
-- Therefore, you can run this script with no items selected if you just want to merge coincident regions.

-- Optional setting: shrinking
-- By default, this script will "shrink" regions above your item cluster to match the items selected.
-- If you would rather only ever add to regions, without shrinking them. Change the variable below to 0.
shrinkRegions = 1
-- This can be useful if you like to have regions which include "gaps" — maybe for sausage files or for having tails.

-- Optional setting: preserve and concatenate names.
-- If the below variable is set to 1, the script will combine the names of existing regions and set the new regions to this name.
-- This is handy to preserve existing region names.
concatNames = 0
-- In the current version, this can quickly lead to really long names as it doesn't check for repeats. So, it defaults to OFF for now.


--DO NOT TOUCH anything below here.
keepgoing = 1
regionfocussed = 0
terminatescript = 0

function getTimeSelAndItems ()
-- Returns start time, end time, and boolean of whether any items are selected.
-- The start and end times will be the span of selected items. If no items are selected, it will be the normal time selection.
local timestart, timeend = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
local countItems = reaper.CountSelectedMediaItems()
local itemsSel
if countItems > 0 then
  itemsSel = true
  for i = 0, 0 do
  local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
  timestart = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")
  timeend = timestart + reaper.GetMediaItemInfo_Value(selectedItem, "D_LENGTH")
  end
  
    for i = 0, countItems -1 do
      local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
      local selectedItemPosition = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")
      local selectedItemLength = reaper.GetMediaItemInfo_Value(selectedItem, "D_LENGTH")
        if timestart > selectedItemPosition then
        timestart = selectedItemPosition
        end
        if timeend < selectedItemPosition + selectedItemLength then
        timeend = selectedItemPosition + selectedItemLength
        end
      end
  else
  itemsSel = false
  end
return timestart, timeend, itemsSel
end

function createRegionsForSelectedItems(name)
  for i = 0, reaper.CountSelectedMediaItems()-1 do
    local selectedItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
    local selectedItemPosition = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")
    local selectedItemLength = reaper.GetMediaItemInfo_Value(selectedItem, "D_LENGTH")
    reaper.AddProjectMarker(0, true, selectedItemPosition, selectedItemPosition+selectedItemLength, name, -1, 0)
  end
end

function mergeOverlappingRegions(arg1,arg2)
-- arg1 and arg2 are your start and end times for where you want merging.
local num_markers = reaper.CountProjectMarkers(0)
keepgoing = 0
  --for i = 0, num_markers-1 do
  i = regionfocussed
  local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(proj, i)
  
    for a = 0, num_markers-1 do
    retval, compisrgn, comppos, comprgnend, compname, compmarkrgnindexnumber, compcolor = reaper.EnumProjectMarkers3(proj, a)
     
     if pos < arg1 and rgnend < arg1 or pos > arg2 then
     -- the above line makes it so regions outside of time selection are not merged
     else
       if comppos < pos and comprgnend > pos and isrgn == true then
       -- if region overlaps the starting pos, make a new merged region.
        reaper.DeleteProjectMarker(0, markrgnindexnumber, isrgn)
        reaper.DeleteProjectMarker(0, compmarkrgnindexnumber, isrgn)
            if rgnend > comprgnend then
              reaper.AddProjectMarker(0, true, comppos, rgnend, "", -1, 0)
              else
              reaper.AddProjectMarker(0, true, comppos, comprgnend, "", -1, 0)
              end
        keepgoing = 1
        return
        end
       
        if comprgnend > rgnend and comppos < rgnend and isrgn == true then
        -- if region overlaps the ending pos, make a new merged region.
        reaper.DeleteProjectMarker(0, markrgnindexnumber, isrgn)
        reaper.DeleteProjectMarker(0, compmarkrgnindexnumber, isrgn)
            if pos < comppos then
              reaper.AddProjectMarker(0, true, pos, comprgnend, "", -1, 0)
              else
              reaper.AddProjectMarker(0, true, comppos, comprgnend, "", -1, 0)
              end
        keepgoing = 1
        return
        end
      
      end
      
    --end a loop
    end
    
--end function
end




function runMergeLoop ()
  while keepgoing == 1 do
    mergeOverlappingRegions(timeStart,timeEnd)
  end
end

function runMergeAction ()
  while terminatescript == 0 do
    if keepgoing == 0 then
      num_markers = reaper.CountProjectMarkers(0)
      regionfocussed = regionfocussed + 1
          if regionfocussed > num_markers then
            terminatescript = 1
          else
            keepgoing = 1
            runMergeLoop()
          end
        else
          runMergeLoop()
    end
  end
end



-- Colour Stuff


local r = reaper

if not force_color and not reaper.CF_GetCustomColor then
  reaper.MB("SWS extension is required by this script.\nPlease download it on https://www.sws-extension.org/ or via reapack on https://www.reapack.com", "Warning", 0)
 -- return
end

function hex2rgb(HEX_COLOR) -- sourced: https://gist.github.com/jasonbradley/4357406
    local hex = HEX_COLOR:sub(2)
    return tonumber('0x'..hex:sub(1,2)), tonumber('0x'..hex:sub(3,4)), tonumber('0x'..hex:sub(5,6))
end

function NativeToHex(nativeColour)
    -- Get RGB from native COPIED
    local R = (nativeColour >> 16) & 0xFF
    local G = (nativeColour >> 8) & 0xFF
    local B = nativeColour & 0xFF
    -- Format to hex string (#RRGGBB)
    return string.format("#%02X%02X%02X", R, G, B)
end

-- Colour Setup END






function RegionBeforeTimeSel ()
  local nearestend = 0
  local nearestcolour = 0
  local timeStart, timeEnd = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  local num_markers = reaper.CountProjectMarkers(0)
    for i = 0, num_markers-1 do
      local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, i)
        if rgnend < timeStart and rgnend > nearestend then
        --region is before time selection and closer than all prev checked
            nearestregion = i
            nearestend = rgnend
            nearestcolour = color
        end
    end
  return nearestregion, nearestcolour
end


function colourRegionsInTimeSel(arg1,arg2,arg3,alternateBrightness)
num_markers = reaper.CountProjectMarkers(0)

  for i = 0, num_markers-1 do
  local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(proj, i)
    if pos < timeStart and rgnend < timeStart or pos > timeEnd then
    -- Do nothing if the region is out of bounce
    else
    --reaper.SetProjectMarker3(0,markrgnindexnumber,isrgn,pos,rgnend,name,r.ColorToNative(arg1,arg2,arg3)|0x1000000)
            if i % 2 == 0 and alternateBrightness == 1 then
            local dimR = math.max(R - 33, 0)
            local dimG = math.max(G - 33, 0)
            local dimB = math.max(B - 33, 0)
            reaper.SetProjectMarker3(0,markrgnindexnumber,isrgn,pos,rgnend,name,r.ColorToNative(dimR,dimG,dimB)|0x1000000)
            else
            reaper.SetProjectMarker3(0,markrgnindexnumber,isrgn,pos,rgnend,name,r.ColorToNative(arg1,arg2,arg3)|0x1000000)
            end
    end
  end
end






function ColourRegionsTimeSelSameRandom()
--Get Details of Previous Region
local nearestregion, nearestcolour = RegionBeforeTimeSel()
local prevColour = NativeToHex(nearestcolour)

--Pick a random Colour from the Colour Scheme defined at top of script.
--Makes sure that the regions are coloured differently than the directly preceeding region.
  randColour = colourscheme[math.random(1,#colourscheme-1)]
  if randColour == prevColour then
  selectedColour = colourscheme[#colourscheme]
  else
  selectedColour = randColour
  end

R,G,B = hex2rgb(selectedColour) -- R because r is already taken by reaper, the rest is for consistency
colourRegionsInTimeSel(R,G,B,AltDim)

end






function removeRegionsInTimeBounds(t_start,t_end)

local i = 0

while true do

local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers(i)
  
-- this exits the loop if there are no more markers or regions to evaluate.
  if retval == 0 then
  --keepRunning = 0
  break
  end
  
-- If its a region, check if it needs deleting, if not skip to the next region.
  if isrgn == true then
  -- if we are focussed on a region then
              if (pos >= t_start and pos < t_end) or (pos < t_start and rgnend >= t_start) then
              -- check if the region overlaps time sel, and if yes, delete it.
                reaper.DeleteProjectMarkerByIndex(0,i)
              else
              -- If region is not in the time selection, we skip to the next.
              i = i + 1
              end
  else
  -- if its a marker, skip to the next.
              i = i + 1
  end
end -- end of while loop
      
end -- end of function








function checkForUniqueMarkerNamesInTime (arg1, arg2)
-- use arg1 and arg2 to define time range
local uniqueMarkerNames = {}
--local UniqueMarkerNames = {}
for i = 0, reaper.CountProjectMarkers()-1 do
  local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers(i)

  if ((arg1<pos and pos<arg2) or (pos<arg1 and rgnend>arg1)) and (name~="") then
    table.insert(uniqueMarkerNames,name)
    end

  end

--concatNames = table.concat(uniqueMarkerNames,", ")
return table.concat(uniqueMarkerNames,", ")
end





function generateListUniqueMarkerNamesInTimeNoRepeats (arg1, arg2)
--WIP still doesn't work
-- use arg1 and arg2 to define time range
uniqueMarkerNames = {}
--local UniqueMarkerNames = {}
for i = 0, reaper.CountProjectMarkers()-1 do
  local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers(i)

  if ((arg1<pos and pos<arg2) or (pos<arg1 and rgnend>arg1)) and (name~="") then
     for n = 0, #uniqueMarkerNames do
            --  if uniqueMarkerNames[ n ] ~= name then
                table.insert(uniqueMarkerNames,name)
            --  end
     end
  end
end
--concatNames = table.concat(uniqueMarkerNames,", ")
return table.concat(uniqueMarkerNames,", ")
end



function nameRegionsInTime(starttime,endtime,newname)
local num_markers = reaper.CountProjectMarkers(0)

  for i = 0, num_markers-1 do
  local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(proj, i)
    if pos < starttime and rgnend < starttime or pos > endtime then
    -- Do nothing if the region is out of bounds
    else
    reaper.SetProjectMarker3(0,markrgnindexnumber,isrgn,pos,rgnend,newname,color)
    end
  end
end






reaper.PreventUIRefresh( 1 )
reaper.Undo_BeginBlock()



timeStart, timeEnd, areItemsSel = getTimeSelAndItems()


newRegionID = checkForUniqueMarkerNamesInTime(timeStart,timeEnd)
--newRegionID = generateListUniqueMarkerNamesInTimeNoRepeats(timeStart,timeEnd)

if shrinkRegions == 1  and areItemsSel == true then
removeRegionsInTimeBounds(timeStart,timeEnd)
end

if concatNames == 1 then
createRegionsForSelectedItems(newRegionID)
else
createRegionsForSelectedItems("")
end

runMergeAction()

ColourRegionsTimeSelSameRandom(timeStart,timeEnd)

if concatNames == 1 then
nameRegionsInTime(timeStart,timeEnd, newRegionID)
end



reaper.UpdateArrange()
reaper.Undo_EndBlock("Create Regions for Item Clusters in Time Selection :)",-1)
reaper.PreventUIRefresh( - 1 )

-- ewan says GOODBYE

