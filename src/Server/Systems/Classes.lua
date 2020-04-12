local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Players = game:GetService("Players")

local PlayerClassesFolder = import "ServerStorage/PlayerClasses"

local possibleClasses = {"Citizen", "Gatherer"} -- , "Warrior"

local function setClass(character, className)
    print("OKAY WE ARE SETTING PLAYER CLASSS")
    local classAsset = PlayerClassesFolder[className]
    for _, value in pairs(classAsset.Humanoid:GetChildren()) do 
        if value:IsA("NumberValue") then 
            character.Humanoid[value.Name].Value = value.Value
        end
    end
    character.UpperTorso.BrickColor = classAsset.UpperTorso.BrickColor
    character.RightUpperLeg.BrickColor = classAsset.RightUpperLeg.BrickColor
    character.LeftUpperLeg.BrickColor = classAsset.LeftUpperLeg.BrickColor
    print("SET STUFF HERE ")
    for _, v in pairs(character:GetChildren()) do 
        if v:IsA("Accessory") then 
            if not v:FindFirstChild("HatAttachment", true) and not v:FindFirstChild("HairAttachment", true) then 
                v:Destroy()
            end
        end
    end
    if character:FindFirstChild("Shirt") then
        character.Shirt:Destroy()
    else
        print("HAD NO SHIRT")
    end
    if character:FindFirstChild("Pants") then
        character.Pants:Destroy()
    end
end

local Classes = {}

function Classes:start()
    Messages:hook("CharacterAdded", function(player, character)
        print("CHAR WAS ADDED CLASS")
        wait()
        local class = possibleClasses[math.random(1, #possibleClasses)]
        setClass(character, class)
    end)
end

return Classes