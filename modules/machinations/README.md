# Machinations-like Modules

## Main modules

- `types.lua` - shared enums and compatibility aliases
- `loader.lua` - schema validation + normalization
- `state.lua` - runtime state construction
- `engine.lua` - step/run/batch simulation
- `batch.lua` - compact batch helper + CSV export
- `examples/*.lua` - sample diagrams

## Usage

```lua
local engine = require("modules.machinations.engine")
local example = require("modules.machinations.examples.hourglass")

local state, err = engine.init(example)
if not state then
	print("init error", err)
	return
end

engine.run(state)
print("ticks", state.tick, "reason", state.end_reason)
```

## Batch mode

```lua
local batch = require("modules.machinations.batch")
local example = require("modules.machinations.examples.gate_random")

local report, err = batch.run(example, { runs = 200, max_ticks = 120 })
if not report then
	print("batch error", err)
	return
end

print("runs", #report.runs)
print(batch.aggregate_csv(report, "resources"))
```

