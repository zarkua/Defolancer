local types = require("modules.machinations.types")

local legacy_xml = {}

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

local function trim(value)
	value = tostring(value or "")
	value = value:gsub("^%s+", "")
	value = value:gsub("%s+$", "")
	return value
end

local function starts_with(value, prefix)
	return string.sub(value, 1, #prefix) == prefix
end

local function parse_number(value)
	value = trim(value)
	if value == "" then
		return nil
	end
	return tonumber(value)
end

local function parse_integer(value)
	local numeric = parse_number(value)
	if numeric == nil then
		return nil
	end
	return math.floor(numeric)
end

local function parse_bool(value)
	value = string.lower(trim(value))
	return value == "1" or value == "true" or value == "yes"
end

local function xml_unescape(text)
	text = tostring(text or "")
	text = text:gsub("&#x([0-9a-fA-F]+);", function(hex)
		return string.char(tonumber(hex, 16) or 0)
	end)
	text = text:gsub("&#([0-9]+);", function(num)
		return string.char(tonumber(num) or 0)
	end)
	text = text:gsub("&lt;", "<")
	text = text:gsub("&gt;", ">")
	text = text:gsub("&quot;", "\"")
	text = text:gsub("&apos;", "'")
	text = text:gsub("&amp;", "&")
	return text
end

local function new_element(name, attrs, children, text)
	return {
		name = name,
		attrs = attrs or {},
		children = children or {},
		text = text or "",
	}
end

local function clone_element(element)
	return new_element(
		element.name,
		copy_table(element.attrs),
		copy_table(element.children),
		element.text
	)
end

local function get_attr(element, key)
	if type(element) ~= "table" or type(element.attrs) ~= "table" then
		return ""
	end
	return tostring(element.attrs[key] or "")
end

local function set_attr(element, key, value)
	if value == nil then
		return
	end
	element.attrs[key] = tostring(value)
end

local function find_element(children, name)
	for _, child in ipairs(children or {}) do
		if child.name == name then
			return child
		end
	end
	return nil
end

local function parse_xml(text)
	text = tostring(text or "")
	text = text:gsub("^\239\187\191", "")

	local index = 1
	local length = #text

	local function current(offset)
		offset = offset or 0
		return text:sub(index + offset, index + offset)
	end

	local function skip_whitespace()
		while index <= length and current():match("%s") do
			index = index + 1
		end
	end

	local function skip_until(marker)
		local found = text:find(marker, index, true)
		if not found then
			index = length + 1
			return false
		end
		index = found + #marker
		return true
	end

	local function skip_misc()
		while true do
			skip_whitespace()
			if text:sub(index, index + 3) == "<!--" then
				if not skip_until("-->") then
					return nil, "unterminated XML comment"
				end
			elseif text:sub(index, index + 1) == "<?" then
				if not skip_until("?>") then
					return nil, "unterminated XML processing instruction"
				end
			elseif text:sub(index, index + 8) == "<!DOCTYPE" then
				if not skip_until(">") then
					return nil, "unterminated XML doctype"
				end
			else
				return true
			end
		end
	end

	local function parse_name()
		local start_index = index
		while index <= length and current():match("[%w_:%-%.]") do
			index = index + 1
		end
		if start_index == index then
			return nil, "expected XML name at position " .. tostring(index)
		end
		return text:sub(start_index, index - 1)
	end

	local function parse_quoted_value()
		local quote = current()
		if quote ~= '"' and quote ~= "'" then
			return nil, "expected XML attribute quote at position " .. tostring(index)
		end
		index = index + 1
		local start_index = index
		while index <= length and current() ~= quote do
			index = index + 1
		end
		if index > length then
			return nil, "unterminated XML attribute value"
		end
		local value = text:sub(start_index, index - 1)
		index = index + 1
		return xml_unescape(value)
	end

	local parse_element

	parse_element = function()
		local ok, err = skip_misc()
		if not ok then
			return nil, err
		end
		if current() ~= "<" then
			return nil, "expected '<' at position " .. tostring(index)
		end
		if current(1) == "/" then
			return nil, "unexpected closing tag at position " .. tostring(index)
		end

		index = index + 1
		local name = nil
		name, err = parse_name()
		if not name then
			return nil, err
		end

		local attrs = {}
		while true do
			skip_whitespace()
			if current() == "/" and current(1) == ">" then
				index = index + 2
				return new_element(name, attrs, {}, "")
			end
			if current() == ">" then
				index = index + 1
				break
			end

			local attr_name = nil
			attr_name, err = parse_name()
			if not attr_name then
				return nil, err
			end
			skip_whitespace()
			if current() ~= "=" then
				return nil, "expected '=' after attribute " .. tostring(attr_name)
			end
			index = index + 1
			skip_whitespace()
			local attr_value = nil
			attr_value, err = parse_quoted_value()
			if attr_value == nil then
				return nil, err
			end
			attrs[attr_name] = attr_value
		end

		local children = {}
		local text_parts = {}
		while index <= length do
			if text:sub(index, index + 1) == "</" then
				index = index + 2
				local close_name = nil
				close_name, err = parse_name()
				if not close_name then
					return nil, err
				end
				if close_name ~= name then
					return nil, "mismatched closing tag for " .. tostring(name)
				end
				skip_whitespace()
				if current() ~= ">" then
					return nil, "expected '>' after closing tag " .. tostring(close_name)
				end
				index = index + 1
				break
			end

			if text:sub(index, index + 8) == "<![CDATA[" then
				index = index + 9
				local close_index = text:find("]]>", index, true)
				if not close_index then
					return nil, "unterminated CDATA section"
				end
				text_parts[#text_parts + 1] = text:sub(index, close_index - 1)
				index = close_index + 3
			elseif current() == "<" then
				local child = nil
				child, err = parse_element()
				if not child then
					return nil, err
				end
				children[#children + 1] = child
			else
				local next_lt = text:find("<", index, true) or (length + 1)
				local raw = text:sub(index, next_lt - 1)
				local plain = trim(xml_unescape(raw))
				if plain ~= "" then
					text_parts[#text_parts + 1] = plain
				end
				index = next_lt
			end
		end

		return new_element(name, attrs, children, table.concat(text_parts, " "))
	end

	local ok, err = skip_misc()
	if not ok then
		return nil, err
	end
	local root = nil
	root, err = parse_element()
	if not root then
		return nil, err
	end
	return root
end

local function convert_node_v2_v30(element)
	local converted = new_element("node", {}, {})
	set_attr(converted, "symbol", get_attr(element, "symbol"))
	set_attr(converted, "x", get_attr(element, "x"))
	set_attr(converted, "y", get_attr(element, "y"))
	set_attr(converted, "color", get_attr(element, "colorLine"))
	set_attr(converted, "caption", get_attr(element, "label"))
	set_attr(converted, "thickness", get_attr(element, "thickness"))
	set_attr(converted, "captionPos", get_attr(element, "labelPosition") == "1" and "0.25" or "0.75")
	set_attr(converted, "interactive", get_attr(element, "clickable") == "true" and "1" or "0")
	set_attr(converted, "actions", get_attr(element, "free") == "true" and "0" or "1")

	local symbol = get_attr(converted, "symbol")
	if symbol == "Source" or symbol == "Converter" or symbol == "Drain" then
		set_attr(converted, "resourceColor", get_attr(element, "colorResources"))
	elseif symbol == "Pool" then
		set_attr(converted, "resourceColor", get_attr(element, "colorResources"))
		set_attr(converted, "startingResources", get_attr(element, "startingResources"))
		set_attr(converted, "maxResources", get_attr(element, "maxResources"))
	elseif symbol == "Knot" or symbol == "Gate" then
		set_attr(converted, "symbol", "Gate")
		set_attr(converted, "gateType", string.lower(get_attr(element, "type")))
	elseif symbol == "Chart" then
		set_attr(converted, "width", get_attr(element, "width"))
		set_attr(converted, "height", get_attr(element, "height"))
		set_attr(converted, "scaleX", get_attr(element, "scaleX"))
		set_attr(converted, "scaleY", get_attr(element, "scaleY"))
	elseif symbol == "AIBox" or symbol == "ArtificialPlayer" then
		set_attr(converted, "symbol", "ArtificialPlayer")
	end

	return converted
end

local function convert_connection_v2_v30(element, node_count)
	local converted = new_element("connection", {}, {})
	local connection_type = get_attr(element, "type")
	set_attr(converted, "type", connection_type)
	set_attr(converted, "start", get_attr(element, "start"))
	set_attr(converted, "end", get_attr(element, "end"))

	local start_id = parse_integer(get_attr(element, "start")) or -1
	local end_id = parse_integer(get_attr(element, "end")) or -1

	if start_id < 0 then
		converted.children[#converted.children + 1] = new_element("point", {
			x = get_attr(element, "startX"),
			y = get_attr(element, "startY"),
		}, {})
	end

	for _, child in ipairs(element.children or {}) do
		if child.name == "waypoint" then
			converted.children[#converted.children + 1] = new_element("point", {
				x = get_attr(child, "x"),
				y = get_attr(child, "y"),
			}, {})
		end
	end

	if end_id < 0 then
		converted.children[#converted.children + 1] = new_element("point", {
			x = get_attr(element, "endX"),
			y = get_attr(element, "endY"),
		}, {})
	end

	local label = ""
	local position = 0.5
	local start_modifier = get_attr(element, "startModifier")
	local end_modifier = get_attr(element, "endModifier")
	if start_modifier ~= "" and end_modifier ~= "" then
		if end_modifier == "*" then
			label = start_modifier
			if connection_type == "State" then
				local first = label:sub(1, 1)
				local second = label:sub(2, 2)
				if first ~= "<" and second ~= "=" and first ~= ">" then
					label = ">=" .. label
				end
			end
		else
			label = end_modifier .. "/" .. start_modifier
		end
	elseif start_modifier ~= "" then
		label = start_modifier
		position = 0.25
		if connection_type == "State" then
			label = "1/" .. label
		end
	elseif end_modifier ~= "" then
		label = end_modifier
		position = 0.75
	end

	if label == "*/*" then
		label = "*"
	end
	if connection_type == "State" and label == "*" then
		label = ">0"
		position = 0.5
	end
	if connection_type == "Flow" and label == "*" then
		position = 0.5
		set_attr(converted, "type", "State")
	end

	set_attr(converted, "modifier", label)
	set_attr(converted, "position", position)
	set_attr(converted, "color", get_attr(element, "color"))
	set_attr(converted, "thickness", get_attr(element, "thickness"))

	if end_id > node_count then
		end_id = end_id - node_count
		end_id = math.floor(end_id / 2)
		end_id = end_id + node_count
		set_attr(converted, "end", end_id)
	end
	if start_id > node_count then
		start_id = start_id - node_count
		start_id = math.floor(start_id / 2)
		start_id = start_id + node_count
		set_attr(converted, "start", start_id)
	end

	return converted
end

local function convert_v2_v30(graph)
	local converted = new_element("graph", {}, {})
	set_attr(converted, "version", "v3.0")
	set_attr(converted, "name", get_attr(graph, "name"))
	set_attr(converted, "author", get_attr(graph, "author"))
	set_attr(converted, "interval", "1")
	set_attr(converted, "speed", get_attr(graph, "speed"))
	set_attr(converted, "actions", get_attr(graph, "actions"))
	set_attr(converted, "dice", get_attr(graph, "dice"))
	set_attr(converted, "skill", get_attr(graph, "skill"))
	set_attr(converted, "strategy", get_attr(graph, "strategy"))
	set_attr(converted, "multiplayer", get_attr(graph, "multiplayer"))
	set_attr(converted, "width", get_attr(graph, "width"))
	set_attr(converted, "height", get_attr(graph, "height"))

	local node_count = 0
	for _, child in ipairs(graph.children or {}) do
		if child.name == "node" then
			converted.children[#converted.children + 1] = convert_node_v2_v30(child)
			node_count = node_count + 1
		end
	end
	for _, child in ipairs(graph.children or {}) do
		if child.name == "connection" then
			converted.children[#converted.children + 1] = convert_connection_v2_v30(child, node_count)
		end
	end

	return converted
end

local function convert_v30_v35(graph)
	local converted = new_element("graph", {}, {})
	set_attr(converted, "version", "v3.5")
	set_attr(converted, "name", get_attr(graph, "name"))
	set_attr(converted, "author", get_attr(graph, "author"))
	set_attr(converted, "interval", get_attr(graph, "interval"))
	if get_attr(graph, "actions") == "0" then
		set_attr(converted, "timeMode", "asynchronous")
		set_attr(converted, "actions", "1")
	else
		set_attr(converted, "timeMode", "turn-based")
		set_attr(converted, "actions", get_attr(graph, "actions"))
	end
	set_attr(converted, "distributionMode", "fixed speed")
	set_attr(converted, "speed", get_attr(graph, "speed"))
	set_attr(converted, "dice", get_attr(graph, "dice"))
	set_attr(converted, "skill", get_attr(graph, "skill"))
	set_attr(converted, "strategy", get_attr(graph, "strategy"))
	set_attr(converted, "multiplayer", get_attr(graph, "multiplayer"))
	set_attr(converted, "width", get_attr(graph, "width"))
	set_attr(converted, "height", get_attr(graph, "height"))
	set_attr(converted, "numberOfRuns", get_attr(graph, "numberOfRuns"))
	set_attr(converted, "visibleRuns", get_attr(graph, "visibleRuns"))

	for _, child in ipairs(graph.children or {}) do
		if child.name == "node" then
			local converted_node = clone_element(child)
			if get_attr(converted_node, "symbol") == "Label" then
				set_attr(converted_node, "symbol", "TextLabel")
			end
			converted.children[#converted.children + 1] = converted_node
		elseif child.name == "connection" then
			local converted_connection = clone_element(child)
			if get_attr(converted_connection, "type") == "State" then
				set_attr(converted_connection, "type", "State Connection")
			end
			set_attr(converted_connection, "label", get_attr(child, "modifier"))
			converted.children[#converted.children + 1] = converted_connection
		end
	end

	return converted
end

local function convert_v35_v40(graph)
	local converted = clone_element(graph)
	set_attr(converted, "version", "v4.0")
	for _, child in ipairs(converted.children or {}) do
		if child.name == "node" and get_attr(child, "symbol") == "ArtificialPlayer" then
			set_attr(child, "actionsPerTurn", get_attr(child, "interval"))
		end
		if child.name == "node" and get_attr(child, "symbol") == "Delayer" then
			set_attr(child, "symbol", "Delay")
		end
	end
	return converted
end

local function upgrade_graph(graph)
	local original_version = get_attr(graph, "version")
	local source_version = original_version ~= "" and original_version or "v2"
	local upgraded = clone_element(graph)

	if original_version == "" then
		upgraded = convert_v2_v30(upgraded)
		original_version = get_attr(upgraded, "version")
	end
	if starts_with(original_version, "v3.0") then
		upgraded = convert_v30_v35(upgraded)
		original_version = get_attr(upgraded, "version")
	end
	if starts_with(original_version, "v3.5") then
		upgraded = convert_v35_v40(upgraded)
		original_version = get_attr(upgraded, "version")
	end
	if get_attr(upgraded, "version") == "" then
		set_attr(upgraded, "version", source_version)
	end

	return upgraded, source_version, get_attr(upgraded, "version")
end

local SYMBOL_TO_NODE_TYPE = {
	Pool = types.NODE.POOL,
	Source = types.NODE.SOURCE,
	Drain = types.NODE.DRAIN,
	Converter = types.NODE.CONVERTER,
	Trader = types.NODE.TRADER,
	Gate = types.NODE.GATE,
	Register = types.NODE.REGISTER,
	Delay = types.NODE.DELAY,
	EndCondition = types.NODE.END_CONDITION,
}

local ACTIVATION_TO_TRIGGER = {
	passive = types.TRIGGER_MODE.PASSIVE,
	interactive = types.TRIGGER_MODE.INTERACTIVE,
	automatic = types.TRIGGER_MODE.AUTOMATIC,
	onstart = types.TRIGGER_MODE.AUTOMATIC,
}

local GATE_TYPE_TO_MODE = {
	deterministic = types.GATE_MODE.ROUND_ROBIN,
	random = types.GATE_MODE.RANDOM,
	probabilistic = types.GATE_MODE.RANDOM_ALL,
	dice = types.GATE_MODE.RANDOM,
	skill = types.GATE_MODE.RANDOM,
	strategy = types.GATE_MODE.RANDOM,
	multiplayer = types.GATE_MODE.RANDOM,
}

local LEGACY_ALWAYS_COMPARE_VALUE = -1000000000
local LEGACY_NEVER_COMPARE_VALUE = 1000000000

local function sanitize_id(text)
	text = string.lower(trim(text))
	text = text:gsub("[%s%-]+", "_")
	text = text:gsub("[^%w_]+", "_")
	text = text:gsub("_+", "_")
	text = text:gsub("^_+", "")
	text = text:gsub("_+$", "")
	if text == "" then
		return nil
	end
	if text:match("^[0-9]") then
		text = "n_" .. text
	end
	return text
end

local function looks_like_formula(text)
	text = trim(text)
	if text == "" then
		return false
	end
	if text:find("[%+%-%*/%%()]", 1) then
		return true
	end
	if text:find("[Dd][0-9]", 1) then
		return true
	end
	if text:find("[<>!=]", 1) then
		return true
	end
	return false
end

local function make_unique_id(used_ids, base_name, fallback_prefix)
	local base = sanitize_id(base_name) or sanitize_id(fallback_prefix) or "node"
	if not used_ids[base] then
		used_ids[base] = true
		return base
	end
	local serial = 2
	while true do
		local candidate = base .. "_" .. tostring(serial)
		if not used_ids[candidate] then
			used_ids[candidate] = true
			return candidate
		end
		serial = serial + 1
	end
end

local function raw_to_index(raw_id)
	local numeric = parse_integer(raw_id)
	if numeric == nil or numeric < 0 then
		return nil
	end
	return numeric + 1
end

local function guess_flow_mode(target_element)
	local pull_mode = string.lower(get_attr(target_element, "pullMode"))
	if starts_with(pull_mode, "pull") then
		return types.FLOW_MODE.PULL
	end
	return types.FLOW_MODE.PUSH
end

local function parse_comparator_label(label)
	label = trim(label)

	local interval_numeric = nil
	local interval_expression = nil
	local multiplier = nil
	local draw_random = false

	local before_interval, after_interval = label:match("^(.-)/(.-)$")
	if before_interval ~= nil and after_interval ~= nil then
		label = trim(before_interval)
		interval_expression = trim(after_interval)
		interval_numeric = parse_number(interval_expression)
	end

	local multiplier_text, base_text = label:match("^(-?[%d%.]+)%*(.+)$")
	if multiplier_text ~= nil and base_text ~= nil then
		multiplier = tonumber(multiplier_text)
		label = trim(base_text)
	end

	if starts_with(string.lower(label), "draw") then
		draw_random = true
		label = trim(string.sub(label, 5))
	end

	local function with_meta(payload)
		payload.interval = interval_numeric
		payload.interval_expression = interval_expression
		payload.multiplier = multiplier
		payload.draw_random = draw_random
		return payload
	end

	if label == "" then
		return with_meta({
			kind = "empty",
			number = 1,
		})
	end

	if label == "*" then
		return with_meta({ kind = "trigger" })
	end

	if label == "!" then
		return with_meta({ kind = "reverse_trigger" })
	end

	if label == "%" then
		return with_meta({ kind = "probability_dynamic" })
	end

	if string.lower(label) == "else" then
		return with_meta({ kind = "else" })
	end

	if string.lower(label) == "all" then
		return with_meta({ kind = "all" })
	end

	if label == "D" or label == "S" or label == "ST" or label == "M" then
		return with_meta({
			kind = "random_source",
			source = label,
		})
	end

	local sign = string.sub(label, 1, 1)
	if sign == "+" or sign == "-" then
		local suffix = string.sub(label, -1)
		local number_text = string.sub(label, 2)
		local kind = "change_value"
		if suffix == "m" then
			kind = "change_multiplier"
			number_text = string.sub(number_text, 1, -2)
		elseif suffix == "c" then
			kind = "change_capacity"
			number_text = string.sub(number_text, 1, -2)
		elseif suffix == "i" then
			kind = "change_interval"
			number_text = string.sub(number_text, 1, -2)
		elseif suffix == "%" then
			kind = "change_probability"
			number_text = string.sub(number_text, 1, -2)
		end
		local numeric = tonumber(number_text)
		if numeric ~= nil then
			if sign == "-" then
				numeric = -numeric
			end
			return with_meta({
				kind = kind,
				number = numeric,
			})
		end
	end

	local comparator, numeric = label:match("^(>=|<=|==|!=|>|<)%s*(-?[%d%.]+)$")
	if comparator ~= nil then
		return with_meta({
			kind = "condition",
			comparator = comparator,
			value = tonumber(numeric) or 0,
		})
	end

	local left, right = label:match("^(-?[%d%.]+)%.%.(-?[%d%.]+)$")
	if left ~= nil and right ~= nil then
		return with_meta({
			kind = "range",
			min = tonumber(left) or 0,
			max = tonumber(right) or 0,
		})
	end
	local left_dash, right_dash = label:match("^(-?[%d%.]+)%s*%-%s*(-?[%d%.]+)$")
	if left_dash ~= nil and right_dash ~= nil then
		return with_meta({
			kind = "range",
			min = tonumber(left_dash) or 0,
			max = tonumber(right_dash) or 0,
		})
	end

	local probability_numeric = label:match("^(-?[%d%.]+)%%$")
	if probability_numeric ~= nil then
		return with_meta({
			kind = "probability",
			number = tonumber(probability_numeric) or 0,
		})
	end

	local numeric_only = tonumber(label)
	if numeric_only ~= nil then
		return with_meta({
			kind = "numeric",
			number = numeric_only,
		})
	end

	if looks_like_formula(label) then
		return with_meta({
			kind = "expression",
			expression = label,
		})
	end

	return with_meta({ kind = "unsupported" })
end

local function build_imported_node(element, used_ids)
	local symbol = get_attr(element, "symbol")
	local node_type = SYMBOL_TO_NODE_TYPE[symbol]
	local delay_type = string.lower(get_attr(element, "delayType"))
	if symbol == "Delay" and delay_type == "queue" then
		node_type = types.NODE.QUEUE
	end
	if node_type == nil then
		return nil
	end

	local caption = trim(get_attr(element, "caption"))
	local node_id = make_unique_id(used_ids, caption, string.lower(symbol))
	local activation_mode = string.lower(get_attr(element, "activationMode"))
	if parse_bool(get_attr(element, "interactive")) then
		activation_mode = "interactive"
	end
	local trigger_mode = ACTIVATION_TO_TRIGGER[activation_mode] or types.TRIGGER_MODE.PASSIVE
	local node = {
		id = node_id,
		type = node_type,
		trigger_mode = trigger_mode,
		initial_resources = 0,
		rate = 1,
		register_value = 0,
		enabled = true,
		data = {
			legacy_symbol = symbol,
			legacy_caption = caption,
			legacy_color = get_attr(element, "color"),
			legacy_thickness = parse_number(get_attr(element, "thickness")),
			legacy_caption_pos = parse_number(get_attr(element, "captionPos")),
			legacy_pull_mode = get_attr(element, "pullMode"),
			legacy_actions = parse_integer(get_attr(element, "actions")),
			legacy_resource_color = get_attr(element, "resourceColor"),
			legacy_activation_mode = activation_mode,
		},
	}

	if symbol == "Pool" then
		node.initial_resources = parse_integer(get_attr(element, "startingResources")) or 0
		local capacity = parse_integer(get_attr(element, "capacity")) or parse_integer(get_attr(element, "maxResources"))
		if capacity ~= nil and capacity >= 0 then
			node.capacity = capacity
		end
		node.data.legacy_display_capacity = parse_integer(get_attr(element, "displayCapacity"))
	elseif symbol == "Register" then
		node.register_value = parse_number(get_attr(element, "start")) or 0
		node.data.legacy_min = parse_number(get_attr(element, "min"))
		node.data.legacy_max = parse_number(get_attr(element, "max"))
		node.data.legacy_step = parse_number(get_attr(element, "step"))
		if looks_like_formula(caption) then
			node.data.register_expression = caption
		end
	elseif symbol == "Gate" then
		node.gate_mode = GATE_TYPE_TO_MODE[string.lower(get_attr(element, "gateType"))] or types.GATE_MODE.ALL
		node.data.legacy_gate_type = get_attr(element, "gateType")
	elseif symbol == "Delay" then
		node.delay_ticks = 1
		node.data.legacy_delay_type = get_attr(element, "delayType")
	elseif symbol == "Source" then
		node.data.finite_source = false
	elseif symbol == "EndCondition" then
		node.enabled = false
	end

	return node
end

local function build_visual_node(element, used_ids)
	local symbol = get_attr(element, "symbol")
	local caption = trim(get_attr(element, "caption"))
	local node_id = make_unique_id(used_ids, caption, string.lower(symbol))
	local script_text = trim(element.text)
	return {
		id = node_id,
		symbol = symbol,
		caption = caption,
		x = parse_number(get_attr(element, "x")) or 0,
		y = parse_number(get_attr(element, "y")) or 0,
		width = parse_integer(get_attr(element, "width")) or 132,
		height = parse_integer(get_attr(element, "height")) or 72,
		color = get_attr(element, "color"),
		thickness = parse_number(get_attr(element, "thickness")),
		caption_pos = get_attr(element, "captionPos"),
		scale_x = parse_number(get_attr(element, "scaleX")),
		scale_y = parse_number(get_attr(element, "scaleY")),
		actions_per_turn = parse_number(get_attr(element, "actionsPerTurn")),
		activation_mode = get_attr(element, "activationMode"),
		pull_mode = get_attr(element, "pullMode"),
		gate_type = get_attr(element, "gateType"),
		delay_type = get_attr(element, "delayType"),
		script = script_text ~= "" and script_text or nil,
	}
end

local function collect_connection_points(element)
	local points = {}
	for _, point in ipairs(element.children or {}) do
		if point.name == "point" then
			points[#points + 1] = {
				x = parse_number(get_attr(point, "x")) or 0,
				y = parse_number(get_attr(point, "y")) or 0,
			}
		end
	end
	return points
end

local function build_base_diagram(graph, source_version, upgraded_version)
	local diagram = {
		name = get_attr(graph, "name"),
		author = get_attr(graph, "author"),
		play_mode = string.lower(get_attr(graph, "timeMode")) == "turn-based" and types.PLAY_MODE.INTERACTIVE or types.PLAY_MODE.HEADLESS,
		distribution_mode = get_attr(graph, "distributionMode") ~= "" and get_attr(graph, "distributionMode") or "fixed speed",
		interval = parse_number(get_attr(graph, "interval")) or 1,
		dice = get_attr(graph, "dice"),
		skill = get_attr(graph, "skill"),
		strategy = get_attr(graph, "strategy"),
		multiplayer = get_attr(graph, "multiplayer"),
		width = parse_integer(get_attr(graph, "width")) or 600,
		height = parse_integer(get_attr(graph, "height")) or 560,
		nodes = {},
		connections = {},
		legacy_visual_nodes = {},
		legacy_visual_connections = {},
		editor_positions = {},
		["end"] = {
			stop_when_idle = true,
			max_ticks = 1000,
			conditions = {},
		},
		legacy_import = {
			source_version = source_version,
			upgraded_version = upgraded_version,
			speed = parse_number(get_attr(graph, "speed")),
			actions = parse_integer(get_attr(graph, "actions")),
			number_of_runs = parse_integer(get_attr(graph, "numberOfRuns")),
			visible_runs = parse_integer(get_attr(graph, "visibleRuns")),
			color_coding = parse_integer(get_attr(graph, "colorCoding")) or 1,
			warnings = {},
			unsupported_nodes = {},
			skipped_connections = {},
		},
	}
	return diagram
end

local function push_warning(diagram, message, details)
	diagram.legacy_import.warnings[#diagram.legacy_import.warnings + 1] = {
		message = message,
		details = details,
	}
end

local function push_skipped_connection(diagram, raw_index, reason, label)
	diagram.legacy_import.skipped_connections[#diagram.legacy_import.skipped_connections + 1] = {
		index = raw_index,
		reason = reason,
		label = label,
	}
end

local function set_legacy_label_metadata(connection, parsed)
	connection.data.legacy_label_kind = parsed.kind
	connection.data.legacy_interval = parsed.interval
	connection.data.legacy_interval_expression = parsed.interval_expression
	connection.data.legacy_multiplier = parsed.multiplier
	connection.data.legacy_draw_random = parsed.draw_random
	if parsed.expression ~= nil then
		connection.data.legacy_expression = parsed.expression
	end
end

local function get_legacy_label_scale(parsed, fallback)
	local scale = parsed.number
	if scale == nil then
		scale = fallback
	end
	if scale == nil then
		scale = 1
	end
	if parsed.multiplier ~= nil then
		scale = scale * parsed.multiplier
	end
	return scale
end

local function is_resource_buffer_type(node_type)
	return node_type == types.NODE.POOL or node_type == types.NODE.DELAY or node_type == types.NODE.QUEUE
end

local function import_graph(graph, source_version, upgraded_version)
	local diagram = build_base_diagram(graph, source_version, upgraded_version)
	local used_ids = {}
	local raw_elements = {}
	for _, child in ipairs(graph.children or {}) do
		if child.name == "node" or child.name == "connection" then
			raw_elements[#raw_elements + 1] = child
		end
	end

	local raw_meta = {}
	for raw_index, element in ipairs(raw_elements) do
		if element.name == "node" then
			local imported = build_imported_node(element, used_ids)
			if imported ~= nil then
				diagram.nodes[#diagram.nodes + 1] = imported
				diagram.editor_positions[imported.id] = {
					x = parse_number(get_attr(element, "x")) or 0,
					y = parse_number(get_attr(element, "y")) or 0,
				}
				raw_meta[raw_index] = {
					kind = "node",
					imported_id = imported.id,
					node_type = imported.type,
					raw = element,
				}
			else
				local symbol = get_attr(element, "symbol")
				local visual_node = build_visual_node(element, used_ids)
				raw_meta[raw_index] = {
					kind = "node",
					visual_id = visual_node.id,
					raw = element,
				}
				diagram.legacy_visual_nodes[#diagram.legacy_visual_nodes + 1] = visual_node
				diagram.legacy_import.unsupported_nodes[#diagram.legacy_import.unsupported_nodes + 1] = {
					index = raw_index,
					symbol = symbol,
					caption = get_attr(element, "caption"),
				}
				push_warning(diagram, "legacy node imported as visual-only", {
					index = raw_index,
					symbol = symbol,
				})
			end
		else
			raw_meta[raw_index] = {
				kind = "connection",
				raw = element,
			}
		end
	end

	for raw_index, element in ipairs(raw_elements) do
		if element.name == "connection" then
			local start_index = raw_to_index(get_attr(element, "start"))
			local end_index = raw_to_index(get_attr(element, "end"))
			local label = trim(get_attr(element, "label"))
			local visual_points = collect_connection_points(element)
			local start_meta = start_index and raw_meta[start_index] or nil
			local end_meta = end_index and raw_meta[end_index] or nil
			if start_meta == nil or end_meta == nil then
				if #visual_points >= 2 then
					diagram.legacy_visual_connections[#diagram.legacy_visual_connections + 1] = {
						id = "legacy_connection_" .. tostring(#diagram.legacy_visual_connections + 1),
						type = get_attr(element, "type"),
						label = label,
						color = get_attr(element, "color"),
						thickness = parse_number(get_attr(element, "thickness")),
						points = visual_points,
						floating = true,
					}
					push_warning(diagram, "dangling legacy connection imported as visual-only polyline", {
						index = raw_index,
						label = label,
					})
				else
					push_skipped_connection(diagram, raw_index, "dangling element id", label)
				end
			elseif start_meta.kind ~= "node" or end_meta.kind ~= "node" then
				push_skipped_connection(diagram, raw_index, "connection-to-connection links are not supported", label)
			elseif start_meta.imported_id == nil or end_meta.imported_id == nil then
				diagram.legacy_visual_connections[#diagram.legacy_visual_connections + 1] = {
					id = "legacy_connection_" .. tostring(#diagram.legacy_visual_connections + 1),
					type = get_attr(element, "type"),
					label = label,
					color = get_attr(element, "color"),
					thickness = parse_number(get_attr(element, "thickness")),
					from = start_meta.imported_id or start_meta.visual_id,
					to = end_meta.imported_id or end_meta.visual_id,
					points = visual_points,
				}
				push_warning(diagram, "legacy connection to visual-only node imported as visual-only", {
					index = raw_index,
					label = label,
				})
			else
				local connection_type = string.lower(get_attr(element, "type"))
				local connection = {
					id = "connection_" .. tostring(#diagram.connections + 1),
					from = start_meta.imported_id,
					to = end_meta.imported_id,
					type = types.CONNECTION.RESOURCE,
					amount = 1,
					weight = 1,
					flow_mode = guess_flow_mode(end_meta.raw),
					data = {
						legacy_type = get_attr(element, "type"),
						legacy_label = label,
						legacy_position = parse_number(get_attr(element, "position")),
						legacy_color = get_attr(element, "color"),
						legacy_thickness = parse_number(get_attr(element, "thickness")),
						legacy_min = parse_number(get_attr(element, "min")),
						legacy_max = parse_number(get_attr(element, "max")),
						legacy_points = {},
					},
				}

				connection.data.legacy_points = visual_points

				if connection_type == "state connection" or connection_type == "state" then
					local parsed = parse_comparator_label(label)
					local source_field = start_meta.node_type == types.NODE.REGISTER and types.STATE_FIELD.REGISTER or types.STATE_FIELD.RESOURCES
					local target_type = end_meta.node_type
					set_legacy_label_metadata(connection, parsed)
					if parsed.kind == "empty"
						or parsed.kind == "numeric"
						or parsed.kind == "change_value"
						or parsed.kind == "expression"
					then
						connection.type = types.CONNECTION.STATE
						connection.source_field = source_field
						connection.comparator = types.COMPARATOR.GREATER_OR_EQUAL
						connection.value = LEGACY_ALWAYS_COMPARE_VALUE
						connection.use_delta = true
						connection.scale = get_legacy_label_scale(parsed, 1)

						if parsed.kind == "expression" then
							connection.scale = 1
							connection.data.scale_expression = parsed.expression
						end

						if target_type == types.NODE.REGISTER then
							connection.action = types.STATE_ACTION.SET_REGISTER
							connection.register_op = "add"
							push_warning(diagram, "state-to-register connection imported as delta register modifier", {
								index = raw_index,
								label = label,
							})
						elseif target_type == types.NODE.POOL then
							connection.action = types.STATE_ACTION.ADD_RESOURCE
							push_warning(diagram, "state-to-pool connection imported as delta resource modifier", {
								index = raw_index,
								label = label,
							})
						elseif target_type == types.NODE.GATE then
							connection.action = types.STATE_ACTION.SET_REGISTER
							connection.register_op = "add"
							connection.data.legacy_target_modifier = "gate_input"
							push_warning(diagram, "state-to-gate connection imported as gate input modifier", {
								index = raw_index,
								label = label,
							})
						elseif target_type == types.NODE.DELAY or target_type == types.NODE.QUEUE then
							connection.action = types.STATE_ACTION.SET_REGISTER
							connection.register_op = "add"
							connection.data.legacy_target_modifier = "delay_input"
							push_warning(diagram, "state-to-delay connection imported as delay input modifier", {
								index = raw_index,
								label = label,
							})
						else
							push_skipped_connection(diagram, raw_index, "unsupported state connection target", label)
							connection = nil
						end
					elseif parsed.kind == "change_capacity" and target_type == types.NODE.POOL then
						connection.type = types.CONNECTION.STATE
						connection.action = types.STATE_ACTION.SET_CAPACITY
						connection.source_field = source_field
						connection.comparator = types.COMPARATOR.GREATER_OR_EQUAL
						connection.value = LEGACY_ALWAYS_COMPARE_VALUE
						connection.use_delta = true
						connection.scale = get_legacy_label_scale(parsed, 1)
						connection.register_op = "add"
						push_warning(diagram, "state-to-pool capacity connection imported as delta capacity modifier", {
							index = raw_index,
							label = label,
						})
					elseif parsed.kind == "condition" or parsed.kind == "range" or parsed.kind == "else" then
						connection.type = types.CONNECTION.STATE
						connection.action = types.STATE_ACTION.SET_ENABLED
						connection.source_field = source_field
						connection.target_enabled = true
						connection.data.condition_sets_enabled = true
						if parsed.kind == "condition" then
							connection.comparator = parsed.comparator
							connection.value = parsed.value
						elseif parsed.kind == "range" then
							connection.comparator = types.COMPARATOR.GREATER_OR_EQUAL
							connection.value = parsed.min
							local field_name = source_field == types.STATE_FIELD.REGISTER and "register" or "resources"
							connection.condition_expression = string.format("%s <= %s", field_name, tostring(parsed.max))
						else
							connection.comparator = types.COMPARATOR.GREATER
							connection.value = LEGACY_NEVER_COMPARE_VALUE
						end
						push_warning(diagram, "state condition imported as enable/disable gate", {
							index = raw_index,
							label = label,
						})
					else
						push_skipped_connection(diagram, raw_index, "unsupported state connection label", label)
						connection = nil
					end
				else
					local parsed = parse_comparator_label(label)
					set_legacy_label_metadata(connection, parsed)
					if start_meta.node_type == types.NODE.GATE then
						if parsed.kind == "condition" then
							connection.data.legacy_gate_label_kind = "condition"
							connection.data.gate_condition_comparator = parsed.comparator
							connection.data.gate_condition_value = parsed.value
						elseif parsed.kind == "range" then
							connection.data.legacy_gate_label_kind = "range"
							connection.data.gate_condition_min = parsed.min
							connection.data.gate_condition_max = parsed.max
						elseif parsed.kind == "else" then
							connection.data.legacy_gate_label_kind = "else"
						elseif parsed.kind == "probability" or parsed.kind == "numeric" then
							connection.data.legacy_gate_label_kind = parsed.kind
							connection.weight = math.max(tonumber(parsed.number) or 0, 0)
						elseif parsed.kind == "probability_dynamic" then
							connection.data.legacy_gate_label_kind = "probability_dynamic"
							connection.weight = 0
						elseif parsed.kind == "expression" then
							connection.data.weight_expression = parsed.expression
							connection.data.legacy_gate_label_kind = "expression"
						elseif parsed.kind == "all" then
							connection.data.legacy_gate_label_kind = "all"
							connection.data.amount_expression = "resources"
						else
							push_warning(diagram, "non-numeric gate label preserved as legacy metadata", {
								index = raw_index,
								label = label,
							})
						end
					elseif parsed.kind == "all" then
						connection.data.amount_expression = "resources"
					elseif parsed.kind == "expression" then
						connection.data.amount_expression = parsed.expression
					elseif parsed.kind == "numeric" and parsed.number > 0 then
						connection.amount = math.max(math.floor(parsed.number), 1)
					elseif label ~= "" and label ~= "*" and parsed.kind == "unsupported" then
						connection.data.amount_expression = label
					end
				end

				if connection ~= nil then
					diagram.connections[#diagram.connections + 1] = connection
				end
			end
		end
	end

	local node_lookup = {}
	for _, node in ipairs(diagram.nodes) do
		node_lookup[node.id] = node
	end
	for _, connection in ipairs(diagram.connections) do
		local source_node = node_lookup[connection.from]
		if source_node ~= nil and (source_node.type == types.NODE.DELAY or source_node.type == types.NODE.QUEUE) then
			local numeric = parse_integer(connection.data.legacy_label)
			if numeric ~= nil and numeric > 0 then
				source_node.delay_ticks = numeric
				connection.amount = 1
				connection.data.legacy_label_role = "delay_ticks"
			end
		end
	end

	return diagram
end

function legacy_xml.decode_diagram_xml(xml_text)
	local root, parse_err = parse_xml(xml_text)
	if root == nil then
		return nil, parse_err
	end
	if root.name ~= "graph" then
		local nested_graph = find_element(root.children or {}, "graph")
		if nested_graph == nil then
			return nil, "legacy XML root must be <graph>"
		end
		root = nested_graph
	end

	local upgraded, source_version, upgraded_version = upgrade_graph(root)
	local diagram = import_graph(upgraded, source_version, upgraded_version)
	return diagram
end

return legacy_xml
