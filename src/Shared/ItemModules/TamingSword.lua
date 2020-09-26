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
		"Swing1",
		"Swing2",
        "SwingEnd"
    }
    return swingAnims[swings%(#swingAnims) + 1]
end

local function getHitPosition(player, rock)
    local start = player.Character.HumanoidRootPart.Position
    local goal = rock.PrimaryPart.Position
    local hit, pos = CastRay(start, (goal - start).unit * 10)
    if hit then
        return pos
    end
    return goal
end

local Tool = {}

Tool.debounce = .5

Tool.damageType = "tame"

Tool.damage = 20

function Tool.damageClient(victim, part)
    Messages:send("PlayDamageEffect", victim, Tool.damageType, part)
    Messages:sendServer("RegisterHit", victim, GetCharacter().PrimaryPart.CFrame.lookVector * 50)
    Messages:send("PlaySoundOnClient",{
        instance = game.ReplicatedStorage.Sounds.HitBasic,
        part = victim.PrimaryPart
    })
end

function Tool.clientUse(item)
    delay(.3, function()
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds.Swing2,
            part = item.PrimaryPart
        })
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
