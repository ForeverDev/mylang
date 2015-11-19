-- this is where .sol files are interpreted
-- note that the global variable _SRC contains
-- the contents of the .sol file that is being
-- interpreted (It is set globally via sol.c)

local function main()

  local function loadf(f)
    local success, ret = pcall(loadfile(f))
    if not success then
      error(ret)
    end
    return ret
  end

  -- parse the _SRC contents and load the interpreter
  local bytecode = loadf("sol_parse.lua")
  local interpreter = loadf("sol_interpret.lua")

  -- pass bytecode to interpreter
  interpreter(bytecode)

end

main()
