local Interpreter = {}

function Interpreter.new(bytecode, storage)

  local self = {}

  self.bytecode = bytecode
  self.memory = {}
  self.datatypes = {
    int = 4;
    float = 8;
    char = 1;
  }
  local storage = storage
  local memory_end_pointer = 1

  for i = 1, storage do
    self.memory[i] = {
      filled = false;
      datatype = nil;
      pointer_index = nil;
      is_head = nil;
    }
    for j = 1, 8 do
      self.memory[i][j] = 0
    end
  end

  -- converts a binary string to base 10
  local function b2tob10(binary)
    local sum = 0
    for i = 1, binary:len() - 1 do
      sum = sum + math.pow(2, i - 1)*tonumber(binary:sub(i, i))
    end
    if binary:sub(-1, -1) == "1" then
      sum = -sum
    end
    return sum
  end

  -- converts a base 10 number to a binary string
  local function b10tob2(number)
    local t = {}
    local rest;
    while number > 0 do
      rest = number % 2
      table.insert(t, 1, rest)
      number = (number - rest)/2
    end
    return table.concat(t):reverse()
  end

  -- converts a memory range to a string
  local function b2tos(start, size)
    local binary = ""
    for i = start, start + size - 1 do
      for j = 1, 8 do
        binary = binary .. tostring(self.memory[i][j])
      end
    end
    return binary
  end

  function self.Throw(err, line)
    error(string.format("ERROR:\n\tWHAT:%s\n\tWHERE:line %d\n", err, line or 0))
  end

  function self.SizeOf(datatype)
    return self.datatypes[datatype]
  end

  function self.AllocateMemory(datatype, size)
    local index = 1
    local bytes = size
    while index < storage do
      local found_chunk = true
      for i = 0, bytes - 1 do
        local byte = self.memory[index + i]
        if byte.filled then
          index = index + i + 1
          found_chunk = false
          break
        end
      end
      if found_chunk then
        for i = index, index + bytes do
          self.memory[i].filled = true
          self.memory[i].pointer_index = i - index + 1
          self.memory[i].datatype = datatype
        end
        self.memory[index].is_head = true
        return index
      end
      index = index + 1
    end
    self.Throw("couldn't allocate " .. bytes .. " of memory", nil)
  end

  function self.Dereference(pointer, manual_sizeof)
    if pointer > storage then
      self.Throw("attempt to dereference out-of-bounds pointer '" .. pointer .. "'", nil)
    end
    local start_byte = self.memory[pointer]
    local size = self.SizeOf(start_byte.datatype) or manual_sizeof
    local bytes = {}
    for i = 1, size do
      table.insert(bytes, self.memory[pointer + i - 1])
    end
    if start_byte.datatype == "int" then
      local binary = ""
      for i, v in ipairs(bytes) do
        for j = 1, 8 do
          binary = binary .. tostring(v[j])
        end
      end
      return b2tob10(binary)
    elseif start_byte.datatype == "string" then
      local str = ""
      for i, v in ipairs(bytes) do
        str = str .. string.char(b2tob10(table.concat(v)))
      end
      return str
    end
  end

  function self.WriteData(datatype, pointer, binary_byte)
    binary_byte = tostring(binary_byte)
    if pointer > storage then
      self.Throw("attempt to write to out-of-bounds pointer '" .. pointer .. "'", nil)
    end
    local p = pointer
    local byte_index = 0
    for i = 1, binary_byte:len() do
      self.memory[pointer + byte_index][i - byte_index*8] = binary_byte:sub(i, i)
      self.memory[pointer].datatype = datatype
      if i % 8 == 0 then
        p = p + 1
        byte_index = byte_index + 1
      end
    end
  end

  function self.GetRawData(pointer, size, spacing)
    local binary = b2tos(pointer, size)
    if spacing then
      binary = binary:gsub("(........)", "%1 ")
    end
    return binary
  end

  function self.AllocString(str)
    local pointer = self.AllocateMemory("string", str:len())
    for i = 1, str:len() do
      self.WriteData("string", pointer + i - 1, b10tob2(string.byte(str:sub(i, i))), false)
    end
    return pointer
  end

  function self.PrintAllRawData()
    for i, v in ipairs(self.memory) do
      print(table.concat(v))
    end
  end

  return self

end

return function(bytecode, memory)
  local interp = Interpreter.new(bytecode, 100)

  -- strings to store
  local strs = {
    "Hello, World!",
    "This is an example of pushing multiple strings",
    "into the memory of Sol!",
  }
  -- a table that contains the memory locations of strs
  local stack = {}

  for i, v in ipairs(strs) do
    table.insert(stack, interp.AllocString(v))
  end

  for i, v in ipairs(stack) do
    print(interp.Dereference(v, string.len(strs[i])))
  end

  print("Sol's memory: \n")
  interp.PrintAllRawData()
end





