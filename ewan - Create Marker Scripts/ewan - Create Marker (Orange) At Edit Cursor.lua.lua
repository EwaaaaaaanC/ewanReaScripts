-- @description Create Orange Marker at Edit Cursor
-- @author ewan
-- @version 1.0
-- @about
--   Create Orange Marker at Edit Cursor

-- This Script creates markers with a set color and name.

local HEX_COLOR = "#ffaa00"     -- in HEX format
local POS_POINTER = 1           --Set to 1 for Edit Cursor, or change to else for Mouse

local r = reaper

r.PreventUIRefresh(1)

local cur_pos = r.GetCursorPosition() --Get edit Cursor

clipboard = reaper.CF_GetClipboard('')

local markerNAME = ""
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



