STAR_MODS = STAR_MODS or {}
if STAR_MODS.UltimateXPFixView then return end
STAR_MODS.UltimateXPFixView = {}

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

-- Character Creation Screen override from FixXPView
-- Displays XP multipliers as in FixXPView while keeping other features of UltimateXPTweaker.

do
    local HARDCODED = {
        ["+ 75%"] = 4,
        ["+ 100%"] = 5.32,
        ["+ 125%"] = 6.64,
    }
    local HARDCODED_RUN = {
        ["+ 75%"] = 1.25,
        ["+ 100%"] = 1.33,
        ["+ 125%"] = 1.66,
    }

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
                    mult = mult * 0.75
                end
            end
            mult = mult * (extra_trait_mult or 1)
            txt = 'x '..round(mult,2)
        end
        return old_draw_right(self, txt, ...)
    end

    local old_drawmap = CharacterCreationProfession.drawXpBoostMap
    CharacterCreationProfession.drawXpBoostMap = function(self, y, item, ...)
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
            for _,v in pairs(self.listboxTraitSelected.items) do
                local name = v.item and v.item.getType and v.item:getType()
                if name == "FastLearner" then
                    extra_trait_mult = 1.3
                elseif name == "SlowLearner" then
                    extra_trait_mult = 0.7
                end
                if name == "Pacifist" then
                    is_pacifist = true
                end
            end
        end
        return old_checkXPBoost(self, ...)
    end
end

