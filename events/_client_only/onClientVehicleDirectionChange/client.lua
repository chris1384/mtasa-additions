--------------------------------------------------------------------------
--------------------------------------------------------------------------

--[[
	// onClientVehicleDirectionChange - custom event
	// by chris1384 - @2023
	
	// Event Parameters:
		reversing (bool) - returns true if the vehicle is reversing, false otherwise
		move-state (int / nil) - the movement state of the vehicle, this can be:
			nil - no ped
			0 - no ped action
			1 - ped is accelerating/reversing
			2 - ped is braking
		driver (elem:ped / nil) - the ped or player that's controlling the vehicle, returns nil if there's no one
	
	// Source:
		source (vehicle) - the vehicle that changed it's direction and state
	
	// Notice:
		This event will not work on exploded vehicles.
		
--]]

--------------------------------------------------------------------------
--------------------------------------------------------------------------

local GLOBAL_DIRECTION = {vehicles = {}}

local _G = _G
local getElementsByType = getElementsByType
local root = getRootElement()
local pairs = pairs
local type = type
local triggerEvent = triggerEvent
local getElementType = getElementType
local getElementMatrix = getElementMatrix
local getElementVelocity = getElementVelocity
local getPedControlState = getPedControlState
local getVehicleController = getVehicleController

function GLOBAL_DIRECTION.start()
	local vehicles = getElementsByType("vehicle", root, true)
	local vehicles_count = #vehicles
	if vehicles_count > 0 then
		for i=1, vehicles_count do
			local vehicle = vehicles[i]
			GLOBAL_DIRECTION.add(vehicle)
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, GLOBAL_DIRECTION.start)

function GLOBAL_DIRECTION.add(vehicle, ped)
	local vehicle = vehicle or source
	if GLOBAL_DIRECTION.vehicles[vehicle] then return false end
	if getElementType(vehicle) == "vehicle" then
		if isVehicleBlown(vehicle) then return false end
		local state = nil
		local controller = ped or getVehicleController(vehicle)
		if controller then
			state = GLOBAL_DIRECTION.peddetect(vehicle, controller)
		end
		GLOBAL_DIRECTION.vehicles[vehicle] = {controller = (type(controller) == "userdata" and controller), reversing = GLOBAL_DIRECTION.detect(vehicle), state = state}
		return true
	end
	return false
end
addEventHandler("onClientElementStreamIn", root, GLOBAL_DIRECTION.add)

function GLOBAL_DIRECTION.remove(vehicle)
	local vehicle = vehicle or source
	GLOBAL_DIRECTION.vehicles[vehicle] = nil
	return true
end
addEventHandler("onClientElementDestroy", root, GLOBAL_DIRECTION.remove)
addEventHandler("onClientElementStreamOut", root, GLOBAL_DIRECTION.remove)

function GLOBAL_DIRECTION.explode()
	GLOBAL_DIRECTION.vehicles[source] = nil
end
addEventHandler("onClientVehicleExplode", root, GLOBAL_DIRECTION.explode)

function GLOBAL_DIRECTION.enter(ped, seat)
	if seat ~= 0 then return false end
	local vehicle = source
	if not GLOBAL_DIRECTION.vehicles[vehicle] then
		GLOBAL_DIRECTION.add(vehicle, ped)
	end
	if not GLOBAL_DIRECTION.vehicles[vehicle].state then
		GLOBAL_DIRECTION.vehicles[vehicle].state = GLOBAL_DIRECTION.peddetect(vehicle, ped)
		GLOBAL_DIRECTION.vehicles[vehicle].controller = ped
		return true
	end
	return false
end
addEventHandler("onClientVehicleEnter", root, GLOBAL_DIRECTION.enter)

function GLOBAL_DIRECTION.exit(_, seat)
	if seat ~= 0 then return false end
	local vehicle = source
	if GLOBAL_DIRECTION.vehicles[vehicle] then
		GLOBAL_DIRECTION.vehicles[vehicle].state = nil
		GLOBAL_DIRECTION.vehicles[vehicle].controller = nil
		return true
	end
	return false
end
addEventHandler("onClientVehicleExit", root, GLOBAL_DIRECTION.exit)

function GLOBAL_DIRECTION.quit()
	local player = source
	local vehicle = getPedOccupiedVehicle(player)
	if vehicle and getVehicleController(vehicle) == player then
		if GLOBAL_DIRECTION.vehicles[vehicle] then
			GLOBAL_DIRECTION.vehicles[vehicle].state = nil
			GLOBAL_DIRECTION.vehicles[vehicle].controller = nil
		end
	end
end
addEventHandler("onClientPlayerQuit", root, GLOBAL_DIRECTION.quit)

function GLOBAL_DIRECTION.update()
	for vehicle, data in pairs(GLOBAL_DIRECTION.vehicles) do
		local r = GLOBAL_DIRECTION.detect(vehicle)
		local s = nil
		local controller = GLOBAL_DIRECTION.vehicles[vehicle].controller
		if controller then
			s = GLOBAL_DIRECTION.peddetect(r, controller)
		end
		if data.reversing ~= r or data.state ~= s then
			GLOBAL_DIRECTION.vehicles[vehicle].reversing = r
			GLOBAL_DIRECTION.vehicles[vehicle].state = s
			triggerEvent("onClientVehicleDirectionChange", vehicle, r, s, controller)
		end
	end
end
addEventHandler("onClientRender", root, GLOBAL_DIRECTION.update)
--[[
	// If you don't want real time update, delete the onClientRender line and replace with this one:
		setTimer(GLOBAL_DIRECTION.update, 50, 0)

	// It's equal to 20 FPS which should be good for most players.
	-- idea by Zorgman
--]]

function GLOBAL_DIRECTION.detect(vehicle)
	local m = getElementMatrix(vehicle)
	local x, y, z = getElementVelocity(vehicle)
	local d = (x * m[2][1]) + (y * m[2][2]) + (z * m[2][3])
	return d < 0
end

function GLOBAL_DIRECTION.peddetect(data, ped)
	local r
	if type(data) == "userdata" then
		r = GLOBAL_DIRECTION.detect(data)
	else
		r = data
	end
	local s = getPedControlState(ped, "brake_reverse")
	local w = getPedControlState(ped, "accelerate")
	return (r and s and 1) or (r and w and 2) or (not r and w and 1) or (not r and s and 2) or (getPedControlState(ped, "handbrake") and 2) or 0 
	-- // GTA:SA default vehicle behaviour (state 1 AND handbrake RETURNS state 1)
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
