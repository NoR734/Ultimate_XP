require "UXPT/UxptMultiplierUiUtils"

local fakeXp = {}
function fakeXp:getMultiplier() return 0 end
function fakeXp:getPerkBoost() return 0 end
function fakeXp:getXP() return 0 end
function fakeXp:getLevel() return 0 end
local fakeChar = {}
function fakeChar:getXp() return fakeXp end

-- updateTooltip ran every time the tooltip renders. It builds the self.message field that is later shown in the UI
-- We simply mock out some internal methods so that self.message does not get populated with some of the default stuff, and then add things to self.message ourself afterwards 
local updateTooltip_original = ISSkillProgressBar.updateTooltip
function ISSkillProgressBar:updateTooltip(...)
  -- methods on self.char are used to determine whether to render the default XP Boost or Multiplier, which we want to replace, so we repalce self.char with a mock that results in the game code not rendering these
  local char_original = self.char
  self.char = fakeChar
  -- after running the game code, put back the old self.char
  updateTooltip_original(self, ...)
  self.char = char_original

  local perkType = self.perk:getType()
  local boostLevel = self.char:getXp():getPerkBoost(perkType)
  local bookMult = self.char:getXp():getMultiplier(perkType)
  local learnerTrait = (self.char:HasTrait("FastLearner") and TraitFactory.getTrait("FastLearner")) or (self.char:HasTrait("SlowLearner") and TraitFactory.getTrait("SlowLearner"))
  local weaponLearnerTrait = (self.char:HasTrait("Pacifist") and TraitFactory.getTrait("Pacifist"))
  
  local breakdown = UxptMultiplierUiUtils.breakdown(self.perk, boostLevel, self.level, bookMult, learnerTrait, weaponLearnerTrait)
  
  
  if breakdown.isComplex then
    self.message = self.message .. "\n\n" .. breakdown.summary .. "\n\n" .. getText("IGUI_Total") .. " " .. getText("IGUI_skills_Multiplier", UxptMultiplierUiUtils.format(breakdown.cosmeticMult))
  else
    self.message = self.message .. "\n\n" .. string.sub(getText("IGUI_XP_tooltipxpboost"), 1, -4) .. UxptMultiplierUiUtils.format(breakdown.boostMult)
  end
end