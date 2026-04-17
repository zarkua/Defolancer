# Machinations-like Modules

## Main modules

- `types.lua` - shared enums and compatibility aliases
- `expression.lua` - safe formula evaluator for dynamic values
- `loader.lua` - schema validation + normalization
- `state.lua` - runtime state construction
- `engine.lua` - step/run/batch simulation
- `batch.lua` - compact batch helper + CSV export
- `autogen.lua` - auto-built diagram suite + verification helpers
- `io.lua` - JSON file/json-text adapters
- `runner.lua` - file-driven run/batch wrappers
- `examples/*.lua` - sample diagrams

Key examples:
- `examples/hourglass.lua`
- `examples/delay_queue.lua`
- `examples/gate_random.lua`
- `examples/register_end_condition.lua`
- `examples/pulling_flow.lua`
- `examples/variable_feedback.lua`

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

## File-driven run/batch

```lua
local runner = require("modules.machinations.runner")

local run_result, run_err = runner.run_diagram_file("source/diagrams/hourglass.json", {
	max_ticks = 200,
	seed = 123,
})
if not run_result then
	print("run error", run_err)
	return
end

local batch_report, batch_err = runner.run_batch_file("source/diagrams/hourglass.json", {
	runs = 500,
	max_ticks = 200,
	seed = 10,
})
if not batch_report then
	print("batch error", batch_err)
	return
end

runner.write_batch_report("source/runs/hourglass_report.json", batch_report, true)
runner.write_batch_aggregate_csv("source/runs/hourglass_resources.csv", batch_report, "resources")
```

## Auto-generated suites

```lua
local autogen = require("modules.machinations.autogen")

local report = autogen.run_suite({
	profile = "default",
	seed = 17,
	persist = true,
	diagram_dir = "source/diagrams",
	report_path = "source/latest_autogen_report.json",
})

print("generated", report.total, "passed", report.passed, "failed", report.failed)
```
