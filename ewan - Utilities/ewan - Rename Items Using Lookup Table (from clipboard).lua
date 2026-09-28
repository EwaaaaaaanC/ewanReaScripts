-- @description Rename Items Using Lookup Table (from clipboard)
-- @author ewan
-- @version 0.7
-- @about
--   Copy two colums from a google sheet: column A will be the 'Find' values, column B will be the 'Replace' values.

renameCount = 0
clipboard = reaper.CF_GetClipboard('')
recolour = true
local HEX_COLOR = "#40E0D0"
configTable = {}

-- COLOURS!

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

-- COLOURS END

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock()

  -- Iterate through each line and insert it into the table
  for line in clipboard:gmatch("[^\n\t\r]*") do
      table.insert(configTable, line)
  end   

eventCount = (#configTable + 1)/3

count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items > 0 then
    for i = 0, count_sel_items - 1 do
      item = reaper.GetSelectedMediaItem(0, i)
      take = reaper.GetActiveTake(item)
      takeName = reaper.GetTakeName(take)
      
      for i=0, eventCount -1 do
      
        eventString = configTable[i*3+1]
        assetString = configTable[i*3+2]
        
        -- match event column A string only if followed by a . (such as .wav) or NOTHING.
        output = string.gsub(takeName,eventString.."$",assetString)
        output = string.gsub(output,eventString.."%.",assetString)
        
        reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME",output,true)
        
        -- keeps track of how many renames have taken place.
        if output ~= takeName then
        renameCount = renameCount+1
        if recolour then
          reaper.SetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR",  reaper.ColorToNative(R,G,B)|0x1000000)
          end
        end
        
        takeName = reaper.GetTakeName(take)
      
      end
      
    end
  end
  
  
  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock('Renamed '..renameCount..' items with lookup table (clipboard)',-1)
  reaper.MB(renameCount.." items renamed.","ewan's Item Renamer from Clipboard:",0)