local SpawnEvent = Instance.new("BindableEvent")
SpawnEvent.Event:Connect(function(Function, Pointer) Function(Pointer()) end)

local function FastSpawn(callback, ...)
	local Length = select("#", ...)
	local Arguments = {...}
	SpawnEvent:Fire(callback, function() return unpack(Arguments, 1, Length) end)
end

return FastSpawn
