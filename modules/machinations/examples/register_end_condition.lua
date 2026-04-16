local types = require("modules.machinations.types")

return {
	name = "Register Driven End",
	description = "State connection updates register and stops on threshold.",
	play_mode = types.PLAY_MODE.HEADLESS,
	seed = 5,
	nodes = {
		{
			id = "source",
			type = types.NODE.SOURCE,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 25,
			rate = 1,
			data = {
				finite_source = true,
			},
		},
		{
			id = "stock",
			type = types.NODE.POOL,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 0,
			rate = 1,
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
			id = "source_to_stock",
			from = "source",
			to = "stock",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
		},
		{
			id = "stock_to_sink",
			from = "stock",
			to = "sink",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
		},
		{
			id = "stock_to_meter",
			from = "stock",
			to = "meter",
			type = types.CONNECTION.STATE,
			action = types.STATE_ACTION.SET_REGISTER,
			source_field = types.STATE_FIELD.RESOURCES,
			comparator = types.COMPARATOR.GREATER_OR_EQUAL,
			value = 0,
			scale = 1,
			register_op = "set",
		},
	},
	["end"] = {
		max_ticks = 100,
		stop_when_idle = false,
		conditions = {
			{
				id = "meter_reached_ten",
				node_id = "meter",
				field = types.STATE_FIELD.REGISTER,
				comparator = types.COMPARATOR.GREATER_OR_EQUAL,
				value = 10,
			},
		},
	},
}
