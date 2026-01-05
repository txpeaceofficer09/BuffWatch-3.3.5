local buffFrame = _G["BuffWatchFrame"]

local spells = {
	48108, -- Hot Streak
}

local function Init()
	BuffWatch_HideBars()

	if UnitClass("player") == "Mage" and BuffWatch_GetTalentSpec() == "Fire" then
		local bar = BuffWatch_CreateSpecBar(UnitClass("player"), BuffWatch_GetTalentSpec())

		if bar ~= nil then
			for k, spell in pairs(spells) do
				BuffWatch_CreateBuffButton(bar, 48, (k*48)-48, spell) 
			end

			bar:Show()
			buffFrame:Show()
		end
	end
end

buffFrame:HookScript("OnEvent", function(self, event, ...)
	Init()
end)

buffFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
buffFrame:RegisterEvent("PLAYER_LOGIN")
buffFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

Init()
