function isPlayerInACL(player, acl)
	if player and isElement(player) and getElementType(player) == "player" then
		local account = getPlayerAccount(player)
		if account and not isGuestAccount(account) then
			local account_name = getAccountName(account)
			local acl_group = aclGetGroup(acl)
			if acl_group then
				if isObjectInACLGroup("user."..account_name, acl_group) then
					return true
				end
			end
		end
		return false
	end
	return nil
end
