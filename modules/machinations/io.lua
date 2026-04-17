local io_module = {}

local std_io = io
local global_json = json
local legacy_xml_backend = require("modules.machinations.legacy_xml")

local function has_json_api(module_value)
	return type(module_value) == "table"
		and type(module_value.decode) == "function"
		and type(module_value.encode) == "function"
end

local function wrap_unsafe_json_api(module_value, module_name)
	return {
		name = module_name,
		decode = function(text)
			local ok, result = pcall(module_value.decode, text)
			if not ok then
				return nil, tostring(result)
			end
			if result == nil then
				return nil, module_name .. ": decode failed"
			end
			return result
		end,
		encode = function(value)
			local ok, result = pcall(module_value.encode, value)
			if not ok then
				return nil, tostring(result)
			end
			if result == nil then
				return nil, module_name .. ": encode failed"
			end
			return result
		end,
	}
end

local function wrap_safe_json_api(module_value, module_name)
	return {
		name = module_name,
		decode = function(text)
			local result, err = module_value.decode(text)
			if result == nil then
				return nil, tostring(err or (module_name .. ": decode failed"))
			end
			return result
		end,
		encode = function(value)
			local result, err = module_value.encode(value)
			if result == nil then
				return nil, tostring(err or (module_name .. ": encode failed"))
			end
			return result
		end,
	}
end

local function pick_json_backend()
	if has_json_api(global_json) then
		return wrap_unsafe_json_api(global_json, "json")
	end

	local ok_builtin, builtin_json = pcall(require, "json")
	if ok_builtin and has_json_api(builtin_json) then
		return wrap_unsafe_json_api(builtin_json, "json")
	end

	local ok_safe, cjson_safe = pcall(require, "cjson.safe")
	if ok_safe and has_json_api(cjson_safe) then
		return wrap_safe_json_api(cjson_safe, "cjson.safe")
	end

	local ok_cjson, cjson = pcall(require, "cjson")
	if ok_cjson and has_json_api(cjson) then
		return wrap_unsafe_json_api(cjson, "cjson")
	end

	return nil, "json backend is not available (tried json, cjson.safe, cjson)"
end

local JSON_BACKEND, JSON_BACKEND_ERROR = pick_json_backend()

local function is_whitespace(char)
	return char == " " or char == "\n" or char == "\r" or char == "\t"
end

local function next_non_whitespace_char(text, from_index)
	local text_length = #text
	for index = from_index, text_length do
		local char = text:sub(index, index)
		if not is_whitespace(char) then
			return char, index
		end
	end
	return nil, nil
end

local function simple_pretty_json(json_text)
	local out = {}
	local indent = 0
	local indent_unit = "  "
	local in_string = false
	local escaped = false
	local last_token = "none"

	local function append(value)
		out[#out + 1] = value
	end

	local function append_indent(current_indent)
		append(string.rep(indent_unit, current_indent))
	end

	local function append_newline_with_indent(current_indent)
		append("\n")
		append_indent(current_indent)
	end

	for index = 1, #json_text do
		local char = json_text:sub(index, index)

		if in_string then
			append(char)
			if escaped then
				escaped = false
			elseif char == "\\" then
				escaped = true
			elseif char == "\"" then
				in_string = false
				last_token = "value"
			end
		else
			if char == "\"" then
				in_string = true
				append(char)
			elseif is_whitespace(char) then
				-- Skip insignificant whitespace from compact JSON.
			elseif char == "{" or char == "[" then
				append(char)
				local next_char = next_non_whitespace_char(json_text, index + 1)
				local closes_immediately =
					(char == "{" and next_char == "}")
					or (char == "[" and next_char == "]")
				if not closes_immediately then
					indent = indent + 1
					append_newline_with_indent(indent)
				end
				last_token = (char == "{") and "open_object" or "open_array"
			elseif char == "}" or char == "]" then
				local was_empty =
					last_token == "open_object" or last_token == "open_array"
				if was_empty then
					append(char)
				else
					indent = math.max(indent - 1, 0)
					append_newline_with_indent(indent)
					append(char)
				end
				last_token = (char == "}") and "close_object" or "close_array"
			elseif char == "," then
				append(char)
				append_newline_with_indent(indent)
				last_token = "comma"
			elseif char == ":" then
				append(": ")
				last_token = "colon"
			else
				append(char)
				last_token = "value"
			end
		end
	end

	return table.concat(out)
end

local function ensure_json_backend()
	if JSON_BACKEND ~= nil then
		return true
	end
	return nil, JSON_BACKEND_ERROR
end

local function decode_json(json_text)
	local ok, err = ensure_json_backend()
	if not ok then
		return nil, err
	end
	return JSON_BACKEND.decode(json_text)
end

local function decode_diagram_xml(xml_text)
	if type(legacy_xml_backend) ~= "table" or type(legacy_xml_backend.decode_diagram_xml) ~= "function" then
		return nil, "legacy XML backend is missing decode_diagram_xml()"
	end
	return legacy_xml_backend.decode_diagram_xml(xml_text)
end

local function normalize_resource_path(path)
	if type(path) ~= "string" or path == "" then
		return nil
	end
	if string.sub(path, 1, 1) == "/" then
		return path
	end
	return "/" .. path
end

local function read_text_file_or_resource(path)
	local file, open_err = std_io.open(path, "rb")
	if file then
		local text, read_err = file:read("*a")
		file:close()
		if not text then
			return nil, string.format("failed to read '%s': %s", path, tostring(read_err))
		end
		return text
	end

	if type(sys) == "table" and type(sys.load_resource) == "function" then
		local resource_path = normalize_resource_path(path)
		local text, resource_err = sys.load_resource(resource_path)
		if text ~= nil then
			return text
		end
		return nil, string.format(
			"failed to open '%s' for reading: %s; sys.load_resource('%s') failed: %s",
			path,
			tostring(open_err),
			tostring(resource_path),
			tostring(resource_err)
		)
	end

	return nil, string.format("failed to open '%s' for reading: %s", path, tostring(open_err))
end

local function encode_json(value, pretty)
	local ok, err = ensure_json_backend()
	if not ok then
		return nil, err
	end

	local json_text, encode_err = JSON_BACKEND.encode(value)
	if not json_text then
		return nil, encode_err
	end

	if pretty then
		json_text = simple_pretty_json(json_text)
	end

	return json_text
end

function io_module.decode_diagram_json(json_text)
	return decode_json(json_text)
end

function io_module.decode_diagram_xml(xml_text)
	return decode_diagram_xml(xml_text)
end

function io_module.encode_diagram_json(diagram_table, pretty)
	return encode_json(diagram_table, pretty)
end

function io_module.decode_diagram_file(path)
	local json_text, read_err = read_text_file_or_resource(path)
	if not json_text then
		return nil, read_err
	end

	local first_char = next_non_whitespace_char(json_text, 1)
	if first_char == "<" then
		return decode_diagram_xml(json_text)
	end

	return decode_json(json_text)
end

function io_module.encode_diagram_file(path, diagram_table, pretty)
	local json_text, encode_err = encode_json(diagram_table, pretty)
	if not json_text then
		return nil, encode_err
	end

	local file, open_err = std_io.open(path, "wb")
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

function io_module.encode_batch_report_json(report_table, pretty)
	return encode_json(report_table, pretty)
end

return io_module
