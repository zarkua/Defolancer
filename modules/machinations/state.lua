-- Build runtime state from a normalized diagram.
local Rng = require("modules.machinations.rng")
local types = require("modules.machinations.types")

local State = {}

local function copy_table(value)
  if type(value) ~= "table" then
    return value
  end

  local out = {}
  for key, item in pairs(value) do
    out[key] = copy_table(item)
  end
  return out
end

local function build_nodes(diagram_nodes)
  local nodes = {}
  local order = {}
  local total_tokens = 0

  for _, node in ipairs(diagram_nodes or {}) do
    nodes[node.id] = {
      id = node.id,
      type = node.type,
      trigger = node.trigger or types.TRIGGER.NONE,
      tokens = node.initial_tokens or 0,
      capacity = node.capacity,
      data = copy_table(node.data or {}),
      active = false,
    }

    order[#order + 1] = node.id
    total_tokens = total_tokens + (node.initial_tokens or 0)
  end

  return nodes, order, total_tokens
end

local function build_outbound(connections)
  local outbound = {}
  local list = {}

  for _, connection in ipairs(connections or {}) do
    local copy = {
      id = connection.id,
      from = connection.from,
      to = connection.to,
      type = connection.type,
      weight = connection.weight or 1,
      data = copy_table(connection.data or {}),
    }

    list[#list + 1] = copy
    outbound[copy.from] = outbound[copy.from] or {}
    outbound[copy.from][#outbound[copy.from] + 1] = copy
  end

  return list, outbound
end

-- Create a new mutable runtime state.
function State.new(diagram, options)
  options = options or {}

  local nodes, node_order, total_tokens = build_nodes(diagram.nodes)
  local connections, outbound = build_outbound(diagram.connections)
  local seed = options.seed
  if seed == nil then
    seed = diagram.seed
  end

  return {
    diagram = diagram,
    options = copy_table(options),
    play_mode = options.play_mode or diagram.play_mode or types.PLAY_MODE.HEADLESS,
    tick = 0,
    ended = false,
    end_reason = nil,
    rng = Rng.new(seed),
    nodes = nodes,
    node_order = node_order,
    connections = connections,
    outbound = outbound,
    totals = {
      initial_tokens = total_tokens,
    },
    transfers_last_tick = 0,
    last_transfer_log = {},
    history = {},
  }
end

return State
