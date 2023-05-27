function getPlayerFullName(player)
	if player and isElement(player) and getElementType(player) == "player" then
		local r, g, b = getPlayerNametagColor(player)
	
		return string.format("#%.2X%.2X%.2X", r, g, b) .. getPlayerName(player)
	end
	return nil
end
