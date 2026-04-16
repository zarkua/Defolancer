local types = require("modules.machinations.types")

return {
	name = "Weighted Gate",
	description = "A gate routes resources by weighted randomness.",
	play_mode = types.PLAY_MODE.HEADLESS,
	seed = 42,
	nodes = {
		{
			id = "source",
			type = types.NODE.SOURCE,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 40,
			rate = 2,
			data = {
				finite_source = true,
			},
		},
		{
			id = "gate",
			type = types.NODE.GATE,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 0,
			rate = 1,
			gate_mode = types.GATE_MODE.RANDOM,
		},
		{
			id = "sink_common",
			type = types.NODE.DRAIN,
			trigger_mode = types.TRIGGER_MODE.PASSIVE,
			initial_resources = 0,
			rate = 99,
		},
		{
			id = "sink_rare",
			type = types.NODE.DRAIN,
			trigger_mode = types.TRIGGER_MODE.PASSIVE,
			initial_resources = 0,
			rate = 99,
		},
	},
	connections = {
		{
			id = "source_to_gate",
			from = "source",
			to = "gate",
			type = types.CONNECTION.RESOURCE,
			amount = 2,
		},
		{
			id = "gate_to_common",
			from = "gate",
			to = "sink_common",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
			weight = 8,
		},
		{
			id = "gate_to_rare",
			from = "gate",
			to = "sink_rare",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
			weight = 2,
		},
	},
	["end"] = {
		max_ticks = 60,
		stop_when_idle = true,
	},
}
