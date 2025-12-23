local buffFrame = _G["BuffWatchFrame"]

local spells = {
	57761, -- Brain Freeze
	74396, -- Fingers of Frost
}

if UnitClass("player") == "Mage" and BuffWatch_GetTalentSpec() == "Frost" then
	for k, spell in pairs(spells) do
		BuffWatch_CreateBuffButton(buffFrame, 48, (k*48)-48, spell) 
	end

	buffFrame:Show()
end
