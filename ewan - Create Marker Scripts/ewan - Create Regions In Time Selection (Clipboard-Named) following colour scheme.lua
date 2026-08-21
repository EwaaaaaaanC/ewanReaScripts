-- @description Create Clipboard-Named Regions In Time Selection, following colour scheme.
-- @author ewan
-- @version 1
-- @about
--   Creates a region within the time selection following a colour scheme.

-- The colour used is chosen at random, and is guaranteed to not be the same as the preceeding region.
-- On the below line is where you can define your colour scheme with hex codes.
-- This script is a bit messy, but works without problem.

colourscheme = {"#FFBE0B", "#FB5607", "#FF006E", "#8338EC", "#3A86FF", "#329E32"} -- There is no max no. of colours.

reaper.PreventUIRefresh(1)

clipboard = reaper.CF_GetClipboard('')

rgnName =  clipboard

reaper.Undo_BeginBlock()


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
    local B = (nativeColour >> 16) & 0xFF
    local G = (nativeColour >> 8) & 0xFF
    local R = nativeColour & 0xFF
    -- Format to hex string (#RRGGBB)
    return string.format("#%02X%02X%02X", R, G, B)
end

-- Colour Setup END



function findMatchIndex(arr, target)
    for index, value in ipairs(arr) do
        if value == target then
            return index -- Returns the 1-based index of the match
        end
    end
    return nil
end
-- the above returns the number in the list of match.


function RegionBeforeTimeSel ()
  local nearestend = 0
  local nearestcolour = 0
  nearestID = 0
  local timeStart, timeEnd = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  local num_markers = reaper.CountProjectMarkers(0)
    for i = 0, num_markers-1 do
      local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, i)
        if rgnend < timeStart and rgnend > nearestend then
        --region is before time selection and closer than all prev checked
            nearestregion = i
            nearestend = rgnend
            nearestcolour = color
            nearestID = markrgnindexnumber
        end
    end
   -- reaper.DeleteProjectMarker(0, nearestID, true)
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

function getColourRegionInTimeSel()
local currentRegionColour = 0
local timeStart, timeEnd = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
local num_markers = reaper.CountProjectMarkers(0)

    for i = 0, num_markers-1 do
      local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, i)
        if rgnend > timeStart and rgnend < timeEnd then
        --region is before time selection and closer than all prev checked
            currentRegionColour = color
        end
    end
  return currentRegionColour
end


function ColourRegionsTimeSelSameRandom()
--Get Details of Previous Region
local nearestregion, nearestcolour = RegionBeforeTimeSel()
local prevColour = NativeToHex(nearestcolour)
local currentRegionColour = NativeToHex(getColourRegionInTimeSel())

local indexPrevColour = findMatchIndex(colourscheme, prevColour)
local indexCurrentColour = findMatchIndex(colourscheme,currentRegionColour)
local coloursAvailable = {}
--Pick a random Colour from the Colour Scheme defined at top of script.
--Makes sure that the regions are coloured differently than the directly preceeding region.

-- the below block makes a list of colour indexes that do not match the previous or current region colours.
for i=1, #colourscheme do
if i ~= indexPrevColour and i ~= indexCurrentColour then
table.insert(coloursAvailable,i)
end
end

local indexFilteredRandom = coloursAvailable[math.random(1,#coloursAvailable)]
local selectedColour = colourscheme[indexFilteredRandom]

R,G,B = hex2rgb(selectedColour) -- R because r is already taken by reaper, the rest is for consistency
colourRegionsInTimeSel(R,G,B,AltDim)

end



startTime,endTime = reaper.GetSet_LoopTimeRange2(0,0,0,0,0,0)

timeStart = startTime
timeEnd = endTime

reaper.AddProjectMarker2(0,true,startTime,endTime,rgnName,0,0)

ColourRegionsTimeSelSameRandom()

reaper.Undo_EndBlock('Insert Region: '..rgnName..' (following colour scheme)',-1)

reaper.PreventUIRefresh(-1)

