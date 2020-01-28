return function(instance, timerName) 
    timerName = timerName.."TIMER"

    local timerInstance = instance:FindFirstChild(timerName)
    if not timerInstance then
        timerInstance = Instance.new("NumberValue", instance)
        timerInstance.Name = timerName
        timerInstance.Value = os.time()
    end

    local TimerObject = {}
    TimerObject.instance = timerInstance

    function TimerObject.advance()
        timerInstance.Value = os.time()
    end

    function TimerObject.hasBeen(duration)
        return timerInstance.Value < (os.time() - duration)
    end

    return TimerObject
end