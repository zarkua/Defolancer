local Engine = require("modules.machinations.engine")
local types = require("modules.machinations.types")

local Batch = {}

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

local function normalize_field(field)
	if field == "register" then
		return "register"
	end
	return "resources"
end

local function get_bucket(report, node_id, field)
	local node_bucket = report.aggregates.nodes[node_id]
	if node_bucket == nil then
		return nil
	end
	if field == "register" then
		return node_bucket.register
	end
	return node_bucket.resources
end

-- Run batch simulation and keep only aggregate-friendly fields.
function Batch.run(diagram, options)
	local report, err = Engine.run_batch(diagram, options)
	if not report then
		return nil, err
	end

	local compact = {
		runs = {},
		metric_node_ids = copy_table(report.metric_node_ids),
		aggregates = copy_table(report.aggregates),
	}

	for _, run in ipairs(report.runs) do
		compact.runs[#compact.runs + 1] = {
			index = run.index,
			seed = run.seed,
			ticks = run.ticks,
			end_reason = run.end_reason,
			transfers_total = run.transfers_total,
		}
	end

	return compact
end

-- Build CSV for one aggregate metric (`resources` or `register`).
function Batch.aggregate_csv(report, field)
	field = normalize_field(field)

	local lines = {
		"node_id,min,max,mean",
	}

	for _, node_id in ipairs(report.metric_node_ids or {}) do
		local bucket = get_bucket(report, node_id, field)
		if bucket ~= nil then
			lines[#lines + 1] = string.format(
				"%s,%s,%s,%.6f",
				node_id,
				tostring(bucket.min or 0),
				tostring(bucket.max or 0),
				bucket.mean or 0
			)
		end
	end

	return table.concat(lines, "\n")
end

-- Convenience wrapper for headless diagrams.
function Batch.run_headless(diagram, runs, max_ticks)
	return Batch.run(diagram, {
		runs = runs or 100,
		max_ticks = max_ticks,
		seed = tonumber(diagram.seed) or 1,
		metric_node_ids = {},
		play_mode = types.PLAY_MODE.BATCH,
	})
end

return Batch
