local types = require("modules.machinations.types")

return {
	name = "Farming & Crafting Flow",
	description = "Farm output moves through a trader chain into currency.",
	play_mode = types.PLAY_MODE.HEADLESS,
	seed = 27,
	nodes = {
		{
			id = "farm_source",
			type = types.NODE.SOURCE,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 30,
			rate = 2,
			data = {
				finite_source = true,
			},
		},
		{
			id = "harvest_bin",
			type = types.NODE.POOL,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 0,
			capacity = 24,
			rate = 2,
		},
		{
			id = "market_stall",
			type = types.NODE.TRADER,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 0,
			rate = 2,
			data = {
				trade_ratio = 2,
			},
		},
		{
			id = "coin_wallet",
			type = types.NODE.POOL,
			trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
			initial_resources = 0,
			capacity = 48,
			rate = 2,
		},
		{
			id = "treasury",
			type = types.NODE.DRAIN,
			trigger_mode = types.TRIGGER_MODE.PASSIVE,
			initial_resources = 0,
			rate = 99,
		},
	},
	connections = {
		{
			id = "farm_to_harvest",
			from = "farm_source",
			to = "harvest_bin",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
		},
		{
			id = "harvest_to_market",
			from = "harvest_bin",
			to = "market_stall",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
		},
		{
			id = "market_to_wallet",
			from = "market_stall",
			to = "coin_wallet",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
		},
		{
			id = "wallet_to_treasury",
			from = "coin_wallet",
			to = "treasury",
			type = types.CONNECTION.RESOURCE,
			amount = 1,
		},
	},
	["end"] = {
		max_ticks = 72,
		stop_when_idle = true,
	},
	editor_positions = {
		farm_source = { x = -420, y = 140 },
		harvest_bin = { x = -180, y = 140 },
		market_stall = { x = 80, y = 140 },
		coin_wallet = { x = 340, y = 140 },
		treasury = { x = 580, y = 140 },
	},
}
