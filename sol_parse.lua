local Parse = {}

function Parse.new(tokens)

  local self = {}

  local tokens = tokens
  local index = 1
  local length = #tokens
  local bytecode = {}

  local function inc()
    index = index + 1
  end

  local function dec()
    index = index - 1
  end

  local function token()
    return tokens[index]
  end

  local function space(i)
    if i then
      return i <= length
    end
    return index <= length
  end

  local function nextline()
    while space() and token().typeof ~= "NEWLINE" do
      inc()
    end
    inc()
  end

  local function throw(message, line)
    print(string.format("ERROR:\n\tMESSAGE: %s\n\tLINE:%d\n", message, line))
  end

  local function peek(start, finish)
    local t = {}
    if finish == "NEWLINE" then
      local i = 0
      while space(index + i) and tokens[index + i].typeof ~= "NEWLINE" do
        table.insert(t, tokens[index + i])
        i = i + 1
      end
      if tokens[index + i].typeof == "NEWLINE" then
        table.insert(t, tokens[index + i])
      end
    else
      for i = start, finish do
        if not space(i) then
          break
        end
        table.insert(t, tokens[index + i])
      end
    end
    return t
  end

  local function matches_grammar(toks, grammar)
    local token_index = 1
    local grammar_index = 1
    while grammar_index <= #grammar and token_index <= #toks do
      if grammar[grammar_index] == "..." then
        grammar_index = grammar_index + 1
        while grammar[grammar_index] ~= toks[token_index].typeof do
          token_index = token_index + 1
          if token_index > #toks then
            return false
          end
        end
      elseif grammar[grammar_index] ~= toks[token_index].typeof then
        return false
      end
      grammar_index = grammar_index + 1
      token_index = token_index + 1
    end
    return true
  end

  local function parse_expression(line, start_index)
    local tree = {}

    return tree
  end

  local function process_statement(current_line)
    local t = token()
    local line = peek(0, "NEWLINE")
    local code = {}
    if #line == 0 or (#line == 1 and line[1].typeof == "NEWLINE") then
      return
    end
    -- function declaration
    if matches_grammar(line, {"DEF_FUNCTION", "IDENTIFIER", "COLON", "...", "NEWLINE"}) then
      code[1] = "DEF_FUNCTION"
      code[2] = line[2].data
      for i = 4, #line - 1 do
        if line[i].typeof ~= "COMMA" then
          table.insert(code, line[i].data)
        end
      end
    -- variable declaration
    elseif matches_grammar(line, {"DATATYPE", "IDENTIFIER", "ASSIGNMENT_OPERATOR", "...", "NEWLINE"}) then
      code[1] = "DEF_VARIABLE"
      code[2] = line[1].data
      code[3] = line[2].data
      -- if the length of the line is equal to 5, we
      -- know that the value being assigned is either
      -- a simple string, array, or number.  It
      -- can easily be parsed
      if #line == 5 then
        code[4] = line[4].data
      else
        --todo parse expression
      end
    elseif matches_grammar(line, {"IDENTIFIER", "OPEN_PARENTHESIS", "...", "CLOSE_PARENTHESIS", "NEWLINE"}) then
      code[1] = "CALL_FUNCTION"
      code[2] = line[1].data
      if #line == 4 then
        -- calling function with no arguments
        code[3] = "NOARGS"
      else
        -- calling function with 1 or more arguments, parse each
        local chunk = {}
        local index = 3

      end
    elseif line[1].typeof == "END" then
      code[1] = "ENDBLOCK"
    elseif line[1].typeof == "IDENTIFIER" then

    else
      throw("Unidentifiable statement", current_line)
    end
    table.insert(bytecode, code)
  end

  function self.GenerateBytecode()
    local line = 1
    while space() do
      process_statement(line)
      nextline()
      line = line + 1
    end
    return bytecode
  end

  function self.PrintBytecode()
    for i, v in pairs(bytecode) do
      for j, k in pairs(v) do
        print(k)
      end
      print("\n")
    end
  end

  return self

end

return Parse
