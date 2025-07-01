-- We circumvent any default XP gain by temporarily mocking out ZombRand so that it returns a value that will make the vanilla code never trigger the AddXP call
local ZombRand_original = ZombRand
local ZombRand_mock = function() return -1 end

Events.OnGameStart.Add(function()

  local ISReloadWeaponAction_animEvent_original = ISReloadWeaponAction.animEvent
  if SandboxVars.UXPT_Advanced.Reloading_Level5_ReloadWeaponAction_Xp_Chance ~= 0.3333 or SandboxVars.UXPT_Advanced.Reloading_Level5_ReloadWeaponAction_Xp ~= 1 then
    function ISReloadWeaponAction:animEvent(event, ...)
      if event ~= 'loadFinished' or self.character:getPerkLevel(Perks.Reloading) < 5 then return ISReloadWeaponAction_animEvent_original(self, event, ...) end
        
      ZombRand = ZombRand_mock
      local ret = ISReloadWeaponAction_animEvent_original(self, event, ...)
      ZombRand = ZombRand_original
      
      if ZombRandFloat(0, 1) < SandboxVars.UXPT_Advanced.Reloading_Level5_ReloadWeaponAction_Xp_Chance then
        self.character:getXp():AddXP(Perks.Reloading, SandboxVars.UXPT_Advanced.Reloading_Level5_ReloadWeaponAction_Xp)
      end
      
      return ret
    end
  end
  
  if SandboxVars.UXPT_Advanced.Reloading_Level5_InsertMagazine_Xp_Chance ~= 0.3333 or SandboxVars.UXPT_Advanced.Reloading_Level5_InsertMagazine_Xp ~= 1 then
    local ISInsertMagazine_animEvent_original = ISInsertMagazine.animEvent
    function ISInsertMagazine:animEvent(event, ...)
      if event ~= 'loadFinished' or self.character:getPerkLevel(Perks.Reloading) < 5 then return ISInsertMagazine_animEvent_original(self, event, ...) end
    
      ZombRand = ZombRand_mock
      local ret = ISInsertMagazine_animEvent_original(self, event, ...)
      ZombRand = ZombRand_original

      if ZombRandFloat(0, 1) < SandboxVars.UXPT_Advanced.Reloading_Level5_InsertMagazine_Xp_Chance then
        self.character:getXp():AddXP(Perks.Reloading, SandboxVars.UXPT_Advanced.Reloading_Level5_InsertMagazine_Xp)
      end

      return ret
    end
  end
  
  if SandboxVars.UXPT_Advanced.Reloading_Level5_LoadBulletsInMagazine_Xp_Chance ~= 0.2 or SandboxVars.UXPT_Advanced.Reloading_Level5_LoadBulletsInMagazine_Xp ~= 1 then
    local ISLoadBulletsInMagazine_animEvent_original = ISLoadBulletsInMagazine.animEvent
    function ISLoadBulletsInMagazine:animEvent(event, ...)
      if event ~= 'InsertBullet' or self.character:getPerkLevel(Perks.Reloading) < 5 then return ISLoadBulletsInMagazine_animEvent_original(self, event, ...) end
        
      ZombRand = ZombRand_mock
      local ret = ISLoadBulletsInMagazine_animEvent_original(self, event, ...)
      ZombRand = ZombRand_original
          
      if ZombRandFloat(0, 1) < SandboxVars.UXPT_Advanced.Reloading_Level5_LoadBulletsInMagazine_Xp_Chance then
        self.character:getXp():AddXP(Perks.Reloading, SandboxVars.UXPT_Advanced.Reloading_Level5_LoadBulletsInMagazine_Xp)
      end

      return ret
    end
  end
    

end)