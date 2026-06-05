-- @description New Take Blinker
-- @author ewan
-- @version 1.2
-- @changelog
--    Changed colour to reflect record state.

-- @about
--    Blinks red every time Move To and Loop Item Under Mouse script is used.
--    This lets talent know a new take has started.


--set width and height
w = 150
h = w

posX = 200
posY = 200

gfx.init("NewTake", w, h, 0, posX, posY)

function main()
  -- 1. Reset/Clear the background color
  gfx.clear = 0 -- Color integer (corresponds to a dark gray)
  gfx.mode = 0
  -- 2. Set drawing color: gfx.set(r, g, b, alpha)
  
  playState = reaper.GetPlayState()
  status = reaper.GetExtState("ewanRecordingStatus","status")
  
  if status == "activated" then
  gfx.set(0.3, 1, 0.7, 1) -- Green
  gfx.rect(20, 20, w-40, h-40, 0.8)
  
  else
    if playState == 5 then
    gfx.set(1, 0.6, 0.6, 1) -- Faint Red
    else
    gfx.set(0.6, 0.6, 0.6, 1) -- Grey
    end
  gfx.rect(20, 20, w-40, h-40, 0) 
  end

  -- 5. Keep window alive and catch closure (char 27 = Escape key)
  local char = gfx.getchar()
  if char >= 0 and char ~= 27 then
    reaper.defer(main) -- Loop the function
  else
    gfx.quit() -- Close cleanly
  end
end

-- Start the script loop
main()