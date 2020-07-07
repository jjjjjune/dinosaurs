local import = require(game.ReplicatedStorage.Shared.Import)

local ItemPlacementHelperUi = game.Players.LocalPlayer.PlayerGui:WaitForChild("ItemPlacementHelper")

local GetCharacter = import "Shared/Utils/GetCharacter"
local CastRay = import "Shared/Utils/CastRay"

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- local function getAttachedItemsToIgnore(item)
-- 	local itemsToIgnore = {}
-- 	local ignored = {}
-- 	if item:FindFirstChild("ObjectWeld") then
--         local weldedItem = item.ObjectWeld.Part1.Parent
-- 		if not ignored[item] then
-- 			ignored[item] = true
--             for _, v in pairs((getAttachedItemsToIgnore(weldedItem, itemsToIgnore))) do
--                 table.insert(itemsToIgnore, v)
--             end
--         end
-- 	end
-- 	return (itemsToIgnore)
-- end


local function getPlaceableSurface(item)
	local character = GetCharacter()
	local start = character.HumanoidRootPart.CFrame * CFrame.new(0,4,-4)
	local hit, pos = CastRay(start.p, Vector3.new(0,-8,0), {item, game.Players.LocalPlayer.Character})
	if (hit) and (CollectionService:HasTag(hit.Parent, "Building") or CollectionService:HasTag(hit.Parent, "Monster")) then
		if hit.Anchored == false then
			return hit, pos
		end
	end
end

local function runHelper()
	local shouldShow = false
	local showPosition = Vector3.new()
	local character = GetCharacter()
	if character then
		for _, v in pairs(character:GetChildren()) do
			if CollectionService:HasTag(v, "Item") then
				local hit, pos = getPlaceableSurface(v)
				if hit then
					shouldShow = true
					showPosition = pos
				end
			end
		end
	end
	if shouldShow then
		local vector, onScreen = workspace.CurrentCamera:WorldToScreenPoint(showPosition)
		ItemPlacementHelperUi.AttachLabel.Visible = true
		ItemPlacementHelperUi.AttachLabelShadow.Visible = true
		ItemPlacementHelperUi.AttachLabel.Position = UDim2.new(0, vector.X, 0, vector.Y)
		ItemPlacementHelperUi.AttachLabelShadow.Position = UDim2.new(0, vector.X, 0, vector.Y + 1)
	else
		ItemPlacementHelperUi.AttachLabel.Visible = false
		ItemPlacementHelperUi.AttachLabelShadow.Visible = false
	end
end

local ItemPlacementHelper = {}

function ItemPlacementHelper:start()
    RunService.Heartbeat:connect(runHelper)
end

return ItemPlacementHelper
