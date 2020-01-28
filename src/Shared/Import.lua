local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Lib.t)
local FromFullName = require(script.Parent:WaitForChild("Utils"):WaitForChild("FromFullName"))
local aliasesMap = require(ReplicatedStorage:WaitForChild("ImportPaths"))

local DEFAULT_ROOT = game
local DELIMETER = "/+"

local function getPotentialAlias(name)
	return FromFullName(aliasesMap[name])
end

local function recurseWait(fromInst, path)
    local start, stop = string.find(path, DELIMETER)

    local fst = start and string.sub(path, 1, start - 1) or path
    local snd = stop and string.sub(path, stop + 1) or ""

    if fst == "." then
        return recurseWait(fromInst, snd)
    elseif fst:match("[.]+") then
        return recurseWait(fromInst.Parent, snd)
    end

    local result
	if fromInst == DEFAULT_ROOT then
		result = getPotentialAlias(fst) or fromInst:GetService(fst)
    else
        result = fromInst:WaitForChild(fst)
    end

    if result then
        if snd ~= "" then
            return recurseWait(result, snd)
        elseif result:IsA("ModuleScript") then
            return require(result)
        else
            return result
        end
    end
end

--[[
	Given a required module and an array of names that the module exports,
	returns those exports as a tuple.

	For example:

		local module = {
			foo = true,
			bar = false
		}

		local foo, bar = getExports(module, { "foo", "bar" })
		print(foo, bar) -- true, false
]]
local function getExports(result, exportNames)
	local exports = {}

	for _, name in ipairs(exportNames) do
		local export = result[name]
		assert(export, ("no export named %s"):format(name))
		table.insert(exports, export)
	end

	return unpack(exports)
end

local pathLookupCache = {}

local check = t.tuple(
	t.string,
	t.optional(t.array(t.string))
)
return function(path, exports)
	assert(check(path, exports))

    local cachedResult = pathLookupCache[path]
	if cachedResult then
		if exports then
			return getExports(cachedResult, exports)
		end
        return cachedResult
    end

    local fromInst
    local shouldCache = false

    -- Check if we're searching from the current directory
    if string.match(path, "^[.]") then
        fromInst = getfenv(2)["script"]
    else
        fromInst = DEFAULT_ROOT
        shouldCache = true
    end

    -- Throw away the root directory "/"
    path = string.gsub(path, "^"..DELIMETER, "")

    local result = recurseWait(fromInst, path)
    if shouldCache and result then
        pathLookupCache[path] = result
	end

	if exports then
		return getExports(result, exports)
	end

    return result
end
