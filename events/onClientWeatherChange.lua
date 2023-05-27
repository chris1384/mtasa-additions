addDebugHook("postFunction", function(_, _, _, _, _, weatherType) 
    triggerEvent("onClientWeatherChange", resourceRoot, weatherType)  
end, {"setWeather"})
