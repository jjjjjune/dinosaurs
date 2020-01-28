local function split(str, delimiter)
	local result = {}
	local from  = 1
	local delim_from, delim_to = string.find(str, delimiter, from)

	while delim_from do
		table.insert( result, string.sub(str, from , delim_from-1))
		from  = delim_to + 1
		delim_from, delim_to = string.find(str, delimiter, from)
	end

	table.insert(result, string.sub(str, from))
	return result
end

local function fold(list, initial, callback)
	local accum = initial

	for key = 1, #list do
		accum = callback(accum, list[key], key)
	end

	return accum
end

return function(fullName)
	local directories = split(fullName, "%.")

	return fold(directories, game, function(accum, str, i)
		if i == 1 then
			return accum:GetService(str)
		else
			return accum:WaitForChild(str)
		end
	end)
end