require "XpSystem/XpUpdate"

Events.OnGameStart.Add(function()
	if isServer() or not SandboxVars.UXPT_Advanced.Derandomize then return end
	
	local fitnessCounter = 0
	local strengthCounter = 0
	local nimbleCounter = 0
	local sprintingCounter = 0
	
	local onPlayerMove_original = xpUpdate.onPlayerMove
	Events.OnPlayerMove.Remove(xpUpdate.onPlayerMove)
	Events.OnPlayerMove.Add(
		function()
			local player = getPlayer();
			local xp = player:getXp();
			
			-- instead of using the getMultiplier() value to determine the chance, we just keep adding it up until it reaches the threshold, and then give XP and set it to 0
			local mult = GameTime:getInstance():getMultiplier()
			
			-- if you're running and your endurance has changed
			if (player:IsRunning() or player:isSprinting()) and player:getStats():getEndurance() > player:getStats():getEndurancewarn() then
				-- you may gain 1 xp in sprinting or fitness
				fitnessCounter = fitnessCounter + mult
				sprintingCounter = sprintingCounter + mult
			end
			
			-- aiming while moving, gain nimble xp (move faster in aiming mode)
			if player:isAiming() then
				nimbleCounter = nimbleCounter + mult
			end
			
			-- if you're walking with a lot of stuff, you may gain in Strength
			if player:getInventoryWeight() > player:getMaxWeight() * 0.5 then
				strengthCounter = strengthCounter + mult
			end
			
			while (fitnessCounter > SandboxVars.UXPT_Advanced.Fitness_interval) do
				fitnessCounter = fitnessCounter - SandboxVars.UXPT_Advanced.Fitness_interval
				xp:AddXP(Perks.Fitness, 1);
			end
			
			while (sprintingCounter > SandboxVars.UXPT_Advanced.Sprinting_interval) do
				sprintingCounter = sprintingCounter - SandboxVars.UXPT_Advanced.Sprinting_interval
				xp:AddXP(Perks.Sprinting, 1);
			end
			
			while (nimbleCounter > SandboxVars.UXPT_Advanced.Nimble_interval) do
				nimbleCounter = nimbleCounter - SandboxVars.UXPT_Advanced.Nimble_interval
				xp:AddXP(Perks.Nimble, 1);
			end
			
			while (strengthCounter > SandboxVars.UXPT_Advanced.Strength_interval) do
				strengthCounter = strengthCounter - SandboxVars.UXPT_Advanced.Strength_interval
				xp:AddXP(Perks.Strength, 2);
			end
			
		end
	)
	
	print('UXPT: Derandomizer enabled')
		
end)
