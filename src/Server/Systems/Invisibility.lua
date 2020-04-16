local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local invisibleBits = {}


local function manageVisibility()
	for object, timeEnd in pairs(invisibleBits) do
		if not object:FindFirstChild("OriginalTransparency") then
			if object:IsA("BasePart") or object:IsA("Decal") then
				local x = Instance.new("NumberValue", object)
				x.Name = "OriginalTransparency"
				x.Value = object.Transparency
			end
		end
		if tick() > timeEnd or object.Parent == nil then
			if object:IsA("BasePart") or object:IsA("Decal") then
				if object:IsA("BasePart") then
					object.Material = Enum.Material.SmoothPlastic
				end
				object.Transparency = object.OriginalTransparency.Value
				object.OriginalTransparency:Destroy()
				invisibleBits[object] = nil
			else
				object.Enabled = true
				invisibleBits[object] = nil
			end
		else
			if object:IsA("BasePart") or object:IsA("Decal") then
				object.Transparency = 1
				if object:IsA("BasePart") then
					object.Material = Enum.Material.Glass
					object.Transparency = 1
				end
			elseif object:IsA("BillboardGui") then
				object.Enabled = false
			end
		end
	end
end

local Invisibility = {}

function Invisibility:start()
	Messages:hook("MakeInvisible", function(thing, time)
		if thing:IsA("Tool") or thing.Parent:IsA("Tool") then return end
		for _, v in pairs(thing:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("BillboardGui") then
				if not (v:IsA("BasePart") and v.Transparency > 0.98) then
					invisibleBits[v] = tick() + time
				end
			end
		end
	end)
	game:GetService("RunService").Stepped:connect(function()
		manageVisibility()
	end)
end

return Invisibility
