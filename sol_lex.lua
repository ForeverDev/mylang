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
    c.data = chunk
    if chunk == "\n" then
      c.typeof = "NEWLINE"
      c.data = ""
    elseif chunk == "(" then
      c.typeof = "OPEN_PARENTHESIS"
    elseif chunk == ")" then
      c.typeof = "CLOSE_PARENTHESIS"
    elseif chunk == ":" then
      c.typeof = "COLON"
    elseif chunk == "," then
      c.typeof = "COMMA"
    elseif chunk == "end" then
      c.typeof = "END"
    elseif chunk == "func" then
      c.typeof = "DEF_FUNCTION"
    elseif datatypes[chunk] then
      c.typeof = "DATATYPE"
    else
      c.typeof = "IDENTIFIER"
    end
    table.insert(tokens, c)
  end

  function self.GenerateTokens()
    source = (source .. " "):gsub("//.-\n", "")
    length = source:len()
    local cnode = ""
    while space() do
      local c = char()
      if c:match("%p") then
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
        process_chunk(c)
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

  return self

end

return Lexer
