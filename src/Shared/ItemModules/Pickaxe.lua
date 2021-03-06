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

local function getClosestRock(player)
    local rocks = CollectionService:GetTagged("Rock")
    local closestDist = 10
    local closestRock
    for _, rock in pairs(rocks) do
        local dist = (rock.PrimaryPart.Position - player.Character.HumanoidRootPart.Position).magnitude
        if dist < closestDist then
            closestDist = dist
            closestRock = rock
        end
    end
    return closestRock
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

local function chopRock(item, rock)
    local shouldDestroy = rock:FindFirstChild("Health") and rock.Health.Value == 1
    local pos = getHitPosition(game.Players.LocalPlayer, rock)
    if shouldDestroy then
        Messages:send("PlayParticle", "HitSparks", 40, pos)
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds.HitPan2,
            part = item.PrimaryPart,
        })
        Messages:send("PlayDamageEffect", rock)
        --rock.Parent = nil
    else
        Messages:send("PlayParticle", "HitSparks", 10, pos)
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds.HitPan,
            part = item.PrimaryPart,
        })
        Messages:send("PlayDamageEffect", rock)
    end
end

local Tool = {}

Tool.debounce = .5

Tool.damageType = "normal"

Tool.damage = 10

Tool.knockback = 40

function Tool.damageClient(victim, part)
    Messages:send("PlayDamageEffect", victim, "normal", part)
    Messages:sendServer("RegisterHit", victim, GetCharacter().PrimaryPart.CFrame.lookVector * Tool.knockback)
    Messages:send("PlaySoundOnClient",{
        instance = game.ReplicatedStorage.Sounds.HitBasic,
        part = victim.PrimaryPart
    })
end

function Tool.clientUse(item)
    local rock = getClosestRock(game.Players.LocalPlayer)
    delay(.3, function()
        Messages:send("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds.Swing2,
            part = item.PrimaryPart
        })
        if rock then
            chopRock(item, rock)
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
	local rock = getClosestRock(player)
	delay(.3, function()
		if rock then
			local pos = getHitPosition(player, rock)
			local health = rock:FindFirstChild("Health")
			if (not health) or (health and health.Value > 1) then
				if not health then
					print("no health therefore val is 5")
				else
					print("health and the value is ", health.Value)
				end
				Messages:reproOnClients(player, "HitSparks", 10, pos)
				Messages:reproOnClients(player, "PlaySoundOnClient",{
					instance = game.ReplicatedStorage.Sounds.HitPan,
					part = item.PrimaryPart,
				})
			else
				print("to us this is the last hit", health.Value)
				Messages:reproOnClients(player, "PlayParticle", "HitSparks", 40, pos)
				Messages:reproOnClients(player, "PlaySoundOnClient",{
					instance = game.ReplicatedStorage.Sounds.HitPan2,
					part = item.PrimaryPart,
				})
			end
			Messages:send("DamageRock", player, rock, item)
		end
	end)
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
