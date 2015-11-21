local Interpreter = {}

function Interpreter.new(bytecode)

  local self = {}

  local code = bytecode
  local functions = {}
  local index = 0
  local blockstart = {
    DEF_FUNCTION = 1;       IF_STATEMENT = 1;
    FOR_LOOP = 1;           WHILE_LOOP = 1;
    SWITCH_CASE = 1;
  }
  local DEBUG = true

  local function inc()
    index = index + 1
  end

  local function dec()
    index = index - 1
  end

  local function jump(i)
    index = i
  end

  local function space(i)
    if i then
      return i <= #bytecode
    end
    return index <= #bytecode
  end

  local function log(f, ...)
    if not DEBUG then
      return
    end
    print(string.format(f, ...))
  end

  local function push_sol_function(name, args, commands)
    functions[name] = {
      name = name;
      args = args;
      commands = commands;
      is_lua_function = false;
    }
    log("push_sol_function '%s' with args %d and with commands %d", name, #args, #commands)
  end

  local function push_lua_function(luafunc, name, args)
    functions[name] = {
      luafunc = luafunc;
      name = name;
      args = args;
      is_lua_function = true;
    }
    log("push_lua_function '%s' with args %d", name, #args)
  end

  local function call_function(fname, fargs)
    local f = functions[fname]
    if f.is_lua_function then
      f.luafunc(unpack(fargs))
    else

    end
  end

  function self.InterpretBytecode()
    for i, v in ipairs(bytecode) do
      if v[1] == "DEF_FUNCTION" then
        local commands = {}
        local args = {}
        for j = 3, #v - 1, 2 do
          table.insert(args, {datatype = v[j], name = v[j + 1]})
        end
        local count = 1
        local ind = i + i
        while space(ind) and count >= 0 do
          if blockstart[v[ind]] then
            count = count + 1
          elseif blockstart[v[ind]] == "ENDBLOCK" then
            count = count - 1
          end
          ind = ind  + 1
        end
        push_sol_function(v[2], args, commands)
      elseif v[1] == "CALL_FUNCTION" then
        if v[3] == "NOARGS" then
          call_function(v[2], {})
        end
      end
      print(v[1])
    end
  end

  do
    push_lua_function(print, "println", {{datatype = "string"}})
    push_lua_function(io.write, "print", {{datatype = "string"}})
  end

  return self

end

return Interpreter
