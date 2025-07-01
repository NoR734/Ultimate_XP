Events.OnServerStarted.Add(function ()
  
  if isServer() then
    local perksToCheck = { nil }
    local maxMultFound = 1.0
    for _, v in pairs(UxptPerkUtils.perkOrder) do table.insert(perksToCheck, v) end
    for _, v in pairs(perksToCheck) do
      for i = 0,3, 1 do
        local thisMult = UxptMultiplierMath.skill(v) * UxptMultiplierMath.configuredBoost(v, i)
        if thisMult > maxMultFound then maxMultFound = thisMult end
      end
    end
    
    local antiCheatThresholdMult = maxMultFound / 1.6666
    
    if antiCheatThresholdMult >= 10 then
      ServerOptions.getInstance():putOption("AntiCheatProtectionType9", "false")
      ServerOptions.getInstance():putOption("AntiCheatProtectionType15", "false")
      print('UXPT: Disabled server-side XP-based auto kick')
    elseif antiCheatThresholdMult > 1 then
      local type9 = ServerOptions.getInstance():getDouble("AntiCheatProtectionType9ThresholdMultiplier")
      local type15 = ServerOptions.getInstance():getDouble("AntiCheatProtectionType15ThresholdMultiplier")
      ServerOptions.getInstance():putOption("AntiCheatProtectionType9ThresholdMultiplier", tostring(math.max(type9, antiCheatThresholdMult)) )
      ServerOptions.getInstance():putOption("AntiCheatProtectionType15ThresholdMultiplier", tostring(math.max(type15, antiCheatThresholdMult)) )    
      print('UXPT: Raised server-side XP-based auto kick threshold to ' .. tostring(antiCheatThresholdMult))
    end
  end
end)