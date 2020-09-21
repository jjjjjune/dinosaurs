--[[
    Messages:reproOnClients(player, "PlaySound", "HeavyWhoosh", item.PrimaryPart.Position)
]]
local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local GetCharacter = import "Shared/Utils/GetCharacter"

local CastRay = import "Shared/Utils/CastRay"

local swings = 0

local function getSwingAnimation()
    local swingAnims = {
        "SwingEnd"
    }
    return swingAnims[swings%(#swingAnims) + 1]
end

local function getClosestTree(player)
    local trees = CollectionService:GetTagged("Plant")
    local closestDist = 10
    local closestTree
    for _, tree in pairs(trees) do
        local dist = (tree.PrimaryPart.Position - player.Character.HumanoidRootPart.Position).magnitude
        if dist < closestDist then
            closestDist = dist
            closestTree = tree
        end
    end
    return closestTree
end

local function getHitPosition(player, tree)
    local start = player.Character.HumanoidRootPart.Position
    local goal = tree.PrimaryPart.Position
    local hit, pos = CastRay(start, (goal - start).unit * 10)
    if hit then
        return pos
    end
    return goal
end

local function chopTree(player, item, tree)
    local shouldDestroy = math.random(1, 5) == 1
    local pos = getHitPosition(game.Players.LocalPlayer, tree)
    if shouldDestroy then
        Messages:send("PlayParticle", "HitSparks", 40, pos)
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds.HitPan2,
            part = item.PrimaryPart,
        })
        Messages:send("PlayDamageEffect", tree)
		--tree.Parent = nil
		Messages:sendServer("ChopTree", tree)
    else
        Messages:send("PlayParticle", "HitSparks", 10, pos)
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds.HitPan,
            part = item.PrimaryPart,
        })
        Messages:send("PlayDamageEffect", tree)
	end
end

local Tool = {}

Tool.debounce = .7

Tool.damageType = "normal"

Tool.damage = 14

function Tool.damageClient(victim, part)
    Messages:send("PlayDamageEffect", victim, "normal", part)
    Messages:sendServer("RegisterHit", victim, GetCharacter().PrimaryPart.CFrame.lookVector * 100)
    Messages:send("PlaySoundOnClient",{
        instance = game.ReplicatedStorage.Sounds.HitBasic,
        part = victim.PrimaryPart
    })
end

function Tool.clientUse(item)
    local tree = getClosestTree(game.Players.LocalPlayer)
    delay(.3, function()
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds.Swing2,
            part = item.PrimaryPart
        })
        if tree then
            chopTree(game.Players.LocalPlayer, item, tree)
        end
        Messages:send("RegisterHitbox", "Default", function(part)
            if CollectionService:HasTag(part.Parent, "Monster") then
                Tool.damageClient(part.Parent, part)
            end
        end)
    end)
    Messages:send("PlayAnimationClient", getSwingAnimation())
    swings = swings + 1
end

function Tool.serverUse(player, item)
    Messages:reproOnClients(player, "PlaySound", "Swing2", item.PrimaryPart.Position)
end

function Tool.clientEquip(item)
end

function Tool.serverEquip(player, item)
end

function Tool.clientUnequip(item)
end

function Tool.serverUnequip(player, item)
end

return Tool
