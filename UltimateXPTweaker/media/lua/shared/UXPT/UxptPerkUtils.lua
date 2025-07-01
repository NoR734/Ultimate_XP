UxptPerkUtils = {}

UxptPerkUtils.perkOrder = {
  Perks.Fitness, Perks.Strength,
  Perks.Sprinting, Perks.Lightfoot, Perks.Nimble, Perks.Sneak,
  Perks.Woodwork, Perks.Cooking, Perks.Farming, Perks.Doctor, Perks.Electricity, Perks.MetalWelding, Perks.Mechanics, Perks.Tailoring,
  Perks.Fishing, Perks.Trapping, Perks.PlantScavenging,
  Perks.Axe, Perks.Blunt, Perks.SmallBlunt, Perks.LongBlade, Perks.SmallBlade, Perks.Spear, Perks.Maintenance,
  Perks.Aiming, Perks.Reloading,
}

knownPerks = {}
for _, v in pairs(UxptPerkUtils.perkOrder) do knownPerks[v] = true end

local weaponPerks = {
  [Perks.Axe] = true, [Perks.Blunt] = true, [Perks.SmallBlunt] = true, [Perks.LongBlade] = true, [Perks.SmallBlade] = true, [Perks.Spear] = true, [Perks.Maintenance] = true,
  [Perks.Aiming] = true
}

local weaponPerksCount = 0
for _,_ in pairs(weaponPerks) do weaponPerksCount = weaponPerksCount+1 end

function UxptPerkUtils.isWeaponPerk(perk)
  return weaponPerks[perk] or perk == Perks.Melee or false
end

function UxptPerkUtils.isKnownPerk(perk)
  return knownPerks[perk] or false
end

function UxptPerkUtils.weaponSkillText(numberOfEmptyWeaponPerks)
  if numberOfEmptyWeaponPerks == weaponPerksCount then return getText("UI_Weapon_Skills")
  else return getText("UI_Other_Weapon_Skills") end
end

function UxptPerkUtils.skillMultText(perk)
  if UxptPerkUtils.isDummy(perk) then return string.sub(getText("IGUI_skills_Multiplier"), 1, -5)
  else return perk:getName() end
end

function UxptPerkUtils.isDummy(perk)
  -- None is used as a dummy for the "Everything else" item, Melee is used as a dummy for the "Other weapon skills"
  return perk == Perks.None or perk == Perks.Melee
end