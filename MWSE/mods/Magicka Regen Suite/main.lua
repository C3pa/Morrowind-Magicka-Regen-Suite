-- Ensure we have the features we need.
if (mwse.buildDate == nil or mwse.buildDate < 20220108) then
	mwse.log("[Magicka Regeneration Suite] Build date of %s does not meet minimum build date of 20220108.", mwse.buildDate)
	return
end

dofile("Magicka Regen Suite.modules.regeneration")
dofile("Magicka Regen Suite.modules.waitRegeneration")
dofile("Magicka Regen Suite.modules.travelRegeneration")

event.register("modConfigReady", function()
	dofile("Magicka Regen Suite.mcm")
end)

event.register(tes3.event.initialized, function()
	-- Disable vanilla magicka restoration on resting since this mod has its own calculation
	tes3.findGMST(tes3.gmst.fRestMagicMult).value = 0

	local stuntedEffect = tes3.getMagicEffect(tes3.effect.stuntedMagicka)
	stuntedEffect.description = "Prevents the target from regenerating Magicka for the duration of the effect."
end)
