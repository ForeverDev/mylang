local Lexer = {}

function Lexer.new(source)

  local self = {}

  local tokens = {}
  local index = 0
  local source = source
  local length = source:len()

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
    print(chunk)
    return chunk
  end

  function self.GenerateTokens()
    source = (source .. " "):gsub("//.-\n", "")
    length = source:len()
    local cnode = ""
    while space() do
      local c = char()
      if c ~= " " and c ~= "\n" then
        cnode = cnode .. c
      else
        table.insert(tokens, process_chunk(cnode))
        cnode = ""
      end
      inc()
    end
  end

  return self

end

return Lexer
