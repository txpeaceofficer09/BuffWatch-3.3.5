local buffFrame = _G["BuffWatchFrame"]

local spells = {
	--53307, -- Thorns
	29166, --"Innervate" -- Make an addon to whisper people when you cast a buff and when it fades.
	--69369, -- Predator's Swiftness
	--62606, -- Savage Defense
	22812, -- Barkskin
	--50334, -- Berserker
	--61336, -- Survival Instincts
	--22842, -- Frenzied Regeneration
	--50212, -- Tiger's Fury
	--52610, -- Savage Roar
	--5229, -- Enrage
	--48567, -- Lacerate
	--33983, -- Mangle (Cat)
	--33987, -- Mangle (Bear)
	--8983, -- Bash
	--48573, -- Rake
	--49799, -- Rip
	33786, -- Cyclone
	26989, -- Entangling Roots
	27009, -- Nature's Grasp (Buff)
	27010, -- Nature's Grasp (Debuff)
	18658, -- Hibernate
	26995, -- Soothe Animal
	--60566, -- PvP Idol buff
	--"Maim",
	--16857, -- Faerie Fire (Feral)
	--770, --"Faerie Fire",
	--"Demoralizing Roar",
	--"Challenging Roar",
	--6795, -- Growl
	--49803, -- Pounce
	--2893, -- Abolish Poison
	--48450, -- Lifebloom
	--48440, -- Rejuvenation
	--48442, -- Regrowth
	--16870, -- Clearcastings
}

local events = {
	"ACTIVE_TALENT_GROUP_CHANGED",
	"PLAYER_LOGIN",
	"PLAYER_ENTERING_WORLD",
	"COMBAT_LOG_EVENT_UNFILTERED"
}

--[[
bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("COMABT_LOG_EVENT_UNFILTERED")
]]

for _, event in pairs(events) do
	buffFrame:RegisterEvent(event)
end

buffFrame:HookScript("OnEvent", function(self, event, ...)
	local class = UnitClass("player")
	local spec = BuffWatch["GetTalentSpec"]()

	if event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then

		local bar = BuffWatch["CreateSpecBar"](class, spec)

		if class == "Druid" and spec == "Balance" and #(spells) > 0 then
			BuffWatch["HideBars"]()

			for k, spell in pairs(spells) do
				BuffWatch["CreateBuffButton"](bar, 48, (k*48)-48, spell)
			end

			bar:Show()
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, subEvent, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID = ...		
		
		if subEvent == "SPELL_CAST_SUCCESS" and srcName ~= dstName and srcGUID == UnitGUID("player") and spec == "Balance" then
			if spellID == 29166 then
				SendChatMessage("You have been innervated.", "WHISPER", nil, dstName)
			end
		end
	end
end)
