-- this is where .sol files are interpreted
-- note that the global variable _SRC contains
-- the contents of the .sol file that is being
-- interpreted (It is set globally via sol.c)

local function main()

  local memory = {}

  -- creates 1,000,000 bytes of memory in 'memory'
  -- note that it is stored in a 2d array, in the form of:
  --  {{0,0,0,0,0,0,0,0}, {0,0,0,0,0,0,0,0}, ...}
  for i = 1, 1e6 do
    memory[i] = {}
    for j = 1, 8 do
      memory[i][j] = 0
    end
  end

  -- parse the _SRC contents and load the interpreter
  local bytecode = dofile("sol_parse.lua")(_SRC)
  local interpreter = dofile("sol_interpret.lua")

  -- pass bytecode to interpreter
  interpreter(bytecode)

end

main()
