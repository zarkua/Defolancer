# Machinations-like Kernel MVP (Defold)

This file documents the current local reimplementation scope in `modules/machinations/*`.

## Implemented now

- Node types:
  - `source`, `pool`, `drain`, `converter`, `trader`, `gate`, `register`, `delay`, `queue`
- Connection types:
  - `resource`, `state`
- Trigger modes:
  - `passive`, `interactive`, `automatic`, `enabling`
- Gate modes:
  - `all`, `random`, `round_robin`
- End conditions:
  - `max_ticks`
  - `stop_when_idle`
  - custom `conditions[]` with comparator checks on `resources` or `register`
- Delayed transfers:
  - per-connection delay
  - per-node delay (for delay/queue-like behavior)
- Resource flow semantics:
  - `push` (default)
  - `pull` flow mode on resource connections
- Expression layer:
  - dynamic variables (`variables` expressions)
  - dynamic node fields (`rate/delay/capacity/register` expressions)
  - dynamic connection fields (`amount/weight/delay` expressions)
  - state-connection `condition/value/scale` expressions
  - end-condition expression predicates
- Batch runs:
  - deterministic seed stepping
  - aggregates (`min/max/mean`) for resources/registers
  - end-reason histogram
- File adapters:
  - JSON decode/encode for diagrams and reports
  - runner wrappers for `run`/`batch` from JSON files

## Normalized node shape

```lua
{
	id = "stock",
	type = "pool",
	trigger_mode = "automatic",
	initial_resources = 0,   -- integer
	capacity = 100,          -- optional integer
	rate = 1,                -- integer >= 1
	delay_ticks = 0,         -- integer >= 0
	gate_mode = "all",       -- for gate nodes
	register_value = 0,      -- number
	enabled = true,
	data = {},               -- free-form extension data
}
```

## Normalized resource connection

```lua
{
	id = "stock_to_sink",
	from = "stock",
	to = "sink",
	type = "resource",
	amount = 1,              -- integer >= 1
	weight = 1,              -- used by random gate routing
	delay_ticks = 0,
	data = {},
}
```

## Normalized state connection

```lua
{
	id = "stock_to_meter",
	from = "stock",
	to = "meter",
	type = "state",
	action = "set_register", -- set_enabled | set_trigger_mode | set_register
	source_field = "resources",
	comparator = ">=",
	value = 0,
	scale = 1,
	target_enabled = true,
	target_trigger_mode = nil,
	register_op = "set",     -- set | add
	data = {},
}
```

## Examples

- `modules/machinations/examples/hourglass.lua`
- `modules/machinations/examples/delay_queue.lua`
- `modules/machinations/examples/gate_random.lua`
- `modules/machinations/examples/register_end_condition.lua`
- `modules/machinations/examples/pulling_flow.lua`
- `modules/machinations/examples/variable_feedback.lua`
- `source/diagrams/hourglass.json`

## Source corpus snapshot

- Full sitemap fetch index: `source/machinations_sitemap_index.md`
- Fetch failures: `source/machinations_sitemap_failures.md`
- Raw pages folder: `source/raw/sitemaps/`
