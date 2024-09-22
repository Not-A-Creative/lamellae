-- lamellae: a music box inspired 
-- generative instrument

engine.name = "PolyPerc"

SCREEN_REFRESH_RATE = 15

KEY_DISPLAY_HEIGHT = 54
KEY_DISPLAY_PADDING = (64 - KEY_DISPLAY_HEIGHT) / 2

DRUM_DISPLAY_START_X = 28

NOTE_DISPLAY_SIZE = 2


drum = {{key = 1, x = 30}, {key = 3, x = 64}, {key = 5, x = 64}} -- for testing, initalise blank normally
num_of_keys = 18

screen_dirty = false


function init()
  screen.aa(1)
  screen.level(15)
  
  params:add{type = "number", id = "drum_length", name = "Drum Length", min = 1, max = 10, default = 2}
  
  params:add_separator("engine_controls", "Engine")
  
  params:add{type = "control", id = "amp", name = "Amp", controlspec = controlspec.def{min = 0, max = 1, warp = "lin", step = 0.1, default = 0.8, quantum = 0.1}, action = function(x) engine.amp(x) end}
  
  params:add{type = "control", id = "cutoff", name = "Filter Cutoff", controlspec = controlspec.def{min = 20, max = 20000, warp = "exp", default = 20000, step = 10, units = "hz", wrap = false}, action = function(x) engine.cutoff(x) end}
  
  params:add{type = "control", id = "pan", name = "Pan", controlspec = controlspec.PAN, action = function(x) engine.pan(x) end}
  
  params:add{type = "control", id = "pw", name = "Pulse Width", controlspec = controlspec.def{min = 0, max = 1, warp = "lin", default = 0.5, step = 0.01}, action = function(x) engine.pw(x) end}
  
  params:add{type = "control", id = "release", name = "Release", controlspec = controlspec.def{min = 0.1, max = 10, default = 2.5, warp = "lin", step = 0.1, units = "s"}, action = function(x) engine.release(x) end}


  -- METROS
  screen_refresh = metro.init(refresh)
  screen_refresh:start(1/SCREEN_REFRESH_RATE)
end


function redraw()
  screen.clear()
  -- draw notes
  for _,note in ipairs(drum) do
    local x = note.x
    local y = ((KEY_DISPLAY_HEIGHT / num_of_keys) * note.key) + KEY_DISPLAY_PADDING
    
    screen.rect(x, y, NOTE_DISPLAY_SIZE, NOTE_DISPLAY_SIZE)
    screen.fill()
  end
  screen.update()
end


function enc(n,d)
  if n == 3 then
    for _,note in ipairs(drum) do
      note.x = util.wrap(note.x + d, DRUM_DISPLAY_START_X, (128 * params:get("drum_length")))
    end
    screen_dirty = true
  end
end


function refresh()
  if screen_dirty then
    redraw()
  end
end
