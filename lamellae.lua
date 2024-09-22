-- lamellae: a music box inspired generative instrument

engine.name = "PolyPerc"


function init()
  screen.level(15)
  
  
  params:add_separator("engine_controls", "Engine")
  
  params:add{type = "control", id = "amp", name = "Amp", controlspec = controlspec.def{min = 0, max = 1, warp = "lin", step = 0.1, default = 0.8, quantum = 0.1}, action = function(x) engine.amp(x) end}
  
  params:add{type = "control", id = "cutoff", name = "Filter Cutoff", controlspec = controlspec.def{min = 20, max = 20000, warp = "exp", default = 20000, step = 10, units = "hz", wrap = false}, action = function(x) engine.cutoff(x) end}
  
  params:add{type = "control", id = "pan", name = "Pan", controlspec = controlspec.PAN, action = function(x) engine.pan(x) end}
  
  params:add{type = "control", id = "pw", name = "Pulse Width", controlspec = controlspec.def{min = 0, max = 1, warp = "lin", default = 0.5, step = 0.01}, action = function(x) engine.pw(x) end}
  
  params:add{type = "control", id = "release", name = "Release", controlspec = controlspec.def{min = 0.1, max = 10, default = 2.5, warp = "lin", step = 0.1, units = "s"}, action = function(x) engine.release(x) end}

end

