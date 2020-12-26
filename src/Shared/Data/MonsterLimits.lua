return {
    Lizard = function(survivedSeasons)
        local min = 0
        local max = 5
        return math.max(min, math.min(max, math.floor(survivedSeasons/6)))
	end,
	["FireLizard"]= function(survivedSeasons)
        local min = 0
        local max = 5
        return math.max(min, math.min(max, math.floor(survivedSeasons/6)))
    end,
    Alpaca = function(survivedSeasons)
        local min = 1
        local max = 6
        return math.max(min, math.min(max, math.floor(survivedSeasons/8)))
	end,
	DesertAlpaca = function(survivedSeasons)
        local min = 1
        local max = 6
        return math.max(min, math.min(max, math.floor(survivedSeasons/8)))
	end,
	RedTurtle = function(survivedSeasons)
        local min = 1
        local max = 6
        return math.max(min, math.min(max, math.floor(survivedSeasons/8)))
    end,
}
