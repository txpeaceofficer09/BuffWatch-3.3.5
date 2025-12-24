local buffFrame = _G["BuffWatchFrame"]

local spells = {
	57761, -- Brain Freeze
	74396, -- Fingers of Frost
}

local function Init()
	if UnitClass("player") == "Mage" and BuffWatch_GetTalentSpec() == "Frost" then
		BuffWatch_HideButtons()

		for k, spell in pairs(spells) do
			BuffWatch_CreateBuffButton(buffFrame, 48, (k*48)-48, spell) 
		end

		buffFrame:Show()
	end
end

buffFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_LOGIN" then
		Init()
	end
end)

buffFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
buffFrame:RegisterEvent("PLAYER_LOGIN")
