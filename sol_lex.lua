local Lexer = {}

function Lexer.new(source)

  local self = {}

  local tokens = {}
  local index = 0
  local source = source
  local length = source:len()
  local datatypes = {
    ["number"] = 1;     ["string"] = 1;
    ["boolean"] = 1;    ["array"] = 1;
  }

  local function inc()
    index = index + 1
  end

  local function dec()
    index = index - 1
  end

  local function space()
    return index <= length
  end

  local function char()
    return source:sub(index, index)
  end

  local function process_chunk(chunk)
    if (chunk:match("[%s\t]+") or chunk == "") and chunk ~= "\n" then
      return
    end
    local c = {}
    c.typeof = nil
    if chunk == "\n" then
      c.typeof = "NEWLINE"
    elseif tonumber(chunk) then
      c.typeof = "NUMBER"
      c.data = tonumber(chunk)
    elseif chunk:sub(1, 1) == "\"" and chunk:sub(-1, -1) == "\"" then
      c.typeof = "STRING"
      c.data = tostring(chunk)
    elseif chunk == "(" then
      c.typeof = "OPEN_PARENTHESIS"
    elseif chunk == ")" then
      c.typeof = "CLOSE_PARENTHESIS"
    elseif chunk == "{" then
      c.typeof = "OPEN_CURLY"
    elseif chunk == "}" then
      c.typeof = "CLOSE_CURLY"
    elseif chunk == "[" then
      c.typeof = "OPEN_BRACKET"
    elseif chunk == "]" then
      c.typeof = "CLOSE_BRACKET"
    elseif chunk == ":" then
      c.typeof = "COLON"
    elseif chunk == "," then
      c.typeof = "COMMA"
    elseif chunk == "=" then
      inc()
      if char() == "=" then
        c.typeof = "COMPARISON_OPERATOR"
      else
        c.typeof = "ASSIGNMENT_OPERATOR"
        dec()
      end
    elseif chunk == "+" then
      c.typeof = "ADDITION_OPERATOR"
    elseif chunk == "-" then
      c.typeof = "SUBTRACTION_OPERATOR"
    elseif chunk == "*" then
      c.typeof = "ASTERISCK"
    elseif chunk == "/" then
      c.typeof = "DIVISION_OPERATOR"
    elseif chunk == "end" then
      c.typeof = "END"
    elseif chunk == "function" then
      c.typeof = "DEF_FUNCTION"
    elseif datatypes[chunk] then
      c.typeof = "DATATYPE"
      c.data = chunk
    else
      c.typeof = "IDENTIFIER"
      c.data = chunk
    end
    table.insert(tokens, c)
  end

  function self.GenerateTokens()
    local cnode = ""
    while space() do
      local c = char()
      if c == "/" and source:sub(index + 1, index + 1) == "/" then
        while space() and char() ~= "\n" do
          inc()
        end
        table.insert(tokens, {typeof = "NEWLINE"})
      elseif c:match("%p") and c ~= "\"" and cnode:sub(1, 1) ~= "\"" then
        if cnode:len() > 0 then
          process_chunk(cnode)
          cnode = ""
        end
        process_chunk(c)
      elseif c == "\n" then
        if cnode:len() > 0 then
          process_chunk(cnode)
          cnode = ""
        end
        table.insert(tokens, {typeof = "NEWLINE"})
      elseif c ~= " " then
        cnode = cnode .. c
      else
        process_chunk(cnode)
        cnode = ""
      end
      inc()
    end
    return tokens
  end

  function self.PrintTokens()
    for i, v in ipairs(tokens) do
      print(v.typeof, v.data or "")
    end
  end

  return self

end

return Lexer
