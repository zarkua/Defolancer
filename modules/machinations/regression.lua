local Engine = require("modules.machinations.engine")
local Autogen = require("modules.machinations.autogen")
local EditorActions = require("modules.machinations.editor_actions")
local LegacyXml = require("modules.machinations.legacy_xml")
local types = require("modules.machinations.types")

local Regression = {}

local function run_steps(state, max_steps)
	local steps = max_steps or 30
	for _ = 1, steps do
		Engine.step(state)
		if state.ended then
			break
		end
	end
end

local function run_case(case)
	if case.diagram == nil then
		local ok, message = case.check(nil)
		return {
			name = case.name,
			ok = ok == true,
			message = message or "",
		}
	end

	local state, err = Engine.init(case.diagram, {
		seed = case.seed or 41,
		play_mode = types.PLAY_MODE.BATCH,
	})
	if not state then
		return {
			name = case.name,
			ok = false,
			message = "init failed: " .. tostring(err),
		}
	end

	local ok, message = case.check(state)
	return {
		name = case.name,
		ok = ok == true,
		message = message or "",
	}
end

local function delay_release_case()
	local diagram = {
		name = "reg_delay_release",
		play_mode = types.PLAY_MODE.BATCH,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = 3,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "delay",
				type = types.NODE.DELAY,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				delay_ticks = 2,
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
			{ id = "a", from = "source", to = "delay", type = types.CONNECTION.RESOURCE, amount = 1 },
			{ id = "b", from = "delay", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
		},
		["end"] = { max_ticks = 6, stop_when_idle = false },
	}

	return {
		name = "delay_release",
		diagram = diagram,
		check = function(state)
			Engine.step(state)
			local t1 = state.nodes.sink.resources
			Engine.step(state)
			local t2 = state.nodes.sink.resources
			Engine.step(state)
			local t3 = state.nodes.sink.resources
			Engine.step(state)
			local t4 = state.nodes.sink.resources
			if t1 ~= 0 or t2 ~= 0 or (t3 <= 0 and t4 <= 0) then
				return false, string.format("expected delayed release, got sink resources t1=%d t2=%d t3=%d t4=%d", t1, t2, t3, t4)
			end
			return true, "ok"
		end,
	}
end

local function queue_fifo_case()
	local diagram = {
		name = "reg_queue_fifo",
		play_mode = types.PLAY_MODE.BATCH,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = 4,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "queue",
				type = types.NODE.QUEUE,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				delay_ticks = 1,
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
			{ id = "a", from = "source", to = "queue", type = types.CONNECTION.RESOURCE, amount = 1 },
			{ id = "b", from = "queue", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
		},
		["end"] = { max_ticks = 8, stop_when_idle = false },
	}

	return {
		name = "queue_fifo",
		diagram = diagram,
		check = function(state)
			Engine.step(state)
			local t1 = state.nodes.sink.resources
			run_steps(state, 7)
			local final_value = state.nodes.sink.resources
			if t1 ~= 0 then
				return false, "queue should not release on first tick"
			end
			if final_value ~= 4 then
				return false, "queue final sink resources expected 4, got " .. tostring(final_value)
			end
			return true, "ok"
		end,
	}
end

local function gate_round_robin_case()
	local diagram = {
		name = "reg_gate_round_robin",
		play_mode = types.PLAY_MODE.BATCH,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = 12,
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
				id = "a",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
			{
				id = "b",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
		},
		connections = {
			{ id = "src_gate", from = "source", to = "gate", type = types.CONNECTION.RESOURCE, amount = 1 },
			{ id = "gate_a", from = "gate", to = "a", type = types.CONNECTION.RESOURCE, amount = 1 },
			{ id = "gate_b", from = "gate", to = "b", type = types.CONNECTION.RESOURCE, amount = 1 },
		},
		["end"] = { max_ticks = 40, stop_when_idle = true },
	}

	return {
		name = "gate_round_robin",
		diagram = diagram,
		check = function(state)
			run_steps(state, 40)
			local a = state.nodes.a.resources
			local b = state.nodes.b.resources
			if (a + b) ~= 12 then
				return false, string.format("round_robin split sum mismatch, got a=%d b=%d", a, b)
			end
			if math.abs(a - b) > 1 then
				return false, string.format("round_robin imbalance too large, got a=%d b=%d", a, b)
			end
			return true, "ok"
		end,
	}
end

local function state_action_rate_case()
	local diagram = {
		name = "reg_state_set_rate",
		play_mode = types.PLAY_MODE.BATCH,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = 6,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "buffer",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 3,
			},
			{
				id = "ctrl",
				type = types.NODE.REGISTER,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				register_value = 3,
				rate = 1,
			},
		},
		connections = {
			{ id = "a", from = "source", to = "buffer", type = types.CONNECTION.RESOURCE, amount = 1 },
			{
				id = "set_rate",
				from = "ctrl",
				to = "source",
				type = types.CONNECTION.STATE,
				action = types.STATE_ACTION.SET_RATE,
				source_field = types.STATE_FIELD.REGISTER,
				comparator = types.COMPARATOR.GREATER_OR_EQUAL,
				value = 0,
				scale = 1,
			},
		},
		["end"] = { max_ticks = 8, stop_when_idle = true },
	}

	return {
		name = "state_set_rate",
		diagram = diagram,
		check = function(state)
			Engine.step(state)
			local rate_after_first = state.nodes.source.rate
			run_steps(state, 7)
			local buffered = state.nodes.buffer.resources
			if rate_after_first ~= 3 then
				return false, "expected source rate to become 3 after state action"
			end
			if buffered ~= 6 then
				return false, "expected all 6 resources to reach buffer, got " .. tostring(buffered)
			end
			return true, "ok"
		end,
	}
end

local function gate_random_all_case()
	local diagram = {
		name = "reg_gate_random_all",
		play_mode = types.PLAY_MODE.BATCH,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = 20,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "gate",
				type = types.NODE.GATE,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				gate_mode = types.GATE_MODE.RANDOM_ALL,
				rate = 1,
			},
			{
				id = "a",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
			{
				id = "b",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
		},
		connections = {
			{ id = "src_gate", from = "source", to = "gate", type = types.CONNECTION.RESOURCE, amount = 1 },
			{ id = "gate_a", from = "gate", to = "a", type = types.CONNECTION.RESOURCE, amount = 1, weight = 100 },
			{ id = "gate_b", from = "gate", to = "b", type = types.CONNECTION.RESOURCE, amount = 1, weight = 0 },
		},
		["end"] = { max_ticks = 60, stop_when_idle = true },
	}

	return {
		name = "gate_random_all_weights",
		diagram = diagram,
		check = function(state)
			run_steps(state, 60)
			local a = state.nodes.a.resources
			local b = state.nodes.b.resources
			if b ~= 0 then
				return false, "weight=0 branch should stay empty, got b=" .. tostring(b)
			end
			if a ~= 20 then
				return false, "expected all resources in branch a, got a=" .. tostring(a)
			end
			return true, "ok"
		end,
	}
end

local function state_delta_positive_case()
	local diagram = {
		name = "reg_state_delta_positive",
		play_mode = types.PLAY_MODE.BATCH,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = 2,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "sink",
				type = types.NODE.DRAIN,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
			{
				id = "counter",
				type = types.NODE.REGISTER,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				register_value = 0,
				rate = 1,
			},
		},
		connections = {
			{ id = "src_sink", from = "source", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
			{
				id = "source_counter",
				from = "source",
				to = "counter",
				type = types.CONNECTION.STATE,
				action = types.STATE_ACTION.SET_REGISTER,
				source_field = types.STATE_FIELD.OUTGOING,
				comparator = types.COMPARATOR.GREATER_OR_EQUAL,
				value = -1000000000,
				scale = 1,
				use_delta = true,
				register_op = "add",
			},
		},
		["end"] = { max_ticks = 8, stop_when_idle = true },
	}

	return {
		name = "state_delta_positive",
		diagram = diagram,
		check = function(state)
			Engine.step(state)
			local t1 = state.nodes.counter.register_value
			Engine.step(state)
			local t2 = state.nodes.counter.register_value
			if t1 ~= 1 then
				return false, "counter should receive +1 when outgoing rises to 1, got " .. tostring(t1)
			end
			if t2 ~= 1 then
				return false, "counter should stay at +1 when outgoing stays flat, got " .. tostring(t2)
			end
			return true, "ok"
		end,
	}
end

local function state_delta_negative_case()
	local diagram = {
		name = "reg_state_delta_negative",
		play_mode = types.PLAY_MODE.BATCH,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = 2,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "sink",
				type = types.NODE.DRAIN,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
			{
				id = "counter",
				type = types.NODE.REGISTER,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				register_value = 0,
				rate = 1,
			},
		},
		connections = {
			{ id = "src_sink", from = "source", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
			{
				id = "source_counter",
				from = "source",
				to = "counter",
				type = types.CONNECTION.STATE,
				action = types.STATE_ACTION.SET_REGISTER,
				source_field = types.STATE_FIELD.RESOURCES,
				comparator = types.COMPARATOR.GREATER_OR_EQUAL,
				value = -1000000000,
				scale = 1,
				use_delta = true,
				register_op = "add",
			},
		},
		["end"] = { max_ticks = 4, stop_when_idle = true },
	}

	return {
		name = "state_delta_negative",
		diagram = diagram,
		check = function(state)
			Engine.step(state)
			local t1 = state.nodes.counter.register_value
			Engine.step(state)
			local t2 = state.nodes.counter.register_value
			if t1 ~= -1 then
				return false, "counter should receive -1 when source resources drop, got " .. tostring(t1)
			end
			if t2 ~= -2 then
				return false, "counter should receive a second -1 when source drains again, got " .. tostring(t2)
			end
			return true, "ok"
		end,
	}
end

local function gate_conditional_else_case()
	local diagram = {
		name = "reg_gate_conditional_else",
		play_mode = types.PLAY_MODE.BATCH,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = 5,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "gate",
				type = types.NODE.GATE,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				gate_mode = types.GATE_MODE.ROUND_ROBIN,
				rate = 1,
				register_value = 0,
				data = { legacy_gate_type = "deterministic" },
			},
			{
				id = "a",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
			{
				id = "b",
				type = types.NODE.POOL,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
		},
		connections = {
			{ id = "src_gate", from = "source", to = "gate", type = types.CONNECTION.RESOURCE, amount = 1 },
			{
				id = "gate_a",
				from = "gate",
				to = "a",
				type = types.CONNECTION.RESOURCE,
				amount = 1,
				data = {
					legacy_gate_label_kind = "condition",
					gate_condition_comparator = types.COMPARATOR.EQUAL,
					gate_condition_value = 10,
				},
			},
			{
				id = "gate_b",
				from = "gate",
				to = "b",
				type = types.CONNECTION.RESOURCE,
				amount = 1,
				data = {
					legacy_gate_label_kind = "else",
				},
			},
		},
		["end"] = { max_ticks = 20, stop_when_idle = true },
	}

	return {
		name = "gate_conditional_else",
		diagram = diagram,
		check = function(state)
			run_steps(state, 20)
			local a = state.nodes.a.resources
			local b = state.nodes.b.resources
			if a ~= 0 then
				return false, "conditional branch should stay empty when no condition matches"
			end
			if b ~= 5 then
				return false, "else branch should receive all 5 resources, got " .. tostring(b)
			end
			return true, "ok"
		end,
	}
end

local function legacy_import_mapping_case()
	local xml_text = [[
<graph version="v4.05" name="Import Mapping" interval="1" timeMode="asynchronous">
  <node symbol="Pool" x="80" y="120" color="Black" caption="source_pool" activationMode="passive" pullMode="push any" startingResources="3" />
  <node symbol="Pool" x="220" y="120" color="Black" caption="target_pool" activationMode="passive" pullMode="push any" />
  <node symbol="Gate" x="360" y="120" color="Black" caption="gate" activationMode="passive" pullMode="pull any" gateType="deterministic" />
  <connection type="State Connection" start="0" end="1" label="+2" position="0.50" color="Black" thickness="2" />
  <connection type="Resource Connection" start="0" end="2" label="all" position="0.50" color="Black" thickness="2" />
  <connection type="Resource Connection" start="2" end="1" label="else" position="0.50" color="Black" thickness="2" />
</graph>
]]

	return {
		name = "legacy_import_mapping",
		diagram = nil,
		check = function(_)
			local diagram, err = LegacyXml.decode_diagram_xml(xml_text)
			if diagram == nil then
				return false, "legacy xml decode failed: " .. tostring(err)
			end

			local found_state = nil
			local found_all = nil
			local found_else = nil
			for _, connection in ipairs(diagram.connections or {}) do
				if connection.type == types.CONNECTION.STATE then
					found_state = connection
				end
				if connection.data and connection.data.amount_expression == "resources" then
					found_all = connection
				end
				if connection.data and connection.data.legacy_gate_label_kind == "else" then
					found_else = connection
				end
			end

			if found_state == nil then
				return false, "expected imported state connection"
			end
			if found_state.use_delta ~= true or found_state.action ~= types.STATE_ACTION.ADD_RESOURCE then
				return false, "state connection should import as delta ADD_RESOURCE"
			end
			if found_all == nil then
				return false, "expected resource label 'all' to map to amount_expression=resources"
			end
			if found_else == nil then
				return false, "expected gate label 'else' to be preserved"
			end
			return true, "ok"
		end,
	}
end

local function end_condition_node_case()
	local diagram = {
		name = "reg_end_condition_node",
		play_mode = types.PLAY_MODE.BATCH,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = 1,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "sink",
				type = types.NODE.DRAIN,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
			{
				id = "victory",
				type = types.NODE.END_CONDITION,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
				enabled = false,
				data = { legacy_caption = "victory" },
			},
		},
		connections = {
			{ id = "src_sink", from = "source", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
			{
				id = "src_end",
				from = "source",
				to = "victory",
				type = types.CONNECTION.STATE,
				action = types.STATE_ACTION.SET_ENABLED,
				source_field = types.STATE_FIELD.OUTGOING,
				comparator = types.COMPARATOR.GREATER_OR_EQUAL,
				value = 1,
				scale = 1,
				target_enabled = true,
			},
		},
		["end"] = { max_ticks = 4, stop_when_idle = false },
	}

	return {
		name = "end_condition_node",
		diagram = diagram,
		check = function(state)
			Engine.step(state)
			if state.ended ~= true then
				return false, "graph should end when end condition node becomes enabled"
			end
			if state.end_reason ~= "victory" then
				return false, "expected end reason 'victory', got " .. tostring(state.end_reason)
			end
			return true, "ok"
		end,
	}
end

local function artificial_player_fire_case()
	local diagram = {
		name = "reg_ap_fire",
		play_mode = types.PLAY_MODE.BATCH,
		nodes = {
			{
				id = "director",
				type = types.NODE.ARTIFICIAL_PLAYER,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = 0,
				rate = 1,
				data = {
					legacy_caption = "Director",
					ap_actions_per_turn = 1,
					ap_script = "fire(source)",
				},
			},
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.INTERACTIVE,
				initial_resources = 2,
				rate = 1,
				data = {
					finite_source = true,
					legacy_caption = "source",
				},
			},
			{
				id = "sink",
				type = types.NODE.DRAIN,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
				data = {
					legacy_caption = "sink",
				},
			},
		},
		connections = {
			{ id = "src_sink", from = "source", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
		},
		["end"] = { max_ticks = 3, stop_when_idle = false },
	}

	return {
		name = "artificial_player_fire",
		diagram = diagram,
		check = function(state)
			Engine.step(state)
			if state.metrics.drained_total ~= 1 then
				return false, "artificial player should fire interactive source and drain 1 resource"
			end
			local director = state.nodes.director
			if director == nil or (director.data and director.data.ap_actions_executed or 0) < 1 then
				return false, "artificial player should record at least one executed action"
			end
			return true, "ok"
		end,
	}
end

local function artificial_player_import_case()
	local xml_text = [[
<graph version="v4.05" name="AP Import" interval="1" timeMode="turnBased">
  <node symbol="ArtificialPlayer" x="120" y="140" color="Black" caption="Director" activationMode="automatic" pullMode="push any" actionsPerTurn="2">fire(source)</node>
  <node symbol="Source" x="280" y="140" color="Black" caption="source" activationMode="interactive" pullMode="push any" />
</graph>
]]

	return {
		name = "artificial_player_import",
		diagram = nil,
		check = function(_)
			local diagram, err = LegacyXml.decode_diagram_xml(xml_text)
			if diagram == nil then
				return false, "legacy xml decode failed: " .. tostring(err)
			end

			local director = nil
			for _, node in ipairs(diagram.nodes or {}) do
				if node.type == types.NODE.ARTIFICIAL_PLAYER then
					director = node
					break
				end
			end

			if director == nil then
				return false, "expected ArtificialPlayer to import as runtime node"
			end
			if (director.data and director.data.ap_script or "") ~= "fire(source)" then
				return false, "expected AP script to be preserved on import"
			end
			if math.floor(tonumber(director.data and director.data.ap_actions_per_turn) or 0) ~= 2 then
				return false, "expected actionsPerTurn=2 on imported AP"
			end
			return true, "ok"
		end,
	}
end

local function autogen_smoke_case()
	return {
		name = "autogen_smoke",
		diagram = nil,
		check = function(_)
			local report = Autogen.run_suite({
				profile = "smoke",
				seed = 17,
				persist = false,
			})
			if report == nil then
				return false, "autogen report missing"
			end
			if report.failed > 0 then
				local first_failure = nil
				for _, case_result in ipairs(report.cases or {}) do
					if not case_result.ok then
						first_failure = case_result
						break
					end
				end
				if first_failure ~= nil then
					return false, string.format(
						"%s: %s",
						tostring(first_failure.id or first_failure.name or "autogen"),
						tostring(first_failure.message or "failed")
					)
				end
				return false, "autogen suite failed"
			end
			return true, string.format("%d/%d generated cases passed", report.passed, report.total)
		end,
	}
end

local function editor_copy_paste_case()
	local diagram = {
		name = "editor_copy_paste",
		author = "regression",
		nodes = {
			{ id = "source", type = types.NODE.SOURCE, trigger_mode = types.TRIGGER_MODE.AUTOMATIC, initial_resources = 3, rate = 1, data = { finite_source = true } },
			{ id = "buffer", type = types.NODE.POOL, trigger_mode = types.TRIGGER_MODE.PASSIVE, initial_resources = 0, rate = 1 },
			{ id = "sink", type = types.NODE.DRAIN, trigger_mode = types.TRIGGER_MODE.PASSIVE, initial_resources = 0, rate = 1 },
		},
		connections = {
			{ id = "a", from = "source", to = "buffer", type = types.CONNECTION.RESOURCE, amount = 1 },
			{ id = "b", from = "buffer", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
		},
	}
	local positions = {
		source = { x = -120, y = 40 },
		buffer = { x = 0, y = 40 },
		sink = { x = 120, y = 40 },
	}

	return {
		name = "editor_copy_paste",
		diagram = nil,
		check = function(_)
			local clipboard = EditorActions.copy_selection(diagram, positions, { "source", "buffer" })
			if clipboard == nil or clipboard.diagram == nil then
				return false, "copy_selection should return clipboard diagram"
			end
			if #(clipboard.diagram.nodes or {}) ~= 2 then
				return false, "clipboard should contain 2 selected nodes"
			end
			if #(clipboard.diagram.connections or {}) ~= 1 then
				return false, "clipboard should contain 1 internal connection"
			end

			local pasted_diagram, pasted_positions, pasted_ids, id_map = EditorActions.paste_selection(
				diagram,
				positions,
				clipboard,
				{ offset_x = 20, offset_y = 30 }
			)
			if #(pasted_diagram.nodes or {}) ~= 5 then
				return false, "paste_selection should append 2 nodes"
			end
			if #(pasted_diagram.connections or {}) ~= 3 then
				return false, "paste_selection should append 1 connection"
			end
			if #(pasted_ids or {}) ~= 2 then
				return false, "paste_selection should return 2 pasted ids"
			end
			local pasted_source_id = id_map and id_map.source or nil
			local pasted_buffer_id = id_map and id_map.buffer or nil
			if pasted_source_id == nil or pasted_buffer_id == nil then
				return false, "paste_selection should return source/buffer id remap"
			end
			local pasted_source_pos = pasted_positions[pasted_source_id]
			local pasted_buffer_pos = pasted_positions[pasted_buffer_id]
			if pasted_source_pos == nil or pasted_buffer_pos == nil then
				return false, "paste_selection should return positions for pasted nodes"
			end
			if pasted_source_pos.x ~= positions.source.x + 20 or pasted_source_pos.y ~= positions.source.y + 30 then
				return false, "pasted source position should be offset"
			end
			if pasted_buffer_pos.x ~= positions.buffer.x + 20 or pasted_buffer_pos.y ~= positions.buffer.y + 30 then
				return false, "pasted buffer position should be offset"
			end
			return true, "ok"
		end,
	}
end

local function editor_visual_copy_paste_case()
	local diagram = {
		name = "editor_visual_copy_paste",
		author = "regression",
		nodes = {
			{ id = "source", type = types.NODE.SOURCE, trigger_mode = types.TRIGGER_MODE.AUTOMATIC, initial_resources = 3, rate = 1, data = { finite_source = true } },
			{ id = "sink", type = types.NODE.DRAIN, trigger_mode = types.TRIGGER_MODE.PASSIVE, initial_resources = 0, rate = 1 },
		},
		connections = {
			{ id = "flow", from = "source", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
		},
		legacy_visual_nodes = {
			{ id = "label", symbol = "TextLabel", caption = "Loot", x = 120, y = 80, width = 96, height = 28 },
			{ id = "group", symbol = "GroupBox", caption = "Frame", x = 40, y = 220, width = 220, height = 120 },
		},
		legacy_visual_connections = {
			{ id = "visual_link", from = "label", to = "sink", label = "note", points = {} },
		},
	}
	local positions = {
		source = { x = 40, y = 120 },
		sink = { x = 240, y = 120 },
	}

	return {
		name = "editor_visual_copy_paste",
		diagram = nil,
		check = function(_)
			local selected_ids = EditorActions.select_all(diagram)
			if #selected_ids ~= 4 then
				return false, "select_all should include 2 runtime and 2 visual nodes"
			end

			local clipboard = EditorActions.copy_selection(diagram, positions, { "label", "group" })
			if clipboard == nil or clipboard.diagram == nil then
				return false, "copy_selection should return clipboard for visual nodes"
			end
			if #(clipboard.diagram.legacy_visual_nodes or {}) ~= 2 then
				return false, "clipboard should contain 2 visual nodes"
			end

			local pasted_diagram, _, pasted_ids, id_map = EditorActions.paste_selection(
				diagram,
				positions,
				clipboard,
				{ offset_x = 24, offset_y = 18 }
			)
			if #(pasted_diagram.legacy_visual_nodes or {}) ~= 4 then
				return false, "paste_selection should append copied visual nodes"
			end
			if #(pasted_ids or {}) ~= 2 then
				return false, "paste_selection should return pasted visual ids"
			end
			local pasted_label_id = id_map and id_map.label or nil
			if pasted_label_id == nil then
				return false, "visual paste should remap label id"
			end

			local pasted_label = nil
			for _, visual_node in ipairs(pasted_diagram.legacy_visual_nodes or {}) do
				if visual_node.id == pasted_label_id then
					pasted_label = visual_node
					break
				end
			end
			if pasted_label == nil then
				return false, "pasted visual label missing"
			end
			if pasted_label.x ~= 144 or pasted_label.y ~= 98 then
				return false, "visual label should be offset by paste delta"
			end
			return true, "ok"
		end,
	}
end

local function editor_state_connection_case()
	local diagram = {
		name = "editor_state_connection",
		author = "regression",
		nodes = {
			{ id = "source", type = types.NODE.SOURCE, trigger_mode = types.TRIGGER_MODE.AUTOMATIC, initial_resources = 3, rate = 1, data = { finite_source = true } },
			{ id = "target", type = types.NODE.END_CONDITION, trigger_mode = types.TRIGGER_MODE.PASSIVE, initial_resources = 0, rate = 1, enabled = false },
		},
		connections = {},
	}

	return {
		name = "editor_state_connection",
		diagram = nil,
		check = function(_)
			local added, connection_id = EditorActions.append_connection(diagram, "source", "target", types.CONNECTION.STATE, {
				action = types.STATE_ACTION.SET_ENABLED,
				source_field = types.STATE_FIELD.OUTGOING,
				comparator = types.COMPARATOR.GREATER_OR_EQUAL,
				value = 1,
				scale = 1,
				target_enabled = true,
			})
			if not added then
				return false, "append_connection should add a state connection"
			end
			if connection_id == nil then
				return false, "append_connection should return the new state connection id"
			end
			if #(diagram.connections or {}) ~= 1 then
				return false, "diagram should contain one state connection"
			end
			local connection = diagram.connections[1]
			if connection.type ~= types.CONNECTION.STATE then
				return false, "connection type should be state"
			end
			local duplicate_added = EditorActions.append_connection(diagram, "source", "target", types.CONNECTION.STATE, {})
			if duplicate_added ~= false then
				return false, "duplicate state connection should be rejected"
			end
			return true, "ok"
		end,
	}
end

local function editor_history_case()
	local base_diagram = {
		name = "editor_history",
		nodes = {
			{ id = "a", type = types.NODE.POOL, trigger_mode = types.TRIGGER_MODE.PASSIVE, initial_resources = 1, rate = 1 },
		},
		connections = {},
	}
	local base_positions = {
		a = { x = 0, y = 0 },
	}

	return {
		name = "editor_history",
		diagram = nil,
		check = function(_)
			local history = EditorActions.new_history(
				EditorActions.snapshot(base_diagram, base_positions, { "a" }, "a", { x = 0, y = 0, zoom = 1 })
			)
			local next_diagram = EditorActions.clone_table(base_diagram)
			next_diagram.nodes[1].initial_resources = 4
			history = EditorActions.push_history(
				history,
				EditorActions.snapshot(next_diagram, base_positions, { "a" }, "a", { x = 20, y = 10, zoom = 1.2 })
			)
			local undo_snapshot
			history, undo_snapshot = EditorActions.undo_history(history)
			if undo_snapshot == nil or undo_snapshot.diagram.nodes[1].initial_resources ~= 1 then
				return false, "undo_history should restore first snapshot"
			end
			local redo_snapshot
			history, redo_snapshot = EditorActions.redo_history(history)
			if redo_snapshot == nil or redo_snapshot.diagram.nodes[1].initial_resources ~= 4 then
				return false, "redo_history should restore latest snapshot"
			end
			return true, "ok"
		end,
	}
end

local function editor_export_case()
	local diagram = {
		name = "editor_export",
		author = "regression",
		width = 600,
		height = 560,
		nodes = {
			{ id = "source", type = types.NODE.SOURCE, trigger_mode = types.TRIGGER_MODE.AUTOMATIC, initial_resources = 2, rate = 1, data = { finite_source = true } },
			{ id = "buffer", type = types.NODE.POOL, trigger_mode = types.TRIGGER_MODE.PASSIVE, initial_resources = 0, rate = 1 },
			{ id = "sink", type = types.NODE.DRAIN, trigger_mode = types.TRIGGER_MODE.PASSIVE, initial_resources = 0, rate = 1 },
		},
		connections = {
			{ id = "ab", from = "source", to = "buffer", type = types.CONNECTION.RESOURCE, amount = 1 },
			{ id = "bc", from = "buffer", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
		},
	}
	local positions = {
		source = { x = 120, y = 240 },
		buffer = { x = 260, y = 240 },
		sink = { x = 400, y = 240 },
	}

	return {
		name = "editor_export",
		diagram = nil,
		check = function(_)
			local selection = EditorActions.export_selection(diagram, positions, { "source", "buffer" })
			if #(selection.nodes or {}) ~= 2 then
				return false, "export_selection should keep 2 nodes"
			end
			if #(selection.connections or {}) ~= 1 then
				return false, "export_selection should keep 1 internal connection"
			end
			if selection.editor_positions == nil or selection.editor_positions.source == nil then
				return false, "export_selection should include editor positions"
			end
			local svg = EditorActions.build_svg(diagram, positions)
			if type(svg) ~= "string" or not string.find(svg, "<svg", 1, true) then
				return false, "build_svg should return svg markup"
			end
			if not string.find(svg, "editor_export", 1, true) then
				return false, "svg should include graph title"
			end
			if not string.find(svg, "source", 1, true) then
				return false, "svg should include node labels"
			end
			return true, "ok"
		end,
	}
end

local function editor_run_modes_case()
	local diagram = {
		name = "editor_run_modes",
		play_mode = types.PLAY_MODE.BATCH,
		nodes = {
			{
				id = "source",
				type = types.NODE.SOURCE,
				trigger_mode = types.TRIGGER_MODE.AUTOMATIC,
				initial_resources = 3,
				rate = 1,
				data = { finite_source = true },
			},
			{
				id = "sink",
				type = types.NODE.DRAIN,
				trigger_mode = types.TRIGGER_MODE.PASSIVE,
				initial_resources = 0,
				rate = 1,
			},
		},
		connections = {
			{ id = "src_sink", from = "source", to = "sink", type = types.CONNECTION.RESOURCE, amount = 1 },
		},
		["end"] = { max_ticks = 8, stop_when_idle = true },
	}

	return {
		name = "editor_run_modes",
		diagram = nil,
		check = function(_)
			local quick_report = EditorActions.quick_run(diagram, {
				seed = 13,
				max_ticks = 8,
			})
			if quick_report == nil or quick_report.state == nil then
				return false, "quick_run should return a stateful report"
			end
			if quick_report.state.ended ~= true then
				return false, "quick_run should end finite source diagram"
			end

			local batch_report = EditorActions.multiple_runs(diagram, {
				seed = 13,
				runs = 8,
				max_ticks = 8,
			})
			if batch_report == nil or #(batch_report.runs or {}) ~= 8 then
				return false, "multiple_runs should produce 8 runs"
			end
			if batch_report.aggregates == nil or batch_report.aggregates.ticks == nil then
				return false, "multiple_runs should include aggregate ticks"
			end
			return true, "ok"
		end,
	}
end

local function build_cases()
	return {
		delay_release_case(),
		queue_fifo_case(),
		gate_round_robin_case(),
		state_action_rate_case(),
		gate_random_all_case(),
		state_delta_positive_case(),
		state_delta_negative_case(),
		gate_conditional_else_case(),
		legacy_import_mapping_case(),
		end_condition_node_case(),
		artificial_player_fire_case(),
		artificial_player_import_case(),
		autogen_smoke_case(),
		editor_copy_paste_case(),
		editor_visual_copy_paste_case(),
		editor_history_case(),
		editor_export_case(),
		editor_state_connection_case(),
		editor_run_modes_case(),
	}
end

function Regression.run_cases(cases)
	local report = {
		total = 0,
		passed = 0,
		failed = 0,
		cases = {},
	}

	for _, case in ipairs(cases or {}) do
		report.total = report.total + 1
		local case_result = run_case(case)
		report.cases[#report.cases + 1] = case_result
		if case_result.ok then
			report.passed = report.passed + 1
		else
			report.failed = report.failed + 1
		end
	end

	return report
end

function Regression.run_all()
	return Regression.run_cases(build_cases())
end

return Regression
