STAR_MODS = STAR_MODS or {}
if STAR_MODS.FixXPView41 then
	return
end
STAR_MODS.FixXPView41 = {}

local PACIFIST_SKILLS = {Axe=1, Blunt=1, Spear=1, LongBlade=1, SmallBlade=1, SmallBlunt=1, Aiming=1, Maintenance=1}

local function CheckMult(player, num, is_combat)
	if not player then
		return num
	end
	if is_combat and player:HasTrait("Pacifist") then
		num = num * 0.75
	end
	if player:HasTrait("FastLearner") then
		return num * 1.3
	elseif player:HasTrait("SlowLearner") then
		return num * 0.7
	end
	return num
end



--Character Creation Screen
do
	--require "OptionScreens/CharacterCreationProfession"
	local HARDCODED = {
		["+ 75%"] = 4,
		["+ 100%"] = 5.32,
		["+ 125%"] = 6.64,
	}
	local HARDCODED_RUN = { -- Sprinting
		["+ 75%"] = 1.25,
		["+ 100%"] = 1.33,
		["+ 125%"] = 1.66,
	}
	--local NEW_VALUE = {
	--	'x 4', 'x 5.32', 'x 6.64',
	--}

	local extra_trait_mult = 1
	local is_pacifist = false
	local old_draw_right, temp_item
	local function new_drawTextRight(self, txt, ...)
		local mult = HARDCODED[txt]
		if mult then
			if temp_item and temp_item.perk and temp_item.perk.getId then
				local name = temp_item.perk:getId()
				if name == 'Sprinting' then
					mult = HARDCODED_RUN[txt]
				elseif is_pacifist and PACIFIST_SKILLS[name] then
					mult = mult * 0.75 -- pacifist
				end
			end
			mult = mult * (extra_trait_mult or 1) --ленивый или трудолюб
			txt = 'x '..round(mult,2);
		end
		return old_draw_right(self, txt, ...)
	end

	local old_drawmap = CharacterCreationProfession.drawXpBoostMap
	CharacterCreationProfession.drawXpBoostMap = function(self, y, item, ...) --print('Injected!')
		temp_item = item.item
		old_draw_right = self.drawTextRight
		self.drawTextRight = new_drawTextRight
		local res = old_drawmap(self, y, item, ...)
		self.drawTextRight = old_draw_right
		return res
	end
	
	local old_checkXPBoost = CharacterCreationProfession.checkXPBoost
	function CharacterCreationProfession:checkXPBoost(...)
		if self.listboxTraitSelected and self.listboxTraitSelected.items then
			extra_trait_mult = 1
			is_pacifist = false
			for i,v in pairs(self.listboxTraitSelected.items) do
				local name = v.item and v.item.getType and v.item:getType()
				if name == "FastLearner" then
					extra_trait_mult = 1.3
					--break
				elseif name == "SlowLearner" then
					extra_trait_mult = 0.7
					--break
				end
				if name == "Pacifist" then
					is_pacifist = true
				end
			end
		end
		return old_checkXPBoost(self, ...)
	end
end


-- Admin Panel (debug mode or server admin)
do
	--require "ISUI/PlayerStats/ISPlayerStatsUI"
	local HARDCODED = {
		["50%"] = 1,
		["75%"] = 4,
		["100%"] = 5.32,
		["125%"] = 6.64,
	}
	local HARDCODED_RUN = {
		["50%"] = 1,
		["75%"] = 1.25,
		["100%"] = 1.33,
		["125%"] = 1.66,
	}
	
	local old_fn, player
	local function new_addItem(self, name, newPerk, ...)
		if newPerk then
			local boost = HARDCODED[newPerk.boost];
			if boost then
				local name = newPerk.perk and newPerk.perk.getId and newPerk.perk:getId()
				if name == 'Sprinting' then
					boost = HARDCODED_RUN[newPerk.boost];
				elseif player:HasTrait("Pacifist") then
					if PACIFIST_SKILLS[name] then
						boost = boost * 0.75
					end
				end
				if player:HasTrait("FastLearner") then
					boost = boost * 1.3
				elseif player:HasTrait("SlowLearner") then
					boost = boost * 0.7
				end
				newPerk.boost = tostring(round(boost * 100)) .. '%'
			elseif newPerk then
				newPerk.boost = '???';
			end
			local mult = newPerk.multiplier --vanilla bugfix
			if mult then
				if mult < 1 then
					mult = 1
				end
				newPerk.multiplier = tostring(round(mult,2))
			end
			if newPerk.xp then
				newPerk.xp = round(newPerk.xp,2)
			end
		end
		return old_fn(self, name, newPerk, ...)
	end

	local old_loadPerks = ISPlayerStatsUI.loadPerks
	ISPlayerStatsUI.loadPerks = function(self, ...)
		player = self.char
		old_fn = self.xpListBox.addItem
		self.xpListBox.addItem = new_addItem
		old_loadPerks(self, ...)
		self.xpListBox.addItem = old_fn
	end
end


-- Skills Window
do
	--require "XpSystem/ISUI/ISSkillProgressBar"
	local HARDCODED = {
		["0%"] = 1, --custom
		["75%"] = 4, -- +300%
		["100%"] = 5.32,
		["125%"] = 6.64,
	}
	local HARDCODED_RUN = {
		["0%"] = 1, --custom
		["75%"] = 1.25, -- +300%
		["100%"] = 1.33,
		["125%"] = 1.66,
	}
	local skip_this, player, is_triggered, is_combat, skill_sprinting

	local old_getText
	function new_getText(id, percentage, ...)
		if id == "IGUI_XP_tooltipxpboost" and percentage then
			is_triggered = true
			if skip_this then
				return "" --no boost for strength and fitness
			end
			local mult = HARDCODED[percentage]
			if skill_sprinting then
				mult = HARDCODED_RUN[percentage]
			end
			if not mult then
				print('ERROR in CorrectPercentXP: bad percent ',percentage)
				mult = 1
			end
			mult = CheckMult(player, mult, is_combat)
			percentage = 'x ' .. tostring(round(mult,2))
			local s = old_getText(id, percentage, ...)
			local i = s:find('+',1,true)
			if i then
				s = s:sub(1,i-1) .. s:sub(i+1)
			end
			return s
		end
		return old_getText(id, percentage, ...)
	end

	local old_updateTooltip = ISSkillProgressBar.updateTooltip
	ISSkillProgressBar.updateTooltip = function(self, ...)
		skip_this = false
		is_combat = false
		skill_sprinting = false
		if self.perk then
			local typ = self.perk:getType()
			local name = type(typ.name) == 'function' and typ:name() or typ:getId()
			if name == "Fitness" or name == "Strength" then
				skip_this = true
			elseif name == "Sprinting" then
				skill_sprinting = true
			elseif PACIFIST_SKILLS[name] then
				is_combat = true
			end
		end
		player = self.char
		old_getText = getText
		getText = new_getText
		is_triggered = false
		old_updateTooltip(self, ...)
		--print(is_triggered, CheckMult(player, 1), not not self.message)
		if not is_triggered and CheckMult(player, 1, is_combat) ~= 1 and self.message then
			self.message = self.message .. " <LINE> " .. getText("IGUI_XP_tooltipxpboost", "0%");
		end
		getText = old_getText
	end
end

