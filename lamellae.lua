-- Lamellae: 
-- a music box inspired 
-- generative instrument
--
-- KEY2: Play/Stop
-- KEY3: Regenerate pattern
-- ENC2: Play Speed
-- ENC3: Clockwise to play
--
-- Note, scale and engine
-- options in params
--
-- v1.0 @Not_A_Creative
-- Full docs at: 
-- github.com/Not-A-Creative/Lamellae


MusicUtil = require("lib/musicutil")

engine.name = "PolyPerc"


-- CONSTANTS

SCREEN_REFRESH_RATE = 15

NOTE_DISPLAY_SIZE = 2

PATTERN_DISPLAY_START_X = 28

KEY_DISPLAY_HEIGHT = 54
KEY_DISPLAY_PADDING = (64 - KEY_DISPLAY_HEIGHT) / 2
KEY_END_X = PATTERN_DISPLAY_START_X + 1.75
KEY_DISPLAY_LEVEL_DEFAULT = 9
KEY_BASE_THICKNESS = NOTE_DISPLAY_SIZE


-- VARIABLES

screen_dirty = false

is_motor_running = false

pattern = {}

key_sprites = {}

scale_names = {}
for i = 1,#MusicUtil.SCALES do
  table.insert(scale_names, MusicUtil.SCALES[i].name)
end


function init()
  screen.aa(1)
  screen.line_width(1)
  screen.level(15)
  
  -- PARAMS SETUP
  params:add{type = "control", id = "motor_time", name = "Auto Play Speed", controlspec = controlspec.def{min = 0.5, max = 20, default = 5, step = 0.5, quantum = (1 / (2*19.5)), warp = "lin"}, action = function() set_motor_time() end}
  
  params:add_separator("pattern_params", "Pattern Options")
  params:add{type = "number", id = "pattern_length", name = "Pattern Length", min = 1, max = 10, default = 2, action = function() generate_pattern(params:get("num_of_notes")) end}
  params:add{type = "number", id = "num_of_notes", name = "Number of Notes", min = 10, max = 200, default = 50, action = function() generate_pattern(params:get("num_of_notes")) end}
  params:add{type = "trigger", id = "regen", name = "Regenerate Pattern", action = function() generate_pattern(params:get("num_of_notes")) end}
  
  params:add_separator("scale_params", "Keys & Scale")
  params:add{type = "number", id = "num_of_keys", name = "Number of Keys", min = 5, max = 18, default = 18, action = function() create_key_sprites(); generate_pattern(params:get("num_of_notes")) end}
  params:add{type = "number", id = "root_note", name = "Root Note", min = 0, max = 127, default = 60, formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end, action = function() build_scale() end}
  params:add{type = "option", id = "scale", name = "Scale", options = scale_names, default = 11, action = function() build_scale() end}

  params:add_separator("engine_controls", "Engine")
  params:add{type = "control", id = "amp", name = "Amp", controlspec = controlspec.def{min = 0, max = 1, warp = "lin", step = 0.1, default = 0.8, quantum = 0.1}, action = function(x) engine.amp(x) end}
  params:add{type = "control", id = "cutoff", name = "Filter Cutoff", controlspec = controlspec.def{min = 20, max = 20000, warp = "exp", default = 500, step = 10, units = "hz", wrap = false}, action = function(x) engine.cutoff(x) end}
  params:add{type = "control", id = "pan", name = "Pan", controlspec = controlspec.PAN, action = function(x) engine.pan(x) end}
  params:add{type = "control", id = "pw", name = "Pulse Width", controlspec = controlspec.def{min = 0, max = 1, warp = "lin", default = 0.5, step = 0.01}, action = function(x) engine.pw(x) end}
  params:add{type = "control", id = "release", name = "Release", controlspec = controlspec.def{min = 0.1, max = 10, default = 1.5, warp = "lin", step = 0.1, units = "s"}, action = function(x) engine.release(x) end}
  
  
  -- METROS
  screen_refresh = metro.init(refresh)
  screen_refresh:start(1/SCREEN_REFRESH_RATE)
  
  motor = metro.init(motor_tick)
  
  params:bang()
end


function redraw()
  screen.clear()
  screen.level(15)
  
  -- Draw notes
  for _,note in ipairs(pattern) do
    local x = note.x
    local y = calculate_key_y_coord(note.key)
    
    screen.rect(x, y, NOTE_DISPLAY_SIZE, NOTE_DISPLAY_SIZE)
  end
  screen.fill()
  screen.update()
  
  -- Draw comb keys
  for _,key in ipairs(key_sprites) do
    screen.level(key.level)
    screen.move(0, key.y)
    screen.line(key.x, key.y)
    screen.line(key.x, (key.y + KEY_BASE_THICKNESS))
    screen.line(0, key.y)
  
    screen.fill()
    screen.update()
  end
end


function enc(n,d)
  if n == 2 then
    params:delta("motor_time", d)
  end
  
  if n == 3 and d == 1 then
    for _,note in ipairs(pattern) do
      note.x = util.wrap(note.x + d, PATTERN_DISPLAY_START_X, ((128 - PATTERN_DISPLAY_START_X) * params:get("pattern_length")))
      animate_key(note.key, note.x)
      play_note(note)
    end
    screen_dirty = true
  end
end


function key(n,z)
  if n == 2 and z == 1 then
    is_motor_running = not is_motor_running
    run_motor()
  end
  
  if n == 3 and z == 1 then
    generate_pattern(params:get("num_of_notes"))
  end
end


function play_note(note)
  if note.x == PATTERN_DISPLAY_START_X + NOTE_DISPLAY_SIZE then
    engine.hz(key_freq[note.key])
  end
end


function generate_pattern(number_of_notes)
  pattern = {} -- REALLY IMPORTANT TO CLEAR PREVIOUS TABLE!
  
  local number_of_keys = params:get("num_of_keys")
  local start_x = PATTERN_DISPLAY_START_X
  local end_x = (128 - PATTERN_DISPLAY_START_X) * params:get("pattern_length")

  reset_all_key_animations()

  for i = 1,number_of_notes do
    local new_note = {key = math.random(1, number_of_keys), x = math.random(start_x, end_x)}
    
    table.insert(pattern, new_note)
    animate_key(new_note.key, new_note.x)
  end
  screen_dirty = true
end


function run_motor()
  if is_motor_running then
    set_motor_time()
    motor:start()
  else
    motor:stop()
  end
end


function set_motor_time()
  motor.time = 1 / params:get("motor_time")
end


function motor_tick()
  enc(3,1) -- turns ENC3 once
end


function create_key_sprites()
  key_sprites = {} -- Same issue as notes!
  
  for i = 1,params:get("num_of_keys") do
    local coords = {key = i, x = KEY_END_X, y = calculate_key_y_coord(i), level = KEY_DISPLAY_LEVEL_DEFAULT}
    table.insert(key_sprites, coords)
  end
end


function animate_key(key, x)
  if x == PATTERN_DISPLAY_START_X then
    key_sprites[key].x = KEY_END_X - 1.5
    key_sprites[key].level = 15
  elseif x == (PATTERN_DISPLAY_START_X + NOTE_DISPLAY_SIZE) then
    key_sprites[key].x = KEY_END_X
    key_sprites[key].level = KEY_DISPLAY_LEVEL_DEFAULT
  end
end


function reset_all_key_animations()
  for key = 1,#key_sprites do
    key_sprites[key].x = KEY_END_X
    key_sprites[key].level = KEY_DISPLAY_LEVEL_DEFAULT
  end
end


function calculate_key_y_coord(key)
  return math.floor(((KEY_DISPLAY_HEIGHT / params:get("num_of_keys")) * key) + KEY_DISPLAY_PADDING)
end


function build_scale()
  key_nums = MusicUtil.generate_scale_of_length(params:get("root_note"), params:get("scale"), params:get("num_of_keys"))
  key_freq = MusicUtil.note_nums_to_freqs(key_nums)
end


function refresh()
  if screen_dirty then
    redraw()
  end
end
