return {
    Lizard = function(survivedSeasons)
        local min = 2
        local max = 10
        return math.max(min, math.min(max, math.floor(survivedSeasons/6)))
    end
}