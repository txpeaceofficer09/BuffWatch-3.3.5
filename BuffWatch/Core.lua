-- Create a new frame to hold the buttons
local buffFrame = CreateFrame("Frame", "BuffWatchFrame", UIParent)
buffFrame:SetSize(32, 32)
buffFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -100) -- Adjust position as needed
buffFrame:SetMovable(true)

local ACTIVE_ALPHA = 1
local INACTIVE_ALPHA = 0.25

function BuffWatch_GetTalentSpec()
	local maxPoints = -1
	local mainSpecName = "None"

	for i=1,3,1 do
		local name, _, pointsSpent = GetTalentTabInfo(i)

		if pointsSpent > maxPoints then
			maxPoints = pointsSpent
			mainSpecName = name
		end
	end

	return mainSpecName, maxPoints
end

function BuffWatch_HideButtons()
	local i = 1

	while _G["BuffWatchFrameButton"..i] ~= nil do
		_G["BuffWatchFrameButton"..i]:Hide()

		i = i + 1
	end
end

function BuffWatch_ShowButtons(num)
	for i=1,num,1 do
		_G["BuffWatchFrameButton"..i]:Show()
	end

	local n = num + 1

	--[[
	while _G["BuffWatchFrameButton"..n] ~= nil do
		_G["BuffWatchFrameButton"..n]:Hide()
		n = n + 1
	end
	]]
end

function BuffWatch_HideBars()
	local count = buffFrame:GetNumChildren()

	for i = 1, count do
		local child = select(i, buffFrame:GetChildren())
		child:Hide()
	end
end

local function GetUnitByGUID(guid)
	local units = {"player", "playerpet", "target", "targetpet", "focus", "focuspet"}

	for _, unit in ipairs(units) do
		if UnitGUID(unit) == guid then return unit end
	end

	local numMembers, groupType = GetNumGroupMembers()

	for i=1, numMembers, 1 do
		local unit = ("%s%d"):format(groupType, i)
		local unitPet = ("%s%s"):format(unit, "pet")
		local unitTarget = ("%s%s"):format(unit, "target")
		local unitFocus = ("%s%s"):format(unit, "focus")

		if UnitGUID(unit) == guid then
			return unit
		elseif UnitGUID(unitPet) == guid then
			return unitPet
		elseif UnitGUID(unitTarget) == guid then
			return unitTarget
		elseif UnitGUID(unitFocus) == guid then
			return unitFocus
		end
	end

	return nil
end

local function GetAuraInfo(unit, spellID)
	local spellName = GetSpellInfo(spellID)
	
	for i=1,40,1 do
		local name, _, _, stacks, _, duration, expirationTime = UnitBuff(unit, i)
		if name ~= spellName then
			name, _, _, stacks, _, duration, expirationTime = UnitDebuff(unit, i)
		end

		if name == spellName then
			if duration and expirationTime then
				local remaining = expirationTime - GetTime();
				return duration, remaining, stacks
			end
		end
	end
	
	return nil, nil, nil
end

local function GetSpellTexture(spellID)
	local _, _, texture = GetSpellInfo(spellID)

	return texture
end

local function OnEvent(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, subEvent, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName = ...

		if srcGUID == UnitGUID("player") then
			if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_APPLIED_DOSE" or subEvent == "SPELL_AURA_REFRESH" then
				if spellID == self.spellID then
					local unit = GetUnitByGUID(dstGUID)

					self:SetAlpha(ACTIVE_ALPHA)
					self.startTime = GetTime()
					
					if unit ~= nil then
						local duration, endTime, stacks = GetAuraInfo(unit, spellID)

						if endTime ~= nil then
							self.endTime = self.startTime + endTime
						elseif duration ~= nil then
							self.endTime = self.startTime + duration
						end
						if ( stacks or 0 ) > 0 then
							self.stackText:SetText(stacks)
						else
							self.stackText:SetText("")
						end
					end

					--self.endTime = self.startTime + self.duration
				end
			elseif subEvent == "SPELL_AURA_REMOVED" then
				self:SetAlpha(INACTIVE_ALPHA)
				self.startTime = nil
				self.endTime = nil
			end
		end
	end
end

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed

	if ( self.timer >= 0.2 ) then
		if self.startTime ~= nil and self.endTime ~= nil then
			local duration = self.endTime - GetTime()

			self.cooldownText:SetText(("%.1f"):format(duration))
		else
			self.cooldownText:SetText("")
		end
	end
end

local function GetButtonCount()
	local i = 1

	while _G["BuffWatchFrameButton"..i] ~= nil do
		i = i + 1
	end

	return i-1
end

-- Function to create a buff button
function BuffWatch_CreateBuffButton(parent, size, xOffset, spellID)
	local spellName = GetSpellInfo(spellID)
	local i = (xOffset / size) + 1
	local buttonName = "BuffWatchFrameButton"..i
	local button = _G[buttonName] or CreateFrame("Frame", buttonName, parent)

	button:SetSize(size, size)
	button:SetPoint("LEFT", parent, "LEFT", xOffset, 0)
	--button:SetMovable(true)
	button:EnableMouse(true)
	button:RegisterForDrag("LeftButton")
	--button:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
	--button:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)
	button:SetScript("OnDragStart", function(self) buffFrame:StartMoving() end)
	button:SetScript("OnDragStop", function(self) buffFrame:StopMovingOrSizing() end)
	button:SetAlpha(INACTIVE_ALPHA)
	button.spellID = spellID
	--button.duration = duration

	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetSize(size-4, size-4)
	button.icon:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.icon:SetTexture(GetSpellTexture(spellID))

	-- Cooldown Text (optional, for displaying remaining time)
	button.cooldownText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
	button.cooldownText:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.cooldownText:SetJustifyH("CENTER")
	button.cooldownText:SetTextColor(0, 1, 0, 1)
	button.cooldownText:SetText("") -- Initially empty

	button.stackText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.stackText:SetPoint("BOTTOM", button, "BOTTOM", 0, 0)
	button.stackText:SetJustifyH("CENTER")
	button.stackText:SetTextColor(1, 1, 1, 1)
	button.stackText:SetText("")

	button:SetScript("OnUpdate", OnUpdate)
	button:SetScript("OnEvent", OnEvent)

	button:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	button:Show()

	return button
end

function BuffWatch_CreateSpecBar(class, spec)
	if spec ~= nil then
		local barName = ("BuffWatch%s%sFrame"):format(class:gsub(" ", ""), spec:gsub(" ", ""))
		local bar = _G[barName] or CreateFrame("frame", barName, BuffWatchFrame)

		bar:SetAllPoints(BuffWatchFrame)
		--bar:Show()

		return bar
	end

	return nil
end
