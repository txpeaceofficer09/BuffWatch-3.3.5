local buffFrame = _G["BuffWatchFrame"]

local bar = BuffWatch_CreateSpecBar(UnitClass("player"), BuffWatch_GetTalentSpec())

local spells = {
	48108, -- Hot Streak
}

local function Init()
	local count = buffFrame:GetNumChildren()

	for i = 1, count do
		local child = select(i, frame:GetChildren())
		child:Hide()
	end

	if UnitClass("player") == "Mage" and BuffWatch_GetTalentSpec() == "Fire" then
		--BuffWatch_HideButtons()

		for k, spell in pairs(spells) do
			BuffWatch_CreateBuffButton(bar, 48, (k*48)-48, spell) 
		end

		bar:Show()
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
