require "UXPT/UxptMultiplierMath"

UxptMultiplierUiUtils = {}

-- UxptMultiplierUiUtils.format nicely formats a multiplier float into a readable string. Only used for UI presentation
function UxptMultiplierUiUtils.format(mult)
  return tostring(round(mult, 3)) .. "x"
end

-- UxptMultiplierUiUtils.breakdown generates a full summary of how the total skill multiplier is achieved. Only used for UI presentation
function UxptMultiplierUiUtils.breakdown(perk, boostLevel, perkLevel, bookMult, learnerTrait, weaponLearnerTrait)
  local ret = {
    globalSkillMult = UxptMultiplierMath.globalSkill(perk),
    boostMult = UxptMultiplierMath.configuredBoost(perk, boostLevel),
    bookMult = UxptMultiplierMath.skillBook(bookMult),
    learnerMult = UxptMultiplierMath.learnerTrait(perk, learnerTrait),
    weaponLearnerMult = UxptMultiplierMath.weaponLearnerTrait(perk, weaponLearnerTrait),
    isComplex = false,
  }
      
  ret.cosmeticMult = ret.globalSkillMult * ret.boostMult * ret.bookMult * ret.learnerMult * ret.weaponLearnerMult

  ret.summary = string.sub(getText("IGUI_XP_tooltipxpboost"), 1, -4) .. UxptMultiplierUiUtils.format(ret.boostMult)
  if ret.globalSkillMult ~= 1.0 then
    ret.summary = ret.summary .. "\n" .. UxptPerkUtils.skillMultText(perk) .. ": " .. UxptMultiplierUiUtils.format(ret.globalSkillMult)
    ret.isComplex = true
  end
  if ret.bookMult ~= 1.0 then
    ret.summary = ret.summary .. "\n" .. getText("IGUI_ItemCat_SkillBook") .. ": " .. UxptMultiplierUiUtils.format(ret.bookMult)
    ret.isComplex = true
  end
  if ret.learnerMult ~= 1.0 then
    ret.summary = ret.summary .. "\n" .. tostring(learnerTrait and learnerTrait:getLabel()) .. ": " .. UxptMultiplierUiUtils.format(ret.learnerMult) 
    ret.isComplex = true
  end
  if ret.weaponLearnerMult ~= 1.0 then
    ret.summary = ret.summary .. "\n" .. tostring(weaponLearnerTrait and weaponLearnerTrait:getLabel()) .. ": " .. UxptMultiplierUiUtils.format(ret.weaponLearnerMult)
    ret.isComplex = true
  end
  
  return ret
end