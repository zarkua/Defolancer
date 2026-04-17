local types = require("modules.machinations.types")

return {
	name = "Variable Feedback",
	description = "Variable-driven amount expression with state connection writing variables.",
	play_mode = types.PLAY_MODE.HEADLESS,
	seed = 13,
	variables = {
		burst = {
			value = 1,
			expression = "if_else(tick % 3 == 0, 3, 1)",
		},
	},
	nodes = {
		{
			id = "source",
			type = types.NODE.SOURCE,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 30,
			rate = 3,
			data = {
				finite_source = true,
			},
		},
		{
			id = "buffer",
			type = types.NODE.POOL,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 0,
			capacity = 15,
			rate = 3,
		},
		{
			id = "meter",
			type = types.NODE.REGISTER,
			trigger_mode = types.TRIGGER_MODE.PASSIVE,
			register_value = 0,
		},
		{
			id = "sink",
			type = types.NODE.DRAIN,
			trigger_mode = types.TRIGGER_MODE.PASSIVE,
			initial_resources = 0,
			rate = 99,
		},
	},
	connections = {
		{
			id = "source_to_buffer",
			from = "source",
			to = "buffer",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
			amount_expression = "burst",
		},
		{
			id = "buffer_to_sink",
			from = "buffer",
			to = "sink",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
		},
		{
			id = "buffer_to_meter",
			from = "buffer",
			to = "meter",
			type = types.CONNECTION.STATE,
			action = types.STATE_ACTION.SET_REGISTER,
			source_field = types.STATE_FIELD.RESOURCES,
			comparator = types.COMPARATOR.GREATER_OR_EQUAL,
			value = 0,
			scale = 1,
		},
		{
			id = "meter_to_burst",
			from = "meter",
			to = "source",
			type = types.CONNECTION.STATE,
			action = types.STATE_ACTION.SET_VARIABLE,
			target_variable = "burst",
			source_field = types.STATE_FIELD.REGISTER,
			comparator = types.COMPARATOR.GREATER_OR_EQUAL,
			value_expression = "5",
			scale_expression = "if_else(register >= 10, 2, 1)",
			register_op = "set",
		},
	},
	["end"] = {
		max_ticks = 80,
		stop_when_idle = false,
		conditions = {
			{
				id = "meter_threshold",
				expression = "nodes.meter.register_value >= 12",
			},
		},
	},
}
