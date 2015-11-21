-- this is where .sol files are interpreted
-- note that the global variable _SRC contains
-- the contents of the .sol file that is being
-- interpreted (It is set globally via sol.c)

local function main()

  _G.LIB = {}

  local function loadf(f)
    local success, ret = pcall(loadfile(f))
    if not success then
      error(ret)
    end
    return ret
  end

  LIB.Token = loadf("sol_token.lua")
  LIB.Lexer = loadf("sol_lex.lua")
  LIB.Parser = loadf("sol_parse.lua")
  LIB.Interpreter = loadf("sol_interpret.lua")

  local lex = LIB.Lexer.new(_SRC)
  local tokens = lex.GenerateTokens()
  local parser = LIB.Parser.new(tokens)
  local bytecode = parser.GenerateBytecode()
  local interpreter = LIB.Interpreter.new(bytecode)

  --lex.PrintTokens()
  parser.PrintBytecode()

  interpreter.InterpretBytecode()

end

main()
