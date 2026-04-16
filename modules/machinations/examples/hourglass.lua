-- Tiny example diagram that can be fed into the loader or engine.
local types = require("modules.machinations.types")

return {
  name = "Hourglass",
  description = "Simple deterministic pipeline example.",
  play_mode = types.PLAY_MODE.HEADLESS,
  seed = 1,
  nodes = {
    {
      id = "source",
      type = types.NODE.SOURCE,
      trigger = types.TRIGGER.ON_TICK,
      initial_tokens = 8,
    },
    {
      id = "buffer",
      type = types.NODE.POOL,
      trigger = types.TRIGGER.ON_TICK,
      capacity = 4,
      initial_tokens = 0,
    },
    {
      id = "sink",
      type = types.NODE.DRAIN,
      trigger = types.TRIGGER.NONE,
      initial_tokens = 0,
    },
  },
  connections = {
    {
      id = "source_to_buffer",
      from = "source",
      to = "buffer",
      type = types.CONNECTION.NORMAL,
      weight = 1,
    },
    {
      id = "buffer_to_sink",
      from = "buffer",
      to = "sink",
      type = types.CONNECTION.NORMAL,
      weight = 1,
    },
  },
  end = {
    max_ticks = 12,
    stop_when_idle = true,
  },
}
