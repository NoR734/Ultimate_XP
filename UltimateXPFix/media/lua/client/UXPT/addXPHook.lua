require "UXPT/UxptMultiplierMath"

Events.AddXP.Add(function (gamechar, perk, xpAmount)
    local perkLevel = gamechar:getPerkLevel(perk)
    local boostLevel = gamechar:getXp():getPerkBoost(perk)
    
    local mult = UxptMultiplierMath.skill(perk) * UxptMultiplierMath.actualBoost(perk, boostLevel) * UxptMultiplierMath.extra(perk, perkLevel)
    local extraXP = xpAmount * (mult - 1)
    
    if getDebug() then
        print("UXPT : " .. tostring(perk) .. "_" .. boostLevel .. " (" .. UxptMultiplierMath.skill(perk) .. "," .. UxptMultiplierMath.actualBoost(perk, boostLevel) .. "," .. UxptMultiplierMath.extra(perk, perkLevel) .. ") : " .. tostring(xpAmount) .. " + " .. tostring(extraXP) .. " = " .. tostring(xpAmount + extraXP))
    end

    if extraXP > 0 then
        gamechar:getXp():AddXP(perk, extraXP, false, false, false)
    end
end)
