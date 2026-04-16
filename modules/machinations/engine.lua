-- Headless simulation kernel for Machinations-like diagrams.
local Loader = require("modules.machinations.loader")
local Rng = require("modules.machinations.rng")
local State = require("modules.machinations.state")
local types = require("modules.machinations.types")

local Engine = {}

local function clamp_integer(value)
	value = math.floor(tonumber(value) or 0)
	if value < 0 then
		return 0
	end
	return value
end

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

local function read_node_field(node, field)
	if field == types.STATE_FIELD.REGISTER then
		return node.register_value
	end
	return node.resources
end

local function compare_values(left, comparator, right)
	if comparator == types.COMPARATOR.GREATER then
		return left > right
	end
	if comparator == types.COMPARATOR.GREATER_OR_EQUAL then
		return left >= right
	end
	if comparator == types.COMPARATOR.LESS then
		return left < right
	end
	if comparator == types.COMPARATOR.LESS_OR_EQUAL then
		return left <= right
	end
	if comparator == types.COMPARATOR.EQUAL then
		return left == right
	end
	if comparator == types.COMPARATOR.NOT_EQUAL then
		return left ~= right
	end
	return false
end

local function reset_tick_counters(state)
	for _, node_id in ipairs(state.node_order) do
		local node = state.nodes[node_id]
		node.active = false
		node.outgoing_last_tick = 0
		node.consumed_last_tick = 0
		node.last_generated = 0
	end
end

local function add_transfer_log(log, entry)
	log[#log + 1] = entry
end

local function deliver_resource(state, target_id, amount, incoming_bucket)
	local target_node = state.nodes[target_id]
	local accepted = clamp_integer(amount)
	if accepted <= 0 then
		return 0
	end

	if target_node.type == types.NODE.DRAIN then
		target_node.consumed_last_tick = target_node.consumed_last_tick + accepted
		state.metrics.drained_total = state.metrics.drained_total + accepted
		incoming_bucket[target_id] = incoming_bucket[target_id] + accepted
		return accepted
	end

	if target_node.type == types.NODE.REGISTER then
		target_node.register_value = target_node.register_value + accepted
		incoming_bucket[target_id] = incoming_bucket[target_id] + accepted
		return accepted
	end

	if target_node.capacity ~= nil then
		local room = target_node.capacity - target_node.resources
		accepted = math.min(accepted, math.max(room, 0))
	end

	if accepted <= 0 then
		return 0
	end

	target_node.resources = target_node.resources + accepted
	incoming_bucket[target_id] = incoming_bucket[target_id] + accepted
	return accepted
end

local function queue_transfer(state, connection, from_id, amount, deliver_tick)
	state.pending_transfers[#state.pending_transfers + 1] = {
		connection_id = connection.id,
		from = from_id,
		to = connection.to,
		amount = clamp_integer(amount),
		deliver_tick = deliver_tick,
	}
end

local function deliver_due_transfers(state, incoming_current, transfer_log)
	local delivered_total = 0
	local pending_next = {}

	for _, event in ipairs(state.pending_transfers) do
		if event.deliver_tick <= state.tick then
			local accepted = deliver_resource(state, event.to, event.amount, incoming_current)
			if accepted > 0 then
				delivered_total = delivered_total + accepted
				add_transfer_log(transfer_log, {
					tick = state.tick,
					connection_id = event.connection_id,
					from = event.from,
					to = event.to,
					amount = accepted,
					delayed = true,
					deliver_tick = event.deliver_tick,
				})
			end
		else
			pending_next[#pending_next + 1] = event
		end
	end

	state.pending_transfers = pending_next
	return delivered_total
end

local function build_interactive_set(step_options)
	local interactive_set = {}
	local interactive_nodes = step_options and step_options.interactive_nodes or {}
	for _, node_id in ipairs(interactive_nodes) do
		interactive_set[node_id] = true
	end
	return interactive_set
end

local function should_fire_legacy(node, tick)
	local legacy_trigger = node.data.legacy_trigger
	if legacy_trigger == types.TRIGGER.ON_START then
		return tick == 1
	end
	if legacy_trigger == types.TRIGGER.ON_EMPTY then
		return node.resources <= 0
	end
	if legacy_trigger == types.TRIGGER.ON_FULL then
		return node.capacity ~= nil and node.resources >= node.capacity
	end
	return nil
end

local function should_fire_node(node, tick, incoming_current, interactive_set)
	if not node.enabled then
		return false
	end

	local legacy = should_fire_legacy(node, tick)
	if legacy ~= nil then
		return legacy
	end

	local incoming = incoming_current[node.id]
	if node.trigger_mode == types.TRIGGER_MODE.AUTOMATIC then
		return true
	end
	if node.trigger_mode == types.TRIGGER_MODE.INTERACTIVE then
		return interactive_set[node.id] == true
	end
	if node.trigger_mode == types.TRIGGER_MODE.PASSIVE then
		return incoming > 0
	end
	if node.trigger_mode == types.TRIGGER_MODE.ENABLING then
		if node.type == types.NODE.SOURCE then
			return true
		end
		return incoming > 0
	end
	return false
end

-- Evaluate which nodes are active for the current tick.
function Engine.evaluate_triggers(state, incoming_current, interactive_set)
	local fired = {}

	for _, node_id in ipairs(state.node_order) do
		local node = state.nodes[node_id]
		node.active = should_fire_node(node, state.tick, incoming_current, interactive_set)
		if node.active then
			fired[#fired + 1] = node_id
		end
	end

	return fired
end

local function select_gate_connections(state, node, outgoing)
	if #outgoing <= 1 then
		return outgoing
	end

	if node.gate_mode == types.GATE_MODE.ALL then
		return outgoing
	end

	if node.gate_mode == types.GATE_MODE.ROUND_ROBIN then
		local index = node.round_robin_index
		if index > #outgoing then
			index = 1
		end
		node.round_robin_index = index + 1
		if node.round_robin_index > #outgoing then
			node.round_robin_index = 1
		end
		return { outgoing[index] }
	end

	local weights = {}
	for _, connection in ipairs(outgoing) do
		weights[#weights + 1] = connection.weight
	end

	local index = Rng.pick_weighted_index(state.rng, weights)
	if index == nil then
		return {}
	end
	return { outgoing[index] }
end

local function get_outgoing_connections(state, node)
	local outgoing = state.outbound_resource[node.id] or {}
	if node.type ~= types.NODE.GATE then
		return outgoing
	end
	return select_gate_connections(state, node, outgoing)
end

local function get_resource_spend(node, requested_amount)
	if node.type == types.NODE.SOURCE and node.data.finite_source ~= true then
		return 0
	end
	return requested_amount
end

local function get_output_multiplier(node)
	local multiplier = tonumber(node.data.output_multiplier)
	if multiplier == nil then
		multiplier = tonumber(node.data.conversion_ratio)
	end
	if multiplier == nil then
		multiplier = tonumber(node.data.trade_ratio)
	end
	if multiplier == nil then
		multiplier = 1
	end
	return math.max(multiplier, 0)
end

local function get_available_resources(node)
	if node.type == types.NODE.SOURCE and node.data.finite_source ~= true then
		return node.rate
	end
	if node.type == types.NODE.REGISTER then
		return 0
	end
	return node.resources
end

local function consume_node_resources(node, amount)
	local consumed = clamp_integer(amount)
	if consumed <= 0 then
		return
	end
	if node.type == types.NODE.SOURCE and node.data.finite_source ~= true then
		node.last_generated = node.last_generated + consumed
		return
	end
	node.resources = math.max(node.resources - consumed, 0)
end

local function process_drain_node(state, node)
	if node.type ~= types.NODE.DRAIN then
		return
	end
	if node.resources <= 0 then
		return
	end

	local consumed = math.min(node.resources, node.rate)
	if consumed <= 0 then
		return
	end

	node.resources = node.resources - consumed
	node.consumed_last_tick = node.consumed_last_tick + consumed
	state.metrics.drained_total = state.metrics.drained_total + consumed
end

local function process_resource_connections(state, node, incoming_next, transfer_log)
	local outgoing = get_outgoing_connections(state, node)
	if #outgoing == 0 then
		return 0
	end

	local available = get_available_resources(node)
	if available <= 0 then
		return 0
	end

	local output_multiplier = get_output_multiplier(node)
	local transferred_total = 0
	local spent_total = 0

	for _, connection in ipairs(outgoing) do
		if available <= 0 then
			break
		end

		local requested = math.min(available, clamp_integer(connection.amount))
		if requested > 0 then
			local output_amount = requested
			if node.type == types.NODE.CONVERTER or node.type == types.NODE.TRADER then
				output_amount = clamp_integer(math.floor(requested * output_multiplier))
			end

			if output_amount > 0 then
				local connection_delay = clamp_integer(connection.delay_ticks)
				local total_delay = connection_delay + clamp_integer(node.delay_ticks)
				local accepted = 0
				if total_delay > 0 then
					queue_transfer(state, connection, node.id, output_amount, state.tick + total_delay)
					accepted = output_amount
				else
					accepted = deliver_resource(state, connection.to, output_amount, incoming_next)
				end

				if accepted > 0 then
					local spent = get_resource_spend(node, requested)
					spent_total = spent_total + spent
					available = math.max(available - requested, 0)
					transferred_total = transferred_total + accepted
					node.outgoing_last_tick = node.outgoing_last_tick + accepted
					add_transfer_log(transfer_log, {
						tick = state.tick,
						connection_id = connection.id,
						from = node.id,
						to = connection.to,
						amount = accepted,
						delayed = total_delay > 0,
						deliver_tick = total_delay > 0 and (state.tick + total_delay) or state.tick,
					})
				end
			end
		end
	end

	consume_node_resources(node, spent_total)
	return transferred_total
end

local function apply_state_action(source_node, target_node, connection, source_value)
	if connection.action == types.STATE_ACTION.SET_ENABLED then
		target_node.enabled = connection.target_enabled
		return
	end

	if connection.action == types.STATE_ACTION.SET_TRIGGER_MODE then
		if connection.target_trigger_mode ~= nil then
			target_node.trigger_mode = connection.target_trigger_mode
		end
		return
	end

	if connection.action == types.STATE_ACTION.SET_REGISTER then
		local scaled = source_value * connection.scale
		if connection.register_op == "add" then
			target_node.register_value = target_node.register_value + scaled
		else
			target_node.register_value = scaled
		end
	end
end

local function process_state_connections(state, node)
	local outgoing = state.outbound_state[node.id] or {}
	for _, connection in ipairs(outgoing) do
		local source_value = read_node_field(node, connection.source_field)
		if compare_values(source_value, connection.comparator, connection.value) then
			local target_node = state.nodes[connection.to]
			apply_state_action(node, target_node, connection, source_value)
		end
	end
end

-- Move resources for active nodes and collect next-tick incoming counts.
function Engine.transfer(state, fired_nodes)
	local incoming_next = {}
	local transfer_log = {}
	local total_transferred = 0

	for _, node_id in ipairs(state.node_order) do
		incoming_next[node_id] = 0
	end

	for _, node_id in ipairs(fired_nodes) do
		local node = state.nodes[node_id]
		process_drain_node(state, node)
		total_transferred = total_transferred + process_resource_connections(state, node, incoming_next, transfer_log)
	end

	for _, node_id in ipairs(fired_nodes) do
		process_state_connections(state, state.nodes[node_id])
	end

	return total_transferred, transfer_log, incoming_next
end

local function snapshot_metrics(state, summary)
	state.metrics.per_tick[#state.metrics.per_tick + 1] = summary
	for _, node_id in ipairs(state.node_order) do
		local node = state.nodes[node_id]
		local node_history = state.metrics.node_history[node_id]
		node_history.resources[#node_history.resources + 1] = node.resources
		node_history.register[#node_history.register + 1] = node.register_value
	end
end

local function check_conditions(state, end_cfg)
	for _, condition in ipairs(end_cfg.conditions) do
		local node = state.nodes[condition.node_id]
		local current = read_node_field(node, condition.field)
		if compare_values(current, condition.comparator, condition.value) then
			state.ended = true
			state.end_reason = condition.id
			return true
		end
	end
	return false
end

-- Check configured end conditions.
function Engine.check_end_conditions(state)
	local end_cfg = state.diagram["end"] or {}

	if end_cfg.max_ticks ~= nil and state.tick >= end_cfg.max_ticks then
		state.ended = true
		state.end_reason = "max_ticks"
		return true
	end

	if end_cfg.stop_when_idle and state.transfers_last_tick == 0 and #state.pending_transfers == 0 then
		state.ended = true
		state.end_reason = "idle"
		return true
	end

	if check_conditions(state, end_cfg) then
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

-- Advance one tick:
-- deliver delayed resources -> trigger evaluation -> transfers -> end checks.
function Engine.step(state, step_options)
	if not state then
		return nil, "state is required"
	end

	if state.ended then
		return state, {
			tick = state.tick,
			fired = {},
			transfers = 0,
			delivered = 0,
			ended = true,
			reason = state.end_reason,
		}
	end

	state.tick = state.tick + 1
	reset_tick_counters(state)

	local incoming_current = {}
	for _, node_id in ipairs(state.node_order) do
		incoming_current[node_id] = state.nodes[node_id].incoming_last_tick
	end

	local transfer_log = {}
	local delivered = deliver_due_transfers(state, incoming_current, transfer_log)
	local interactive_set = build_interactive_set(step_options)
	local fired = Engine.evaluate_triggers(state, incoming_current, interactive_set)
	local transferred, new_log, incoming_next = Engine.transfer(state, fired)

	for _, entry in ipairs(new_log) do
		add_transfer_log(transfer_log, entry)
	end

	for _, node_id in ipairs(state.node_order) do
		state.nodes[node_id].incoming_last_tick = incoming_next[node_id]
	end

	state.transfers_last_tick = delivered + transferred
	state.metrics.transfers_total = state.metrics.transfers_total + state.transfers_last_tick
	state.last_transfer_log = transfer_log
	Engine.check_end_conditions(state)

	local summary = {
		tick = state.tick,
		fired = copy_table(fired),
		transfers = state.transfers_last_tick,
		delivered = delivered,
		new_transfers = transferred,
		ended = state.ended,
		reason = state.end_reason,
	}

	state.history[#state.history + 1] = summary
	snapshot_metrics(state, summary)
	return state, summary
end

-- Run until simulation ends or an optional step limit is reached.
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

local function ensure_metric_node_ids(result)
	local selected = {}
	for _, node_id in ipairs(result.metric_node_ids) do
		selected[node_id] = true
	end
	return selected
end

local function init_node_aggregate(container, node_id)
	if container[node_id] ~= nil then
		return
	end
	container[node_id] = {
		resources = {
			min = nil,
			max = nil,
			mean = 0,
		},
		register = {
			min = nil,
			max = nil,
			mean = 0,
		},
	}
end

local function update_aggregate_value(bucket, value, run_index)
	if bucket.min == nil or value < bucket.min then
		bucket.min = value
	end
	if bucket.max == nil or value > bucket.max then
		bucket.max = value
	end
	bucket.mean = bucket.mean + (value - bucket.mean) / run_index
end

local function update_run_aggregates(result, state, run_index)
	local selected = ensure_metric_node_ids(result)
	for _, node_id in ipairs(state.node_order) do
		if selected[node_id] then
			local node = state.nodes[node_id]
			init_node_aggregate(result.aggregates.nodes, node_id)
			local aggregate = result.aggregates.nodes[node_id]
			update_aggregate_value(aggregate.resources, node.resources, run_index)
			update_aggregate_value(aggregate.register, node.register_value, run_index)
		end
	end

	local tick_bucket = result.aggregates.ticks
	update_aggregate_value(tick_bucket, state.tick, run_index)
	result.aggregates.end_reasons[state.end_reason or "running"] =
		(result.aggregates.end_reasons[state.end_reason or "running"] or 0) + 1
end

-- Monte-Carlo style batch runner with deterministic seed stepping.
function Engine.run_batch(diagram, options)
	options = options or {}

	local run_count = clamp_integer(options.runs or 100)
	if run_count <= 0 then
		run_count = 1
	end

	local max_ticks = options.max_ticks
	local base_seed = tonumber(options.seed) or tonumber(diagram.seed) or 1
	local metric_node_ids = options.metric_node_ids or {}
	local result = {
		runs = {},
		metric_node_ids = copy_table(metric_node_ids),
		aggregates = {
			nodes = {},
			ticks = {
				min = nil,
				max = nil,
				mean = 0,
			},
			end_reasons = {},
		},
	}

	for run_index = 1, run_count do
		local run_seed = base_seed + run_index - 1
		local state, init_err = Engine.init(diagram, {
			seed = run_seed,
			play_mode = types.PLAY_MODE.BATCH,
		})
		if not state then
			return nil, init_err
		end

		if #result.metric_node_ids == 0 then
			result.metric_node_ids = copy_table(state.node_order)
		end

		Engine.run(state, max_ticks)
		result.runs[#result.runs + 1] = {
			index = run_index,
			seed = run_seed,
			ticks = state.tick,
			end_reason = state.end_reason,
			transfers_total = state.metrics.transfers_total,
			final = copy_table(state.nodes),
		}
		update_run_aggregates(result, state, run_index)
	end

	return result
end

return Engine
