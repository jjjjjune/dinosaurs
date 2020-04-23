local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ServerData = import "Server/Systems/ServerData"
local TweenService = game:GetService("TweenService")

local OCEAN_LOWER_AMOUNT = 200

--600, 419.5, 600

local function lowerOcean()
    local oceanHeight = ServerData:getValue("oceanHeight") or 500
    
    oceanHeight = oceanHeight - OCEAN_LOWER_AMOUNT

    local newPos = Vector3.new(600, oceanHeight, 600)

    workspace.Effects.Sky.Position = newPos

    local goals = {
        Position = newPos,
    }
    local sandGoals = {
        Position = newPos - Vector3.new(0,3,0)
    }
    local tweenInfo = TweenInfo.new(6, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    TweenService:Create(workspace.Effects.Water, tweenInfo, goals):Play()
    TweenService:Create(workspace.Effects.Sand, tweenInfo, sandGoals):Play()

    ServerData:setValue("oceanHeight", oceanHeight)

    delay(1, function()
        Messages:send("WaterPositionUpdated")
    end)
end

local function setOceanHeight(height)
    print("OCEAN HEIGHT SET!!!!!!!!!!!!!!!!!!!")
    local newPos = Vector3.new(600, height, 600)
    ServerData:setValue("oceanHeight", height)
    
    workspace.Effects.Sky.Position = newPos

    workspace.Effects.Water.Position = newPos
    workspace.Effects.Sand.Position = newPos - Vector3.new(0,3,0)
end

local function onMapDoneGenerating()
    local oceanHeight = ServerData:getValue("oceanHeight") or 400
    local newPos = Vector3.new(600, oceanHeight, 600)
    workspace.Effects.Sky.Position = newPos
    workspace.Effects.Water.Position = newPos
    workspace.Effects.Sand.Position = newPos - Vector3.new(0,3,0)
end

local Ocean = {}

function Ocean:start()
    Messages:hook("MapDoneGenerating", onMapDoneGenerating)
    Messages:hook("LowerOcean", lowerOcean)
    Messages:hook("SetOceanHeight", setOceanHeight)
end

return Ocean