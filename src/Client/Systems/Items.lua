local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Binds = import "Client/Systems/Binds"
local GetCharacter = import "Shared/Utils/GetCharacter"
local CollectionService = game:GetService("CollectionService")
local ActionBinds = import "Shared/Data/ActionBinds"
local ContextActionService = game:GetService("ContextActionService")
local TagsToModulesMap = import "Shared/Data/TagsToModulesMap"
local UseTexts = import "Shared/Data/UseTexts"
local CastRay = import "Shared/Utils/CastRay"
local GetMouseHit = import "Shared/Utils/GetMouseHit"

local itemModule
local carryItemInstance
local lastToolUse = time()

local function getItemModule(itemInstance)
    local itemModule
    for tag, moduleState in pairs(TagsToModulesMap.Items) do
        if CollectionService:HasTag(itemInstance, tag) then
            itemModule = moduleState
            break
        end
    end
    if not itemModule then
        itemModule = import "Shared/ItemModules/Default"
    end
    return itemModule
end

local function unequipCarryItem(context)
    local holdAnimation = "Carry"
    if carryItemInstance:FindFirstChild("HoldAnimation") then
        holdAnimation = carryItemInstance.HoldAnimation.Value
    end
    Messages:send("StopAnimationClient", holdAnimation)
    if itemModule then
        itemModule.clientUnequip(carryItemInstance)
        itemModule = nil
    else
        warn("bad item module? look into this")
    end
    Messages:send("DestroyContextualBind", "USE")
    Messages:send("DestroyContextualBind", "GRAB")
    Messages:send("DestroyContextualBind", "STORE")
end


local function attemptCarryItem(item)
    if not item:IsDescendantOf(workspace) then
        return
    end
    Messages:sendServer("CarryItem", item)
    local holdAnimation = "Carry"
    if item:FindFirstChild("HoldAnimation") then
        holdAnimation = item.HoldAnimation.Value
    end
    Messages:send("PlayAnimationClient", holdAnimation)
    return true
end

local function playThrowSound(velocity, character, possibleItem)

	if not CollectionService:HasTag(possibleItem, "Building") then
		if velocity.magnitude > 1 then
			Messages:send("PlaySoundOnClient",{
				instance = game.ReplicatedStorage.Sounds.HeavyWhoosh,
				part = character.Head,
				volume = (possibleItem.PrimaryPart.Velocity.Magnitude > 2 and .1) or .05
			})
		else
			Messages:send("PlaySoundOnClient",{
				instance = game.ReplicatedStorage.Sounds.UiClickLow,
				part = character.Head,
				volume = .15
			})
		end
	else
		Messages:send("PlaySoundOnClient",{
			instance = game.ReplicatedStorage.Sounds.ClickHigh,
			part = character.Head,
		})
	end
end

-- local function getAttachedItemsToIgnore(item)
-- 	local itemsToIgnore = {}
-- 	if item:FindFirstChild("ObjectWeld") then
-- 		local weldedItem = item.ObjectWeld.Part1.Parent
-- 		for _, v in pairs((getAttachedItemsToIgnore(weldedItem, itemsToIgnore))) do
-- 			table.insert(itemsToIgnore, v)
-- 		end
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

local function computeLaunchAngle(dx,dy,grav, speed)
	-- arcane
	-- http://en.wikipedia.org/wiki/Trajectory_of_a_projectile

	local g = math.abs(grav)
	local inRoot = (speed*speed*speed*speed) - (g * ((g*dx*dx) + (2*dy*speed*speed)))
	if inRoot <= 0 then
		return .25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((speed*speed) + root) / (g*dx)

	local inATan2 = ((speed*speed) - root) / (g*dx)
	local answer1 = math.atan(inATan1)
	local answer2 = math.atan(inATan2)
	if answer1 < answer2 then return answer1 end
	return answer2
end

local function getFinalVelocityTo(startPos, endPos, speed)
	local launch = startPos

	local delta = endPos - launch

	local dy = delta.y

	local new_delta = Vector3.new(delta.x, 0, delta.z)
	delta = new_delta

	local dx = delta.magnitude
	local unit_delta = delta.unit

	-- acceleration due to gravity in RBX units
	local g = (-9.81 * 20)

	local theta = computeLaunchAngle( dx, dy, g, speed)

	local vy = math.sin(theta)
	local xz = math.cos(theta)
	local vx = unit_delta.x * xz
	local vz = unit_delta.z * xz

	local finalVelocity = Vector3.new(vx,vy,vz) * speed
	return finalVelocity
end

local function computeDirection(vec)
	local lenSquared = vec.magnitude * vec.magnitude
	local invSqrt = 1 / math.sqrt(lenSquared)
	return Vector3.new(vec.x * invSqrt, vec.y * invSqrt, vec.z * invSqrt)
end

local function attemptThrowItem()
    local character = GetCharacter()
    for _, possibleItem in pairs(character:GetChildren()) do
		if CollectionService:HasTag(possibleItem, "Item") or CollectionService:HasTag(possibleItem, "Building") then
			local item = possibleItem
			local velocity = character.HumanoidRootPart.Velocity
			playThrowSound(velocity, character, item)

            item:WaitForChild("ServerWeld")
            item.ServerWeld:Destroy()
			item.Parent = workspace

			if not CollectionService:HasTag(item, "Building") then
				local mouseHit, mouseHitPos = GetMouseHit()
				-- local dir = mouseHitPos - character.Head.Position
				-- dir = computeDirection(dir)
				-- local startCFrame = CFrame.new(character.Head.Position + 5 * dir)
				-- local speed = math.min(70, math.max(30, (startCFrame.p - mouseHitPos).magnitude*1.3))
				-- if mouseHit and CollectionService:HasTag(mouseHit.Parent, "Monster") then
				-- 	math.min(100, math.max(60, (startCFrame.p - mouseHitPos).magnitude*1.3))
				-- end
				-- local velocity = getFinalVelocityTo(startCFrame.p, mouseHitPos, speed)
                -- item.PrimaryPart.CFrame = startCFrame
				-- item.PrimaryPart:GetRootPart().Velocity = velocity * 1.5

				-- local t = math.min(4, (character.Head.Position - mouseHitPos).magnitude/50)
				-- local dir = mouseHitPos - character.Head.Position
				-- dir = computeDirection(dir)
				-- local startCFrame = CFrame.new(character.Head.Position + Vector3.new(0,2,0) + (5 * dir))
				-- local g = Vector3.new(0, -game.Workspace.Gravity, 0);
			    -- local x0 = startCFrame.p

			    -- -- calculate the v0 needed to reach mouse.Hit.p
			    -- local v0 = (mouseHitPos - x0 - 0.5*g*t*t)/t;

				-- item.PrimaryPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,0,-4)
				-- item.PrimaryPart:GetRootPart().Velocity = v0

				item.PrimaryPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,0,-4)
				item.PrimaryPart:GetRootPart().Velocity = velocity * 1.5
			else
                for _, v in pairs(item:GetDescendants()) do
                    if v:IsA("BasePart") then
						v.Velocity = Vector3.new()
						v.RotVelocity = Vector3.new()
                    end
                end
			end

			local holdAnimation = "Carry"

            if item:FindFirstChild("HoldAnimation") then
                holdAnimation = possibleItem.HoldAnimation.Value
			end

			Messages:send("StopAnimationClient", holdAnimation)

            if CollectionService:HasTag(item, "Building") then
				local BuildingSystem = import "Client/Systems/Building"

				item:SetPrimaryPartCFrame(BuildingSystem.placementCF)

                Messages:sendServer("Throw", item, BuildingSystem.placementCF, BuildingSystem.placementTarget)
			else
				local hit, pos = getPlaceableSurface(item)
				if hit then
					possibleItem.PrimaryPart:GetRootPart().Velocity = Vector3.new()
					Messages:sendServer("Throw", item, CFrame.new(pos), hit)
				else
					Messages:sendServer("Throw", item)
				end
            end
        end
    end
end

local function unbindCarry()
    Binds.unbindTagFromAction("Item", "GRAB")
    Binds.unbindTagFromAction("Building", "GRAB")
end

local function carryItem(item)
    local bindInfo = ActionBinds.GRAB
    ContextActionService:BindAction("Throw", function(contextActionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Begin then
            Messages:send("Throw")
        end
    end, false, bindInfo.pcBind, bindInfo.gamepadBind)
    unbindCarry()
end


local function bindCarry()
    ContextActionService:UnbindAction("Throw")
    Binds.bindTagToAction("Item", "GRAB", function(item)
        if attemptCarryItem(item) then
           carryItem(item)
        end
    end,
	function()
		local BuildMode = import "Client/Systems/BuildMode"
		return not BuildMode.isBuilding
	end)
    Binds.bindTagToAction("Building", "GRAB", function(item)
        if attemptCarryItem(item) then
           carryItem(item)
        end
	end,
	function()
		local BuildMode = import "Client/Systems/BuildMode"
		return BuildMode.isBuilding
	end)
end

local function getUseText(itemInstance)
    for tag, text in pairs(UseTexts) do
        if CollectionService:HasTag(itemInstance, tag) then
            return text
        end
    end
end

local function equipCarryItem(itemInstance)
    itemModule = getItemModule(itemInstance)
    itemModule.clientEquip(itemInstance)
    carryItemInstance = itemInstance
    Messages:send("CreateContextualBind", "USE", function()
        local canUse = true
        if itemModule.debounce and time() - lastToolUse < itemModule.debounce then
            canUse = false
        end
        if canUse then
            lastToolUse = time()
            itemModule.clientUse(itemInstance)
            Messages:sendServer("UseItem", itemInstance)
        end
    end, getUseText(itemInstance) or "USE")
    local throwOrPlaceText = (CollectionService:HasTag(itemInstance, "Building") and "PLACE") or "THROW"
    Messages:send("CreateContextualBind", "GRAB", nil, throwOrPlaceText)
    --if CollectionService:HasTag(itemInstance, "Tool") then

        Messages:send("CreateContextualBind", "STORE", function()
            Messages:send("OnStoreAction")
            -- the server will tell us what to do with respect to equipping/unequipping
        end, "STORE")

    --end
end

local function canStore()
	local available = 0
	local currentInventory = _G.Data.server.storedTools
	for _, data in pairs(currentInventory) do
		if data.item == nil then
			available = available + 1
		end
	end
	return available > 0
end

local Items = {}

function Items:start()
    Messages:hook("ForceSetItem", function(item)
        if attemptCarryItem(item) then
            carryItem(item)
         end
    end)
    Messages:hook("Unequip", function()
        unequipCarryItem("UN EQUIP")
        bindCarry()
    end)
    Messages:hook("ForceThrowItems", function()
        attemptThrowItem()
        bindCarry()
    end)
    Messages:hook("OnStoreAction", function()
        if carryItemInstance and carryItemInstance.Parent ~= nil and not CollectionService:HasTag(carryItemInstance, "Building") then
			if not canStore() then
				Messages:send("PlaySoundOnClient",{
					instance = game.ReplicatedStorage.Sounds.NewUICancel,
				})
				return
			end
			unequipCarryItem("STORE BIND")
            Messages:send("StoreTool", carryItemInstance)
            bindCarry()
        end
    end)
    Messages:hook("Throw", function()
        unequipCarryItem(" THROW ")
        attemptThrowItem()
        bindCarry()
    end)
    Messages:hook("SetCarryItem", function(carryItemInstance)
        if carryItemInstance then
            if carryItemInstance:FindFirstChild("TemporaryInstantWeld") then
                carryItemInstance.TemporaryInstantWeld:Destroy()
            end
            unbindCarry() -- just in case!
            equipCarryItem(carryItemInstance)
        end
    end)
    Messages:hook("CharacterAddedClient", function(character)
        bindCarry()
        character:WaitForChild("Humanoid").Died:connect(function()
            unbindCarry()
            if carryItemInstance then
                unequipCarryItem(" DEATH ")
            end
        end)
    end)
end

return Items
