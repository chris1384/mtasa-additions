local loadedPlayers = {}

function functionWrapper(sourceRes, funcName, aclAllowed, luaName, luaLine, ...)
	local args = {...}
	local target = args[2]
	
	if target == root then
		for k,v in ipairs(getElementsByType("player")) do
			if loadedPlayers[v] then
				triggerClientEvent(v, "chatMessage:serverWrap", resourceRoot, args[1], args[3], args[4], args[5], args[6])
			else
				outputChatBox(args[1], v, args[3], args[4], args[5], args[6])
			end
		end
		
	elseif type(target) == "table" then
		for k,v in ipairs(target) do
			if v and isElement(v) then
				if loadedPlayers[v] then 
					triggerClientEvent(v, "chatMessage:serverWrap", resourceRoot, args[1], args[3], args[4], args[5], args[6])
				else
					outputChatBox(args[1], v, args[3], args[4], args[5], args[6])
				end
			end
		end
		
	elseif type(target) == "userdata" and getElementType(target) == "player" then
		if loadedPlayers[target] then 
			triggerClientEvent(target, "chatMessage:serverWrap", resourceRoot, args[1], args[3], args[4], args[5], args[6])
		else
			outputChatBox(args[1], target, args[3], args[4], args[5], args[6])
		end
	end
	
	return "skip"
	
end
addDebugHook("preFunction", functionWrapper, {"outputChatBox"})

addEvent("chatMessage:playerLoaded", true)
addEventHandler("chatMessage:playerLoaded", root, function()
	if not client then 
		return false 
	end
	loadedPlayers[client] = true
end)

addEventHandler("onPlayerQuit", root, function()
	loadedPlayers[source] = nil
end)
