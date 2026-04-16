-- Deterministic seeded RNG with a tiny pure-Lua implementation.
local Rng = {}

local MODULUS = 2147483647
local MULTIPLIER = 48271

local function normalize_seed(seed)
	seed = tonumber(seed) or 1
	seed = seed % MODULUS
	if seed <= 0 then
		seed = seed + MODULUS - 1
	end
	return seed
end

-- Create a new RNG state table.
function Rng.new(seed)
	return {
		seed = normalize_seed(seed),
	}
end

-- Return the next raw integer sample.
function Rng.next_int_raw(rng)
	rng.seed = (rng.seed * MULTIPLIER) % MODULUS
	return rng.seed
end

-- Return a float in [0, 1).
function Rng.random(rng)
	return Rng.next_int_raw(rng) / MODULUS
end

-- Return an integer in [min, max].
function Rng.random_int(rng, min, max)
	if min == nil and max == nil then
		return Rng.next_int_raw(rng)
	end

	if max == nil then
		max = min
		min = 1
	end

	min = math.floor(min or 1)
	max = math.floor(max or min)
	if max < min then
		min, max = max, min
	end

	local span = max - min + 1
	return min + math.floor(Rng.random(rng) * span)
end

-- Return true with probability `chance` in [0, 1].
function Rng.chance(rng, chance)
	chance = tonumber(chance) or 0
	if chance <= 0 then
		return false
	end
	if chance >= 1 then
		return true
	end
	return Rng.random(rng) < chance
end

-- Pick an index from an array of non-negative weights.
function Rng.pick_weighted_index(rng, weights)
	local total = 0
	for _, weight in ipairs(weights) do
		local normalized = math.max(math.floor(weight or 0), 0)
		total = total + normalized
	end

	if total <= 0 then
		return nil
	end

	local pick = Rng.random_int(rng, 1, total)
	local cumulative = 0
	for index, weight in ipairs(weights) do
		cumulative = cumulative + math.max(math.floor(weight or 0), 0)
		if pick <= cumulative then
			return index
		end
	end

	return #weights
end

-- Create another RNG state with the same internal seed.
function Rng.clone(rng)
	return Rng.new(rng.seed)
end

return Rng
