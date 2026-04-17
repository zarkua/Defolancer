-- Validate and normalize a Machinations-like diagram table.
local types = require("modules.machinations.types")

local Loader = {}

local function make_set(values)
	local set = {}
	for _, value in pairs(values) do
		set[value] = true
	end
	return set
end

local NODE_TYPES = make_set(types.NODE)
local CONNECTION_TYPES = make_set(types.CONNECTION)
local TRIGGER_MODES = make_set(types.TRIGGER_MODE)
local PLAY_MODES = make_set(types.PLAY_MODE)
local GATE_MODES = make_set(types.GATE_MODE)
local FLOW_MODES = make_set(types.FLOW_MODE)
local STATE_ACTIONS = make_set(types.STATE_ACTION)
local STATE_FIELDS = make_set(types.STATE_FIELD)
local COMPARATORS = make_set(types.COMPARATOR)

local LEGACY_PLAY_MODE_MAP = {
	autoplay = types.PLAY_MODE.INTERACTIVE,
}

local LEGACY_GATE_MODE_MAP = {
	sequential = types.GATE_MODE.ROUND_ROBIN,
	probabilistic = types.GATE_MODE.RANDOM_ALL,
}

local LEGACY_TRIGGER_MAP = {
	[types.TRIGGER.NONE] = {
		mode = types.TRIGGER_MODE.PASSIVE,
	},
	[types.TRIGGER.ON_TICK] = {
		mode = types.TRIGGER_MODE.AUTOMATIC,
	},
	[types.TRIGGER.ON_START] = {
		mode = types.TRIGGER_MODE.AUTOMATIC,
		legacy_rule = types.TRIGGER.ON_START,
	},
	[types.TRIGGER.ON_EMPTY] = {
		mode = types.TRIGGER_MODE.ENABLING,
		legacy_rule = types.TRIGGER.ON_EMPTY,
	},
	[types.TRIGGER.ON_FULL] = {
		mode = types.TRIGGER_MODE.ENABLING,
		legacy_rule = types.TRIGGER.ON_FULL,
	},
}

local LEGACY_CONNECTION_MAP = {
	[types.CONNECTION_LEGACY.NORMAL] = {
		type = types.CONNECTION.RESOURCE,
		delay_ticks = 0,
	},
	[types.CONNECTION_LEGACY.INSTANT] = {
		type = types.CONNECTION.RESOURCE,
		delay_ticks = 0,
	},
	[types.CONNECTION_LEGACY.DELAYED] = {
		type = types.CONNECTION.RESOURCE,
		delay_ticks = 1,
	},
}

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

local function as_number(value, field_name)
	if value == nil then
		return nil
	end

	if type(value) ~= "number" then
		return nil, field_name .. " must be a number"
	end

	return value
end

local function as_string(value, field_name, allow_empty)
	if value == nil then
		return nil
	end

	if type(value) ~= "string" then
		return nil, field_name .. " must be a string"
	end
	if not allow_empty and value == "" then
		return nil, field_name .. " must not be empty"
	end

	return value
end

local function is_array(value)
	if type(value) ~= "table" then
		return false
	end

	for key, _ in pairs(value) do
		if type(key) ~= "number" then
			return false
		end
	end

	return true
end

local function normalize_variables(raw_variables)
	local normalized_values = {}
	local definitions = {}

	if type(raw_variables) ~= "table" then
		return normalized_values, definitions
	end

	if is_array(raw_variables) then
		for index, variable in ipairs(raw_variables) do
			if type(variable) ~= "table" then
				return nil, nil, "variables[" .. tostring(index) .. "] must be a table"
			end

			local name = variable.id or variable.name or variable.key
			local name_err = nil
			name, name_err = as_string(name, "variables[" .. tostring(index) .. "].name")
			if not name then
				return nil, nil, name_err
			end

			if definitions[name] ~= nil then
				return nil, nil, "duplicate variable name: " .. name
			end

			local expression = variable.expression or variable.formula
			if expression ~= nil then
				local expr_err = nil
				expression, expr_err = as_string(expression, "variables[" .. tostring(index) .. "].expression")
				if not expression then
					return nil, nil, expr_err
				end
				definitions[name] = expression
				local default_value = tonumber(variable.default_value)
				if default_value ~= nil then
					normalized_values[name] = default_value
				elseif type(variable.value) == "number" then
					normalized_values[name] = variable.value
				else
					normalized_values[name] = 0
				end
			elseif variable.value ~= nil then
				normalized_values[name] = variable.value
			else
				normalized_values[name] = 0
			end
		end

		return normalized_values, definitions
	end

	for name, value in pairs(raw_variables) do
		if type(name) ~= "string" or name == "" then
			return nil, nil, "variable names must be non-empty strings"
		end

		if type(value) == "table" then
			local expression = value.expression or value.formula
			if expression ~= nil then
				local expr_err = nil
				expression, expr_err = as_string(expression, "variables." .. name .. ".expression")
				if not expression then
					return nil, nil, expr_err
				end
				definitions[name] = expression
				local default_value = tonumber(value.default_value)
				if default_value ~= nil then
					normalized_values[name] = default_value
				elseif type(value.value) == "number" then
					normalized_values[name] = value.value
				else
					normalized_values[name] = 0
				end
			elseif value.value ~= nil then
				normalized_values[name] = value.value
			else
				normalized_values[name] = 0
			end
		else
			normalized_values[name] = value
		end
	end

	return normalized_values, definitions
end

local function normalize_trigger_mode(node, node_id)
	local raw = node.trigger_mode
	if raw == nil then
		raw = node.trigger
	end

	if raw == nil then
		return types.TRIGGER_MODE.PASSIVE, nil
	end

	if TRIGGER_MODES[raw] then
		return raw, nil
	end

	local legacy = LEGACY_TRIGGER_MAP[raw]
	if legacy then
		return legacy.mode, legacy.legacy_rule
	end

	return nil, "node " .. node_id .. " has unsupported trigger_mode: " .. tostring(raw)
end

local function normalize_connection_type(connection, index)
	local raw = connection.type
	if raw == nil then
		raw = connection.connection_type
	end

	if raw == nil then
		return types.CONNECTION.RESOURCE, 0
	end

	if CONNECTION_TYPES[raw] then
		return raw, 0
	end

	local legacy = LEGACY_CONNECTION_MAP[raw]
	if legacy then
		return legacy.type, legacy.delay_ticks
	end

	return nil, "connection #" .. tostring(index) .. " has unsupported type: " .. tostring(raw)
end

local function copy_node(node, index)
	local id = node.id
	if type(id) ~= "string" or id == "" then
		return nil, "node #" .. tostring(index) .. " needs a non-empty id"
	end

	local node_type = node.type or types.NODE.POOL
	if not NODE_TYPES[node_type] then
		return nil, "node " .. id .. " has unsupported type: " .. tostring(node_type)
	end

	local trigger_mode, trigger_error = normalize_trigger_mode(node, id)
	if not trigger_mode then
		return nil, trigger_error
	end

	local initial_resources, initial_resources_err = as_integer(
		node.initial_resources or node.initial_tokens or 0,
		"node " .. id .. ".initial_resources",
		0
	)
	if not initial_resources then
		return nil, initial_resources_err
	end

	local capacity, capacity_err = as_integer(node.capacity, "node " .. id .. ".capacity", 0)
	if node.capacity ~= nil and not capacity then
		return nil, capacity_err
	end

	local rate, rate_err = as_integer(node.rate or 1, "node " .. id .. ".rate", 1)
	if not rate then
		return nil, rate_err
	end

	local default_delay_ticks = 0
	if node_type == types.NODE.DELAY or node_type == types.NODE.QUEUE then
		default_delay_ticks = 1
	end

	local delay_ticks, delay_ticks_err = as_integer(
		node.delay_ticks or default_delay_ticks,
		"node " .. id .. ".delay_ticks",
		0
	)
	if not delay_ticks then
		return nil, delay_ticks_err
	end

	local gate_mode = node.gate_mode or types.GATE_MODE.ALL
	if LEGACY_GATE_MODE_MAP[gate_mode] ~= nil then
		gate_mode = LEGACY_GATE_MODE_MAP[gate_mode]
	end
	if not GATE_MODES[gate_mode] then
		return nil, "node " .. id .. " has unsupported gate_mode: " .. tostring(gate_mode)
	end

	local register_value, register_value_err = as_number(
		node.register_value or node.initial_value or 0,
		"node " .. id .. ".register_value"
	)
	if not register_value then
		return nil, register_value_err
	end

	local data = {}
	if type(node.data) == "table" then
		data = copy_table(node.data)
	end

	local _, legacy_rule = normalize_trigger_mode(node, id)
	if legacy_rule ~= nil then
		data.legacy_trigger = legacy_rule
	end

	if node.finite_source ~= nil then
		data.finite_source = node.finite_source == true
	end

	local rate_expression, rate_expr_err = as_string(node.rate_expression, "node " .. id .. ".rate_expression")
	if node.rate_expression ~= nil and not rate_expression then
		return nil, rate_expr_err
	end
	local delay_expression, delay_expr_err = as_string(node.delay_expression, "node " .. id .. ".delay_expression")
	if node.delay_expression ~= nil and not delay_expression then
		return nil, delay_expr_err
	end
	local capacity_expression, cap_expr_err = as_string(node.capacity_expression, "node " .. id .. ".capacity_expression")
	if node.capacity_expression ~= nil and not capacity_expression then
		return nil, cap_expr_err
	end
	local register_expression, reg_expr_err = as_string(node.register_expression, "node " .. id .. ".register_expression")
	if node.register_expression ~= nil and not register_expression then
		return nil, reg_expr_err
	end

	if rate_expression ~= nil then
		data.rate_expression = rate_expression
	end
	if delay_expression ~= nil then
		data.delay_expression = delay_expression
	end
	if capacity_expression ~= nil then
		data.capacity_expression = capacity_expression
	end
	if register_expression ~= nil then
		data.register_expression = register_expression
	end

	return {
		id = id,
		type = node_type,
		trigger_mode = trigger_mode,
		initial_resources = initial_resources,
		capacity = capacity,
		rate = rate,
		delay_ticks = delay_ticks,
		gate_mode = gate_mode,
		register_value = register_value,
		enabled = node.enabled ~= false,
		data = data,
	}
end

local function copy_resource_connection(connection, index, id, from, to, default_delay_ticks)
	local amount, amount_err = as_integer(
		connection.amount or connection.weight or 1,
		"connection #" .. tostring(index) .. ".amount",
		1
	)
	if not amount then
		return nil, amount_err
	end

	local weight, weight_err = as_integer(connection.weight or 1, "connection #" .. tostring(index) .. ".weight", 0)
	if not weight then
		return nil, weight_err
	end

	local delay_ticks, delay_ticks_err = as_integer(
		connection.delay_ticks or default_delay_ticks or 0,
		"connection #" .. tostring(index) .. ".delay_ticks",
		0
	)
	if not delay_ticks then
		return nil, delay_ticks_err
	end

	local flow_mode = connection.flow_mode or connection.mode or types.FLOW_MODE.PUSH
	if not FLOW_MODES[flow_mode] then
		return nil, "connection #" .. tostring(index) .. ".flow_mode is unsupported: " .. tostring(flow_mode)
	end

	local amount_expression, amount_expr_err = as_string(
		connection.amount_expression,
		"connection #" .. tostring(index) .. ".amount_expression"
	)
	if connection.amount_expression ~= nil and not amount_expression then
		return nil, amount_expr_err
	end

	local weight_expression, weight_expr_err = as_string(
		connection.weight_expression,
		"connection #" .. tostring(index) .. ".weight_expression"
	)
	if connection.weight_expression ~= nil and not weight_expression then
		return nil, weight_expr_err
	end

	local delay_expression, delay_expr_err = as_string(
		connection.delay_expression,
		"connection #" .. tostring(index) .. ".delay_expression"
	)
	if connection.delay_expression ~= nil and not delay_expression then
		return nil, delay_expr_err
	end

	local data = type(connection.data) == "table" and copy_table(connection.data) or {}
	if amount_expression ~= nil then
		data.amount_expression = amount_expression
	end
	if weight_expression ~= nil then
		data.weight_expression = weight_expression
	end
	if delay_expression ~= nil then
		data.delay_expression = delay_expression
	end

	return {
		id = id,
		from = from,
		to = to,
		type = types.CONNECTION.RESOURCE,
		amount = amount,
		weight = weight,
		delay_ticks = delay_ticks,
		flow_mode = flow_mode,
		data = data,
	}
end

local function copy_state_connection(connection, index, id, from, to)
	local action = connection.action or types.STATE_ACTION.SET_ENABLED
	if not STATE_ACTIONS[action] then
		return nil, "connection #" .. tostring(index) .. ".action is unsupported: " .. tostring(action)
	end

	local source_field = connection.source_field or types.STATE_FIELD.RESOURCES
	if not STATE_FIELDS[source_field] then
		return nil, "connection #" .. tostring(index) .. ".source_field is unsupported: " .. tostring(source_field)
	end

	local comparator = connection.comparator or types.COMPARATOR.GREATER
	if not COMPARATORS[comparator] then
		return nil, "connection #" .. tostring(index) .. ".comparator is unsupported: " .. tostring(comparator)
	end

	local value, value_err = as_number(connection.value or 0, "connection #" .. tostring(index) .. ".value")
	if not value then
		return nil, value_err
	end

	local scale, scale_err = as_number(connection.scale or 1, "connection #" .. tostring(index) .. ".scale")
	if not scale then
		return nil, scale_err
	end

	local target_trigger_mode = connection.target_trigger_mode
	if target_trigger_mode ~= nil and not TRIGGER_MODES[target_trigger_mode] then
		return nil, "connection #" .. tostring(index) .. ".target_trigger_mode is unsupported"
	end

	local register_op = connection.register_op or "set"
	if register_op ~= "set" and register_op ~= "add" and register_op ~= "mul" then
		return nil, "connection #" .. tostring(index) .. ".register_op must be `set`, `add` or `mul`"
	end

	local target_rate, target_rate_err = as_number(
		connection.target_rate,
		"connection #" .. tostring(index) .. ".target_rate"
	)
	if connection.target_rate ~= nil and not target_rate then
		return nil, target_rate_err
	end

	local target_capacity, target_capacity_err = as_number(
		connection.target_capacity,
		"connection #" .. tostring(index) .. ".target_capacity"
	)
	if connection.target_capacity ~= nil and not target_capacity then
		return nil, target_capacity_err
	end

	local value_expression, value_expr_err = as_string(
		connection.value_expression,
		"connection #" .. tostring(index) .. ".value_expression"
	)
	if connection.value_expression ~= nil and not value_expression then
		return nil, value_expr_err
	end

	local scale_expression, scale_expr_err = as_string(
		connection.scale_expression,
		"connection #" .. tostring(index) .. ".scale_expression"
	)
	if connection.scale_expression ~= nil and not scale_expression then
		return nil, scale_expr_err
	end

	local condition_expression, condition_expr_err = as_string(
		connection.condition_expression,
		"connection #" .. tostring(index) .. ".condition_expression"
	)
	if connection.condition_expression ~= nil and not condition_expression then
		return nil, condition_expr_err
	end

	local target_variable, target_variable_err = as_string(
		connection.target_variable,
		"connection #" .. tostring(index) .. ".target_variable"
	)
	if connection.target_variable ~= nil and not target_variable then
		return nil, target_variable_err
	end

	local data = type(connection.data) == "table" and copy_table(connection.data) or {}
	if value_expression ~= nil then
		data.value_expression = value_expression
	end
	if scale_expression ~= nil then
		data.scale_expression = scale_expression
	end
	if condition_expression ~= nil then
		data.condition_expression = condition_expression
	end

		return {
			id = id,
			from = from,
			to = to,
			type = types.CONNECTION.STATE,
			action = action,
			source_field = source_field,
			comparator = comparator,
			value = value,
			scale = scale,
			use_delta = connection.use_delta == true,
			target_enabled = connection.target_enabled ~= false,
			target_trigger_mode = target_trigger_mode,
			target_variable = target_variable,
		target_rate = target_rate,
		target_capacity = target_capacity,
		register_op = register_op,
		data = data,
	}
end

local function copy_connection(connection, index, node_lookup, connection_lookup)
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

	local id = connection.id or ("connection_" .. tostring(index))
	if connection_lookup[id] then
		return nil, "duplicate connection id: " .. id
	end
	connection_lookup[id] = true

	local connection_type, default_delay_ticks_or_error = normalize_connection_type(connection, index)
	if not connection_type then
		return nil, default_delay_ticks_or_error
	end

	if connection_type == types.CONNECTION.RESOURCE then
		return copy_resource_connection(connection, index, id, from, to, default_delay_ticks_or_error)
	end

	return copy_state_connection(connection, index, id, from, to)
end

local function copy_end_conditions(diagram, node_lookup)
	local end_cfg = diagram["end"] or diagram.end_conditions or {}
	if type(end_cfg) ~= "table" then
		return nil, "diagram.end must be a table if present"
	end

	local max_ticks, max_ticks_err = as_integer(end_cfg.max_ticks, "diagram.end.max_ticks", 1)
	if end_cfg.max_ticks ~= nil and not max_ticks then
		return nil, max_ticks_err
	end

	local normalized = {
		max_ticks = max_ticks,
		stop_when_idle = end_cfg.stop_when_idle == true,
		conditions = {},
	}

	local raw_conditions = end_cfg.conditions or end_cfg.targets or {}
	if type(raw_conditions) ~= "table" then
		return nil, "diagram.end.conditions must be an array if present"
	end

	for index, condition in ipairs(raw_conditions) do
		if type(condition) ~= "table" then
			return nil, "diagram.end.conditions[" .. tostring(index) .. "] must be a table"
		end

		local expression, expression_err = as_string(
			condition.expression,
			"diagram.end.conditions[" .. tostring(index) .. "].expression"
		)
		if condition.expression ~= nil and not expression then
			return nil, expression_err
		end

		local normalized_condition = {
			id = condition.id or ("condition_" .. tostring(index)),
			description = condition.description,
			expression = expression,
		}

		if expression == nil then
			local node_id = condition.node_id
			if type(node_id) ~= "string" or node_id == "" then
				return nil, "diagram.end.conditions[" .. tostring(index) .. "].node_id is required"
			end
			if not node_lookup[node_id] then
				return nil, "diagram.end.conditions[" .. tostring(index) .. "] references unknown node: " .. node_id
			end

			local field = condition.field or types.STATE_FIELD.RESOURCES
			if not STATE_FIELDS[field] then
				return nil, "diagram.end.conditions[" .. tostring(index) .. "].field is unsupported: " .. tostring(field)
			end

			local comparator = condition.comparator or types.COMPARATOR.GREATER_OR_EQUAL
			if not COMPARATORS[comparator] then
				return nil, "diagram.end.conditions[" .. tostring(index) .. "].comparator is unsupported"
			end

			local value, value_err = as_number(condition.value, "diagram.end.conditions[" .. tostring(index) .. "].value")
			if not value then
				return nil, value_err
			end

			normalized_condition.node_id = node_id
			normalized_condition.field = field
			normalized_condition.comparator = comparator
			normalized_condition.value = value
		end

		normalized.conditions[#normalized.conditions + 1] = normalized_condition
	end

	return normalized
end

-- Load a raw diagram table and return a normalized copy.
function Loader.validate(diagram)
	if type(diagram) ~= "table" then
		return nil, "diagram must be a table"
	end

	local play_mode = diagram.play_mode or types.PLAY_MODE.HEADLESS
	if LEGACY_PLAY_MODE_MAP[play_mode] ~= nil then
		play_mode = LEGACY_PLAY_MODE_MAP[play_mode]
	end
	if not PLAY_MODES[play_mode] then
		return nil, "diagram.play_mode has unsupported value: " .. tostring(play_mode)
	end

	if diagram.nodes ~= nil and type(diagram.nodes) ~= "table" then
		return nil, "diagram.nodes must be an array"
	end

	if diagram.connections ~= nil and type(diagram.connections) ~= "table" then
		return nil, "diagram.connections must be an array"
	end

	local variable_values, variable_definitions, variable_err = normalize_variables(diagram.variables)
	if variable_values == nil then
		return nil, variable_err
	end

	local normalized = {
		name = diagram.name,
		description = diagram.description,
		seed = tonumber(diagram.seed) or 1,
		play_mode = play_mode,
		variables = variable_values,
		variable_definitions = variable_definitions,
		nodes = {},
		connections = {},
	}

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

	local connection_lookup = {}
	for index, connection in ipairs(diagram.connections or {}) do
		if type(connection) ~= "table" then
			return nil, "connection #" .. tostring(index) .. " must be a table"
		end

		local copy, err = copy_connection(connection, index, node_lookup, connection_lookup)
		if not copy then
			return nil, err
		end

		normalized.connections[#normalized.connections + 1] = copy
	end

	local normalized_end, end_err = copy_end_conditions(diagram, node_lookup)
	if not normalized_end then
		return nil, end_err
	end
	normalized["end"] = normalized_end

	return normalized
end

function Loader.load(diagram)
	return Loader.validate(diagram)
end

return Loader
