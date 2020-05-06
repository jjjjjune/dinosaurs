local import = require(game.ReplicatedStorage.Shared.Import)

local TagsToModulesMap = {}
TagsToModulesMap.Items = {}
TagsToModulesMap.Entities = {}

-- items

TagsToModulesMap.Items.Food = import "Shared/ItemModules/Food"
TagsToModulesMap.Items.Seed = import "Shared/ItemModules/Seed"
TagsToModulesMap.Items.Pickaxe = import "Shared/ItemModules/Pickaxe"
TagsToModulesMap.Items.Bucket = import "Shared/ItemModules/Bucket"

-- special module (this is a very funny way of defining buildings through the interaction system)
-- idk if it is a good idea, but i also don't care

TagsToModulesMap.Items.Building = import "Shared/ItemModules/Building"

-- entities

TagsToModulesMap.Entities.FreshWater = import "Shared/EntityModules/FreshWater"
TagsToModulesMap.Entities.Plant = import "Shared/EntityModules/Plant"
TagsToModulesMap.Entities.Workbench = import "Shared/EntityModules/Workbench"

return TagsToModulesMap