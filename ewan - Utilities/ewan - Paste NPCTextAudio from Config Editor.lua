-- @description Paste NPCTextAudio from Config Editor SIMPLE
-- @author ewan
-- @version 1.3
-- @changelog
--    Now handles blank text and audio cells correctly.

-- @about
--   Copy the first four columns from config and paste them into reaper.

--HOW TO:
-- COPY the first FIVE columns in config for the steps you want to paste.
-- Then, run this action at the point in the reaper session you wish to insert them.
-- Enter the number of seconds you want to separate each line.

dialoguePath = [[D:\SVN\4.0.0\bin\Client\Audio\Dialogue\]]
-- Paste your dialogue path above, if not the same as mine. 

-- The colour used is chosen at random, and is guaranteed to not be the same as the preceeding region.
-- On the below line is where you can define your colour scheme with hex codes.
colourscheme = {"#FFBE0B", "#FB5607", "#FF006E", "#8338EC", "#3A86FF", "#329E32"} -- There is no max no. of colours.
colourFirst = false


retval, spacing = reaper.GetUserInputs("ewan: Paste From Config (NPCTalkDialogueTextAudio)", 1, "Space between lines(s)","5")

clipboard = reaper.CF_GetClipboard('')

configTable = {}
-- Iterate through each line and insert it into the table
for line in clipboard:gmatch("[^\r\n\t]*") do
    table.insert(configTable, line)
end

function reduceToFileNameOnly(input)
local extensionRemoved = (string.gsub(input, ".ogg", ""))
local fileNameOnly = string.match(extensionRemoved, "([^/]+)$")
return fileNameOnly
end

function pasteConfigAudio (path,textinput)

if textinput == nil or textinput =="" then
textinput = ""
end

local pos = reaper.GetCursorPosition()
local fullpath = dialoguePath..path
itemStartPos = reaper.GetCursorPosition()
local fixed_path = (string.gsub(fullpath, "\\\\", "/"))
reaper.InsertMedia(fixed_path, 0)
local itemEndPos = reaper.GetCursorPosition()
reaper.SetEditCurPos(itemEndPos+spacing,true,false)

local fileName = reduceToFileNameOnly(path)
reaper.AddProjectMarker2(0, false, itemStartPos, 0, fileName, -1, 0)
--adds a marker with filename for rendering.


local track = reaper.GetSelectedTrack(0, 0)
local item = reaper.AddMediaItemToTrack(track)
reaper.SetMediaItemInfo_Value(item, "D_POSITION", pos)
reaper.SetMediaItemInfo_Value(item, "D_LENGTH", itemEndPos-pos+spacing-1) -- Length in seconds
reaper.GetSetMediaItemInfo_String(item,"P_NOTES",textinput,true)



end



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




function main()

id = ""
speaker = ""
text = ""
assetList = {}
textList = {}

stepCount = (#configTable+1)/5

for i = 1, stepCount do
  id = configTable[i*5-4]
  speaker = configTable[i*5-3]
  text = configTable[i*5-2]
  asset = configTable[i*5-1]
--above gets data for each step.

reaper.SelectAllMediaItems(0,false)
--deselectallitems

currentPos = reaper.GetCursorPosition()

 if asset == nil or asset == "" then
    pasteConfigAudio("NullFile/Null_3s.ogg",text)
   else
    pasteConfigAudio(asset,text)
 end

--above pastes assets in a row.

endPos = reaper.GetCursorPosition()
--reaper.SetEditCurPos(endPos+30,true,false)
--above moves the cursor forwards before next assets are pasted.

--insert an item below with the text on it


-- COLOUR REGIONS TO RANDOM FOR EACH DIFFERENT NPC CONVOS.
idNPCTag = id:match("([^_]+_[^_]+_)") 
if lastIdNPCTag == idNPCTag then
if colourFirst == true then
colour = "#808080"
end
else
randColour = colourscheme[math.random(1,#colourscheme-1)]

  if randColour == lastColour then
  colour = colourscheme[#colourscheme]
  else
  colour = randColour
  end
end
R,G,B = hex2rgb(colour) -- R because r is already taken by reaper, the rest is for consistency
lastColour = colour

reaper.AddProjectMarker2(0, true, currentPos, endPos-1, id, -1, reaper.ColorToNative(R,G,B)|0x1000000)
--insert region with id

lastIdNPCTag = id:match("([^_]+_[^_]+_)")
-- END OF COLOUR THEORY. ba dum chhh

end

end


if retval then
reaper.Undo_BeginBlock()

main()

reaper.Undo_EndBlock("Paste from Config Editor (NPCTextAudio)",-1)

end