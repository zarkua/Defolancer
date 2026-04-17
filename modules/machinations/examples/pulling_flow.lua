local types = require("modules.machinations.types")

return {
	name = "Pulling Flow",
	description = "Collector pulls resources from producer via pull-mode connection.",
	play_mode = types.PLAY_MODE.HEADLESS,
	seed = 7,
	nodes = {
		{
			id = "producer",
			type = types.NODE.SOURCE,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 20,
			rate = 2,
			data = {
				finite_source = true,
			},
		},
		{
			id = "collector",
			type = types.NODE.POOL,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 0,
			rate = 1,
			capacity = 10,
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
			id = "collector_pulls_producer",
			from = "collector",
			to = "producer",
			type = types.CONNECTION.RESOURCE,
			flow_mode = types.FLOW_MODE.PULL,
			amount = 1,
		},
		{
			id = "collector_to_sink",
			from = "collector",
			to = "sink",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
		},
	},
	["end"] = {
		max_ticks = 50,
		stop_when_idle = true,
	},
}
