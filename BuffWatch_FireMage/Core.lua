local buffFrame = _G["BuffWatchFrame"]

local spells = {
	48108, -- Hot Streak
}

local events = {
	"ACTIVE_TALENT_GROUP_CHANGED",
	"PLAYER_LOGIN",
	"PLAYER_ENTERING_WORLD",
	"COMBAT_LOG_EVENT_UNFILTERED"
}

for _, event in pairs(events) do
	buffFrame:RegisterEvent(event)
end

buffFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
		local class = UnitClass("player")
		local spec = BuffWatch["GetTalentSpec"]()

		local bar = BuffWatch["CreateSpecBar"](class, spec)

		if class == "Mage" and spec == "Fire" and #(spells) > 0 then
			BuffWatch["HideBars"]()

			for k, spell in pairs(spells) do
				BuffWatch["CreateBuffButton"](bar, 48, (k*48)-48, spell)
			end

			bar:Show()
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if srcName ~= dstName then
			if spellID == 29166 then
				SendChatMessage("You have been innervated.", "WHISPER", nil, dstName)
			end
		end
	end
end)
