local buffFrame = _G["BuffWatchFrame"]

local spells = {
	48108, -- Hot Streak
}

local function Init()
	if UnitClass("player") == "Mage" and BuffWatch_GetTalentSpec() == "Fire" then
		BuffWatch_HideButtons()

		for k, spell in pairs(spells) do
			BuffWatch_CreateBuffButton(buffFrame, 48, (k*48)-48, spell) 
		end

		buffFrame:Show()
	end
end

buffFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
		Init()
	end
end)

buffFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
buffFrame:RegisterEvent("PLAYER_LOGIN")
buffFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

Init()
