local types = require("modules.machinations.types")

return {
	name = "Progression Loop",
	description = "Accumulated XP pushes the next phase of the reward loop.",
	play_mode = types.PLAY_MODE.HEADLESS,
	seed = 33,
	nodes = {
		{
			id = "quest_source",
			type = types.NODE.SOURCE,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 36,
			rate = 2,
			data = {
				finite_source = true,
			},
		},
		{
			id = "xp_bank",
			type = types.NODE.POOL,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 0,
			capacity = 24,
			rate = 2,
		},
		{
			id = "level_meter",
			type = types.NODE.REGISTER,
			trigger_mode = types.TRIGGER_MODE.PASSIVE,
			register_value = 0,
		},
	},
	connections = {
		{
			id = "quest_to_xp",
			from = "quest_source",
			to = "xp_bank",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
		},
		{
			id = "xp_to_level",
			from = "xp_bank",
			to = "level_meter",
			type = types.CONNECTION.STATE,
			action = types.STATE_ACTION.SET_REGISTER,
			source_field = types.STATE_FIELD.RESOURCES,
			comparator = types.COMPARATOR.GREATER_OR_EQUAL,
			value = 0,
			scale = 1,
			register_op = "set",
		},
		{
			id = "level_to_rate",
			from = "level_meter",
			to = "quest_source",
			type = types.CONNECTION.STATE,
			action = types.STATE_ACTION.SET_RATE,
			source_field = types.STATE_FIELD.REGISTER,
			comparator = types.COMPARATOR.GREATER_OR_EQUAL,
			value = 0,
			scale = 1,
		},
	},
	["end"] = {
		max_ticks = 60,
		stop_when_idle = false,
		conditions = {
			{
				id = "victory",
				node_id = "xp_bank",
				field = types.STATE_FIELD.RESOURCES,
				comparator = types.COMPARATOR.GREATER_OR_EQUAL,
				value = 8,
			},
		},
	},
	editor_positions = {
		quest_source = { x = -380, y = 140 },
		xp_bank = { x = -120, y = 140 },
		level_meter = { x = 120, y = 140 },
	},
}
