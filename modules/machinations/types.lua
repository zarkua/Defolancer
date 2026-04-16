-- Shared constants for the local Machinations-like simulator.
local types = {}

types.NODE = {
	SOURCE = "source",
	POOL = "pool",
	DRAIN = "drain",
	CONVERTER = "converter",
	TRADER = "trader",
	GATE = "gate",
	REGISTER = "register",
	DELAY = "delay",
	QUEUE = "queue",
}

types.CONNECTION = {
	RESOURCE = "resource",
	STATE = "state",
}

types.TRIGGER_MODE = {
	PASSIVE = "passive",
	INTERACTIVE = "interactive",
	AUTOMATIC = "automatic",
	ENABLING = "enabling",
}

types.PLAY_MODE = {
	HEADLESS = "headless",
	STEP = "step",
	INTERACTIVE = "interactive",
	BATCH = "batch",
}

types.GATE_MODE = {
	ALL = "all",
	RANDOM = "random",
	ROUND_ROBIN = "round_robin",
}

types.STATE_ACTION = {
	SET_ENABLED = "set_enabled",
	SET_TRIGGER_MODE = "set_trigger_mode",
	SET_REGISTER = "set_register",
}

types.STATE_FIELD = {
	RESOURCES = "resources",
	REGISTER = "register",
}

types.COMPARATOR = {
	GREATER = ">",
	GREATER_OR_EQUAL = ">=",
	LESS = "<",
	LESS_OR_EQUAL = "<=",
	EQUAL = "==",
	NOT_EQUAL = "!=",
}

-- Backward-compatibility aliases for old examples.
types.TRIGGER = {
	NONE = "none",
	ON_START = "on_start",
	ON_TICK = "on_tick",
	ON_EMPTY = "on_empty",
	ON_FULL = "on_full",
}

types.CONNECTION_LEGACY = {
	NORMAL = "normal",
	INSTANT = "instant",
	DELAYED = "delayed",
}

return types
