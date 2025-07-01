require "UXPT/UxptMultiplierUiUtils"

-- loadPerks is run before the Player Stats part of the admin panel renders
-- We run it as normal, and just replace some of the attributes on the xpListBox items with modded ones
local loadPerks_original = ISPlayerStatsUI.loadPerks
function ISPlayerStatsUI:loadPerks(...)
  loadPerks_original(self, ...)
  local learnerTrait = (self.char:HasTrait("FastLearner") and TraitFactory.getTrait("FastLearner")) or (self.char:HasTrait("SlowLearner") and TraitFactory.getTrait("SlowLearner"))
  local weaponLearnerTrait = (self.char:HasTrait("Pacifist") and TraitFactory.getTrait("Pacifist"))
  
  for _, v in pairs(self.xpListBox.items) do
    local boostLevel = self.char:getXp():getPerkBoost(v.item.perk)
    local breakdown = UxptMultiplierUiUtils.breakdown(v.item.perk, boostLevel, v.item.level, v.item.multiplier, learnerTrait, weaponLearnerTrait)
    v.item.boost = UxptMultiplierUiUtils.format(breakdown.boostMult)
    v.item.multiplier = UxptMultiplierUiUtils.format(breakdown.cosmeticMult)
  end
end