-- Safe expression evaluator for Machinations-like formulas.
local expression = {}

local EMPTY_EXPRESSION_PATTERN = "^%s*$"

local function if_else(condition, when_true, when_false)
	if condition then
		return when_true
	end
	return when_false
end

local function round(value, digits)
	value = tonumber(value) or 0
	digits = tonumber(digits) or 0
	local power = 10 ^ digits
	return math.floor(value * power + 0.5) / power
end

local function sign(value)
	value = tonumber(value) or 0
	if value > 0 then
		return 1
	end
	if value < 0 then
		return -1
	end
	return 0
end

local function clamp_value(value, min_value, max_value)
	value = tonumber(value) or 0
	min_value = tonumber(min_value) or value
	max_value = tonumber(max_value) or value
	if max_value < min_value then
		min_value, max_value = max_value, min_value
	end
	if value < min_value then
		return min_value
	end
	if value > max_value then
		return max_value
	end
	return value
end

local function lerp(start_value, end_value, alpha)
	start_value = tonumber(start_value) or 0
	end_value = tonumber(end_value) or 0
	alpha = tonumber(alpha) or 0
	return start_value + (end_value - start_value) * alpha
end

local function sum(...)
	local total = 0
	for index = 1, select("#", ...) do
		total = total + (tonumber(select(index, ...)) or 0)
	end
	return total
end

local function avg(...)
	local count = select("#", ...)
	if count <= 0 then
		return 0
	end
	return sum(...) / count
end

local function is_integer(value)
	if type(value) ~= "number" then
		return false
	end

	if math.type ~= nil then
		return math.type(value) == "integer"
	end

	return value % 1 == 0
end

local function safe_log(value, base)
	if base == nil then
		return math.log(value)
	end

	return math.log(value) / math.log(base)
end

local function runtime_random(env)
	if type(env.__rng_random) == "function" then
		return env.__rng_random()
	end

	return math.random()
end

local function runtime_rand(env, min_value, max_value)
	if min_value == nil and max_value == nil then
		return runtime_random(env)
	end

	if max_value == nil then
		max_value = min_value
		min_value = 1
	end

	min_value = tonumber(min_value)
	max_value = tonumber(max_value)
	if min_value == nil or max_value == nil then
		error("rand(min, max) expects numeric arguments")
	end

	if max_value < min_value then
		min_value, max_value = max_value, min_value
	end

	if type(env.__rng_random_int) == "function" then
		return env.__rng_random_int(min_value, max_value)
	end

	if is_integer(min_value) and is_integer(max_value) then
		return math.random(min_value, max_value)
	end

	return min_value + (max_value - min_value) * runtime_random(env)
end

local function runtime_chance(env, probability)
	probability = tonumber(probability) or 0
	if probability <= 0 then
		return false
	end
	if probability >= 1 then
		return true
	end
	return runtime_random(env) <= probability
end

local function runtime_choose(env, ...)
	local count = select("#", ...)
	if count <= 0 then
		return nil
	end
	local random_value = runtime_random(env)
	local index = math.floor(random_value * count) + 1
	if index > count then
		index = count
	end
	return select(index, ...)
end

local function create_runtime_env()
	local env = {
		if_else = if_else,
		round = round,
		pow = math.pow or function(base, exponent)
			return base ^ exponent
		end,
		clamp = clamp_value,
		lerp = lerp,
		sign = sign,
		sum = sum,
		avg = avg,
		min = math.min,
		max = math.max,
		abs = math.abs,
		floor = math.floor,
		ceil = math.ceil,
		sqrt = math.sqrt,
		log = safe_log,
		exp = math.exp,
		sin = math.sin,
		cos = math.cos,
		tan = math.tan,
		__rng_random = nil,
		__rng_random_int = nil,
	}

	env.random = function()
		return runtime_random(env)
	end

	env.rand = function(min_value, max_value)
		return runtime_rand(env, min_value, max_value)
	end

	env.chance = function(probability)
		return runtime_chance(env, probability)
	end

	env.choose = function(...)
		return runtime_choose(env, ...)
	end

	local static_keys = {
		if_else = true,
		round = true,
		pow = true,
		clamp = true,
		lerp = true,
		sign = true,
		sum = true,
		avg = true,
		min = true,
		max = true,
		abs = true,
		floor = true,
		ceil = true,
		sqrt = true,
		log = true,
		exp = true,
		sin = true,
		cos = true,
		tan = true,
		random = true,
		rand = true,
		chance = true,
		choose = true,
		__rng_random = true,
		__rng_random_int = true,
	}

	return env, static_keys
end

local function normalize_expression_text(expression_text)
	if expression_text == nil then
		return nil, nil
	end

	if type(expression_text) ~= "string" then
		return nil, "expression must be a string"
	end

	if expression_text:match(EMPTY_EXPRESSION_PATTERN) ~= nil then
		return nil, nil
	end

	return expression_text, nil
end

local function apply_context(env, static_keys, context)
	for key, _ in pairs(env) do
		if static_keys[key] ~= true then
			env[key] = nil
		end
	end

	env.__rng_random = nil
	env.__rng_random_int = nil

	if type(context) ~= "table" then
		return
	end

	for key, value in pairs(context) do
		if type(key) == "string" and static_keys[key] ~= true then
			env[key] = value
		end
	end

	if type(context.rng_random) == "function" then
		env.__rng_random = context.rng_random
	end

	if type(context.rng_random_int) == "function" then
		env.__rng_random_int = context.rng_random_int
	end
end

local function compile_chunk(source_code, env)
	if load ~= nil then
		local ok, chunk_or_err, load_err = pcall(load, source_code, "=(machinations_expression)", "t", env)
		if ok and chunk_or_err ~= nil then
			return chunk_or_err, nil
		end

		if ok and chunk_or_err == nil then
			return nil, tostring(load_err)
		end
	end

	if loadstring ~= nil then
		local chunk, err = loadstring(source_code, "=(machinations_expression)")
		if chunk == nil then
			return nil, tostring(err)
		end

		if setfenv ~= nil then
			setfenv(chunk, env)
		end

		return chunk, nil
	end

	return nil, "no supported loader found (load/loadstring unavailable)"
end

local function ensure_allowed_result_type(value)
	local value_type = type(value)
	if value_type == "nil" or value_type == "number" or value_type == "boolean" or value_type == "string" then
		return true, nil
	end

	return false, "runtime error: expression returned unsupported type '" .. value_type .. "'"
end

local function empty_compiled_function(_context)
	return nil, nil
end

function expression.compile(expression_text)
	local normalized_text, normalize_err = normalize_expression_text(expression_text)
	if normalize_err ~= nil then
		return nil, normalize_err
	end

	if normalized_text == nil then
		return empty_compiled_function, nil
	end

	local runtime_env, static_keys = create_runtime_env()
	local source_code = "return (" .. normalized_text .. ")"
	local chunk, compile_err = compile_chunk(source_code, runtime_env)
	if chunk == nil then
		return nil, "compile error: " .. tostring(compile_err)
	end

	return function(context)
		apply_context(runtime_env, static_keys, context)

		local ok, value_or_err = pcall(chunk)
		if not ok then
			return nil, "runtime error: " .. tostring(value_or_err)
		end

		local type_ok, type_err = ensure_allowed_result_type(value_or_err)
		if not type_ok then
			return nil, type_err
		end

		return value_or_err, nil
	end, nil
end

function expression.evaluate(expression_text, context_table)
	local fn, compile_err = expression.compile(expression_text)
	if fn == nil then
		return nil, compile_err
	end

	return fn(context_table)
end

return expression
