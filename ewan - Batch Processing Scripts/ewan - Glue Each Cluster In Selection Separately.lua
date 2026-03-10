-- @description Glue Each Cluster in Selection Seperately
-- @author ewan
-- @version 1.0
-- @about
--   Glues each Item Cluster in sequence.
-- @noindex
-- NoIndex: true

-- ewan says ENJOY!
ClustersProcessed = 0
-- In the below function, enter whatever actions you want to do for all items in each separate cluster.
-- Item clusters are sets of items that overlap in time, and can be assumed to be layers of the same sound.

-- Describe your action below with a verb. This is for the undo tags.
DescribeYourAction = "Glue Each Separately"

function actionsForCluster ()

-- INSERT YOUR ACTIONS HERE:
reaper.Main_OnCommand(40362, 0) -- Glue Selected Items

-- Do not touch line below. :n) TY!
ClustersProcessed = ClustersProcessed + 1
end

-- EDIT BELOW AT YOUR PERIL!



function storeSelItems()
local selItemList = {}

 for i = 0, reaper.CountMediaItems()-1 do
  local item = reaper.GetMediaItem(0,i)
  
    if  reaper.IsMediaItemSelected(item) then
     table.insert(selItemList,item)
    end
    
  end
  return selItemList
end

local function has_value (table, val)
    for index, value in ipairs(table) do
        if value == val then
            return true
        end
    end
    
    return false
end


function getClusterForItemNo(arg1)
local i = arg1
local item = reaper.GetMediaItem(0,i)
local itemCluster = {}
local clusterExpanded = 1

if has_value(savedSelItems, item) then
  
  itemCluster = {item}
  local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  local itemLen = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  local itemEnd = itemPos + itemLen
  
  local clusterPos = itemPos
  local clusterEnd = itemEnd
  
  
  while clusterExpanded == 1 do

  local initClusterSize = #itemCluster
  clusterExpanded = 0
          for a = 0, reaper.CountMediaItems()-1 do
            if a ~= i then
            
             local compareItem = reaper.GetMediaItem(0,a)
              
                if has_value(savedSelItems, compareItem) then
                  local compItemPos = reaper.GetMediaItemInfo_Value(compareItem, "D_POSITION")
                  local compItemLen = reaper.GetMediaItemInfo_Value(compareItem, "D_LENGTH")
                  local compItemEnd = compItemPos + compItemLen
                  local compItemSel = reaper.IsMediaItemSelected(item)
              
                      if (compItemPos <= clusterPos and compItemEnd >= clusterPos) or (compItemPos >= clusterPos and compItemPos <= clusterEnd) then -- compItem overlaps or touches previous
                          if compItemPos <= clusterPos then clusterPos = compItemPos; end
                          if compItemEnd > clusterEnd then clusterEnd = compItemEnd; end
                          if has_value(itemCluster,compareItem) then else table.insert(itemCluster, compareItem) end
                      end
                end
            end
          end
  local postClusterSize = #itemCluster

  if postClusterSize > initClusterSize then clusterExpanded = 1 else clusterExpanded = 0 end

  
  end

end
  return itemCluster
end






function selClusterOfItem(arg1)

local selItemCluster = getClusterForItemNo(arg1)

  for n = 0, reaper.CountMediaItems()-1 do
    local CHECKitem = reaper.GetMediaItem(0,n)
    if has_value(selItemCluster,CHECKitem) then
    reaper.SetMediaItemSelected(CHECKitem, true)
    else
    reaper.SetMediaItemSelected(CHECKitem, false)
    end
  end
end

function selItemsFromArray(arg1)

  for n = 0, reaper.CountMediaItems()-1 do
    local CHECKitem = reaper.GetMediaItem(0,n)
    if has_value(arg1,CHECKitem) then
    reaper.SetMediaItemSelected(CHECKitem, true)
    else
    reaper.SetMediaItemSelected(CHECKitem, false)
    end
  end
end


local function find_location(tbl, value_to_find)
    for i, v in ipairs(tbl) do
        if v == value_to_find then
            return i -- Return the index if the value is found
        end
    end
    return nil -- Return nil if the value is not found
end

function clean_nils(tbl)
    local ans = {}
    for _, v in pairs(tbl) do
        if v ~= nil then -- Check if the value is not nil (i.e., not an "empty entry")
            ans[#ans + 1] = v -- Append non-nil value to the new array
        end
    end
    return ans
end


function doActionForAllClusters()
initSelItems = storeSelItems()
savedSelItems = storeSelItems()  -- Save the Items Selected At Init.
local i = 0 -- initial item to check for clusters
while true do

local itemClusterItems = getClusterForItemNo(i) -- creates an array of all the items in the cluster of Item I

selItemsFromArray( itemClusterItems ) -- Selects the items from that array. Deselects all other items

-- remove items from pool if their cluster has already been actioned.
  for n = 0, reaper.CountMediaItems()-1 do
    local CHECKitem = reaper.GetMediaItem(0,n)
    if has_value(itemClusterItems, CHECKitem)  then
    local LOCATION = find_location(savedSelItems,CHECKitem)
    table.remove(savedSelItems, LOCATION)
    end
  end
  
actionsForCluster()  -- Runs actions at top of script.
-- CLUSTER PROCESSED.

  
itemClusterItems = {} -- resets ItemClusterItems List

selItemsFromArray( savedSelItems ) -- Select Items, but with already processed clusters removed.

  if #savedSelItems == 0 then 
  reaper.MB("All Clusters Processed","Do Action for Clusters",0)
  break -- If No more Items from Init Selection to be processed, end the function.
  else 
  --if reaper.CountSelectedMediaItems(0) == 0 then break -- BREAKS OUT OF LOOP ONCE ALL SEL ITEMS PROCESSED
  

  for n = 0, reaper.CountMediaItems()-1 do
    local CHECKitem = reaper.GetMediaItem(0,n)
        if CHECKitem == savedSelItems[1] then
          i = n
        end
  end



  --i = 1
  
  end

  if reaper.CountSelectedMediaItems(0) == 0 then 
    break
  end

end -- END OF WHILE LOOP

-- after processing reselect initial items
selItemsFromArray( initSelItems )
end 


if reaper.CountSelectedMediaItems(0) == 0 then 

reaper.MB("You have No Items Selected!","WHOOPSIE DAISY!",0) else

reaper.Undo_BeginBlock()

doActionForAllClusters()

reaper.UpdateArrange()

reaper.Undo_EndBlock("Processed Clusters: "..DescribeYourAction, -1)

end

-- ewan says GOODBYE! :n)

