require "UXPT/UxptMultiplierMath"
require "UXPT/UxptMultiplierUiUtils"
require "UXPT/UxptPerkUtils"

-- checkXPBoost is called upon every change in traits. Its purpose is to populate the listboxXpBoost field, the items of which are later passed to drawXpBoostMap
-- Because we want to make lots of changes to this list, we first let the original populate listboxXpBoost, read that listboxXpBoost, then clear it, then fill it in our own preferred way
local checkXPBoost_original = CharacterCreationProfession.checkXPBoost
function CharacterCreationProfession:checkXPBoost(...)
  checkXPBoost_original(self, ...)
  
  -- Gather required info on traits
  local learnerTrait
  local weaponLearnerTrait
  for _, v in pairs(self.listboxTraitSelected.items) do
    local traitString = v.item and v.item.getType and v.item:getType()
    if traitString == "FastLearner" or traitString == "SlowLearner" then learnerTrait = v.item end
    if traitString == "Pacifist" then weaponLearnerTrait = v.item end
  end
  
  
  -- Gather required info on skills
  local levels = {}
  local unknownPerks = {}
  for _, v in pairs(self.listboxXpBoost.items) do
    levels[v.item.perk] = v.item.level
    if not UxptPerkUtils.isKnownPerk(v.item.perk) then table.insert(unknownPerks, v.item.perk) end
  end
  
  
  -- Clear old skill list and build our own
  self.listboxXpBoost:clear()
  function addToList(perk, text)
    local skillLevel = levels[perk] or 0
    
    local newItem = self.listboxXpBoost:addItem(text, { perk = perk, level = skillLevel })
    local breakdown = UxptMultiplierUiUtils.breakdown(perk, skillLevel, skillLevel, nil, learnerTrait, weaponLearnerTrait)
    newItem.mult = UxptMultiplierUiUtils.format(breakdown.cosmeticMult)
    newItem.tooltip = breakdown.summary
  end  
  
  local emptyWeaponPerks = {}
  local emptyPerks = {}
  for _, perk in pairs(UxptPerkUtils.perkOrder) do
    local skillLevel = levels[perk] or 0
    if skillLevel ~= 0 or UxptMultiplierMath.skill(perk) ~= 1.0 or UxptMultiplierMath.globalSkill(perk) ~= 1.0 or UxptMultiplierMath.actualBoost(perk, skillLevel) ~= 1.0
       or perk == Perks.Strength or perk == Perks.Fitness or perk == Perks.Sprinting then
      addToList(perk, PerkFactory.getPerkName(perk))
    elseif UxptPerkUtils.isWeaponPerk(perk) then table.insert(emptyWeaponPerks, perk)
    else table.insert(emptyPerks, perk) end
  end
  for _, perk in pairs(unknownPerks) do
    addToList(perk, PerkFactory.getPerkName(perk))
  end
  
  if weaponLearnerTrait and #emptyWeaponPerks>0 then
    addToList(Perks.Melee, UxptPerkUtils.weaponSkillText(#emptyWeaponPerks))
  end
  if (weaponLearnerTrait and #emptyPerks ~= 0) or
     (not weaponLearnerTrait and (#emptyPerks ~= 0 or #emptyWeaponPerks ~= 0)) then
    addToList(Perks.None, getText("UI_Everything_Else"))
  end
end



-- drawXpBoostMap imperatively draws a single skill in the bottom-right corner of the character creation screen
-- It passes hardcoded +X% strings to the drawTextRight function. And it is hardcoded to ignore Strength and Fitness. We don't want that, so we replace the function
local drawXpBoostMap_original = CharacterCreationProfession.drawXpBoostMap
function CharacterCreationProfession:drawXpBoostMap(y, item, alt, ...)
  -- temporarily replace drawTextRight to render item.mult instead of the originally passed "X% Boost" string 
  local drawTextRight_original = CharacterCreationProfession.drawTextRight
  self.drawTextRight = function(self, _, ...) return drawTextRight_original(self, item.mult, ...) end
  
  -- temporarily replace the perk with Perk.None, to circumvent Strength/Fitness from getting skipped
  local perk_original = item.item.perk
  item.item.perk = Perks.None
  
  local ret = drawXpBoostMap_original(self, y, item, alt, ...)
  
  -- put the original values back in place
  self.drawTextRight = drawTextRight_original
  item.item.perk = perk_original
  return ret
end



-- The following code ensures all the state is up to date when the trait selection screen appears
local setVisible_original = CharacterCreationProfession.setVisible
function CharacterCreationProfession:setVisible(...)
  -- In single-player, ensure sandbox vars are set when going back-and-forth between the sandbox vars screen and the trait selection screen 
  -- Without it, multipliers shown in the trait selection screen would not be updated after having moved back to the sandbox vars screen to edit them
  if not isClient() and not isServer() and self.previousScreen == "SandboxOptionsScreen" then
    if SandboxOptionsScreen.instance.controls ~= nil then SandboxOptionsScreen.instance:setSandboxVars() end
  end
  
  -- Force repopulation of the "Major Skills" portion of the UI each time the trait selection screen appears
  -- Without it, changes to the sandbox vars that have just been loaded aren't applied initially
  if self.listboxXpBoost ~= nil then self:checkXPBoost() end
  
  setVisible_original(self, ...)
end
