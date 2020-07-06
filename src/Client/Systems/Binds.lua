local import = require(game.ReplicatedStorage.Shared.Import)
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local ActionBinds = import "Shared/Data/ActionBinds"
local Messages = import "Shared/Utils/Messages"
local GetCharacterPosition = import "Shared/Utils/GetCharacterPosition"
local RunService = game:GetService("RunService")

local boundActionTags = {}
local tagsCache = {}
local lastFoundTagItem = {}
local disabledActions = {}

local MIN_FIND_DISTANCE = 10

local function isValid(item)
    return item.Parent:FindFirstChild("Humanoid") == nil
end

local function getClosestItemOfTag(position, tag)
    local closestDistance = MIN_FIND_DISTANCE
    local closestItem
    if not tagsCache[tag] then
        return
    end
    for _, item in pairs(tagsCache[tag]) do
        if isValid(item) then
            local itemPos = item.PrimaryPart and item.PrimaryPart.Position
            if itemPos then
                local dist = (position - itemPos).magnitude
                if (dist < closestDistance) then
                    closestDistance = dist
                    closestItem = item
                end
            end
        end
    end
    if not closestItem then
        local checkPart = Instance.new("Part")
        checkPart.CanCollide = false
        CollectionService:AddTag(checkPart, "RayIgnore")
        checkPart.Transparency = 1
        checkPart.Size = Vector3.new(9,9,9)
        checkPart.CFrame = CFrame.new(position)
        checkPart.Anchored = true
        checkPart.Touched:connect(function() end)
        checkPart.Parent = workspace
        closestDistance = MIN_FIND_DISTANCE
        for _, p in pairs(checkPart:GetTouchingParts()) do
            if CollectionService:HasTag(p.Parent, tag) and isValid(p.Parent) then
                local dist = (p.Position - position).magnitude
                if dist < closestDistance then
                    closestItem = p.Parent
                    closestDistance = dist
                    break
                end
            end
        end
        checkPart:Destroy()
    end
    --print("the item is: ", closestItem)
    lastFoundTagItem[tag] = closestItem
    return closestItem, closestDistance
end

local function handleActionUi(actionName, boundData)
    local shouldShow = false
    local position = GetCharacterPosition(true)
    local foundPosition
    local foundTarget
    local charPosition = GetCharacterPosition()
    local lowestDist = 1000
    if position then
		for _, tag in pairs(boundData.tags) do
			local ignore = false
			local auth = boundData.auths[tag]
			if auth then
				if not auth() then
					ignore = true
				end
			end
			local item, dist = getClosestItemOfTag(position, tag)
            if item and dist < lowestDist and not ignore then
                lowestDist = dist
                foundTarget = item
                foundPosition = item.PrimaryPart.Position
                shouldShow = true
                if charPosition and charPosition.Y < foundPosition.Y then
                    foundPosition = Vector3.new(foundPosition.X, charPosition.Y, foundPosition.Z)
                end
            end
        end
    end
    return shouldShow, foundPosition, foundTarget
end

local function bindStep()
    for actionName, boundData in pairs(boundActionTags) do

        local shouldShowForAction, foundPosition, foundTarget = handleActionUi(actionName, boundData)

        if shouldShowForAction then
            Messages:send("ShowTooltip", actionName, foundPosition, foundTarget)
        else
            Messages:send("HideTooltip", actionName)
        end

    end
end

local function performActionCallbackForAction(actionName)
    local foundItem
    local tagBindInfo = boundActionTags[actionName]
    if tagBindInfo then
        local closestDist = 10000
        local closestTagItem
        local closestTag
        for _, tag in pairs(tagBindInfo.tags) do
            if lastFoundTagItem[tag] then
                foundItem = lastFoundTagItem[tag]
			end
			local ignore = false
			local auth = tagBindInfo.auths[tag]
			if auth then
				if not auth() then
					ignore = true
				end
			end
            if foundItem and (foundItem.PrimaryPart.Position - GetCharacterPosition()).magnitude < closestDist and not ignore then
                closestDist = (foundItem.PrimaryPart.Position - GetCharacterPosition()).magnitude
                closestTagItem = foundItem
                closestTag = tag
            end
        end
        if closestTagItem then
            tagBindInfo.callbacks[closestTag](closestTagItem)
            Messages:send("PlayPressedEffect", actionName)
        end
    else
        warn("no bound action for : ", actionName)
    end
end

local function getTagged(collectionServiceTag)
    local initial = CollectionService:GetTagged(collectionServiceTag)
    local new = {}
    for _, v in pairs(initial) do
        if v:IsDescendantOf(workspace) then
            table.insert(new, v)
        end
    end
    return new
end

local Binds = {}

Binds.actionActivatedCallbacks = {}

function Binds.unbindTagFromAction(collectionServiceTag, actionName)
    lastFoundTagItem[collectionServiceTag] = nil
    if not boundActionTags[actionName] then
        return
    end
    for i, v in pairs(boundActionTags[actionName].tags) do
        if v == collectionServiceTag then
            table.remove(boundActionTags[actionName].tags, i)
        end
    end
    for _, event in pairs(boundActionTags[actionName].events[collectionServiceTag]) do
        event:disconnect()
    end
    tagsCache[collectionServiceTag] = nil
end

function Binds.bindTagToAction(collectionServiceTag, actionName, callback, authFunction)
    if not boundActionTags[actionName] then
        boundActionTags[actionName] = {
            tags = {},
            events = {},
			callbacks = {},
			auths = {}
        }
    end
    if not tagsCache[collectionServiceTag] then
        tagsCache[collectionServiceTag] = getTagged(collectionServiceTag)
        local tagsTable = tagsCache[collectionServiceTag]
		boundActionTags[actionName].callbacks[collectionServiceTag] = callback
		boundActionTags[actionName].auths[collectionServiceTag] = authFunction
        boundActionTags[actionName].events[collectionServiceTag] = {}
        boundActionTags[actionName].events[collectionServiceTag][1] = CollectionService:GetInstanceAddedSignal(collectionServiceTag):connect(
            function(instance)
                if instance:IsDescendantOf(workspace) then
                    table.insert(tagsTable, instance)
                end
            end
        )
        boundActionTags[actionName].events[collectionServiceTag][2] = CollectionService:GetInstanceRemovedSignal(collectionServiceTag):connect(
            function(instance)
                for i, checkInstance in pairs(tagsTable) do
                    if checkInstance == instance then
                        table.remove(tagsTable, i)
                        break
                    end
                end
            end
        )
    end
    table.insert(boundActionTags[actionName].tags, collectionServiceTag)
end

function Binds:start()
    RunService.RenderStepped:connect(function()
        bindStep()
	end)
	Messages:hook("EnableAction", function(actionName)
		disabledActions[actionName] = nil
	end)
	Messages:hook("DisableAction", function(actionName)
		disabledActions[actionName] = true
	end)
    for actionName, bindInfo in pairs(ActionBinds) do
        Binds.actionActivatedCallbacks[actionName] = function()
            performActionCallbackForAction(actionName)
        end
        ContextActionService:BindAction(actionName.."Callback", function(contextActionName, inputState, inputObject)
			if inputState == Enum.UserInputState.Begin then
				if not disabledActions[actionName] then
					performActionCallbackForAction(actionName)
				end
            end
        end, false, bindInfo.pcBind, bindInfo.gamepadBind)
    end
end

return Binds
