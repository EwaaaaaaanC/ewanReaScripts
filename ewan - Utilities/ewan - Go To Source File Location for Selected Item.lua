-- @description Go To Source File Location for Selected Item
-- @author ewan
-- @version 1
-- @about
--   Go To Source File Location for Selected Item

-- has SWS dependency
-- In Reaper, you are likely using WAVs, but may have rendered OGGs,
-- With the below variable set to true, the OGG will be opened instead of the WAV.
-- This script is assuming you have adjacent OGG and WAV folders with the respective filetypes within.
openOGG = false
-- the variable below can be set to true to copy the filepath to your clipboard.
copyToClipboard = false

if not reaper.CF_LocateInExplorer then
  reaper.MB("SWS extension is required by this script.\nPlease download it on http://www.sws-extension.org/", "Warning", 0)
end

item = reaper.GetSelectedMediaItem(0,0)
--grabs the first selected media item, so if you select several, you still only navigate to one file location.
take = reaper.GetActiveTake(item)

SOURCE = reaper.GetMediaItemTake_Source(take)
path = reaper.GetMediaSourceFileName(SOURCE)

oggPath = string.gsub(string.gsub(path,".wav",".ogg"),"WAV","OGG")

if openOGG then
path = oggPath
end

if copyToClipboard then
reaper.CF_SetClipboard(path)
end

reaper.CF_LocateInExplorer(path)