local ZE = RV_ZESCAPE
local CV = ZE.Console

ZE.CharSelector = {
	active = {},
	availableSkins = {},
	initialized = false
}

local function InitAvailableSkins()
	if ZE.CharSelector.initialized then return end

	ZE.CharSelector.availableSkins = {}
	
	for i = 0, #skins do
		local skin = skins[i]
		if skin and skin.valid and skin.name ~= "dzombie" then
			table.insert(ZE.CharSelector.availableSkins, {
				name = skin.name,
				realname = skin.realname or skin.name,
				skinnum = i,
				prefcolor = skin.prefcolor or SKINCOLOR_BLUE,
				skin = skin
			})
		end
	end
	
	ZE.CharSelector.initialized = true
	//print("Initialized "..#ZE.CharSelector.availableSkins.." skins")
end
function ZE.OpenCharSelector(player, duration)
	if not player or not player.valid then return end
	
	InitAvailableSkins()
	
	ZE.CharSelector.active[#player] = {
		open = true,
		selectedIndex = 1,
		scrollOffset = 0,
		timer = duration or (10 * TICRATE),
		confirmed = false
	}
	//print("Opened character selector for player "..#player)
end

function ZE.CloseCharSelector(player)
	if not player or not player.valid then return end
	
	if ZE.CharSelector.active[#player] then
		ZE.CharSelector.active[#player].open = false
		ZE.CharSelector.active[#player] = nil
		//print("Closed character selector for player "..#player)
		
		// allow control again
		player.powers[pw_nocontrol] = 0
	end
end

function ZE.ConfirmCharSelection(player)
	if not player or not player.valid then return end
	
	local selector = ZE.CharSelector.active[#player]
	if not selector or not selector.open or selector.timer <= 0 then return end
	
	local selectedSkin = ZE.CharSelector.availableSkins[selector.selectedIndex]
	if selectedSkin then
		R_SetPlayerSkin(player, selectedSkin.name)
		player.skincolor = selectedSkin.prefcolor
		
		if player.mo and player.mo.valid then
			S_StartSound(player.mo, sfx_bkpoof)
		end
		
		selector.confirmed = true
		//print("Selected skin: "..selectedSkin.realname.." for player "..#player)
	end
end



addHook("PreThinkFrame", function()
	for player in players.iterate do
		if not (gametype == GT_ZESCAPE) then continue end
		
		local selector = ZE.CharSelector.active[#player]
		if not selector or not selector.open then continue end
		
		
		if selector.timer > 0 then
			selector.timer = $ - 1
			if selector.timer <= 0 then
				ZE.CloseCharSelector(player)
				continue
			end
		end
		
		
		local cmd = player.cmd
		local totalSkins = #ZE.CharSelector.availableSkins
		if totalSkins == 0 then continue end
		
		// left
		if cmd.sidemove < 0 and not selector.lastLeft then
			selector.selectedIndex = $ - 1
			if selector.selectedIndex < 1 then
				selector.selectedIndex = totalSkins // wrapping
			end
			if player.mo and player.mo.valid then
				S_StartSound(player.mo, sfx_menu1)
			end
			selector.lastLeft = true
		elseif cmd.sidemove >= 0 then
			selector.lastLeft = false
		end

		// right
		if cmd.sidemove > 0 and not selector.lastRight then
			selector.selectedIndex = $ + 1
			if selector.selectedIndex > totalSkins then
				selector.selectedIndex = 1 // wrapping
			end
			if player.mo and player.mo.valid then
				S_StartSound(player.mo, sfx_menu1)
			end
			selector.lastRight = true
		elseif cmd.sidemove <= 0 then
			selector.lastRight = false
		end

		//confirmation w jump or spin
		if (cmd.buttons & BT_JUMP) and not selector.lastJump then
			ZE.ConfirmCharSelection(player)
			ZE.CloseCharSelector(player)
			selector.lastJump = true
		elseif not (cmd.buttons & BT_JUMP) then
			selector.lastJump = false
		end

		if (cmd.buttons & BT_SPIN) and not selector.lastSpin then
			ZE.ConfirmCharSelection(player)
			ZE.CloseCharSelector(player)
			selector.lastSpin = true
		elseif not (cmd.buttons & BT_SPIN) then
			selector.lastSpin = false
		end
		
		player.powers[pw_nocontrol] = 25
	end
end)

//draw hud
hud.add(function(v, player)
	if not (gametype == GT_ZESCAPE) then return end
	if not player or not player.valid then return end
	
	local selector = ZE.CharSelector.active[#player]
	if not selector or not selector.open then return end
	
	local totalSkins = #ZE.CharSelector.availableSkins
	if totalSkins == 0 then
		v.drawString(160, 100, "NO SKINS AVAILABLE", V_YELLOWMAP, "center")
		return
	end
	
	//config
	local centerX = 160
	local centerY = 100
	local spacing = 50
	local baseSize = FRACUNIT*7/10
	local fallSize = FRACUNIT/7
	local maxDistance = 3

	v.fadeScreen(0xFF00, 16)
	v.drawString(centerX, 30, "SELECT CHARACTER", V_YELLOWMAP, "center")
	local timeLeft = selector.timer / TICRATE
	v.drawString(centerX, 45, string.format("Time: %d", timeLeft), V_WHITEMAP, "center")

	// draw icons
	for i = -maxDistance, maxDistance do
		local skinIndex = selector.selectedIndex + i
		if skinIndex < 1 then
			skinIndex = skinIndex + totalSkins
		elseif skinIndex > totalSkins then
			skinIndex = skinIndex - totalSkins
		end
		
		local skinData = ZE.CharSelector.availableSkins[skinIndex]
		if not skinData then continue end
		
		local iconX = centerX + (i * spacing)
		local iconY = centerY
		local distance = abs(i)
		local scale = baseSize - (fallSize * distance)
		
		//so things wont go KABUM
		if scale < FRACUNIT/20 then
			scale = FRACUNIT/20
		end
		
		local flags = 0
		if distance == 0 then
			flags = 0
		elseif distance == 1 then
			flags = V_TRANSLUCENT
		elseif distance == 2 then
			flags = V_70TRANS
		else
			flags = V_50TRANS
		end
		
		local charsprite = v.getSprite2Patch(skinData.skinnum, SPR2_WAIT, false, A, 0)
		if charsprite then
			local colormap = v.getColormap(TC_RAINBOW, skinData.prefcolor)
			v.drawScaled(iconX*FRACUNIT, iconY*FRACUNIT, scale, charsprite, flags, colormap)
		else
			local foundPatch = nil
			for frame = 0, 255 do
				foundPatch = v.getSprite2Patch(skinData.skinnum, frame, false, A, 0)
				if foundPatch then break end
			end
			if foundPatch then
				local colormap = v.getColormap(TC_RAINBOW, skinData.prefcolor)
				v.drawScaled(iconX*FRACUNIT, iconY*FRACUNIT, scale, foundPatch, flags, colormap)
			else
				local questionPatch = v.cachePatch("MISSING")
				v.drawScaled(iconX*FRACUNIT, iconY*FRACUNIT, scale, questionPatch, flags, nil)
			end
		end

		if distance == 0 then
			v.drawString(iconX, iconY + 28, skinData.realname, V_YELLOWMAP, "center")
		end
	end
	
	v.drawString(centerX - 60, centerY, "<", V_YELLOWMAP, "center")
	v.drawString(centerX + 60, centerY, ">", V_YELLOWMAP, "center")
	//v.drawString(centerX, 150, "LEFT/RIGHT to select", "center")
	//v.drawString(centerX, 162, "JUMP/SPIN to confirm", "center")
end, "game")

addHook("PlayerSpawn", function(player)
	if not (gametype == GT_ZESCAPE) then return end
	if not (player.mo and player.mo.valid) then return end
	
	if player.ctfteam == 2 and leveltime < CV.waittime then
		local timeremaining = (CV.waittime - leveltime) / TICRATE
		ZE.OpenCharSelector(player, timeremaining * TICRATE)
	end
end)

addHook("MapLoad", function()
	if gametype == GT_ZESCAPE then
		ZE.CharSelector.initialized = false
		ZE.CharSelector.active = {}
		InitAvailableSkins()

		for player in players.iterate do
			ZE.OpenCharSelector(player, CV.waittime)
		end
	end
end)