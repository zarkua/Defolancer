local Batch = require("modules.machinations.batch")
local Engine = require("modules.machinations.engine")
local types = require("modules.machinations.types")

local EditorActions = {}
local render_svg_shape

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

local function xml_escape(value)
	local text = tostring(value or "")
	text = string.gsub(text, "&", "&amp;")
	text = string.gsub(text, "<", "&lt;")
	text = string.gsub(text, ">", "&gt;")
	text = string.gsub(text, "\"", "&quot;")
	return text
end

local function normalize_selection(selected_ids)
	local ordered = {}
	local seen = {}
	for _, node_id in ipairs(selected_ids or {}) do
		if type(node_id) == "string" and not seen[node_id] then
			seen[node_id] = true
			ordered[#ordered + 1] = node_id
		end
	end
	return ordered, seen
end

local function shallow_metadata(diagram)
	local out = {}
	for key, value in pairs(diagram or {}) do
		if key ~= "nodes"
			and key ~= "connections"
			and key ~= "editor_positions"
			and key ~= "legacy_visual_nodes"
			and key ~= "legacy_visual_connections" then
			out[key] = copy_table(value)
		end
	end
	out.nodes = {}
	out.connections = {}
	out.editor_positions = {}
	out.legacy_visual_nodes = {}
	out.legacy_visual_connections = {}
	return out
end

local function find_node(diagram, node_id)
	for _, node in ipairs(diagram.nodes or {}) do
		if node.id == node_id then
			return node
		end
	end
	return nil
end

local function find_visual_node(diagram, node_id)
	for _, visual_node in ipairs(diagram.legacy_visual_nodes or {}) do
		if visual_node.id == node_id then
			return visual_node
		end
	end
	return nil
end

local function build_existing_id_lookup(diagram)
	local ids = {}
	for _, node in ipairs(diagram.nodes or {}) do
		ids[node.id] = true
	end
	for _, visual_node in ipairs(diagram.legacy_visual_nodes or {}) do
		ids[visual_node.id] = true
	end
	for _, connection in ipairs(diagram.connections or {}) do
		ids[connection.id] = true
	end
	for _, connection in ipairs(diagram.legacy_visual_connections or {}) do
		ids[connection.id] = true
	end
	return ids
end

local function make_unique_id(existing_ids, base_id)
	local normalized = tostring(base_id or "item")
	if not existing_ids[normalized] then
		existing_ids[normalized] = true
		return normalized
	end

	local suffix = 1
	while true do
		local candidate = string.format("%s_copy_%d", normalized, suffix)
		if not existing_ids[candidate] then
			existing_ids[candidate] = true
			return candidate
		end
		suffix = suffix + 1
	end
end

local function node_dimensions(node_type)
	if node_type == types.NODE.SOURCE or node_type == types.NODE.DRAIN then
		return 88, 72
	end
	if node_type == types.NODE.GATE then
		return 84, 84
	end
	if node_type == types.NODE.POOL then
		return 92, 92
	end
	if node_type == types.NODE.CONVERTER then
		return 118, 74
	end
	if node_type == types.NODE.TRADER then
		return 122, 78
	end
	if node_type == types.NODE.REGISTER then
		return 88, 88
	end
	if node_type == types.NODE.DELAY or node_type == types.NODE.QUEUE then
		return 94, 86
	end
	if node_type == types.NODE.END_CONDITION then
		return 84, 84
	end
	return 112, 70
end

local function visual_dimensions(visual_node)
	local symbol = tostring(visual_node and visual_node.symbol or "")
	if symbol == "TextLabel" then
		return math.max((#tostring(visual_node.caption or "") * 8) + 32, 84), 28
	end
	if symbol == "GroupBox" or symbol == "Chart" then
		return math.max(tonumber(visual_node.width) or 132, 96), math.max(tonumber(visual_node.height) or 72, 56)
	end
	if symbol == "ArtificialPlayer" or symbol == "EndCondition" then
		return 90, 56
	end
	return math.max(tonumber(visual_node.width) or 132, 72), math.max(tonumber(visual_node.height) or 72, 42)
end

local function resolve_visual_center(visual_node)
	local width, height = visual_dimensions(visual_node)
	local x = tonumber(visual_node.x) or 0
	local y = tonumber(visual_node.y) or 0
	local symbol = tostring(visual_node.symbol or "")
	if symbol == "Chart" or symbol == "GroupBox" then
		x = x + width * 0.5
		y = y - height * 0.5
	end
	return x, y, width, height
end

local function shift_visual_node(visual_node, offset_x, offset_y)
	visual_node.x = (tonumber(visual_node.x) or 0) + offset_x
	visual_node.y = (tonumber(visual_node.y) or 0) + offset_y
end

local function render_svg_visual(parts, visual_node, canvas_height)
	local symbol = tostring(visual_node.symbol or "")
	local x, y, width, height = resolve_visual_center(visual_node)
	local draw_y = canvas_height - y
	local stroke = "#1f2937"

	if symbol == "TextLabel" then
		parts[#parts + 1] = string.format(
			"<text x=\"%.1f\" y=\"%.1f\" font-family=\"Segoe UI, Arial\" font-size=\"18\" fill=\"#111827\" text-anchor=\"middle\">%s</text>",
			x,
			draw_y,
			xml_escape(visual_node.caption or visual_node.id)
		)
		return
	end

	if symbol == "GroupBox" then
		parts[#parts + 1] = string.format(
			"<rect x=\"%.1f\" y=\"%.1f\" width=\"%.1f\" height=\"%.1f\" rx=\"10\" ry=\"10\" fill=\"none\" stroke=\"#6b7280\" stroke-width=\"2\" stroke-dasharray=\"7 6\" />",
			x - width * 0.5,
			draw_y - height * 0.5,
			width,
			height
		)
		parts[#parts + 1] = string.format(
			"<text x=\"%.1f\" y=\"%.1f\" font-family=\"Segoe UI, Arial\" font-size=\"16\" fill=\"#111827\" text-anchor=\"start\">%s</text>",
			x - width * 0.45,
			draw_y - height * 0.38,
			xml_escape(visual_node.caption or visual_node.id)
		)
		return
	end

	if symbol == "Chart" then
		parts[#parts + 1] = string.format(
			"<rect x=\"%.1f\" y=\"%.1f\" width=\"%.1f\" height=\"%.1f\" rx=\"8\" ry=\"8\" fill=\"#ffffff\" stroke=\"#4b5563\" stroke-width=\"2\" />",
			x - width * 0.5,
			draw_y - height * 0.5,
			width,
			height
		)
		parts[#parts + 1] = string.format(
			"<text x=\"%.1f\" y=\"%.1f\" font-family=\"Segoe UI, Arial\" font-size=\"14\" fill=\"#111827\" text-anchor=\"start\">%s</text>",
			x - width * 0.42,
			draw_y - height * 0.34,
			xml_escape(visual_node.caption or "Chart")
		)
		return
	end

	if symbol == "ArtificialPlayer" then
		parts[#parts + 1] = string.format(
			"<rect x=\"%.1f\" y=\"%.1f\" width=\"%.1f\" height=\"%.1f\" rx=\"12\" ry=\"12\" fill=\"#f9fafb\" stroke=\"%s\" stroke-width=\"3\" />",
			x - width * 0.5,
			draw_y - height * 0.5,
			width,
			height,
			stroke
		)
		parts[#parts + 1] = string.format(
			"<text x=\"%.1f\" y=\"%.1f\" font-family=\"Segoe UI, Arial\" font-size=\"18\" fill=\"#111827\" text-anchor=\"middle\">AP</text>",
			x,
			draw_y + 6
		)
		return
	end

	if symbol == "EndCondition" then
		render_svg_shape(parts, { type = types.NODE.END_CONDITION }, x, draw_y, width, height)
		return
	end
end

render_svg_shape = function(parts, node, x, y, width, height)
	local stroke = "#1f2937"
	local fill = "#ffffff"
	if node.type == types.NODE.SOURCE then
		local p1x = x
		local p1y = y + height * 0.5
		local p2x = x - width * 0.5
		local p2y = y - height * 0.5
		local p3x = x + width * 0.5
		local p3y = y - height * 0.5
		parts[#parts + 1] = string.format(
			"<polygon points=\"%.1f,%.1f %.1f,%.1f %.1f,%.1f\" fill=\"%s\" stroke=\"%s\" stroke-width=\"3\" />",
			p1x, p1y, p2x, p2y, p3x, p3y, fill, stroke
		)
	elseif node.type == types.NODE.DRAIN then
		local p1x = x - width * 0.5
		local p1y = y + height * 0.5
		local p2x = x + width * 0.5
		local p2y = y + height * 0.5
		local p3x = x
		local p3y = y - height * 0.5
		parts[#parts + 1] = string.format(
			"<polygon points=\"%.1f,%.1f %.1f,%.1f %.1f,%.1f\" fill=\"%s\" stroke=\"%s\" stroke-width=\"3\" />",
			p1x, p1y, p2x, p2y, p3x, p3y, fill, stroke
		)
	elseif node.type == types.NODE.GATE then
		local left = x - width * 0.5
		local right = x + width * 0.5
		local top = y + height * 0.5
		local bottom = y - height * 0.5
		parts[#parts + 1] = string.format(
			"<polygon points=\"%.1f,%.1f %.1f,%.1f %.1f,%.1f %.1f,%.1f\" fill=\"%s\" stroke=\"%s\" stroke-width=\"3\" />",
			x, top, right, y, x, bottom, left, y, fill, stroke
		)
	elseif node.type == types.NODE.POOL or node.type == types.NODE.REGISTER then
		parts[#parts + 1] = string.format(
			"<circle cx=\"%.1f\" cy=\"%.1f\" r=\"%.1f\" fill=\"%s\" stroke=\"%s\" stroke-width=\"3\" />",
			x, y, math.min(width, height) * 0.5, fill, stroke
		)
	elseif node.type == types.NODE.CONVERTER then
		local left = x - width * 0.5
		local right = x + width * 0.5
		local top = y + height * 0.5
		local bottom = y - height * 0.5
		parts[#parts + 1] = string.format(
			"<polygon points=\"%.1f,%.1f %.1f,%.1f %.1f,%.1f\" fill=\"%s\" stroke=\"%s\" stroke-width=\"3\" />",
			left, top, right, y, left, bottom, fill, stroke
		)
		parts[#parts + 1] = string.format(
			"<line x1=\"%.1f\" y1=\"%.1f\" x2=\"%.1f\" y2=\"%.1f\" stroke=\"%s\" stroke-width=\"3\" />",
			left + width * 0.18, top - height * 0.04, left + width * 0.18, bottom + height * 0.04, stroke
		)
	elseif node.type == types.NODE.TRADER then
		local left = x - width * 0.5
		local right = x + width * 0.5
		local top = y + height * 0.5
		local bottom = y - height * 0.5
		parts[#parts + 1] = string.format(
			"<polygon points=\"%.1f,%.1f %.1f,%.1f %.1f,%.1f\" fill=\"%s\" stroke=\"%s\" stroke-width=\"3\" />",
			left, top, x, y, left, bottom, fill, stroke
		)
		parts[#parts + 1] = string.format(
			"<polygon points=\"%.1f,%.1f %.1f,%.1f %.1f,%.1f\" fill=\"%s\" stroke=\"%s\" stroke-width=\"3\" />",
			x, top, right, y, x, bottom, fill, stroke
		)
	elseif node.type == types.NODE.DELAY or node.type == types.NODE.QUEUE then
		local left = x - width * 0.5
		local right = x + width * 0.5
		local top = y + height * 0.5
		local bottom = y - height * 0.5
		local mid = y
		parts[#parts + 1] = string.format(
			"<polygon points=\"%.1f,%.1f %.1f,%.1f %.1f,%.1f %.1f,%.1f\" fill=\"%s\" stroke=\"%s\" stroke-width=\"3\" />",
			left, top, right, top, x, mid, left, top, fill, stroke
		)
		parts[#parts + 1] = string.format(
			"<polygon points=\"%.1f,%.1f %.1f,%.1f %.1f,%.1f %.1f,%.1f\" fill=\"%s\" stroke=\"%s\" stroke-width=\"3\" />",
			left, bottom, right, bottom, x, mid, left, bottom, fill, stroke
		)
	elseif node.type == types.NODE.END_CONDITION then
		local left = x - width * 0.5
		local bottom = y - height * 0.5
		parts[#parts + 1] = string.format(
			"<rect x=\"%.1f\" y=\"%.1f\" width=\"%.1f\" height=\"%.1f\" fill=\"%s\" stroke=\"%s\" stroke-width=\"3\" />",
			left, bottom, width, height, fill, stroke
		)
		parts[#parts + 1] = string.format(
			"<rect x=\"%.1f\" y=\"%.1f\" width=\"%.1f\" height=\"%.1f\" fill=\"#111827\" stroke=\"%s\" stroke-width=\"2\" />",
			x - width * 0.22, y - height * 0.22, width * 0.44, height * 0.44, stroke
		)
	else
		parts[#parts + 1] = string.format(
			"<rect x=\"%.1f\" y=\"%.1f\" width=\"%.1f\" height=\"%.1f\" rx=\"12\" ry=\"12\" fill=\"%s\" stroke=\"%s\" stroke-width=\"3\" />",
			x - width * 0.5, y - height * 0.5, width, height, fill, stroke
		)
	end
end

function EditorActions.clone_table(value)
	return copy_table(value)
end

function EditorActions.select_all(diagram)
	local selected = {}
	for _, node in ipairs(diagram.nodes or {}) do
		selected[#selected + 1] = node.id
	end
	for _, visual_node in ipairs(diagram.legacy_visual_nodes or {}) do
		selected[#selected + 1] = visual_node.id
	end
	return selected
end

function EditorActions.export_selection(diagram, positions, selected_ids)
	local ordered_ids, selected_lookup = normalize_selection(selected_ids)
	local selection = shallow_metadata(diagram)
	if #ordered_ids == 0 then
		return selection
	end

	for _, node_id in ipairs(ordered_ids) do
		local node = find_node(diagram, node_id)
		if node ~= nil then
			selection.nodes[#selection.nodes + 1] = copy_table(node)
			if type(positions) == "table" and type(positions[node_id]) == "table" then
				selection.editor_positions[node_id] = copy_table(positions[node_id])
			end
		end
		local visual_node = find_visual_node(diagram, node_id)
		if visual_node ~= nil then
			selection.legacy_visual_nodes[#selection.legacy_visual_nodes + 1] = copy_table(visual_node)
		end
	end

	for _, connection in ipairs(diagram.connections or {}) do
		if selected_lookup[connection.from] and selected_lookup[connection.to] then
			selection.connections[#selection.connections + 1] = copy_table(connection)
		end
	end

	for _, connection in ipairs(diagram.legacy_visual_connections or {}) do
		local from_selected = connection.from == nil or selected_lookup[connection.from] == true
		local to_selected = connection.to == nil or selected_lookup[connection.to] == true
		if from_selected and to_selected then
			selection.legacy_visual_connections[#selection.legacy_visual_connections + 1] = copy_table(connection)
		end
	end

	return selection
end

function EditorActions.copy_selection(diagram, positions, selected_ids)
	local ordered_ids = normalize_selection(selected_ids)
	if #ordered_ids == 0 then
		return nil
	end

	local selection = EditorActions.export_selection(diagram, positions, ordered_ids)
	return {
		diagram = selection,
		positions = copy_table(selection.editor_positions),
		selected_ids = ordered_ids,
	}
end

function EditorActions.paste_selection(diagram, positions, clipboard, options)
	local source_diagram = clipboard and (clipboard.diagram or clipboard) or nil
	if source_diagram == nil then
		return copy_table(diagram), copy_table(positions), {}, {}
	end

	local offset_x = tonumber(options and options.offset_x) or 20
	local offset_y = tonumber(options and options.offset_y) or 20
	local source_positions = clipboard.positions or source_diagram.editor_positions or {}

	local out_diagram = copy_table(diagram)
	local out_positions = copy_table(positions or {})
	out_diagram.legacy_visual_nodes = out_diagram.legacy_visual_nodes or {}
	out_diagram.legacy_visual_connections = out_diagram.legacy_visual_connections or {}
	local existing_ids = build_existing_id_lookup(out_diagram)
	local id_map = {}
	local pasted_ids = {}

	for _, node in ipairs(source_diagram.nodes or {}) do
		local cloned = copy_table(node)
		local new_id = make_unique_id(existing_ids, cloned.id)
		id_map[cloned.id] = new_id
		cloned.id = new_id
		out_diagram.nodes[#out_diagram.nodes + 1] = cloned
		local original_pos = source_positions[node.id] or { x = 0, y = 0 }
		out_positions[new_id] = {
			x = (tonumber(original_pos.x) or 0) + offset_x,
			y = (tonumber(original_pos.y) or 0) + offset_y,
		}
		pasted_ids[#pasted_ids + 1] = new_id
	end

	for _, connection in ipairs(source_diagram.connections or {}) do
		if id_map[connection.from] ~= nil and id_map[connection.to] ~= nil then
			local cloned = copy_table(connection)
			cloned.id = make_unique_id(existing_ids, cloned.id)
			cloned.from = id_map[connection.from]
			cloned.to = id_map[connection.to]
			out_diagram.connections[#out_diagram.connections + 1] = cloned
		end
	end

	for _, visual_node in ipairs(source_diagram.legacy_visual_nodes or {}) do
		local cloned = copy_table(visual_node)
		local new_id = make_unique_id(existing_ids, cloned.id)
		id_map[cloned.id] = new_id
		cloned.id = new_id
		shift_visual_node(cloned, offset_x, offset_y)
		out_diagram.legacy_visual_nodes[#out_diagram.legacy_visual_nodes + 1] = cloned
		pasted_ids[#pasted_ids + 1] = new_id
	end

	for _, connection in ipairs(source_diagram.legacy_visual_connections or {}) do
		local from_id = connection.from
		local to_id = connection.to
		if (from_id == nil or id_map[from_id] ~= nil) and (to_id == nil or id_map[to_id] ~= nil) then
			local cloned = copy_table(connection)
			cloned.id = make_unique_id(existing_ids, cloned.id)
			cloned.from = from_id ~= nil and id_map[from_id] or nil
			cloned.to = to_id ~= nil and id_map[to_id] or nil
			for _, point in ipairs(cloned.points or {}) do
				point.x = (tonumber(point.x) or 0) + offset_x
				point.y = (tonumber(point.y) or 0) + offset_y
			end
			out_diagram.legacy_visual_connections[#out_diagram.legacy_visual_connections + 1] = cloned
		end
	end

	return out_diagram, out_positions, pasted_ids, id_map
end

function EditorActions.append_connection(diagram, from_id, to_id, connection_type, options)
	if diagram == nil or from_id == nil or to_id == nil or from_id == to_id then
		return false
	end

	local normalized_type = connection_type or types.CONNECTION.RESOURCE
	for _, connection in ipairs(diagram.connections or {}) do
		if connection.type == normalized_type and connection.from == from_id and connection.to == to_id then
			return false
		end
	end

	diagram.connections = diagram.connections or {}
	local existing_ids = build_existing_id_lookup(diagram)
	local connection_id = make_unique_id(existing_ids, normalized_type == types.CONNECTION.STATE and "state_connection" or "connection")

	local connection = {
		id = connection_id,
		from = from_id,
		to = to_id,
		type = normalized_type,
	}

	if normalized_type == types.CONNECTION.STATE then
		connection.action = options and options.action or types.STATE_ACTION.SET_ENABLED
		connection.source_field = options and options.source_field or types.STATE_FIELD.RESOURCES
		connection.comparator = options and options.comparator or types.COMPARATOR.GREATER
		connection.value = tonumber(options and options.value) or 0
		connection.scale = tonumber(options and options.scale) or 1
		connection.use_delta = options and options.use_delta == true or false
		connection.target_enabled = options == nil or options.target_enabled ~= false
		connection.target_trigger_mode = options and options.target_trigger_mode or nil
		connection.target_variable = options and options.target_variable or nil
		connection.target_rate = options and options.target_rate or nil
		connection.target_capacity = options and options.target_capacity or nil
		connection.register_op = options and options.register_op or "set"
		connection.data = type(options and options.data) == "table" and copy_table(options.data) or {}
	else
		connection.flow_mode = options and options.flow_mode or types.FLOW_MODE.PUSH
		connection.amount = tonumber(options and options.amount) or 1
		connection.data = type(options and options.data) == "table" and copy_table(options.data) or nil
	end

	diagram.connections[#diagram.connections + 1] = connection
	return true, connection_id
end

function EditorActions.snapshot(diagram, positions, selected_ids, primary_selected_id, camera)
	return {
		diagram = copy_table(diagram),
		positions = copy_table(positions or {}),
		selected_ids = copy_table(selected_ids or {}),
		primary_selected_id = primary_selected_id,
		camera = copy_table(camera or {}),
	}
end

function EditorActions.new_history(initial_snapshot, limit)
	local history = {
		stack = {},
		index = 0,
		limit = limit or 16,
	}
	if initial_snapshot ~= nil then
		history.stack[1] = copy_table(initial_snapshot)
		history.index = 1
	end
	return history
end

function EditorActions.push_history(history, snapshot)
	local stack = history.stack or {}
	while #stack > history.index do
		table.remove(stack)
	end
	stack[#stack + 1] = copy_table(snapshot)
	if #stack > (history.limit or 16) then
		table.remove(stack, 1)
	end
	history.stack = stack
	history.index = #stack
	return history
end

function EditorActions.undo_history(history)
	if history.index <= 1 then
		return history, history.stack[history.index] and copy_table(history.stack[history.index]) or nil
	end
	history.index = history.index - 1
	return history, copy_table(history.stack[history.index])
end

function EditorActions.redo_history(history)
	if history.index >= #history.stack then
		return history, history.stack[history.index] and copy_table(history.stack[history.index]) or nil
	end
	history.index = history.index + 1
	return history, copy_table(history.stack[history.index])
end

function EditorActions.normalize_run_settings(number_of_runs, visible_runs)
	local runs = math.max(1, math.floor(tonumber(number_of_runs) or 100))
	local visible = math.max(1, math.floor(tonumber(visible_runs) or 25))
	visible = math.min(visible, runs)
	return runs, visible
end

function EditorActions.quick_run(diagram, options)
	local state, err = Engine.init(diagram, {
		seed = options and options.seed or 17,
		play_mode = types.PLAY_MODE.BATCH,
	})
	if not state then
		return nil, err
	end

	local max_ticks = math.max(1, math.floor(tonumber(options and options.max_ticks) or 300))
	for _ = 1, max_ticks do
		Engine.step(state)
		if state.ended then
			break
		end
	end

	return {
		state = state,
		ticks = state.tick or 0,
		ended = state.ended == true,
		end_reason = state.end_reason,
	}
end

function EditorActions.multiple_runs(diagram, options)
	local runs, _ = EditorActions.normalize_run_settings(
		options and options.runs or 100,
		options and options.visible_runs or 25
	)
	return Batch.run(diagram, {
		runs = runs,
		max_ticks = math.max(1, math.floor(tonumber(options and options.max_ticks) or 300)),
		seed = options and options.seed or 17,
	})
end

function EditorActions.build_svg(diagram, positions, options)
	local title = tostring(diagram.name or "Machinations")
	local width = math.floor(tonumber(options and options.width or diagram.width) or 600)
	local height = math.floor(tonumber(options and options.height or diagram.height) or 560)
	local parts = {
		string.format(
			"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\">",
			width,
			height,
			width,
			height
		),
		string.format("<title>%s</title>", xml_escape(title)),
		"<defs><marker id=\"arrow\" markerWidth=\"10\" markerHeight=\"10\" refX=\"7\" refY=\"3\" orient=\"auto\"><path d=\"M0,0 L8,3 L0,6 Z\" fill=\"#374151\" /></marker></defs>",
		"<rect width=\"100%\" height=\"100%\" fill=\"#ffffff\" />",
	}

	local entity_positions = copy_table(positions or {})
	for _, visual_node in ipairs(diagram.legacy_visual_nodes or {}) do
		local center_x, center_y = resolve_visual_center(visual_node)
		entity_positions[visual_node.id] = {
			x = center_x,
			y = center_y,
		}
	end

	for _, connection in ipairs(diagram.connections or {}) do
		local from_pos = entity_positions[connection.from]
		local to_pos = entity_positions[connection.to]
		if from_pos ~= nil and to_pos ~= nil then
			local dash = connection.type == types.CONNECTION.STATE and " stroke-dasharray=\"7 7\"" or ""
			parts[#parts + 1] = string.format(
				"<line x1=\"%.1f\" y1=\"%.1f\" x2=\"%.1f\" y2=\"%.1f\" stroke=\"#374151\" stroke-width=\"3\" marker-end=\"url(#arrow)\"%s />",
				from_pos.x,
				height - from_pos.y,
				to_pos.x,
				height - to_pos.y,
				dash
			)
		end
	end

	for _, connection in ipairs(diagram.legacy_visual_connections or {}) do
		local from_pos = connection.from ~= nil and entity_positions[connection.from] or nil
		local to_pos = connection.to ~= nil and entity_positions[connection.to] or nil
		if from_pos ~= nil and to_pos ~= nil then
			parts[#parts + 1] = string.format(
				"<line x1=\"%.1f\" y1=\"%.1f\" x2=\"%.1f\" y2=\"%.1f\" stroke=\"#6b7280\" stroke-width=\"2\" stroke-dasharray=\"6 5\" marker-end=\"url(#arrow)\" />",
				from_pos.x,
				height - from_pos.y,
				to_pos.x,
				height - to_pos.y
			)
		end
	end

	for _, node in ipairs(diagram.nodes or {}) do
		local pos = entity_positions[node.id]
		if pos ~= nil then
			local x = tonumber(pos.x) or 0
			local y = height - (tonumber(pos.y) or 0)
			local node_width, node_height = node_dimensions(node.type)
			parts[#parts + 1] = "<g>"
			render_svg_shape(parts, node, x, y, node_width, node_height)
			parts[#parts + 1] = string.format(
				"<text x=\"%.1f\" y=\"%.1f\" font-family=\"Segoe UI, Arial\" font-size=\"16\" fill=\"#111827\" text-anchor=\"middle\">%s</text>",
				x,
				y + node_height * 0.8,
				xml_escape((node.data and node.data.legacy_caption) or node.id)
			)
			parts[#parts + 1] = "</g>"
		end
	end

	for _, visual_node in ipairs(diagram.legacy_visual_nodes or {}) do
		parts[#parts + 1] = "<g>"
		render_svg_visual(parts, visual_node, height)
		parts[#parts + 1] = "</g>"
	end

	parts[#parts + 1] = "</svg>"
	return table.concat(parts, "\n")
end

return EditorActions
