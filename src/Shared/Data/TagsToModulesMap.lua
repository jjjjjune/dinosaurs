local import = require(game.ReplicatedStorage.Shared.Import)

local TagsToModulesMap = {}

-- items

TagsToModulesMap.Food = import "Shared/ItemModules/Food"
TagsToModulesMap.Seed = import "Shared/ItemModules/Seed"

-- entities

TagsToModulesMap.FreshWater = import "Shared/EntityModules/FreshWater"
TagsToModulesMap.Plant = import "Shared/EntityModules/Plant"

return TagsToModulesMap