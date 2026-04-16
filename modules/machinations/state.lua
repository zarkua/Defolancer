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
	local total_resources = 0

	for _, node in ipairs(diagram_nodes or {}) do
		nodes[node.id] = {
			id = node.id,
			type = node.type,
			trigger_mode = node.trigger_mode,
			resources = node.initial_resources,
			capacity = node.capacity,
			rate = node.rate,
			delay_ticks = node.delay_ticks,
			gate_mode = node.gate_mode,
			register_value = node.register_value,
			enabled = node.enabled,
			data = copy_table(node.data),
			active = false,
			incoming_last_tick = 0,
			outgoing_last_tick = 0,
			consumed_last_tick = 0,
			last_generated = 0,
			round_robin_index = 1,
		}

		order[#order + 1] = node.id
		total_resources = total_resources + node.initial_resources
	end

	return nodes, order, total_resources
end

local function build_connections(diagram_connections)
	local all = {}
	local outbound_resource = {}
	local outbound_state = {}

	for _, connection in ipairs(diagram_connections or {}) do
		local copy = copy_table(connection)
		all[#all + 1] = copy

		if copy.type == types.CONNECTION.RESOURCE then
			outbound_resource[copy.from] = outbound_resource[copy.from] or {}
			outbound_resource[copy.from][#outbound_resource[copy.from] + 1] = copy
		else
			outbound_state[copy.from] = outbound_state[copy.from] or {}
			outbound_state[copy.from][#outbound_state[copy.from] + 1] = copy
		end
	end

	return all, outbound_resource, outbound_state
end

local function build_metrics(node_order)
	local node_history = {}
	for _, node_id in ipairs(node_order) do
		node_history[node_id] = {
			resources = {},
			register = {},
		}
	end

	return {
		transfers_total = 0,
		drained_total = 0,
		per_tick = {},
		node_history = node_history,
		warnings = {},
		errors = {},
	}
end

-- Create a new mutable runtime state.
function State.new(diagram, options)
	options = options or {}

	local nodes, node_order, total_resources = build_nodes(diagram.nodes)
	local connections, outbound_resource, outbound_state = build_connections(diagram.connections)
	local seed = options.seed or diagram.seed

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
		outbound_resource = outbound_resource,
		outbound_state = outbound_state,
		pending_transfers = {},
		variables = copy_table(diagram.variables or {}),
		totals = {
			initial_resources = total_resources,
		},
		transfers_last_tick = 0,
		last_transfer_log = {},
		history = {},
		metrics = build_metrics(node_order),
	}
end

return State
