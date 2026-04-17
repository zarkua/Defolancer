local Batch = require("modules.machinations.batch")
local Engine = require("modules.machinations.engine")
local Io = require("modules.machinations.io")

local Runner = {}

local function copy_table(value)
	if type(value) ~= "table" then
		return value
	end

	local out = {}
	for key, item in pairs(value) do
		out[key] = copy_table(item)
	end
	return out
end

local function build_run_result(state)
	return {
		tick = state.tick,
		end_reason = state.end_reason,
		metrics = copy_table(state.metrics),
		history = copy_table(state.history),
		nodes = copy_table(state.nodes),
		variables = copy_table(state.variables),
	}
end

function Runner.run_diagram(diagram, options)
	options = options or {}

	local state, init_err = Engine.init(diagram, {
		seed = options.seed,
		play_mode = options.play_mode,
	})
	if not state then
		return nil, init_err
	end

	Engine.run(state, options.max_ticks)
	return build_run_result(state), nil
end

function Runner.run_diagram_file(path, options)
	local diagram, decode_err = Io.decode_diagram_file(path)
	if not diagram then
		return nil, decode_err
	end

	return Runner.run_diagram(diagram, options)
end

function Runner.run_batch(diagram, options)
	return Batch.run(diagram, options)
end

function Runner.run_batch_file(path, options)
	local diagram, decode_err = Io.decode_diagram_file(path)
	if not diagram then
		return nil, decode_err
	end

	return Batch.run(diagram, options)
end

function Runner.write_run_report(path, result, pretty)
	return Io.encode_diagram_file(path, result, pretty)
end

function Runner.write_batch_report(path, report, pretty)
	local json_text, err = Io.encode_batch_report_json(report, pretty)
	if not json_text then
		return nil, err
	end

	local file, open_err = io.open(path, "wb")
	if not file then
		return nil, string.format("failed to open '%s' for writing: %s", path, tostring(open_err))
	end

	local ok, write_err = file:write(json_text)
	file:close()
	if not ok then
		return nil, string.format("failed to write '%s': %s", path, tostring(write_err))
	end

	return true
end

function Runner.write_batch_aggregate_csv(path, report, field)
	local csv_text = Batch.aggregate_csv(report, field)
	local file, open_err = io.open(path, "wb")
	if not file then
		return nil, string.format("failed to open '%s' for writing: %s", path, tostring(open_err))
	end

	local ok, write_err = file:write(csv_text)
	file:close()
	if not ok then
		return nil, string.format("failed to write '%s': %s", path, tostring(write_err))
	end

	return true
end

return Runner
