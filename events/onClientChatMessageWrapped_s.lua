local loadedPlayers = {}

function functionWrapper(sourceRes, funcName, aclAllowed, luaName, luaLine, ...)
	local args = {...}
	if args[2] == root then
		for k,v in ipairs(getElementsByType("player")) do
			if loadedPlayers[v] then
				triggerClientEvent(v, "chatMessage:serverWrap", resourceRoot, args[1], args[3], args[4], args[5], args[6])
			else
				outputChatBox(args[1], v, args[3], args[4], args[5], args[6])
			end
		end
	else
		triggerClientEvent(args[2], "chatMessage:serverWrap", resourceRoot, args[1], args[3], args[4], args[5], args[6])
	end
	return "skip"
end
addDebugHook("preFunction", functionWrapper, {"outputChatBox"})

addEventHandler("onPlayerResourceStart", root, function()
	loadedPlayers[source] = true
end)

addEventHandler("onPlayerQuit", root, function()
	loadedPlayers[source] = nil
end)
