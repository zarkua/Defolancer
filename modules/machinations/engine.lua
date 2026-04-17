-- Headless simulation kernel for Machinations-like diagrams.
local Loader = require("modules.machinations.loader")
local Rng = require("modules.machinations.rng")
local State = require("modules.machinations.state")
local Expression = require("modules.machinations.expression")
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

local function add_warning(state, code, message, details)
	state.metrics.warnings[#state.metrics.warnings + 1] = {
		tick = state.tick,
		code = code,
		message = message,
		details = details,
	}
end

local function sorted_keys(value)
	local keys = {}
	for key, _ in pairs(value or {}) do
		keys[#keys + 1] = key
	end
	table.sort(keys)
	return keys
end

local function build_expression_context(state, node, extra)
	local context = {}

	for name, value in pairs(state.variables or {}) do
		context[name] = value
		local prefixed = "var_" .. name
		if context[prefixed] == nil then
			context[prefixed] = value
		end
	end

	context.tick = state.tick
	context.transfers_last_tick = state.transfers_last_tick
	context.nodes = state.nodes
	context.variables = state.variables
	context.rng_random = function()
		return Rng.random(state.rng)
	end
	context.rng_random_int = function(min_value, max_value)
		return Rng.random_int(state.rng, min_value, max_value)
	end

	if node ~= nil then
		context.node_id = node.id
		context.node_type = node.type
		context.resources = node.resources
		context.register = node.register_value
		context.incoming = node.incoming_last_tick
		context.outgoing = node.outgoing_last_tick
		context.rate = node.rate
		context.capacity = node.capacity
		context.enabled = node.enabled
	end

	if type(extra) == "table" then
		for key, value in pairs(extra) do
			context[key] = value
		end
	end

	return context
end

local function evaluate_expression_value(state, expression_text, node, extra)
	local value, err = Expression.evaluate(expression_text, build_expression_context(state, node, extra))
	if err ~= nil then
		add_warning(state, "expression_eval_failed", err, {
			expression = expression_text,
			node_id = node and node.id or nil,
		})
		return nil, err
	end
	return value, nil
end

local function evaluate_expression_number(state, expression_text, fallback, node, extra)
	if expression_text == nil then
		return fallback
	end

	local value = nil
	local err = nil
	value, err = evaluate_expression_value(state, expression_text, node, extra)
	if err ~= nil then
		return fallback
	end

	local numeric = tonumber(value)
	if numeric == nil then
		add_warning(state, "expression_non_numeric", "expression returned non-numeric value", {
			expression = expression_text,
			value = tostring(value),
			node_id = node and node.id or nil,
		})
		return fallback
	end

	return numeric
end

local function evaluate_expression_boolean(state, expression_text, default_value, node, extra)
	if expression_text == nil then
		return default_value
	end

	local value = nil
	local err = nil
	value, err = evaluate_expression_value(state, expression_text, node, extra)
	if err ~= nil then
		return default_value
	end

	return value == true
end

local function refresh_variables(state)
	for _, variable_name in ipairs(sorted_keys(state.variable_definitions)) do
		local expression_text = state.variable_definitions[variable_name]
		local value = nil
		local err = nil
		value, err = evaluate_expression_value(state, expression_text, nil, {
			variable_name = variable_name,
		})
		if err == nil and value ~= nil then
			state.variables[variable_name] = value
		end
	end
end

local function apply_dynamic_node_values(state)
	for _, node_id in ipairs(state.node_order) do
		local node = state.nodes[node_id]
		local data = node.data or {}

		local dynamic_rate = evaluate_expression_number(state, data.rate_expression, node.rate, node)
		dynamic_rate = math.max(clamp_integer(dynamic_rate), 1)
		node.rate = dynamic_rate

		local dynamic_delay = evaluate_expression_number(state, data.delay_expression, node.delay_ticks, node)
		dynamic_delay = math.max(clamp_integer(dynamic_delay), 0)
		node.delay_ticks = dynamic_delay

		if data.capacity_expression ~= nil then
			local dynamic_capacity = evaluate_expression_number(state, data.capacity_expression, node.capacity or 0, node)
			dynamic_capacity = math.max(clamp_integer(dynamic_capacity), 0)
			node.capacity = dynamic_capacity
			if node.resources > node.capacity then
				node.resources = node.capacity
			end
		end

		if data.register_expression ~= nil then
			local dynamic_register = evaluate_expression_number(state, data.register_expression, node.register_value, node)
			node.register_value = dynamic_register or node.register_value
		end
	end
end

local function read_node_field(node, field)
	if field == types.STATE_FIELD.REGISTER then
		return node.register_value
	end
	if field == types.STATE_FIELD.INCOMING then
		return node.incoming_last_tick
	end
	if field == types.STATE_FIELD.OUTGOING then
		return node.outgoing_last_tick
	end
	if field == types.STATE_FIELD.TICK then
		return node.tick or 0
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

local current_node_load
local route_to_internal_buffer

local function deliver_resource(state, target_id, amount, incoming_bucket, options)
	options = options or {}
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
		local room = target_node.capacity - current_node_load(target_node)
		accepted = math.min(accepted, math.max(room, 0))
	end

	if accepted <= 0 then
		return 0
	end

	if not options.bypass_internal_buffer then
		local buffered = route_to_internal_buffer(state, target_node, accepted)
		if buffered > 0 then
			return buffered
		end
	end

	target_node.resources = target_node.resources + accepted
	incoming_bucket[target_id] = incoming_bucket[target_id] + accepted
	return accepted
end

local function queue_transfer(state, connection, from_id, amount, deliver_tick, deliver_to)
	state.pending_transfers[#state.pending_transfers + 1] = {
		connection_id = connection.id,
		from = from_id,
		to = deliver_to or connection.to,
		amount = clamp_integer(amount),
		deliver_tick = deliver_tick,
	}
end

current_node_load = function(node)
	local load = node.resources
	if node.type == types.NODE.DELAY or node.type == types.NODE.QUEUE then
		load = load + (node.buffered_total or 0)
	end
	return load
end

local function schedule_internal_buffer(node, amount, release_tick)
	node.buffer_events[#node.buffer_events + 1] = {
		amount = amount,
		release_tick = release_tick,
	}
	node.buffered_total = (node.buffered_total or 0) + amount
end

route_to_internal_buffer = function(state, node, amount)
	local accepted = clamp_integer(amount)
	if accepted <= 0 then
		return 0
	end

	if node.type == types.NODE.DELAY then
		local delay_modifier = tonumber(node.data and node.data.legacy_input_state_value) or 0
		local delay_ticks = math.max(clamp_integer(node.delay_ticks + delay_modifier), 0)
		if delay_ticks <= 0 then
			return 0
		end
		schedule_internal_buffer(node, accepted, state.tick + delay_ticks)
		return accepted
	end

	if node.type == types.NODE.QUEUE then
		local delay_modifier = tonumber(node.data and node.data.legacy_input_state_value) or 0
		local queue_step = math.max(clamp_integer(node.delay_ticks + delay_modifier), 1)
		if node.queue_next_release_tick < state.tick then
			node.queue_next_release_tick = state.tick
		end
		node.queue_next_release_tick = node.queue_next_release_tick + queue_step
		schedule_internal_buffer(node, accepted, node.queue_next_release_tick)
		return accepted
	end

	return 0
end

local function release_internal_buffers(state, incoming_current, transfer_log)
	local released_total = 0

	for _, node_id in ipairs(state.node_order) do
		local node = state.nodes[node_id]
		if node.type == types.NODE.DELAY or node.type == types.NODE.QUEUE then
			local pending = {}
			for _, event in ipairs(node.buffer_events or {}) do
				if event.release_tick <= state.tick then
					local amount = clamp_integer(event.amount)
					if amount > 0 then
						node.resources = node.resources + amount
						node.buffered_total = math.max((node.buffered_total or 0) - amount, 0)
						incoming_current[node_id] = incoming_current[node_id] + amount
						released_total = released_total + amount
						add_transfer_log(transfer_log, {
							tick = state.tick,
							connection_id = "internal:" .. node_id,
							from = node_id,
							to = node_id,
							amount = amount,
							delayed = true,
							deliver_tick = event.release_tick,
							internal_buffer = true,
						})
					end
				else
					pending[#pending + 1] = event
				end
			end
			node.buffer_events = pending
		end
	end

	return released_total
end

local function has_internal_buffer_events(state)
	for _, node_id in ipairs(state.node_order) do
		local node = state.nodes[node_id]
		if node.type == types.NODE.DELAY or node.type == types.NODE.QUEUE then
			if #(node.buffer_events or {}) > 0 then
				return true
			end
		end
	end
	return false
end

local function trim_buffer_to_capacity(node)
	if node.capacity == nil then
		return
	end

	local overflow = current_node_load(node) - node.capacity
	if overflow <= 0 then
		return
	end

	if node.resources > 0 then
		local consume = math.min(node.resources, overflow)
		node.resources = node.resources - consume
		overflow = overflow - consume
	end

	if overflow <= 0 then
		return
	end

	if node.type == types.NODE.DELAY or node.type == types.NODE.QUEUE then
		for index = #node.buffer_events, 1, -1 do
			if overflow <= 0 then
				break
			end

			local event = node.buffer_events[index]
			local amount = clamp_integer(event.amount)
			if amount <= overflow then
				overflow = overflow - amount
				node.buffered_total = math.max((node.buffered_total or 0) - amount, 0)
				table.remove(node.buffer_events, index)
			else
				event.amount = amount - overflow
				node.buffered_total = math.max((node.buffered_total or 0) - overflow, 0)
				overflow = 0
			end
		end
	end
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
	if node.type == types.NODE.END_CONDITION then
		return false
	end

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

local function resolve_graph_numeric_value(state, field_name, fallback)
	local raw = state.diagram and state.diagram[field_name] or nil
	if raw == nil or raw == "" then
		return fallback
	end
	local numeric = tonumber(raw)
	if numeric ~= nil then
		return numeric
	end
	return evaluate_expression_number(state, tostring(raw), fallback, nil, {
		graph_field = field_name,
	})
end

local function resolve_gate_condition_value(state, node)
	local gate_type = string.lower(node.data and node.data.legacy_gate_type or "")
	local modifier = tonumber(node.data and node.data.legacy_input_state_value) or 0

	if gate_type == "deterministic" or gate_type == "" then
		node.register_value = (tonumber(node.register_value) or 0) + 1
		return node.register_value
	end

	local value = 0
	if gate_type == "dice" then
		value = resolve_graph_numeric_value(state, "dice", 0)
	elseif gate_type == "skill" then
		value = resolve_graph_numeric_value(state, "skill", 0)
	elseif gate_type == "strategy" then
		value = resolve_graph_numeric_value(state, "strategy", 0)
	elseif gate_type == "multiplayer" then
		value = resolve_graph_numeric_value(state, "multiplayer", 0)
	else
		value = Rng.random_int(state.rng, 0, 100)
	end

	node.register_value = (tonumber(value) or 0) + modifier
	return node.register_value
end

local function connection_matches_gate_condition(value, connection)
	local data = connection.data or {}
	local kind = data.legacy_gate_label_kind
	if kind == "condition" then
		return compare_values(value, data.gate_condition_comparator, tonumber(data.gate_condition_value) or 0)
	end
	if kind == "range" then
		local min_value = tonumber(data.gate_condition_min) or 0
		local max_value = tonumber(data.gate_condition_max) or 0
		return value >= min_value and value <= max_value
	end
	return false
end

local function has_gate_condition_labels(outgoing)
	for _, connection in ipairs(outgoing) do
		local kind = connection.data and connection.data.legacy_gate_label_kind or nil
		if kind == "condition" or kind == "range" then
			return true
		end
	end
	return false
end

local function build_gate_weights(state, node, outgoing)
	local fixed_weights = {}
	local fixed_sum = 0
	local dynamic_count = 0

	for _, connection in ipairs(outgoing) do
		local kind = connection.data and connection.data.legacy_gate_label_kind or nil
		if kind == "probability_dynamic" then
			dynamic_count = dynamic_count + 1
		else
			local dynamic_weight = evaluate_expression_number(
				state,
				connection.data and connection.data.weight_expression or nil,
				connection.weight,
				node,
				{
					connection_id = connection.id,
					connection_to = connection.to,
				}
			)
			dynamic_weight = math.max(tonumber(dynamic_weight) or 0, 0)
			fixed_weights[#fixed_weights + 1] = dynamic_weight
			fixed_sum = fixed_sum + dynamic_weight
		end
	end

	if dynamic_count <= 0 then
		return fixed_weights
	end

	local remainder = math.max(100 - fixed_sum, 0)
	local dynamic_weight = remainder / dynamic_count
	local weights = {}
	local fixed_index = 1
	for _, connection in ipairs(outgoing) do
		local kind = connection.data and connection.data.legacy_gate_label_kind or nil
		if kind == "probability_dynamic" then
			weights[#weights + 1] = dynamic_weight
		else
			weights[#weights + 1] = fixed_weights[fixed_index]
			fixed_index = fixed_index + 1
		end
	end
	return weights
end

local function select_gate_connections(state, node, outgoing)
	local else_outgoing = {}
	local primary_outgoing = {}

	for _, connection in ipairs(outgoing) do
		if connection.data and connection.data.legacy_gate_label_kind == "else" then
			else_outgoing[#else_outgoing + 1] = connection
		else
			primary_outgoing[#primary_outgoing + 1] = connection
		end
	end

	if #primary_outgoing > 0 then
		outgoing = primary_outgoing
	elseif #else_outgoing > 0 then
		return else_outgoing
	end

	if has_gate_condition_labels(outgoing) then
		local gate_value = resolve_gate_condition_value(state, node)
		local matched = {}
		for _, connection in ipairs(outgoing) do
			if connection_matches_gate_condition(gate_value, connection) then
				matched[#matched + 1] = connection
			end
		end
		if #matched > 0 then
			return matched
		end
		if #else_outgoing > 0 then
			return else_outgoing
		end
		return {}
	end

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

	if node.gate_mode == types.GATE_MODE.RANDOM_ALL then
		local selected = {}
		local fallback_weights = build_gate_weights(state, node, outgoing)

		for index, connection in ipairs(outgoing) do
			local dynamic_weight = math.max(tonumber(fallback_weights[index]) or 0, 0)
			local probability = math.min(dynamic_weight, 100) / 100
			if probability >= 1 or (probability > 0 and Rng.random(state.rng) <= probability) then
				selected[#selected + 1] = connection
			end
		end

		if #selected > 0 then
			return selected
		end

		local fallback_index = Rng.pick_weighted_index(state.rng, fallback_weights)
		if fallback_index ~= nil then
			return { outgoing[fallback_index] }
		end
		if #else_outgoing > 0 then
			return else_outgoing
		end
		return {}
	end

	local weights = build_gate_weights(state, node, outgoing)
	for index, weight in ipairs(weights) do
		weights[index] = math.max(clamp_integer(weight), 0)
	end

	local index = Rng.pick_weighted_index(state.rng, weights)
	if index == nil then
		if #else_outgoing > 0 then
			return else_outgoing
		end
		return {}
	end
	return { outgoing[index] }
end

local function resolve_connection_amount(state, node, connection)
	local dynamic_amount = evaluate_expression_number(
		state,
		connection.data and connection.data.amount_expression or nil,
		connection.amount,
		node,
		{
			connection_id = connection.id,
			connection_to = connection.to,
		}
	)
	return math.max(clamp_integer(dynamic_amount), 0)
end

local function resolve_connection_delay(state, node, connection)
	local dynamic_delay = evaluate_expression_number(
		state,
		connection.data and connection.data.delay_expression or nil,
		connection.delay_ticks,
		node,
		{
			connection_id = connection.id,
			connection_to = connection.to,
		}
	)
	return math.max(clamp_integer(dynamic_delay), 0)
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
		return math.max(node.rate, 0)
	end
	if node.type == types.NODE.REGISTER then
		return 0
	end
	return math.min(math.max(node.resources, 0), math.max(node.rate, 0))
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
	local node_delay = 0
	if node.type ~= types.NODE.DELAY and node.type ~= types.NODE.QUEUE then
		node_delay = clamp_integer(node.delay_ticks)
	end
	local transferred_total = 0
	local spent_total = 0

	for _, connection in ipairs(outgoing) do
		if available <= 0 then
			break
		end

		local connection_amount = resolve_connection_amount(state, node, connection)
		local requested = math.min(available, connection_amount)
		if connection.flow_mode == types.FLOW_MODE.PULL then
			requested = math.min(connection_amount, math.max(node.rate, 0))
			if requested > 0 then
				local supplier = state.nodes[connection.to]
				local supplier_available = get_available_resources(supplier)
				local pulled = math.min(requested, supplier_available)
				if pulled > 0 then
					local connection_delay = resolve_connection_delay(state, node, connection)
					local total_delay = connection_delay + node_delay
					local accepted = 0
					if total_delay > 0 then
						queue_transfer(state, connection, supplier.id, pulled, state.tick + total_delay, node.id)
						accepted = pulled
					else
						accepted = deliver_resource(state, node.id, pulled, incoming_next)
					end

					if accepted > 0 then
						local spent = get_resource_spend(supplier, accepted)
						consume_node_resources(supplier, spent)
						supplier.outgoing_last_tick = supplier.outgoing_last_tick + accepted
						transferred_total = transferred_total + accepted
						node.outgoing_last_tick = node.outgoing_last_tick + accepted
						add_transfer_log(transfer_log, {
							tick = state.tick,
							connection_id = connection.id,
							from = supplier.id,
							to = node.id,
							amount = accepted,
							delayed = total_delay > 0,
							deliver_tick = total_delay > 0 and (state.tick + total_delay) or state.tick,
							flow_mode = types.FLOW_MODE.PULL,
						})
					end
				end
			end
		elseif requested > 0 then
			local output_amount = requested
			if node.type == types.NODE.CONVERTER or node.type == types.NODE.TRADER then
				output_amount = clamp_integer(math.floor(requested * output_multiplier))
			end

			if output_amount > 0 then
				local connection_delay = resolve_connection_delay(state, node, connection)
				local total_delay = connection_delay + node_delay
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
						flow_mode = types.FLOW_MODE.PUSH,
					})
				end
			end
		end
	end

	consume_node_resources(node, spent_total)
	return transferred_total
end

local function apply_state_action(state, source_node, target_node, connection, source_value, scale_value, source_delta)
	local base_value = connection.use_delta and source_delta or source_value
	local scaled = base_value * scale_value
	local legacy_target_modifier = connection.data and connection.data.legacy_target_modifier or nil

	if legacy_target_modifier == "gate_input" or legacy_target_modifier == "delay_input" then
		target_node.data = target_node.data or {}
		target_node.data.legacy_input_state_value = (tonumber(target_node.data.legacy_input_state_value) or 0) + scaled
		return
	end

	if connection.action == types.STATE_ACTION.SET_ENABLED then
		target_node.enabled = connection.target_enabled
		return
	end

	if connection.action == types.STATE_ACTION.TOGGLE_ENABLED then
		target_node.enabled = not target_node.enabled
		return
	end

	if connection.action == types.STATE_ACTION.SET_TRIGGER_MODE then
		if connection.target_trigger_mode ~= nil then
			target_node.trigger_mode = connection.target_trigger_mode
		end
		return
	end

	if connection.action == types.STATE_ACTION.SET_REGISTER then
		if connection.register_op == "add" then
			target_node.register_value = target_node.register_value + scaled
		elseif connection.register_op == "mul" then
			target_node.register_value = target_node.register_value * scaled
		else
			target_node.register_value = scaled
		end
		return
	end

	if connection.action == types.STATE_ACTION.SET_VARIABLE then
		if connection.target_variable == nil or connection.target_variable == "" then
			add_warning(state, "state_connection_missing_variable", "SET_VARIABLE connection requires target_variable", {
				connection_id = connection.id,
			})
			return
		end

		if connection.register_op == "add" then
			state.variables[connection.target_variable] = (tonumber(state.variables[connection.target_variable]) or 0) + scaled
		elseif connection.register_op == "mul" then
			state.variables[connection.target_variable] = (tonumber(state.variables[connection.target_variable]) or 0) * scaled
		else
			state.variables[connection.target_variable] = scaled
		end
		return
	end

	if connection.action == types.STATE_ACTION.SCALE_VARIABLE then
		if connection.target_variable == nil or connection.target_variable == "" then
			add_warning(state, "state_connection_missing_variable", "SCALE_VARIABLE connection requires target_variable", {
				connection_id = connection.id,
			})
			return
		end
		local base_value = tonumber(state.variables[connection.target_variable]) or 0
		state.variables[connection.target_variable] = base_value * scaled
		return
	end

	if connection.action == types.STATE_ACTION.SET_RATE then
		local next_rate = connection.target_rate
		if next_rate == nil then
			if connection.register_op == "add" then
				next_rate = target_node.rate + scaled
			elseif connection.register_op == "mul" then
				next_rate = target_node.rate * scaled
			else
				next_rate = scaled
			end
		end
		target_node.rate = math.max(clamp_integer(next_rate), 1)
		return
	end

	if connection.action == types.STATE_ACTION.SET_CAPACITY then
		local next_capacity = connection.target_capacity
		if next_capacity == nil then
			if connection.register_op == "add" then
				next_capacity = (target_node.capacity or 0) + scaled
			elseif connection.register_op == "mul" then
				next_capacity = (target_node.capacity or 0) * scaled
			else
				next_capacity = scaled
			end
		end
		target_node.capacity = math.max(clamp_integer(next_capacity), 0)
		trim_buffer_to_capacity(target_node)
		return
	end

	if connection.action == types.STATE_ACTION.ADD_RESOURCE then
		local delta = math.floor(tonumber(scaled) or 0)
		if delta == 0 then
			return
		end

		if delta < 0 then
			target_node.resources = math.max((target_node.resources or 0) + delta, 0)
			return
		end

		if target_node.type == types.NODE.DELAY or target_node.type == types.NODE.QUEUE then
			route_to_internal_buffer(state, target_node, delta)
			trim_buffer_to_capacity(target_node)
			return
		end

		if target_node.capacity ~= nil then
			local room = math.max(target_node.capacity - current_node_load(target_node), 0)
			delta = math.min(delta, room)
		end
		if delta > 0 then
			target_node.resources = target_node.resources + delta
		end
	end
end

local function quantize_state_value(value, interval)
	interval = math.max(math.floor(tonumber(interval) or 1), 1)
	if interval <= 1 then
		return tonumber(value) or 0
	end
	return math.floor((tonumber(value) or 0) / interval)
end

local function process_state_connections(state, node)
	local outgoing = state.outbound_state[node.id] or {}
	for _, connection in ipairs(outgoing) do
		local is_enabled = evaluate_expression_boolean(
			state,
			connection.data and connection.data.condition_expression or nil,
			true,
			node,
			{
				connection_id = connection.id,
				connection_to = connection.to,
			}
		)
		if is_enabled then
			local source_value = read_node_field(node, connection.source_field)
			local previous_value = state.state_connection_values[connection.id]
			if previous_value == nil then
				previous_value = source_value
			end
			local legacy_interval = connection.data and connection.data.legacy_interval or nil
			local source_delta = quantize_state_value(source_value, legacy_interval) - quantize_state_value(previous_value, legacy_interval)
			local compare_value = evaluate_expression_number(
				state,
				connection.data and connection.data.value_expression or nil,
				connection.value,
				node,
				{
					connection_id = connection.id,
					connection_to = connection.to,
				}
			)
			local scale_value = evaluate_expression_number(
				state,
				connection.data and connection.data.scale_expression or nil,
				connection.scale,
				node,
				{
					connection_id = connection.id,
					connection_to = connection.to,
				}
			)

			if compare_values(source_value, connection.comparator, compare_value) then
				local target_node = state.nodes[connection.to]
				apply_state_action(state, node, target_node, connection, source_value, scale_value, source_delta)
			elseif connection.data and connection.data.condition_sets_enabled then
				local target_node = state.nodes[connection.to]
				target_node.enabled = false
			end
			state.state_connection_values[connection.id] = source_value
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
	for _, node_id in ipairs(state.node_order) do
		local node = state.nodes[node_id]
		if node.type == types.NODE.END_CONDITION and node.enabled then
			state.ended = true
			state.end_reason = node.data.legacy_caption or node.id
			return true
		end
	end

	for _, condition in ipairs(end_cfg.conditions) do
		if condition.expression ~= nil then
			local matched = evaluate_expression_boolean(
				state,
				condition.expression,
				false,
				nil,
				{
					condition_id = condition.id,
				}
			)
			if matched then
				state.ended = true
				state.end_reason = condition.id
				return true
			end
		else
			local node = state.nodes[condition.node_id]
			local current = read_node_field(node, condition.field)
			if compare_values(current, condition.comparator, condition.value) then
				state.ended = true
				state.end_reason = condition.id
				return true
			end
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

	if end_cfg.stop_when_idle and state.transfers_last_tick == 0 and #state.pending_transfers == 0 and not has_internal_buffer_events(state) then
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
		state.nodes[node_id].tick = state.tick
	end

	local transfer_log = {}
	local delivered = deliver_due_transfers(state, incoming_current, transfer_log)
	delivered = delivered + release_internal_buffers(state, incoming_current, transfer_log)
	refresh_variables(state)
	apply_dynamic_node_values(state)
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

	local function new_bucket()
		return {
			min = nil,
			max = nil,
			mean = 0,
			count = 0,
			m2 = 0,
			variance = 0,
			stddev = 0,
			ci95_low = 0,
			ci95_high = 0,
		}
	end

	container[node_id] = {
		resources = new_bucket(),
		register = new_bucket(),
	}
end

local function update_aggregate_value(bucket, value)
	if bucket.min == nil or value < bucket.min then
		bucket.min = value
	end
	if bucket.max == nil or value > bucket.max then
		bucket.max = value
	end

	bucket.count = (bucket.count or 0) + 1
	local delta = value - bucket.mean
	bucket.mean = bucket.mean + delta / bucket.count
	local delta2 = value - bucket.mean
	bucket.m2 = (bucket.m2 or 0) + delta * delta2
end

local function finalize_aggregate_bucket(bucket)
	local count = bucket.count or 0
	if count <= 1 then
		bucket.variance = 0
		bucket.stddev = 0
		bucket.ci95_low = bucket.mean
		bucket.ci95_high = bucket.mean
		return
	end

	bucket.variance = (bucket.m2 or 0) / (count - 1)
	bucket.stddev = math.sqrt(bucket.variance)
	local standard_error = bucket.stddev / math.sqrt(count)
	local ci = 1.96 * standard_error
	bucket.ci95_low = bucket.mean - ci
	bucket.ci95_high = bucket.mean + ci
end

local function finalize_run_aggregates(result, run_count)
	finalize_aggregate_bucket(result.aggregates.ticks)

	for _, node_id in ipairs(result.metric_node_ids) do
		local node_bucket = result.aggregates.nodes[node_id]
		if node_bucket ~= nil then
			finalize_aggregate_bucket(node_bucket.resources)
			finalize_aggregate_bucket(node_bucket.register)
		end
	end

	local most_likely_reason = nil
	local most_likely_count = 0
	result.aggregates.end_reason_share = {}
	for reason, count in pairs(result.aggregates.end_reasons) do
		local share = 0
		if run_count > 0 then
			share = count / run_count
		end
		result.aggregates.end_reason_share[reason] = share
		if count > most_likely_count then
			most_likely_count = count
			most_likely_reason = reason
		end
	end
	result.aggregates.most_likely_end_reason = most_likely_reason
	result.aggregates.runs_count = run_count
end

local function update_run_aggregates(result, state, run_index)
	local selected = ensure_metric_node_ids(result)
	for _, node_id in ipairs(state.node_order) do
		if selected[node_id] then
			local node = state.nodes[node_id]
			init_node_aggregate(result.aggregates.nodes, node_id)
			local aggregate = result.aggregates.nodes[node_id]
			update_aggregate_value(aggregate.resources, node.resources)
			update_aggregate_value(aggregate.register, node.register_value)
		end
	end

	local tick_bucket = result.aggregates.ticks
	update_aggregate_value(tick_bucket, state.tick)
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
				count = 0,
				m2 = 0,
				variance = 0,
				stddev = 0,
				ci95_low = 0,
				ci95_high = 0,
			},
			end_reasons = {},
			end_reason_share = {},
			most_likely_end_reason = nil,
			runs_count = 0,
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

	finalize_run_aggregates(result, run_count)

	return result
end

return Engine
