local regenerationFormula = require("Magicka Regen Suite.regenerationType")
local config = require("Magicka Regen Suite.config").config

local log = mwse.Logger.new()

-- TODO
-- Fun fact: Fortify Attribute apparently affects the base value of the statistic, not just the current value.
-- Not sure if Fortify Skill works the same way. The only way to get the actual base value of an attribute is
-- to get it from the ref's npc record

local common = {}

---@return boolean result
local function isPCinInterior()
	local cell = tes3.player.cell
	return (cell.isInterior and not cell.behavesAsExterior)
end

local function getSunriseNightStartHours()
	local wc = tes3.worldController.weatherController
	local nightStartHour = wc.sunsetHour + wc.sunsetDuration
	return wc.sunsetHour, nightStartHour
end

--- Returns true if the `hour` is during night. If no `hour` is passed, the current in-game hour will be used.
---@param hour number?
---@return boolean result
local function isNight(hour)
	hour = hour or tes3.worldController.hour.value
	local sunrise, nightStart = getSunriseNightStartHours()
	if (hour < sunrise or hour >= nightStart) then
		return true
	end

	return false
end

-- The "PCVampire" global var is set to 1 when the player is considered a vampire.
local PCVampireValue = 1
local vampireScriptIDs = {
	["vampire_berne"] = true,
	["vampire_quarra"] = true,
	["vampire_aundae"] = true,
	["mararascript"] = true,
	["irarakscript"] = true,
	["mertascript"] = true,
	["mastriusscript"] = true,
}

---@param ref tes3reference Can be player, or NPC.
---@return boolean result
local function isVampire(ref)
	if ref == tes3.player and tes3.findGlobal("PCVampire").value == PCVampireValue then
		return true
	end

	local obj = ref.baseObject and ref.baseObject or ref.object
	if obj.head.vampiric then
		return true
	end

	if tes3.isAffectedBy({ reference = ref, effect = tes3.effect.vampirism }) then
		return true
	end

	if obj.script and vampireScriptIDs[obj.script.id:lower()] then
		return true
	end

	return false
end

---@param ref tes3reference
---@return boolean
local function isStunted(ref)
	return tes3.isAffectedBy({ reference = ref, effect = tes3.effect.stuntedMagicka })
end

--- Returns the maximal amount of magicka an actor can currently have.
---@param reference tes3reference
---@return number
local function getMaxMagicka(reference)
	return reference.mobile.magicka.base +
		tes3.getEffectMagnitude({
			reference = reference,
			effect = tes3.effect.fortifyMagicka
		})
end

--- Returns the amount of magicka a reference would regenerate per second.
---@param actor tes3mobileActor
---@param base number The actor's base magicka.
---@return number result
local function getMagickaRestoredPerSecond(actor, base)
	local restored
	local formula = config.regenerationFormula

	if formula == regenerationFormula.morrowind then
		restored = math.max(0,
			math.log(math.max(actor.willpower.current, 0.01), config.baseMorrowind) * config.scaleMorrowind - config.capMorrowind
		)

		if actor.inCombat then
			restored = restored * config.combatPenaltyMorrowind
		end

	elseif formula == regenerationFormula.oblivion then
		restored = base * 0.01 * (config.magickaReturnBaseOblivion + config.magickaReturnMultOblivion * actor.willpower.current)

	elseif formula == regenerationFormula.skyrim then
		restored = base * config.magickaReturnSkyrim

		if actor.inCombat then
			restored = restored * config.combatPenaltySkyrim
		end
	elseif formula == regenerationFormula.logarithmicINT then
		restored = math.max(0,
			math.log(math.max(actor.intelligence.current, 0.01), config.INTBase) * config.INTScale - config.INTb
		)

		if config.INTApplyCombatPenalty and actor.inCombat then
			restored = restored * config.INTCombatPenalty
		end

		if config.INTUseFatigueTerm then
			restored = restored * actor:getFatigueTerm()
		end
	elseif formula == regenerationFormula.logarithmicWILL then
		log:warn("Unsupported regeneration formula. Change your regeneration formula in the mod's MCM.")
		return 0
	end

	if config.useDecay then
		restored = restored * (1 - actor.magicka.current / base) ^ config.decayExp
	end

	return restored * config.regSpeedModifier
end

--- Restores the apropriate amount of magicka to the `ref`.
---@param ref tes3reference
---@param secondsPassed number? If `nil`, `secondsPassed = 1` is used.
---@return number restoredAmount
function common.restoreIf(ref, secondsPassed, restingOrTravelling)
	secondsPassed = secondsPassed or 1
	if isStunted(ref) then return 0 end

	local base = getMaxMagicka(ref)
	local mobile = ref.mobile --[[@as tes3mobileActor]]
	local magickaStat = mobile.magicka
	local currentMagicka = magickaStat.current
	--@diagnostic disable-next-line param-type-mismatch
	local amount = getMagickaRestoredPerSecond(mobile, base) * secondsPassed

	if restingOrTravelling then
		-- Don't restore more than maximum magicka
		if currentMagicka >= base then return 0 end

		amount = math.min(currentMagicka + amount, base)
		tes3.setStatistic({ reference = ref, statistic = magickaStat, current = amount })
		return amount
	end


	if config.vampireChanges and isVampire(ref) then
		if isPCinInterior() or isNight() then
			amount = amount * ( 1 + config.nightBonus )
		else
			amount = amount * ( 1 - config.dayPenalty )
		end
	end
	-- Don't restore more than maximum magicka
	if (currentMagicka >= base and amount > 0) then return 0 end

	-- Clamp positive total values to not overflow
	-- Negative values shouldn't be clamped. If for example, a character just had Fortify Magicka effect worn off,
	-- then their current magicka can be higher than maximum magicka. In such scenario, maxMagicka - currentMagicka
	-- could be more negative than total yielding wrong result
	if amount > 0 then
		amount = math.min(amount, (base - currentMagicka))
	end

	tes3.modStatistic({ reference = ref, statistic = magickaStat, current = amount })
	return amount
end

--- Returns an iterator over all the NPCs, creatures, and optionally the player in all active cells.
--- ```
--- for ref in common.getActors(false) do
---     ...
--- end
--- ```
---@param includePlayer boolean? If `false`, the player will be excluded.
---@return tes3reference[]
function common.getActors(includePlayer)
	---@diagnostic disable-next-line return-type-mismatch
	return coroutine.wrap(function()
		for _, cell in pairs(tes3.getActiveCells()) do
			for ref in cell:iterateReferences({ tes3.objectType.npc, tes3.objectType.creature }) do
				coroutine.yield(ref)
			end
		end
		if includePlayer then
			coroutine.yield(tes3.player)
		end
	end)
end

---Restores magicka to all actors in active cells excluding the player
---@param secondsPassed number? If `nil`, `secondsPassed = 1` is used.
---@param restingOrTravelling boolean?
function common.processActors(secondsPassed, restingOrTravelling)
	for actor in common.getActors(false) do
		if actor.mobile then
			common.restoreIf(actor, secondsPassed, restingOrTravelling)
		end
	end
end

return common
