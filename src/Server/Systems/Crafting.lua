local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local CraftingRecipes = import "Shared/Data/CraftingRecipes"

local function craftItem(player, station, stationType, index)
    local recipe = CraftingRecipes[stationType][index]
    local character = player.Character
    if character:FindFirstChild(recipe.ingredient) then
        Messages:send("DestroyItem", character[recipe.ingredient])
    else
        return
    end
    local Items = import "Server/Systems/Items"
    local product = Items.createItem(recipe.product, Vector3.new(0,10000000,0))
    Messages:send("PlaySound", "GoodCraft", product.PrimaryPart.Position)
    product:SetPrimaryPartCFrame(station.PrimaryPart.CFrame * CFrame.new(0, station.PrimaryPart.Size.Y/2 + product.PrimaryPart.Size.Y/2, 0))
    -- force grab item?
    Messages:sendClient(player, "ForceSetItem", product)
    Messages:send("PlayParticle", "DeathSmoke",  20, product.PrimaryPart.Position)
    -- when crafting water buildings be sure to sert their amounts to zero
end

local Crafting = {}

function Crafting:start()
    Messages:hook("CraftItem", craftItem)
end

return Crafting