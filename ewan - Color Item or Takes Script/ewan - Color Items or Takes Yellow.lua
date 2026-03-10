-- @description Colour Items or Takes Yellow
-- @author ewan
-- @version 1.0
-- @about
--   Run this script to colour items or takes.

local HEX_COLOR = "#ffff00"     -- in HEX format
local r = reaper

if not force_color and not reaper.CF_GetCustomColor then
  reaper.MB("SWS extension is required by this script.\nPlease download it on https://www.sws-extension.org/ or via reapack on https://www.reapack.com", "Warning", 0)
  return
end

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

function Main()

  -- 1. Selected Items Active Take
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items > 0 then
    for i = 0, count_sel_items - 1 do
      local item = reaper.GetSelectedMediaItem(0, i)
      local take = reaper.GetActiveTake(item)
      if take then
        reaper.SetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR",  r.ColorToNative(R,G,B)|0x1000000)
      -- 2. Selected Items
      else
        reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR",  r.ColorToNative(R,G,B)|0x1000000)
      end
    end
    return
  end

end

function Init()
  reaper.PreventUIRefresh( 1 )
  
  reaper.Undo_BeginBlock()
  
  Main()
  
  reaper.UpdateArrange()
  
  reaper.Undo_EndBlock("Recolour item(s) or take(s)"..HEX_COLOR,0)
  
  reaper.PreventUIRefresh( - 1 )
end

if not preset_file_init then
  Init()
end
