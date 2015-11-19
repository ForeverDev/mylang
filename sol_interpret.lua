local Interpreter = {}

function Interpreter.new(bytecode, storage)

  local self = {}

  self.bytecode = bytecode
  self.memory = {}
  local storage = storage
  local memory_end_pointer = 1

  for i = 1, storage do
    self.memory[i] = {filled = false}
    for j = 1, 8 do
      self.memory[i][j] = 0
    end
  end

  local function throw(err, line)
    error(string.format("ERROR:\n\tWHAT:%sWHERE:line %d", err, line or 0))
  end

  local function sizeof(datatype)
    return (
      datatype == "int" and 4 or
      datatype == "char" and 1 or
      datatype == "float" and 8 or
      1
    )
  end

  function self.AllocateMemory(bytes)
    local index = 1
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
        end
        return index
      end
      index = index + 1
    end
    throw("couldn't allocate " .. bytes .. " of memory", nil)
  end

  function self.WriteMemory(pointer, byte)
    self.memory[pointer] = byte
  end

  return self

end

return function(bytecode, memory)

  local int = Interpreter.new(bytecode, 1e5)
  local p = int.AllocateMemory(10)
  local p2 = int.AllocateMemory(12)

end





