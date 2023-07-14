addEvent("chatMessage:serverWrap", true)
addEventHandler("chatMessage:serverWrap", root, function(text, r, g, b, colorCoded)
	triggerEvent("onClientChatMessageWrapped", resourceRoot, text, r, g, b, colorCoded)
end)

function functionWrapper(sourceRes, funcName, aclAllowed, luaName, luaLine, ...)
	local args = {...}
	if args[6] ~= true then
		triggerEvent("onClientChatMessageWrapped", resourceRoot, args[1], args[2], args[3], args[4], args[5])
		return "skip"
	end
	return true
end
addDebugHook("preFunction", functionWrapper, {"outputChatBox"})

addEventHandler("onClientResourceStart", resourceRoot, function()
	triggerServerEvent(localPlayer, "chatMessage:playerLoaded", localPlayer)
end)
