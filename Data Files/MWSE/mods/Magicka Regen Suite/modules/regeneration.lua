local common = require("Magicka Regen Suite.common")
local config = require("Magicka Regen Suite.config")

local log = mwse.Logger.new()
---@type table<tes3reference, number>
local lastCast = {}
local PC_REGEN_RATE = 0.1
local NPC_REGEN_RATE = 1

---@param e spellCastedEventData|spellCastedFailureEventData
local function monitorCasting(e)
	lastCast[e.caster] = os.clock()
end
event.register(tes3.event.spellCasted, monitorCasting)
event.register(tes3.event.spellCastedFailure, monitorCasting)

---@param e referenceDeactivatedEventData
local function onRefDeactivated(e)
	lastCast[e.reference] = nil
end
event.register(tes3.event.referenceDeactivated, onRefDeactivated)

local function actorRegen()
	common.processActors(NPC_REGEN_RATE, false, lastCast)
end

local function playerRegen()
	local canCastClock = (lastCast[tes3.player] or 0) + config.delayCast
	local clock = os.clock()
	if clock < canCastClock then
		log:debug("Current clock = %s, canCastClock = %s", clock, canCastClock)
		return
	end
	common.attemptRestore(tes3.player, PC_REGEN_RATE)
end

event.register(tes3.event.loaded, function()
	timer.start({ iterations = -1, duration = NPC_REGEN_RATE, callback = actorRegen })
	timer.start({ iterations = -1, duration = PC_REGEN_RATE, callback = playerRegen })
end)
