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
	END_CONDITION = "end_condition",
}

types.CONNECTION = {
	RESOURCE = "resource",
	STATE = "state",
}

types.FLOW_MODE = {
	PUSH = "push",
	PULL = "pull",
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
	AUTOPLAY = "autoplay",
}

types.GATE_MODE = {
	ALL = "all",
	RANDOM = "random",
	ROUND_ROBIN = "round_robin",
	RANDOM_ALL = "random_all",
}

types.STATE_ACTION = {
	SET_ENABLED = "set_enabled",
	TOGGLE_ENABLED = "toggle_enabled",
	SET_TRIGGER_MODE = "set_trigger_mode",
	SET_REGISTER = "set_register",
	SET_VARIABLE = "set_variable",
	SCALE_VARIABLE = "scale_variable",
	SET_RATE = "set_rate",
	SET_CAPACITY = "set_capacity",
	ADD_RESOURCE = "add_resource",
}

types.STATE_FIELD = {
	RESOURCES = "resources",
	REGISTER = "register",
	INCOMING = "incoming",
	OUTGOING = "outgoing",
	TICK = "tick",
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
