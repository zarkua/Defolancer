-- Validate and normalize a minimal diagram table.
local types = require("modules.machinations.types")

local Loader = {}

local function make_set(values)
  local set = {}
  for _, value in pairs(values) do
    set[value] = true
  end
  return set
end

local node_types = make_set(types.NODE)
local connection_types = make_set(types.CONNECTION)
local trigger_types = make_set(types.TRIGGER)
local play_modes = make_set(types.PLAY_MODE)

local function as_integer(value, field_name, minimum)
  if value == nil then
    return nil
  end

  if type(value) ~= "number" or value ~= math.floor(value) then
    return nil, field_name .. " must be an integer"
  end

  if minimum ~= nil and value < minimum then
    return nil, field_name .. " must be >= " .. tostring(minimum)
  end

  return value
end

local function copy_node(node, index)
  local id = node.id
  if type(id) ~= "string" or id == "" then
    return nil, "node #" .. tostring(index) .. " needs a non-empty id"
  end

  local node_type = node.type or types.NODE.POOL
  if not node_types[node_type] then
    return nil, "node " .. id .. " has an unsupported type: " .. tostring(node_type)
  end

  local trigger = node.trigger or types.TRIGGER.NONE
  if not trigger_types[trigger] then
    return nil, "node " .. id .. " has an unsupported trigger: " .. tostring(trigger)
  end

  local initial_tokens, err = as_integer(node.initial_tokens or 0, "node " .. id .. ".initial_tokens", 0)
  if not initial_tokens then
    return nil, err
  end

  local capacity, capacity_err = as_integer(node.capacity, "node " .. id .. ".capacity", 0)
  if not capacity and node.capacity ~= nil then
    return nil, capacity_err
  end

  return {
    id = id,
    type = node_type,
    trigger = trigger,
    initial_tokens = initial_tokens or 0,
    capacity = capacity,
    data = type(node.data) == "table" and node.data or {},
  }
end

local function copy_connection(connection, index, node_lookup)
  local from = connection.from
  local to = connection.to
  if type(from) ~= "string" or from == "" then
    return nil, "connection #" .. tostring(index) .. " needs a valid `from` id"
  end
  if type(to) ~= "string" or to == "" then
    return nil, "connection #" .. tostring(index) .. " needs a valid `to` id"
  end
  if not node_lookup[from] then
    return nil, "connection #" .. tostring(index) .. " references unknown source node: " .. from
  end
  if not node_lookup[to] then
    return nil, "connection #" .. tostring(index) .. " references unknown target node: " .. to
  end

  local connection_type = connection.type or types.CONNECTION.NORMAL
  if not connection_types[connection_type] then
    return nil, "connection #" .. tostring(index) .. " has an unsupported type: " .. tostring(connection_type)
  end

  local weight, weight_err = as_integer(connection.weight or 1, "connection #" .. tostring(index) .. ".weight", 1)
  if not weight then
    return nil, weight_err
  end

  return {
    id = connection.id,
    from = from,
    to = to,
    type = connection_type,
    weight = weight or 1,
    data = type(connection.data) == "table" and connection.data or {},
  }
end

-- Load a raw diagram table and return a normalized copy.
function Loader.validate(diagram)
  if type(diagram) ~= "table" then
    return nil, "diagram must be a table"
  end

  local play_mode = diagram.play_mode or types.PLAY_MODE.HEADLESS
  if not play_modes[play_mode] then
    return nil, "diagram.play_mode has an unsupported value: " .. tostring(play_mode)
  end

  local normalized = {
    name = diagram.name,
    description = diagram.description,
    seed = tonumber(diagram.seed),
    play_mode = play_mode,
    nodes = {},
    connections = {},
    end_conditions = {},
  }

  if diagram.nodes ~= nil and type(diagram.nodes) ~= "table" then
    return nil, "diagram.nodes must be an array"
  end

  local node_lookup = {}
  for index, node in ipairs(diagram.nodes or {}) do
    if type(node) ~= "table" then
      return nil, "node #" .. tostring(index) .. " must be a table"
    end

    local copy, err = copy_node(node, index)
    if not copy then
      return nil, err
    end

    if node_lookup[copy.id] then
      return nil, "duplicate node id: " .. copy.id
    end

    node_lookup[copy.id] = true
    normalized.nodes[#normalized.nodes + 1] = copy
  end

  if diagram.connections ~= nil and type(diagram.connections) ~= "table" then
    return nil, "diagram.connections must be an array"
  end

  for index, connection in ipairs(diagram.connections or {}) do
    if type(connection) ~= "table" then
      return nil, "connection #" .. tostring(index) .. " must be a table"
    end

    local copy, err = copy_connection(connection, index, node_lookup)
    if not copy then
      return nil, err
    end

    normalized.connections[#normalized.connections + 1] = copy
  end

  local end_cfg = diagram["end"] or diagram.end_conditions or {}
  if type(end_cfg) ~= "table" then
    return nil, "diagram.end must be a table if present"
  end

  local max_ticks, max_ticks_err = as_integer(end_cfg.max_ticks, "diagram.end.max_ticks", 1)
  if not max_ticks and end_cfg.max_ticks ~= nil then
    return nil, max_ticks_err
  end

  normalized["end"] = {
    max_ticks = max_ticks,
    stop_when_idle = end_cfg.stop_when_idle == true,
  }

  return normalized
end

function Loader.load(diagram)
  return Loader.validate(diagram)
end

return Loader
