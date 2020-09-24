local import = require(game.ReplicatedStorage.Shared.Import)

local PermissionsConstants = import "Shared/Data/PermissionsConstants"

local Data = {}

Data.DEFAULT_DATA = {

}

Data.TEST_DATA = {

}

Data.DEFAULT_SERVER_DATA = {
	players = {},
	rockSpawners = {},
	gates = {},
	seasonsSurvived = 1,
	permissions = PermissionsConstants.DEFAULT_PERMISSIONS,
	ranks = {
		[8835343] = "Leader",
	}
}

Data.DEFAULT_SERVER_PLAYER_DATA = {
    storedTools = {
        [1] = {item = nil, equipped = false},
        [2] = {item = nil, equipped = false},
        [3] = {item = nil, equipped = false},
        [4] = {item = nil, equipped = false},
	},
	unlockedRecipes = {
		Workbench = {},
	}
}

Data.TEST_SERVER_DATA = {
	players = {},
	rockSpawners = {},
	gates = {},
	seasonsSurvived = 1,
	permissions = PermissionsConstants.DEFAULT_PERMISSIONS,
	ranks = {
		["8835343"] = "Leader",
		["-1"] = "Leader",
	}
}

Data.TEST_SERVER_PLAYER_DATA = {
    storedTools = {
        [1] = {item = nil, equipped = false},
        [2] = {item = nil, equipped = false},
        [3] = {item = nil, equipped = false},
        [4] = {item = nil, equipped = false},
	},
	unlockedRecipes = {
		Workbench = {},
	}
}

Data.TEST_STORE = "testStore5"
Data.PRODUCTION_STORE = "prodStore3"

return Data
