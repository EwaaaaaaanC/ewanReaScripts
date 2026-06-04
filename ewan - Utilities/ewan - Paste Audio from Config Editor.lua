-- @description Paste Audio from Config Editor
-- @author ewan
-- @version 1.1
-- @changelog
--    Added spacing feature and ability to cancel from this dialogue (ba dum chh) box.

-- @about
--   Allows pasting config audio file paths into Reaper.

--SETUP:
--paste your filepath to the dialogue folder below.
--paste WITHIN the double square brackets.
dialoguePath = [[D:\SVN\4.0.0\bin\Client\Audio\Dialogue\]]

--HOW IT WORKS:
-- COPY from the Audio File column in config editor.
-- Then, run this script.
-- The assets in the audio file will be pasted into Reaper.

retval, spacing = reaper.GetUserInputs("ewan: Paste From Config (NPCTalkDialogueTextAudio)", 1, "Space between lines(s)","5")

function main()

clipboard = reaper.CF_GetClipboard('')
clipboard = string.gsub(clipboard, ", ", "\n")
--above replaces commas with new lines

assetTable = {}

-- Iterate through each line and insert it into the table
for line in clipboard:gmatch("[^\r\n]+") do
    table.insert(assetTable, line)
end


function pasteConfigAudio (path)
local path = dialoguePath..path
local fixed_path = (string.gsub(path, "\\\\", "/"))
reaper.InsertMedia(fixed_path, 0)
local pos = reaper.GetCursorPosition()
reaper.SetEditCurPos(pos+spacing,true,false)
end

for i = 1, #assetTable do
pasteTarget = assetTable[i]
pasteConfigAudio(pasteTarget)
end

end

if retval then
reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock("Paste Audio Assets from Config Editor",-1)
end