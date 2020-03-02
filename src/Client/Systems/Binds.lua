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

local MIN_FIND_DISTANCE = 10

local function isValid(item)
    return item.Parent:FindFirstChild("Humanoid") == nil
end

local function getClosestItemOfTag(position, tag)
    local closestDistance = MIN_FIND_DISTANCE
    local closestItem
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
        for _, p in pairs(checkPart:GetTouchingParts()) do
            if CollectionService:HasTag(p.Parent, tag) then
                closestItem = p.Parent
                break
            end
        end
        checkPart:Destroy()
    end
    lastFoundTagItem[tag] = closestItem
    return closestItem
end

local function handleActionUi(actionName, boundData)
    local shouldShow = false
    local position = GetCharacterPosition(true)
    local foundPosition
    local foundTarget
    if position then
        for _, tag in pairs(boundData.tags) do
            local item = getClosestItemOfTag(position, tag)
            if item then
                foundTarget = item
                foundPosition = item.PrimaryPart.Position
                shouldShow = true
            end
        end
    end
    if shouldShow then
        Messages:send("ShowTooltip", actionName, foundPosition, foundTarget)
    else
        Messages:send("HideTooltip", actionName)
    end
end

local function bindStep()
    for actionName, boundData in pairs(boundActionTags) do
        handleActionUi(actionName, boundData)
    end
end

local function performActionCallbackForAction(actionName)
    local foundItem
    local tagBindInfo = boundActionTags[actionName]
    for _, tag in pairs(tagBindInfo.tags) do
        if lastFoundTagItem[tag] then
            foundItem = lastFoundTagItem[tag]
        end
        if foundItem then
            tagBindInfo.callbacks[tag](foundItem)
            Messages:send("PlayPressedEffect", actionName)
            break
        end
    end
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

function Binds.bindTagToAction(collectionServiceTag, actionName, callback)
    if not boundActionTags[actionName] then
        boundActionTags[actionName] = {
            tags = {},
            events = {},
            callbacks = {}
        }
    end
    if not tagsCache[collectionServiceTag] then
        tagsCache[collectionServiceTag] = CollectionService:GetTagged(collectionServiceTag)
        local tagsTable = tagsCache[collectionServiceTag]
        boundActionTags[actionName].callbacks[collectionServiceTag] = callback
        boundActionTags[actionName].events[collectionServiceTag] = {}
        boundActionTags[actionName].events[collectionServiceTag][1] = CollectionService:GetInstanceAddedSignal(collectionServiceTag):connect(
            function(instance)
                table.insert(tagsTable, instance)
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
    for actionName, bindInfo in pairs(ActionBinds) do
        Binds.actionActivatedCallbacks[actionName] = function()
            performActionCallbackForAction(actionName)
        end
        ContextActionService:BindAction(actionName.."Callback", function(contextActionName, inputState, inputObject)
            if inputState == Enum.UserInputState.Begin then
                performActionCallbackForAction(actionName)
            end
        end, false, bindInfo.pcBind, bindInfo.gamepadBind)
    end
end

return Binds