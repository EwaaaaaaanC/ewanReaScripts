-- @description Paste NPCTextAudio from Config Editor SIMPLE
-- @author ewan
-- @version 1.44
-- @changelog
--    Bug fix: handles colours and missing columns correctly.
--    Fixed descriptions to reflect proper use.

-- @about
--   Non-UI version. Copy the first four columns from config and paste them into reaper.

--HOW TO:
-- COPY the first FOUR columns in config for the steps you want to paste.
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
  assetList = {}
  textList = {}
  id = configTable[i*5-4]
  speaker = configTable[i*5-3]
  text = configTable[i*5-2]
  assets = configTable[i*5-1]
--above gets data for each step.

reaper.SelectAllMediaItems(0,false)
--deselectallitems

assetsFormatted = string.gsub(assets, ", ", "\n")
for line in assetsFormatted:gmatch("[^\r\n]+") do
    table.insert(assetList, line)
end
-- above four lines formats assets for inserting.

textSplit = string.gsub(text, "<continue>", "\n")
for line in textSplit:gmatch("[^\r\n]+") do
    table.insert(textList, line)
end
-- above four lines formats text for inserting.

currentPos = reaper.GetCursorPosition()

 if #assetList == 0 then
    pasteConfigAudio("NullFile/Null_3s.ogg",text)
   else
     for i = 1, #assetList do
     pasteAsset = assetList[i]
     pasteText = textList[i]
     pasteConfigAudio(pasteAsset,pasteText)
    end
   end
--above pastes assets in a row.

endPos = reaper.GetCursorPosition()
--reaper.SetEditCurPos(endPos+30,true,false)
--above moves the cursor forwards before next assets are pasted.

--insert an item below with the text on it

R,G,B = hex2rgb("#00f5c0") -- R because r is already taken by reaper, the rest is for consistency

reaper.AddProjectMarker2(0, true, currentPos, endPos-1, id, -1, reaper.ColorToNative(R,G,B)|0x1000000)
--insert region with id

_, underscorecount = string.gsub(id, "_", "_")
          if underscorecount >= 2 or underscorecount == nil then
          lastIdNPCTag = id:match("([^_]+_[^_]+_)")
          else
          lastIdNPCTag = "convoIDnotRelevant"
          end
-- END OF COLOUR THEORY. ba dum chhh

end

end


if retval then
reaper.Undo_BeginBlock()

main()

reaper.Undo_EndBlock("Paste from Config Editor (NPCTextAudio)",-1)

end