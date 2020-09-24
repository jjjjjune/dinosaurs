local import = require(game.ReplicatedStorage.Shared.Import)

local TagsToModulesMap = {}
TagsToModulesMap.Items = {}
TagsToModulesMap.Entities = {}
TagsToModulesMap.Monsters = {}

-- items

TagsToModulesMap.Items.Food = import "Shared/ItemModules/Food"
TagsToModulesMap.Items.Seed = import "Shared/ItemModules/Seed"
TagsToModulesMap.Items.Pickaxe = import "Shared/ItemModules/Pickaxe"
TagsToModulesMap.Items.Axe = import "Shared/ItemModules/Axe"
TagsToModulesMap.Items.Bucket = import "Shared/ItemModules/Bucket"
TagsToModulesMap.Items.Rope = import "Shared/ItemModules/Rope"
TagsToModulesMap.Items.Scissors = import "Shared/ItemModules/Scissors"
TagsToModulesMap.Items["Taming Potion"] = import "Shared/ItemModules/TamingPotion"
TagsToModulesMap.Items.RecipeBook = import "Shared/ItemModules/RecipeBook"

-- special module (this is a very funny way of defining buildings through the interaction system)
-- idk if it is a good idea, but i also don't care

TagsToModulesMap.Items.Building = import "Shared/ItemModules/Building"

-- entities

TagsToModulesMap.Entities.Chest = import "Shared/EntityModules/Chest"
TagsToModulesMap.Entities.FreshWater = import "Shared/EntityModules/FreshWater"
TagsToModulesMap.Entities.Plant = import "Shared/EntityModules/Plant"
TagsToModulesMap.Entities.Workbench = import "Shared/EntityModules/Workbench"
TagsToModulesMap.Entities.PermissionsTablet = import "Shared/EntityModules/PermissionsTablet"

-- monsters

TagsToModulesMap.Monsters.Lizard = import "Shared/MonsterModules/Lizard"
TagsToModulesMap.Monsters.FireLizard = import "Shared/MonsterModules/FireLizard"
TagsToModulesMap.Monsters.Alpaca = import "Shared/MonsterModules/Alpaca"
TagsToModulesMap.Monsters.RedTurtle = import "Shared/MonsterModules/RedTurtle"
TagsToModulesMap.Monsters.DesertAlpaca = import "Shared/MonsterModules/DesertAlpaca"

return TagsToModulesMap
