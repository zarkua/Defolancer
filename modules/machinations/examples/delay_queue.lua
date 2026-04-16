local types = require("modules.machinations.types")

return {
	name = "Delay Queue",
	description = "Resources pass through a queue node with delayed output.",
	play_mode = types.PLAY_MODE.HEADLESS,
	seed = 9,
	nodes = {
		{
			id = "source",
			type = types.NODE.SOURCE,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 12,
			rate = 2,
			data = {
				finite_source = true,
			},
		},
		{
			id = "queue",
			type = types.NODE.QUEUE,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 0,
			rate = 1,
			delay_ticks = 2,
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
			id = "source_to_queue",
			from = "source",
			to = "queue",
			type = types.CONNECTION.RESOURCE,
			amount = 2,
		},
		{
			id = "queue_to_sink",
			from = "queue",
			to = "sink",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
		},
	},
	["end"] = {
		max_ticks = 30,
		stop_when_idle = true,
	},
}
