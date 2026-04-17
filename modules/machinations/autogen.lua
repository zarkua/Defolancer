local Runner = require("modules.machinations.runner")
local Io = require("modules.machinations.io")
local types = require("modules.machinations.types")
local example_crafting_system = require("modules.machinations.examples.crafting_system")
local example_economy_loop = require("modules.machinations.examples.economy_loop")
local example_farming_crafting_flow = require("modules.machinations.examples.farming_crafting_flow")
local example_hourglass = require("modules.machinations.examples.hourglass")
local example_random_loot = require("modules.machinations.examples.random_loot")
local example_progression_loop = require("modules.machinations.examples.progression_loop")
local example_variable_feedback = require("modules.machinations.examples.variable_feedback")

local Autogen = {}

local DEFAULT_REPORT_PATH = "source/latest_autogen_report.json"
local DEFAULT_DIAGRAM_DIR = "source/diagrams"

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

local function clamp(value, min_value, max_value)
	if value < min_value then
		return min_value
	end
	if value > max_value then
		return max_value
	end
	return value
end

local function build_linear_positions(node_ids, start_x, start_y, step_x)
	local positions = {}
	for index, node_id in ipairs(node_ids) do
		positions[node_id] = {
			x = start_x + (index - 1) * step_x,
			y = start_y,
		}
	end
	return positions
end

local function build_split_positions()
	return {
		source = { x = -360, y = 120 },
		gate = { x = -100, y = 120 },
		branch_a = { x = 170, y = 210 },
		branch_b = { x = 170, y = 30 },
	}
end

local function build_end_condition_positions()
	return {
		source = { x = -340, y = 120 },
		buffer = { x = -80, y = 120 },
		complete = { x = 220, y = 120 },
	}
end

local function normalize_case_diagram(diagram, fallback_name)
	local normalized = copy_table(diagram)
	normalized.name = normalized.name or fallback_name or "Autogen Diagram"
	normalized.play_mode = normalized.play_mode or types.PLAY_MODE.HEADLESS
	normalized["end"] = normalized["end"] or {
		stop_when_idle = true,
		max_ticks = 120,
	}
	return normalized
end

local function pick_variant(seed, offset, min_value, span)
	local safe_seed = tonumber(seed) or 0
	return min_value + ((safe_seed + offset) % math.max(span, 1))
end

local function count_warnings(run_result)
	if type(run_result) ~= "table" or type(run_result.metrics) ~= "table" then
		return 0
	end
	if type(run_result.metrics.warnings) ~= "table" then
		return 0
	end
	return #run_result.metrics.warnings
end

local function validate_resources_integrity(run_result)
	for node_id, node in pairs(run_result.nodes or {}) do
		local resources = tonumber(node.resources or 0) or 0
		if resources < 0 then
			return false, "negative resources at " .. tostring(node_id)
		end
		if resources ~= math.floor(resources) then
			return false, "non-integer resources at " .. tostring(node_id)
		end
	end
	return true, "ok"
end

local function validate_common_run(case, run_result)
	local ok, message = validate_resources_integrity(run_result)
	if not ok then
		return false, message
	end

	local warnings = count_warnings(run_result)
	local max_warnings = case.max_warnings or 0
	if warnings > max_warnings then
		return false, string.format("expected <= %d warnings, got %d", max_warnings, warnings)
	end

	if case.expected_end_reason ~= nil and run_result.end_reason ~= case.expected_end_reason then
		return false, string.format(
			"expected end_reason=%s, got %s",
			tostring(case.expected_end_reason),
			tostring(run_result.end_reason)
		)
	end

	if case.expected_node_resources ~= nil then
		for node_id, expected_value in pairs(case.expected_node_resources) do
			local node = run_result.nodes[node_id]
			local actual_value = node and tonumber(node.resources or 0) or 0
			if actual_value ~= expected_value then
				return false, string.format(
					"expected %s.resources=%s, got %s",
					tostring(node_id),
					tostring(expected_value),
					tostring(actual_value)
				)
			end
		end
	end

	return true, "ok"
end

local function validate_common_batch(case, batch_report)
	local expected_runs = case.batch_runs or 0
	local actual_runs = #(batch_report.runs or {})
	if expected_runs > 0 and actual_runs ~= expected_runs then
		return false, string.format("expected %d batch runs, got %d", expected_runs, actual_runs)
	end

	local mean_ticks = (((batch_report.aggregates or {}).ticks or {}).mean or 0)
	if mean_ticks <= 0 then
		return false, "batch mean ticks should be positive"
	end

	return true, "ok"
end

local function get_final_resource(run_result, node_id)
	local node = run_result.nodes and run_result.nodes[node_id] or nil
	return node and tonumber(node.resources or 0) or 0
end

local function get_final_register(run_result, node_id)
	local node = run_result.nodes and run_result.nodes[node_id] or nil
	return node and tonumber(node.register_value or 0) or 0
end

local function mean_final_resource(batch_report, node_id)
	local total = 0
	local count = 0
	for _, run in ipairs(batch_report.runs or {}) do
		local final_node = run.final and run.final[node_id] or nil
		total = total + (tonumber(final_node and final_node.resources or 0) or 0)
		count = count + 1
	end
	if count == 0 then
		return 0
	end
	return total / count
end

local function check_hourglass_run(case, run_result)
	local drained_total = tonumber(((run_result.metrics or {}).drained_total) or 0) or 0
	if drained_total < (case.expected_drained_total or 0) then
		return false, string.format("expected drained_total >= %d, got %d", case.expected_drained_total or 0, drained_total)
	end
	return true, "ok"
end

local function check_delay_run(case, run_result)
	local delivered = get_final_resource(run_result, "sink")
	local expected = case.expected_node_resources and case.expected_node_resources.sink or 0
	if delivered ~= expected then
		return false, "delay sink mismatch"
	end
	return true, "ok"
end

local function check_queue_run(case, run_result)
	local delivered = get_final_resource(run_result, "sink")
	local expected = case.expected_node_resources and case.expected_node_resources.sink or 0
	if delivered ~= expected then
		return false, "queue sink mismatch"
	end
	return true, "ok"
end

local function check_round_robin_run(case, run_result)
	local a = get_final_resource(run_result, "branch_a")
	local b = get_final_resource(run_result, "branch_b")
	local total = a + b
	local expected_total = case.expected_total_resources or 0
	if total ~= expected_total then
		return false, string.format("round robin total mismatch, got %d", total)
	end
	if math.abs(a - b) > 1 then
		return false, string.format("round robin imbalance too large, got %d vs %d", a, b)
	end
	return true, "ok"
end

local function check_variable_feedback_run(case, run_result)
	local meter_value = get_final_register(run_result, "meter")
	if meter_value < (case.expected_meter_at_least or 0) then
		return false, string.format("meter should reach at least %d, got %d", case.expected_meter_at_least or 0, meter_value)
	end
	return true, "ok"
end

local function check_end_condition_run(case, run_result)
	local buffer_resources = get_final_resource(run_result, "buffer")
	if buffer_resources < (case.expected_threshold or 0) then
		return false, "buffer should reach end-condition threshold"
	end
	return true, "ok"
end

local function check_random_loot_run(case, run_result)
	if run_result.tick <= 0 then
		return false, "random_loot should advance at least one tick"
	end
	return true, "ok"
end

local function check_random_loot_batch(case, batch_report)
	local ok, message = validate_common_batch(case, batch_report)
	if not ok then
		return false, message
	end

	local rare_target_hits = (((batch_report.aggregates or {}).end_reasons or {}).rare_target or 0)
	if rare_target_hits <= 0 then
		return false, "rare_target should occur in batch report"
	end

	return true, "ok"
end

local function check_progression_run(case, run_result)
	local bank_value = get_final_resource(run_result, "xp_bank")
	if bank_value < (case.expected_bank_at_least or 0) then
		return false, string.format(
			"xp_bank should reach at least %d, got %d",
			case.expected_bank_at_least or 0,
			bank_value
		)
	end
	return true, "ok"
end

local function normalize_path_prefix(path)
	if type(path) ~= "string" or path == "" then
		return nil
	end
	return string.gsub(path, "[/\\]+$", "")
end

local function case_diagram_path(diagram_dir, case_id)
	local prefix = normalize_path_prefix(diagram_dir)
	if prefix == nil then
		return nil
	end
	return string.format("%s/autogen_%s.json", prefix, tostring(case_id))
end

local function build_case_report(case)
	return {
		id = case.id,
		name = case.name,
		description = case.description,
		ok = false,
		message = "",
		ticks = 0,
		end_reason = nil,
		warnings = 0,
		batch_runs = 0,
		artifacts = {},
	}
end

local function build_hourglass_case()
	local diagram = normalize_case_diagram(example_hourglass, "autogen_hourglass")
	diagram.editor_positions = build_linear_positions({ "source", "buffer", "sink" }, -320, 120, 260)
	return {
		id = "hourglass",
		name = "Hourglass",
		description = "Finite source drains through a bounded pool into a sink.",
		seed = 101,
		max_ticks = 24,
		max_warnings = 0,
		expected_end_reason = "idle",
		expected_node_resources = {
			source = 0,
			buffer = 0,
		},
		expected_drained_total = 8,
		check_run = check_hourglass_run,
		diagram = diagram,
	}
end

local function build_crafting_system_case()
	local diagram = normalize_case_diagram(example_crafting_system, "autogen_crafting_system")
	diagram.editor_positions = build_linear_positions({
		"loot",
		"rarity_gate",
		"common_stock",
		"rare_stock",
		"craft_station",
		"item_pool",
		"delivery",
	}, -440, 130, 220)
	return {
		id = "crafting_system",
		name = "Crafting System",
		description = "Loot split into rarity buckets and assembled through a crafting station.",
		seed = 111,
		max_ticks = 80,
		max_warnings = 0,
		expected_end_reason = "idle",
		expected_drained_total = 12,
		check_run = check_hourglass_run,
		diagram = diagram,
	}
end

local function build_delay_case(seed)
	local flow = pick_variant(seed, 1, 4, 3)
	local delay_ticks = pick_variant(seed, 2, 1, 3)
	local diagram = {
		name = "Auto Delay Flow",
		play_mode = types.PLAY_MODE.HEADLESS,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = flow,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "delay",
				type = types.NODE.DELAY,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				delay_ticks = delay_ticks,
				rate = 1,
			},
			{
				id = "sink",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
		},
		connections = {
			{ id = "source_delay", from = "source", to = "delay", type = types.CONNECTION.RESOURCE, amount = 1 },
			{ id = "delay_sink", from = "delay", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
		},
		["end"] = {
			max_ticks = 20,
			stop_when_idle = true,
		},
		editor_positions = build_linear_positions({ "source", "delay", "sink" }, -320, 120, 260),
	}
	return {
		id = "delay_flow",
		name = "Delay Flow",
		description = "Auto-built delayed transfer pipeline.",
		seed = 201 + flow + delay_ticks,
		max_ticks = 20,
		max_warnings = 0,
		expected_end_reason = "idle",
		expected_node_resources = {
			source = 0,
			delay = 0,
			sink = flow,
		},
		check_run = check_delay_run,
		diagram = diagram,
	}
end

local function build_queue_case(seed)
	local flow = pick_variant(seed, 3, 5, 3)
	local queue_delay = pick_variant(seed, 4, 1, 2)
	local diagram = {
		name = "Auto Queue Flow",
		play_mode = types.PLAY_MODE.HEADLESS,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = flow,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "queue",
				type = types.NODE.QUEUE,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				delay_ticks = queue_delay,
				rate = 1,
			},
			{
				id = "sink",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
		},
		connections = {
			{ id = "source_queue", from = "source", to = "queue", type = types.CONNECTION.RESOURCE, amount = 1 },
			{ id = "queue_sink", from = "queue", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
		},
		["end"] = {
			max_ticks = 24,
			stop_when_idle = true,
		},
		editor_positions = build_linear_positions({ "source", "queue", "sink" }, -320, 120, 260),
	}
	return {
		id = "queue_flow",
		name = "Queue Flow",
		description = "Auto-built queued transfer pipeline.",
		seed = 301 + flow + queue_delay,
		max_ticks = 24,
		max_warnings = 0,
		expected_end_reason = "idle",
		expected_node_resources = {
			source = 0,
			queue = 0,
			sink = flow,
		},
		check_run = check_queue_run,
		diagram = diagram,
	}
end

local function build_round_robin_case(seed)
	local flow = pick_variant(seed, 5, 8, 5)
	local diagram = {
		name = "Auto Round Robin",
		play_mode = types.PLAY_MODE.HEADLESS,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = flow,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "gate",
				type = types.NODE.GATE,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				gate_mode = types.GATE_MODE.ROUND_ROBIN,
				rate = 1,
			},
			{
				id = "branch_a",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
			{
				id = "branch_b",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
		},
		connections = {
			{ id = "source_gate", from = "source", to = "gate", type = types.CONNECTION.RESOURCE, amount = 1 },
			{ id = "gate_a", from = "gate", to = "branch_a", type = types.CONNECTION.RESOURCE, amount = 1 },
			{ id = "gate_b", from = "gate", to = "branch_b", type = types.CONNECTION.RESOURCE, amount = 1 },
		},
		["end"] = {
			max_ticks = 40,
			stop_when_idle = true,
		},
		editor_positions = build_split_positions(),
	}
	return {
		id = "round_robin_split",
		name = "Round Robin Split",
		description = "Auto-built gate split with deterministic fairness.",
		seed = 401 + flow,
		max_ticks = 40,
		max_warnings = 0,
		expected_end_reason = "idle",
		expected_total_resources = flow,
		check_run = check_round_robin_run,
		diagram = diagram,
	}
end

local function build_farming_crafting_flow_case()
	local diagram = normalize_case_diagram(example_farming_crafting_flow, "autogen_farming_crafting_flow")
	diagram.editor_positions = build_linear_positions({
		"farm_source",
		"harvest_bin",
		"market_stall",
		"coin_wallet",
		"treasury",
	}, -420, 120, 220)
	return {
		id = "farming_crafting_flow",
		name = "Farming & Crafting Flow",
		description = "Farm output is traded through a market stall into currency.",
		seed = 401,
		max_ticks = 72,
		max_warnings = 0,
		expected_end_reason = "idle",
		expected_drained_total = 10,
		check_run = check_hourglass_run,
		diagram = diagram,
	}
end

local function build_variable_feedback_case()
	local diagram = normalize_case_diagram(example_variable_feedback, "autogen_variable_feedback")
	diagram.editor_positions = {
		source = { x = -340, y = 160 },
		buffer = { x = -60, y = 160 },
		meter = { x = -60, y = -20 },
		sink = { x = 240, y = 160 },
	}
	return {
		id = "variable_feedback",
		name = "Variable Feedback",
		description = "Variable-driven flow with a state connection feeding source behavior.",
		seed = 501,
		max_ticks = 80,
		max_warnings = 0,
		expected_end_reason = "meter_threshold",
		expected_meter_at_least = 12,
		check_run = check_variable_feedback_run,
		diagram = diagram,
	}
end

local function build_progression_loop_case()
	local diagram = normalize_case_diagram(example_progression_loop, "autogen_progression_loop")
		diagram.editor_positions = {
		quest_source = { x = -380, y = 140 },
		xp_bank = { x = -120, y = 140 },
		level_meter = { x = 120, y = 140 },
	}
	return {
		id = "progression_loop",
		name = "Progression Loop",
		description = "Cumulative XP drives the next phase of the reward loop.",
		seed = 501,
		max_ticks = 60,
		max_warnings = 0,
		expected_end_reason = "victory",
		expected_bank_at_least = 8,
		check_run = check_progression_run,
		diagram = diagram,
	}
end

local function build_end_condition_case(seed)
	local threshold = pick_variant(seed, 6, 3, 2)
	local source_resources = threshold + 1
	local diagram = {
		name = "Auto End Condition",
		play_mode = types.PLAY_MODE.HEADLESS,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = source_resources,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "buffer",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
			{
				id = "complete",
				type = types.NODE.END_CONDITION,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				enabled = false,
				data = { legacy_caption = "complete" },
			},
		},
		connections = {
			{ id = "source_buffer", from = "source", to = "buffer", type = types.CONNECTION.RESOURCE, amount = 1 },
			{
				id = "buffer_complete",
				from = "buffer",
				to = "complete",
				type = types.CONNECTION.STATE,
				action = types.STATE_ACTION.SET_ENABLED,
				source_field = types.STATE_FIELD.RESOURCES,
				comparator = types.COMPARATOR.GREATER_OR_EQUAL,
				value = threshold,
				scale = 1,
				target_enabled = true,
			},
		},
		["end"] = {
			max_ticks = 12,
			stop_when_idle = false,
		},
		editor_positions = build_end_condition_positions(),
	}
	return {
		id = "end_condition",
		name = "End Condition",
		description = "Auto-built termination path that activates an end-condition node.",
		seed = 601 + threshold,
		max_ticks = 12,
		max_warnings = 0,
		expected_end_reason = "complete",
		expected_threshold = threshold,
		check_run = check_end_condition_run,
		diagram = diagram,
	}
end

local function build_economy_loop_case()
	local diagram = normalize_case_diagram(example_economy_loop, "autogen_economy_loop")
	diagram.editor_positions = build_linear_positions({
		"ore_mine",
		"ore_stock",
		"smelter",
		"ingot_stock",
		"market",
		"coin_vault",
		"bank",
	}, -440, 130, 220)
	return {
		id = "economy_loop",
		name = "Economy Loop",
		description = "A compact trader chain that turns resources into currency.",
		seed = 611,
		max_ticks = 84,
		max_warnings = 0,
		expected_end_reason = "idle",
		expected_drained_total = 12,
		check_run = check_hourglass_run,
		diagram = diagram,
	}
end

local function build_random_loot_case(profile)
	local smoke = profile == "smoke"
	local diagram = normalize_case_diagram(example_random_loot, "autogen_random_loot")
	return {
		id = "random_loot",
		name = "Random Loot",
		description = "Batch-verified probabilistic loot flow.",
		seed = 701,
		max_ticks = 220,
		max_warnings = 0,
		batch_runs = smoke and 16 or 48,
		check_run = check_random_loot_run,
		check_batch = check_random_loot_batch,
		diagram = diagram,
	}
end

local function run_case(case, options)
	local report = build_case_report(case)

	local run_result, run_err = Runner.run_diagram(case.diagram, {
		seed = case.seed or options.seed,
		max_ticks = case.max_ticks or options.max_ticks,
		play_mode = types.PLAY_MODE.HEADLESS,
	})
	if run_result == nil then
		report.message = "run failed: " .. tostring(run_err)
		return report
	end

	report.ticks = run_result.tick or 0
	report.end_reason = run_result.end_reason
	report.warnings = count_warnings(run_result)

	local ok, message = validate_common_run(case, run_result)
	if ok and type(case.check_run) == "function" then
		ok, message = case.check_run(case, run_result)
	end

	if ok and tonumber(case.batch_runs or 0) > 0 then
		local batch_report, batch_err = Runner.run_batch(case.diagram, {
			runs = case.batch_runs,
			max_ticks = case.max_ticks or options.max_ticks,
			seed = case.seed or options.seed,
		})
		if batch_report == nil then
			ok = false
			message = "batch failed: " .. tostring(batch_err)
		else
			report.batch_runs = #(batch_report.runs or {})
			if type(case.check_batch) == "function" then
				ok, message = case.check_batch(case, batch_report)
			end
		end
	end

	report.ok = ok == true
	report.message = message or ""
	return report
end

function Autogen.build_cases(profile, seed)
	local build_profile = profile or "default"
	local build_seed = tonumber(seed) or 17
	return {
		build_hourglass_case(),
		build_crafting_system_case(),
		build_delay_case(build_seed),
		build_queue_case(build_seed),
		build_round_robin_case(build_seed),
		build_farming_crafting_flow_case(),
		build_variable_feedback_case(),
		build_progression_loop_case(),
		build_end_condition_case(build_seed),
		build_economy_loop_case(),
		build_random_loot_case(build_profile),
	}
end

function Autogen.get_case(index, profile, seed)
	local cases = Autogen.build_cases(profile, seed)
	local total = #cases
	if total == 0 then
		return nil, 0, 0
	end

	local numeric_index = tonumber(index) or 1
	local normalized_index = ((numeric_index - 1) % total) + 1
	return copy_table(cases[normalized_index]), total, normalized_index
end

function Autogen.write_report(path, report, pretty)
	local target_path = path or DEFAULT_REPORT_PATH
	return Io.encode_diagram_file(target_path, report, pretty ~= false)
end

function Autogen.run_suite(options)
	options = options or {}

	local profile = options.profile or "default"
	local seed = tonumber(options.seed) or 17
	local persist = options.persist ~= false
	local diagram_dir = options.diagram_dir or DEFAULT_DIAGRAM_DIR
	local report_path = options.report_path or DEFAULT_REPORT_PATH
	local cases = Autogen.build_cases(profile, seed)

	local report = {
		profile = profile,
		seed = seed,
		total = 0,
		passed = 0,
		failed = 0,
		cases = {},
		report_path = persist and report_path or nil,
	}

	for _, case in ipairs(cases) do
		report.total = report.total + 1
		if persist then
			local diagram_path = case_diagram_path(diagram_dir, case.id)
			if diagram_path ~= nil then
				local saved, save_err = Io.encode_diagram_file(diagram_path, case.diagram, true)
				if saved then
					case.artifact_diagram_path = diagram_path
				else
					case.artifact_diagram_error = tostring(save_err)
				end
			end
		end

		local case_report = run_case(case, options)
		if case.artifact_diagram_path ~= nil then
			case_report.artifacts.diagram_path = case.artifact_diagram_path
		end
		if case.artifact_diagram_error ~= nil then
			case_report.artifacts.diagram_error = case.artifact_diagram_error
		end
		report.cases[#report.cases + 1] = case_report
		if case_report.ok then
			report.passed = report.passed + 1
		else
			report.failed = report.failed + 1
		end
	end

	if persist then
		local saved, err = Autogen.write_report(report_path, report, true)
		report.report_saved = saved == true
		report.report_error = saved == true and nil or tostring(err)
	end

	return report
end

return Autogen
