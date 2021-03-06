local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Players = game:GetService("Players")

local PlayerClassesFolder = import "ServerStorage/PlayerClasses"

local possibleClasses = {"Gatherer"} -- , "Warrior"

local function setClass(character, className)
    local classAsset = PlayerClassesFolder[className]
    for _, value in pairs(classAsset.Humanoid:GetChildren()) do
        if value:IsA("NumberValue") then
            character.Humanoid[value.Name].Value = value.Value
        end
    end
    character.UpperTorso.BrickColor = classAsset.UpperTorso.BrickColor
    character.RightUpperLeg.BrickColor = classAsset.RightUpperLeg.BrickColor
    character.LeftUpperLeg.BrickColor = classAsset.LeftUpperLeg.BrickColor
    for _, v in pairs(character:GetChildren()) do
        if v:IsA("Accessory") then
            if not v:FindFirstChild("HatAttachment", true) and not v:FindFirstChild("HairAttachment", true) then
                v:Destroy()
            end
        end
	end
	for _, v in pairs(character:GetChildren()) do
		if v.Name == "Shirt" or v.Name == "Pants" then
			v:Destroy()
		end
	end
end

local Classes = {}

function Classes:start()
    Messages:hook("CharacterAdded", function(player, character)
        wait()
        local class = possibleClasses[math.random(1, #possibleClasses)]
        setClass(character, class)
        Messages:send("CharacterAppearanceSet", player, character)
    end)
    for _, p in pairs(game.Players:GetPlayers()) do
        if p and p.Character then
            wait()
            local class = possibleClasses[math.random(1, #possibleClasses)]
            setClass(p.Character, class)
        end
    end
end

return Classes
