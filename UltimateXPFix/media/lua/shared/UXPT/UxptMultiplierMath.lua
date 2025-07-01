require "UXPT/UxptPerkUtils"

UxptMultiplierMath = {}

-- UxptMultiplierMath.skill finds the configured general modifier for a single skill
function UxptMultiplierMath.skill(perk)
  if UxptPerkUtils.isDummy(perk) then return 1.0 end
  return SandboxVars.UXPT[tostring(perk)] or SandboxVars.UXPT.Other or 1.0
end

-- UxptMultiplierMath.configuredBoost finds the configured boost modifier for a combination of a skill and its boost level
-- For user convenience, the config values are based on "Base XP", but actually we only know the muliplied XP, not the base XP.
-- Hence, the returned value is only used directly in UI presentation; for calculations its always turned into actualBoost
function UxptMultiplierMath.configuredBoost(perk, boostLevel)
  if UxptPerkUtils.isDummy(perk) then return 0.25 end
  return SandboxVars.UXPT_Advanced[tostring(perk) .. "_" .. math.min(boostLevel, 3)] or SandboxVars.UXPT_Advanced["Other_" .. boostLevel] or 1.0 
end

-- UxptMultiplierMath.actualBoost finds the actual boost modifier to use in XP calculations
-- It effectively translates the "cosmetic" configured value into the actual value
function UxptMultiplierMath.actualBoost(perk, boostLevel)
  local boostMult = UxptMultiplierMath.configuredBoost(perk, boostLevel)
  
  if (perk == Perks.Strength or perk == Perks.Fitness) then return boostMult
  elseif (perk == Perks.Sprinting and boostLevel == 0) then return boostMult
  elseif (perk == Perks.Sprinting and boostLevel == 1) then return boostMult / 1.25
  elseif (boostLevel == 0) then return boostMult / 0.25
  elseif (boostLevel == 1) then return boostMult
  elseif (boostLevel == 2) then return boostMult / 1.33
  elseif (boostLevel >= 3) then return boostMult / 1.66
  else return 1.0 end
end

-- UxptMultiplierMath.extra defines any additional UxptMultiplierMath to use
-- These values are not shown in the UI as they tend to be too dynamic and complicated
-- These are again calculated from "cosmetic" configured values
function UxptMultiplierMath.extra(perk, perkLevel)
  if (perk == Perks.Aiming and perkLevel >= 5) then return SandboxVars.UXPT_Advanced.Aiming_level5mult / 0.37037
  else return 1.0 end
end

-- UxptMultiplierMath.learnerTrait returns the multiplier based on learner traits. Only used for UI presentation
function UxptMultiplierMath.learnerTrait(perk, learnerTrait)
  if not learnerTrait then return 1.0 end
  local traitString = learnerTrait:getType()
    
  if perk == Perks.Strength or perk == Perks.Fitness then return 1.0 end
  if traitString == "FastLearner" then return 1.3
  elseif traitString == "SlowLearner" then return 0.75
  else return 1.0 end
end

-- UxptMultiplierMath.weaponLearnerTrait returns the multiplier based on the pacifist trait.
function UxptMultiplierMath.weaponLearnerTrait(perk, weaponLearnerTrait)
  if not weaponLearnerTrait then return 1.0
  elseif UxptPerkUtils.isWeaponPerk(perk) then return 0.75
  else return 1.0 end
end

-- UxptMultiplierMath.skillBook returns the multiplier based on skill book.
function UxptMultiplierMath.skillBook(bookMult)
  if not bookMult or bookMult < 1 then return 1.0
  else return bookMult end
end

-- UxptMultiplierMath.skill finds the configured general modifier for a single skill
function UxptMultiplierMath.globalSkill(perk)
  if SandboxVars.XpMultiplierAffectsPassive == false and (perk == Perks.Strength or perk == Perks.Fitness) then return UxptMultiplierMath.skill(perk) end
  return UxptMultiplierMath.skill(perk) * SandboxVars.XpMultiplier
end
