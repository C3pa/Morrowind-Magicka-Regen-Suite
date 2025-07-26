				Magicka Regeneration Suite
				By C3pa

Version: 3.0.0

_________
Contents
_________
1.	Requirements
2.	Description
3.	Permissions
4.	Contact
5.	Credits

_____________
Requirements
_____________
Morrowind

MGE XE
MWSE 2+

____________
Description
____________
Magicka Regeneration Suite provides four configurable magicka regeneration types: as in Oblivion and Skyrim, the other three are brand new: Morrowind style, logarithmic INT and realtime at rest rate. Characters with stunted magicka don't regenerate magicka. Magicka is restored even while waiting in the wilderness, sleeping in a bed or traveling by boat, Silt Strider, or any other mod-added travel service will also regenerate magicka. Vampires get lose magicka in broad daylight, while they get a bonus magicka regeneration during the night or indoors.

All of the mod's features can be configured in the mod configuration menu.

____________
Permissions
____________
Modify my mod, but credit me as the original creator.

____________
Changelog
____________
1.0
Initial Release.

1.1
Feature: Visually smoother Magicka regeneration for Player.
Feature: User is notified when changing a setting in MCM needs a game restart to come into effect.
Bugfix: Skyrim regeneration style combat penalty is now calculated properly.
Misc: Made code more readable.

1.2
Feature: Much better MCM.
Feature: Coefficients for different regeneration styles are no longer shared.
Feature: Added new Regeneration Speed Modifer - an easy way to quickly adjust regeneration speed of your selected regeneration style.

1.3
Feature: Added magicka decay inspired by Natural Magicka Regeneration by Knu.
Feature: Companions now also regenerate magicka when travelling by a boat or a siltstrider with player.
Feature: Settings hot-reloading - Restarting the game after changing settings in no longer required!
Bugfix: Fixed actors not regenerating magicka outside of player's cell in adjecent active cells.
Bugfix: Vanilla calculation for magicka restored on resting/waiting will no longer be done alongside this mod's calculation for the same thing.
Bugfix: Containers will no longer be scanned.
Misc: Reduced code duplication a lot, made code a lot easier to work with.

1.3.1
Feature: Allow some settings to be set to 0 in MCM, thus enabling to have Intelligence and Fatigue only scaling in Morrowind Regeneration.
Feature: Allow completely stopping magicka regeneration during combat for Morrowind and Skyrim regeneration types.
Misc: Updated the code to new coding standards in MWSE.

2.0
Feature: Added a new magicka regeneration formula: logarithmic WILL.
Feature: Added a new magicka regeneration formula: logarithmic INT.
Feature: Added conditional bonuses/penalties for vampires.
Misc: Removed a ton of code by introducing metatables to the config file.
Misc: Added an excel file with some graphs showcasing various available formulas in action on the mod's Nexus page.

2.0.1
Misc: Mod repackaged to work with Mod Managers.

2.1
Bugfix: Fixed a bug that made the mod not work for some of the users.

2.2
Change: Morrowind regeneration formula - the regenerated points per second is now a function of log(willpower).
Change: Made default settings for logarithmic INT harsher.
Change: Removed logarithmic Will regeneration formula since Morrowind formula now is basically the same.
Bugfix: Prevented potentiall errors by trying to calculate log(0).
Misc: Added Purist Friendly Magicka Regeneration to the Formulas.xlsx for comparison.

2.2.1
Change: Morrowind Style regeneration - changed scale setting default value from 1.6 to 1.4. That was the intended value for the setting from the last update, but I forgot to set it.
Misc: Fixed Purist Friendly Magicka Regeneration formula column in the Formulas.xlsx table. That helped me to notice the above.

3.0.0
Feature: Added new regeneration formula that restores magicka at the same rate as vanilla does when resting.
Feature: Update magicka, intelligence and willpower descriptions that show on hovering to reflect the changes from this mod.
Feature: Implemented compatibility with Fortify Magicka Regeneration (https://www.nexusmods.com/morrowind/mods/54158).
Bugfix: Morrowind Style formula in one of the updates lost its fatigueTerm scaling which is now restored.
Bugfix: Fixed an error that appeared when using travel services with companions.
Task: Updates to the mod's MCM to use newer MWSE features. These allowed simplifying the settings page for users.
________
Contact
________
C3pa on Nexus and on Discord in Morrowind Modding Community channel

________
Credits
________
Thanks to Anumaril21 for creating the original MWSE Magicka Regen
Thanks to hhuuggss for suggesting to clamp magicka, the comment section of MWSE Magicka Regen
Thanks to Necrolesian for right calculation of time spent resting when the rest had been interrupted, comment section of MWSE Magicka Regen
Thanks to Merlord for developing Ashfall. I learned how to make a mcm menu by reading his code.
Thanks to Knu for coming up with a great decay formula in his Natural Magicka Regeneration
Thanks to Greatness7 and NullCascade for fixing a bug in my code
Thanks to Herbert for writing me a snippet needed to implement compatibility with Fortify Magicka Regeneration
Thanks to the following people from MMC Discord channel, who answered my questions:

Axemagister
Greatness7
OperatorJack
O. E. Academicus
Pinky
tewlwolow
NullCascade

Thanks to UESP and OpenMW for game formulas I read on their pages
Thanks to Dieter Steffmann for his cool and free Morris Roman font
Thanks to Brucoms for developing the TES3 Readme Generator this readme was made from.
