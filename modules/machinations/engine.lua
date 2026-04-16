-- Headless simulation skeleton for Machinations-like diagrams.
local Loader = require("modules.machinations.loader")
local State = require("modules.machinations.state")
local types = require("modules.machinations.types")

local Engine = {}

local function should_fire(node, tick)
  if node.trigger == types.TRIGGER.ON_START then
    return tick == 1
  end
  if node.trigger == types.TRIGGER.ON_TICK then
    return true
  end
  if node.trigger == types.TRIGGER.ON_EMPTY then
    return (node.tokens or 0) <= 0
  end
  if node.trigger == types.TRIGGER.ON_FULL then
    return node.capacity ~= nil and (node.tokens or 0) >= node.capacity
  end
  return false
end

-- Evaluate which nodes are active for the current tick.
function Engine.evaluate_triggers(state)
  local fired = {}

  for _, node_id in ipairs(state.node_order or {}) do
    local node = state.nodes[node_id]
    node.active = node ~= nil and should_fire(node, state.tick)
    if node.active then
      fired[#fired + 1] = node_id
    end
  end

  return fired
end

local function apply_delta(state, node_id, delta)
  local node = state.nodes[node_id]
  if not node or delta == 0 then
    return
  end
  node.tokens = (node.tokens or 0) + delta
end

-- Move tokens using a snapshot of the starting tick state.
function Engine.transfer(state, fired_nodes)
  local active = {}
  local starting_tokens = {}
  local projected_tokens = {}
  local deltas = {}
  local log = {}

  for _, node_id in ipairs(state.node_order or {}) do
    active[node_id] = false
  end

  for _, node_id in ipairs(fired_nodes or {}) do
    active[node_id] = true
  end

  for node_id, node in pairs(state.nodes or {}) do
    starting_tokens[node_id] = node.tokens or 0
    projected_tokens[node_id] = starting_tokens[node_id]
  end

  local total_transferred = 0
  for _, source_id in ipairs(state.node_order or {}) do
    if active[source_id] then
      local source_start = starting_tokens[source_id] or 0
      local available = source_start
      local outgoing = state.outbound[source_id] or {}

      for _, connection in ipairs(outgoing) do
        if available <= 0 then
          break
        end

        local target_id = connection.to
        local target_start = projected_tokens[target_id]
        if target_start ~= nil then
          local request = math.min(available, connection.weight or 1)
          local room = request

          local target_node = state.nodes[target_id]
          if target_node and target_node.capacity ~= nil then
            room = math.max(target_node.capacity - target_start, 0)
          end

          local accepted = math.min(request, room)
          if accepted > 0 then
            available = available - accepted
            projected_tokens[target_id] = target_start + accepted
            deltas[source_id] = (deltas[source_id] or 0) - accepted
            deltas[target_id] = (deltas[target_id] or 0) + accepted
            total_transferred = total_transferred + accepted
            log[#log + 1] = {
              from = source_id,
              to = target_id,
              amount = accepted,
              connection_id = connection.id,
            }
          end
        end
      end
    end
  end

  for node_id, delta in pairs(deltas) do
    apply_delta(state, node_id, delta)
  end

  state.transfers_last_tick = total_transferred
  state.last_transfer_log = log
  return total_transferred, log
end

-- Check the minimal end conditions supported by the scaffold.
function Engine.check_end_conditions(state)
  local end_cfg = state.diagram["end"] or {}

  if end_cfg.max_ticks ~= nil and state.tick >= end_cfg.max_ticks then
    state.ended = true
    state.end_reason = "max_ticks"
    return true
  end

  if end_cfg.stop_when_idle and state.transfers_last_tick == 0 then
    state.ended = true
    state.end_reason = "idle"
    return true
  end

  return false
end

-- Create a runtime state from a raw diagram table.
function Engine.init(diagram, options)
  local normalized, err = Loader.load(diagram)
  if not normalized then
    return nil, err
  end

  return State.new(normalized, options)
end

-- Advance one tick: init -> trigger eval -> transfer -> end check.
function Engine.step(state)
  if not state then
    return nil, "state is required"
  end

  if state.ended then
    return state, {
      tick = state.tick,
      fired = {},
      transfers = 0,
      ended = true,
      reason = state.end_reason,
    }
  end

  state.tick = state.tick + 1

  local fired = Engine.evaluate_triggers(state)
  local transfers = Engine.transfer(state, fired)
  Engine.check_end_conditions(state)

  local summary = {
    tick = state.tick,
    fired = fired,
    transfers = transfers,
    ended = state.ended,
    reason = state.end_reason,
  }

  state.history[#state.history + 1] = summary
  return state, summary
end

-- Run until the simulation ends or an optional step limit is reached.
function Engine.run(state, limit)
  local steps = 0
  while state and not state.ended do
    Engine.step(state)
    steps = steps + 1
    if limit ~= nil and steps >= limit then
      break
    end
  end
  return state, steps
end

return Engine
