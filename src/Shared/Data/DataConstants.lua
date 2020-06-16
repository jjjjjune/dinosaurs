
local Data = {}

Data.DEFAULT_DATA = {

}

Data.TEST_DATA = {

}

Data.DEFAULT_SERVER_DATA = {
    players = {},
    seasonsSurvived = 1,
}

Data.DEFAULT_SERVER_PLAYER_DATA = {
    storedTools = {
        [1] = {item = nil, equipped = false},
        [2] = {item = nil, equipped = false},
        [3] = {item = nil, equipped = false},
        [4] = {item = nil, equipped = false},
    },
}

Data.TEST_SERVER_DATA = {
    players = {},
}

Data.TEST_SERVER_PLAYER_DATA = {
    storedTools = {
        [1] = {item = nil, equipped = false},
        [2] = {item = nil, equipped = false},
        [3] = {item = nil, equipped = false},
        [4] = {item = nil, equipped = false},
    },
}

Data.TEST_STORE = "testStore5"
Data.PRODUCTION_STORE = "prodStore3"

return Data