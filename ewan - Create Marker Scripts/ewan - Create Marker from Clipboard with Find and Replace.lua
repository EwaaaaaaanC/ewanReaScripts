-- @description Create Marker from Clipboard at Edit Cursor with Find and Replace
-- @author ewan
-- @version 1.0
-- @about
--   Create Marker from Clipboard at Edit Cursor with Find and Replace

-- This Script creates markers with a set color and name.

local HEX_COLOR = "#ababab"     -- in HEX format
local POS_POINTER = 1           --Set to 1 for Edit Cursor, or change to else for Mouse

local r = reaper

r.PreventUIRefresh(1)

local cur_pos = r.GetCursorPosition() --Get edit Cursor

clipboard = reaper.CF_GetClipboard('')

local retval, inputs_csv = reaper.GetUserInputs("ewan: Create Marker from Clipboard", 2, "Find and Replace Clipboard Text :) (case sensitive)","Str4b,StrInt4b")

if retval then
    local inputs = {}
    for value in inputs_csv:gmatch("([^,]+)") do
        table.insert(inputs, value)
    end

    find = inputs[1]
    replace = inputs[2]
end

--find = "Str4b"
--replace = "StrInt4b"
-- use above to hard-code your find and replace, delete everything before find.


if replace == nil then
replace = ""
end

newID = string.gsub(clipboard, find, replace)

local markerNAME = newID -- use clipboard if you want, or "presetnamehere"

function hex2rgb(HEX_COLOR) -- sourced: https://gist.github.com/jasonbradley/4357406
    hex = HEX_COLOR:sub(2)
    return tonumber('0x'..hex:sub(1,2)), tonumber('0x'..hex:sub(3,4)), tonumber('0x'..hex:sub(5,6))
end

local HEX_COLOR = type(HEX_COLOR) == 'string' and HEX_COLOR:gsub('%s','') -- remove empty spaces just in case
-- default to black if color is improperly formatted
local HEX_COLOR = (not HEX_COLOR or type(HEX_COLOR) ~= 'string' or HEX_COLOR == '' or #HEX_COLOR < 4 or #HEX_COLOR > 7) and '#000' or HEX_COLOR
-- extend shortened (3 digit) hex color code, duplicate each digit
local HEX_COLOR = #HEX_COLOR == 4 and HEX_COLOR:gsub('%w','%0%0') or HEX_COLOR
local R,G,B = hex2rgb(HEX_COLOR) -- R because r is already taken by reaper, the rest is for consistency


r.Undo_BeginBlock()

r.AddProjectMarker2(0, false, cur_pos, 0, markerNAME, -1, r.ColorToNative(R,G,B)|0x1000000)

r.Undo_EndBlock('Insert marker: '..markerNAME,-1)

r.PreventUIRefresh(-1)



