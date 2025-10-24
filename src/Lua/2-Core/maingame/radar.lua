//col
local c_white = 0
local c_blue = 149
local c_darkblue = 154
local c_red = 34
local c_darkred = 40
local c_yellow = 72
local c_orange = 56
local c_green = 102
local c_black = 31

//config radar
local RADAR_SIZE = 64
local RADAR_BORDER = 2
local RADAR_ICON_SIZE = 3
local RADAR_ICON_SIZE_SPLITSCREEN = 2
local RADAR_DOT_SIZE = 2
local RADAR_CLAMP_MARGIN = 5
local RADAR_COMPASS_DISTANCE = 4
local RADAR_TEXT_OFFSET = 2
local RADAR_POSITION_OFFSET = 8
local RADAR_HEIGHT_SHRINK_SIZE = 2

local radarpatch = nil

local function drawCompassMarkers(v, cx, cy, radius, playerangle, scale)
	local compassdist = radius - RADAR_COMPASS_DISTANCE*scale
	local textoffset = RADAR_TEXT_OFFSET*scale
	local markers = {
		{ang = 0, text = "N"},
		{ang = ANGLE_180, text = "S"},
		{ang = ANGLE_90, text = "E"},
		{ang = -ANGLE_90, text = "W"}
	}
	
	for i = 1, #markers do
		local m = markers[i]
		local angle = playerangle + m.ang
		local mx = FixedMul(cos(angle), compassdist*FRACUNIT)/FRACUNIT
		local my = FixedMul(sin(angle), compassdist*FRACUNIT)/FRACUNIT
		v.drawString(cx+mx-textoffset, cy+my-textoffset, m.text, 
			V_NOSCALESTART|V_ALLOWLOWERCASE|V_6WIDTHSPACE, "small")
	end
end
local function clampToCircle(x, y, maxDist)
	local dist = FixedHypot(x*FRACUNIT, y*FRACUNIT)/FRACUNIT
	if dist > maxDist then
		local angle = R_PointToAngle2(0, 0, x*FRACUNIT, y*FRACUNIT)
		x = FixedMul(cos(angle), maxDist*FRACUNIT)/FRACUNIT
		y = FixedMul(sin(angle), maxDist*FRACUNIT)/FRACUNIT
		return x, y, true
	end
	return x, y, false
end



local function drawPlayerIcon(v, xpos, ypos, centerx, centery, player, size)
	if not player or not player.skin then return end
	
	local icon = v.getSprite2Patch(player.skin, SPR2_LIFE)
	local scale = size*FRACUNIT/(icon.width)
	local colormap = v.getColormap(TC_DEFAULT, player.skincolor)
	local iconx = FixedInt((xpos+centerx)*FRACUNIT - (icon.width*scale)/2)
	local icony = FixedInt((ypos+centery)*FRACUNIT - (icon.height*scale)/2)
	v.drawScaled(iconx*FRACUNIT, icony*FRACUNIT, scale, icon, V_NOSCALESTART, colormap)
end


local function hudstuff(v, user, cam)
	if not multiplayer or maptol&TOL_NIGHTS 
		or (gametype == GT_HIDEANDSEEK and user.pflags&PF_TAGIT)
		or gametype ~= GT_ZESCAPE then 
		return 
	end
	
	local umo = user.mo
	if not umo then return end
	if not radarpatch then
		radarpatch = v.cachePatch("RADAR")
	end
	
	local xscale = v.dupx()
	local yscale = v.dupy()
	local unit = FRACUNIT
	local radius = 152*48
	local fullsight = 260*64
	local radarsize = RADAR_SIZE
	local hradius = radius
	
	if splitscreen then 
		radarsize = radarsize*2/3 
	end
	
	local center = radarsize/2
	local xpos = v.width()-radarsize*xscale-RADAR_POSITION_OFFSET*xscale
	local ypos = RADAR_POSITION_OFFSET*yscale
	if splitscreen then
		ypos = ypos/2
		if user == secondarydisplayplayer then
			ypos = ypos + v.height()/2
		end
	end
	
	local cx = xpos + center*xscale
	local cy = ypos + center*yscale
	local r = center
	
	v.draw(xpos + center, ypos + center, radarpatch, V_NOSCALESTART)
	drawCompassMarkers(v, cx, cy, r*xscale, umo.angle, xscale)

	local maxDist = r*xscale - RADAR_CLAMP_MARGIN*xscale
	local iconsize = xscale*RADAR_ICON_SIZE/2
	if splitscreen then 
		iconsize = iconsize*RADAR_ICON_SIZE_SPLITSCREEN/3 
	end


	if gametype > GT_RACE then
		searchBlockmap("objects", function(umo, mo)
			if not mo or not mo.health then return nil end
			
			local dist = R_PointToDist2(umo.x, umo.y, mo.x, mo.y)
			local zdist = abs(mo.z - umo.z)
			
			if dist > fullsight*unit then return nil end
			
			local color = c_white
			local size = iconsize
			local drawicon = false
			
			if mo.type == MT_PLAYER then
				if mo.player.spectator then return nil end
				
				drawicon = true
				
				if gametype == GT_ZESCAPE then
					local notmyteam = mo.player.ctfteam == 1
					local notdrawing = (mo.flags2 & MF2_DONTDRAW)
					
					if notdrawing then
						color = c_black
					elseif notmyteam and not(leveltime&4) then
						color = c_yellow
					elseif mo.player.ctfteam == 1 then
						color = c_red
					else
						color = c_blue
					end
				end
			elseif mo.type >= MT_BOUNCEPICKUP and mo.type <= MT_GRENADEPICKUP then
				color = c_green
			elseif mo.type == MT_TOKEN or (mo.type <= MT_EMERHUNT and mo.type >= MT_EMERALD1) then
				color = not(leveltime&15) and c_orange or c_yellow
			elseif mo.type == MT_REDFLAG then
				color = (not(leveltime&15) and not(mo.fuse and not(leveltime&4))) and c_darkred or c_yellow
			elseif mo.type == MT_BLUEFLAG then
				color = (not(leveltime&15) and not(mo.fuse and not(leveltime&4))) and c_darkblue or c_yellow
			else
				return nil
			end
			
			if zdist > hradius*unit then 
				size = size*RADAR_HEIGHT_SHRINK_SIZE/3 
			end

			local angle = umo.angle - R_PointToAngle2(umo.x, umo.y, mo.x, mo.y) + ANGLE_270
			local x = P_ReturnThrustX(nil, angle, dist)/unit*center/radius
			local y = P_ReturnThrustY(nil, angle, dist)/unit*center/radius
			
			x = x*xscale
			y = y*yscale
			
			local clamped
			x, y, clamped = clampToCircle(x, y, maxDist)
			if clamped then size = size/2 end
			
			if drawicon and mo.player and mo.player.skin then
				drawPlayerIcon(v, xpos, ypos, x+center*xscale, y+center*yscale, mo.player, size)
			else
				v.drawFill(xpos+x+center*xscale-size/2, ypos+y+center*yscale-size/2, size, size, color|V_NOSCALESTART)
			end
			
			return nil
		end, umo, umo.x-fullsight*unit, umo.x+fullsight*unit, umo.y-fullsight*unit, umo.y+fullsight*unit)
	else
		for player in players.iterate do
			local mo = player.mo
			if not mo or mo == umo or player.spectator or not mo.health or (mo.flags2 & MF2_DONTDRAW) then //if not spectator or helth 0 or draw flag?
				continue
			end
			
			local size = iconsize
			local dist = R_PointToDist2(umo.x, umo.y, mo.x, mo.y)
			local angle = umo.angle - R_PointToAngle2(umo.x, umo.y, mo.x, mo.y) + ANGLE_270
			local x = P_ReturnThrustX(nil, angle, dist)/unit*center/radius
			local y = P_ReturnThrustY(nil, angle, dist)/unit*center/radius
			
			x = x*xscale
			y = y*yscale
			
			local clamped
			x, y, clamped = clampToCircle(x, y, maxDist)
			if clamped then size = size/2 end
			
			drawPlayerIcon(v, xpos, ypos, x+center*xscale, y+center*yscale, player, size)
		end
	end
	
	local dotsize = xscale*RADAR_DOT_SIZE
	v.drawFill(xpos+center*xscale-dotsize/2, ypos+center*yscale-dotsize/2, dotsize, dotsize, c_white|V_NOSCALESTART)
end

hud.add(hudstuff, "game")