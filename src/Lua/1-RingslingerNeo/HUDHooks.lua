local RS = RingSlinger

local AMMO_CONFIG = {
	BAR_HEIGHT = 8,
	DIAGONAL_OFFSET = 3,
	
	AMMO_FILLED_COLOR = 6,
	AMMO_EMPTY_COLOR = 24,
	AMMO_COST_COLOR = 84,
	AMMO_RELOAD_COLOR = 10,
	AMMO_BG = 24,
	AMMO_SHADOW = 16,
}

local function drawDiagonalAmmoBar(v, x, y, width, height, segments, fillSegments, costSegments, curammo, maxammo, isReloading)
	local diagOffset = AMMO_CONFIG.DIAGONAL_OFFSET
	local segmentWidth = width / segments
	
	for i = 0, height - 1 do
		local segmentY = y + i
		local segmentDiagX = (i * diagOffset) / height
		
		v.drawFill(x + segmentDiagX + 1, segmentY + 1, width, 1, AMMO_CONFIG.AMMO_SHADOW|V_PERPLAYER|V_SNAPTOBOTTOM|V_50TRANS)
		v.drawFill(x + segmentDiagX, segmentY, width, 1, AMMO_CONFIG.AMMO_BG|V_PERPLAYER|V_SNAPTOBOTTOM)
		
		for seg = 1, segments do
			local segX = x + segmentDiagX + ((seg - 1) * segmentWidth)
			local color = AMMO_CONFIG.AMMO_EMPTY_COLOR
			
			if isReloading then
				if seg <= fillSegments then
					color = AMMO_CONFIG.AMMO_RELOAD_COLOR
				end
			elseif seg <= fillSegments then
				if seg > fillSegments - costSegments then
					color = AMMO_CONFIG.AMMO_COST_COLOR
				else
					color = AMMO_CONFIG.AMMO_FILLED_COLOR
				end
			end
			
			v.drawFill(segX, segmentY, segmentWidth, 1, color|V_PERPLAYER|V_SNAPTOBOTTOM)
		end
	end
end

local drawammobar = function(v, player, mo, cam)
	local maxammo = mo.ringslinger.maxammo

	local curammo = mo.ringslinger.ammo
	local cost = RS.Weapons[mo.ringslinger.loadout[mo.ringslinger.wepslot]].cost
	if (mo.ringslinger.wepslot != 1)
		cost = RS.GetOffhandCost($)
	end
	local reload = mo.ringslinger.reload
	local weapondelay = mo.ringslinger.weapondelay
	local x = 160
	local y = 187
	local barx = x - maxammo/2
	local bary = y + 2
	local pixel = v.cachePatch("BARPIXEL")
	

	if mo.ringslinger.infinity or maxammo <= 1
		return
	end
	

	if reload
		local reloadammo = maxammo * (FRACUNIT - reload) / FRACUNIT
		drawDiagonalAmmoBar(v, barx, bary, maxammo, AMMO_CONFIG.BAR_HEIGHT, maxammo, reloadammo, 0, reloadammo, maxammo, true)
		
		if leveltime % 2 == 0
			v.drawString(x, bary + 1, "RELOAD", V_PERPLAYER | V_SNAPTOBOTTOM, "thin-center")
		end
	else
		drawDiagonalAmmoBar(v, barx, bary, maxammo, AMMO_CONFIG.BAR_HEIGHT, maxammo, curammo, cost, curammo, maxammo, false)
		
		local textX = x
		if curammo >= 10
			textX = $ + 1
		end
		local textY = bary + 1
		v.drawString(textX, textY, tostring(curammo), V_PERPLAYER | V_SNAPTOBOTTOM, "thin-center")
		
		local delayx = x - weapondelay/2
		local pos = 0
		while (pos < weapondelay)
			pos = $ + 2
			v.draw(delayx + pos - 1, bary+AMMO_CONFIG.BAR_HEIGHT+1, pixel, V_HUDTRANSHALF | V_PERPLAYER | V_SNAPTOBOTTOM)
		end
	end
end

//Weapon bar (main and sub weapon display)
local weapons = function(v, player, mo, cam)
	local y = (170 + mo.ringslinger.hudy) * FRACUNIT
	for i = 1, 2
		local weapon = RS.Weapons[mo.ringslinger.loadout[i]]
		local patch = v.cachePatch(weapon.hudsprite)
		
		local xoff
		if i == 1
			xoff = -10
		else
			xoff = 10
		end
		local x = (160 + xoff) * FRACUNIT
		local trans = ((mo.ringslinger.wepslot == i) and V_HUDTRANS|V_SNAPTOBOTTOM) or V_HUDTRANSHALF|V_SNAPTOBOTTOM
		local scale = FRACUNIT
		if i == 1
			scale = FRACUNIT*2/2
		end
		
		v.drawScaled(x, y, scale, patch, trans | V_SNAPTOBOTTOM | V_PERPLAYER | V_SNAPTOBOTTOM)
	end
	local xoff = 10
	local scale = FRACUNIT
	if mo.ringslinger.wepslot == 1
		xoff = -10
		scale = FRACUNIT*2/2
	end
	local x = (160 + xoff) * FRACUNIT
	local patch = v.cachePatch("CURWEAP")
	v.drawScaled(x, y, scale, patch, V_HUDTRANS | V_SNAPTOBOTTOM | V_PERPLAYER)
	
	--20 ring cost for reloading
	local blink = (mo.ringslinger.lostringstimer % 2)
	if mo.ringslinger.lostrings and mo.ringslinger.lostringstimer
		x = 160 + mo.ringslinger.lostringsxoff
		y = 166
		v.drawString(x, y, "-"+tostring(mo.ringslinger.lostrings), (blink and V_HUDTRANS or V_HUDTRANSHALF) | V_PERPLAYER | V_SNAPTOBOTTOM , "thin-center")
	end
end

//Powerup display
local powerups = function(v, player, mo, cam)
	local yoff = 0
	for i = 1, #RS.Powers
		if not mo.ringslinger.powers[i]
			continue
		end
		local x = 16
		local y = 50 + yoff
		yoff = $ + 12
		local barlength = mo.ringslinger.powers[i] / (8 * FRACUNIT)
		local power = RS.Powers[i]
		v.drawFill(x, y, barlength, 9, (V_SNAPTOLEFT | V_PERPLAYER) + power.hudcolor)
		if (mo.ringslinger.powers[i] / FRACUNIT < 2*TICRATE) and (leveltime % 2)
			continue
		end
		v.drawString(x + 1, y + 1, power.name, V_SNAPTOLEFT | V_HUDTRANS | V_PERPLAYER, "thin")
	end
	if not mo.ringslinger.infinity
		return
	end
	local x = 16
	local y = 50 + yoff
	yoff = $ + 12
	local barlength = mo.ringslinger.infinity / (8 * FRACUNIT)
	v.drawFill(x, y, barlength, 9, (V_SNAPTOLEFT | V_PERPLAYER) + 0)
	if (mo.ringslinger.infinity / FRACUNIT < 2*TICRATE) and (leveltime % 2)
		return
	end
	v.drawString(x + 1, y + 1, "Infinity", V_SNAPTOLEFT | V_HUDTRANS | V_PERPLAYER, "thin")
end

//Show your character holding the ring in firstperson
local holdingring = function(v, player, mo, cam)
	if cam.chase
		return
	end
	local weapon = RS.Weapons[mo.ringslinger.loadout[mo.ringslinger.wepslot]]
	local patch = v.cachePatch(weapon.viewsprite)
	local col = v.getColormap(TC_DEFAULT, player.skincolor)
	local scale = (weapon.scale or FRACUNIT) * 12/5
	local x, y
	if mo.ringslinger.swipe == 1
		x = 115*FRACUNIT
		y = 232*FRACUNIT
	else
		x = 230*FRACUNIT + mo.ringslinger.bobx
		y = 220*FRACUNIT + mo.ringslinger.boby + (weapon.viewoffset or 0)
	end
	
	if not splitscreen
		v.drawScaled(x, y, scale, patch, V_SNAPTOBOTTOM | V_SNAPTORIGHT | V_PERPLAYER, col)
	end
	if mo.ringslinger.swipe
		patch = v.cachePatch("SWIPE"+mo.ringslinger.swipe)
		v.draw(0, 0, patch, V_60TRANS | V_SNAPTOBOTTOM | V_PERPLAYER, col)
	end
end

//Add the hud
hud.add(function(v, player, cam)
	if not (gametyperules & GTR_RINGSLINGER or CV_FindVar("ringslinger").value)
		return
	end
	if not (player.mo and player.mo.valid and player.mo.ringslinger and player.playerstate == PST_LIVE)
		return
	end
	local mo = player.mo
	holdingring(v, player, mo, cam)
	weapons(v, player, mo, cam)
	drawammobar(v, player, mo, cam)
	powerups(v, player, mo, cam)
end, 'game')

hud.disable("weaponrings")