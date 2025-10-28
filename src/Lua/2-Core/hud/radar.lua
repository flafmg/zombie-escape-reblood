local RADAR_CONFIG = {
    RADAR_OFFSETX = 5,
    RADAR_OFFSETY = 5,
    RADAR_SIZE = 131,
    RADAR_SCALE = (3* FRACUNIT) / 5,
    RADAR_SIGHT = (260 * 64) * FRACUNIT,
    ICON_SIZE = 3,
    ICON_OUT_SIZE = 2,
    COL_SURVIVOR = 102,
    COL_ZOMBIE = 33,
}

local radarPatches = {
    background = nil,
    cross = {},
    outer = {},
    rings = nil
}

local function loadRotatingFrames(v)
    for i = 0, 15 do
        radarPatches.outer[i] = v.cachePatch(string.format("ROUTER%d", i))
        radarPatches.cross[i] = v.cachePatch(string.format("RCROSS%d", i))
    end
end

local function drawRotatingParts(v, cx, cy, scale, playerAngle)
    local offset = ANGLE_45 / 16
    local raw = playerAngle / offset
    local logicalIndex = (raw - (raw % 1)) % 16
    logicalIndex = (logicalIndex % 16 + 16) % 16

    if radarPatches.cross[logicalIndex] then
        v.drawScaled(cx * FRACUNIT, cy * FRACUNIT, scale, radarPatches.cross[logicalIndex], V_SNAPTORIGHT|V_SNAPTOTOP)
    end

    local outerFrame = logicalIndex % 8
    if radarPatches.outer[outerFrame] then
        v.drawScaled(cx * FRACUNIT, cy * FRACUNIT, scale, radarPatches.outer[outerFrame], V_SNAPTORIGHT|V_SNAPTOTOP)
    end
end

local function drawSquarePivot(v, x, y, size, color)
    if not size or size <= 0 then return end
    local half = size / 2
    local topRightX = x
    local topRightY = y
    v.drawFill(topRightX, topRightY, size, size, color | V_SNAPTORIGHT | V_SNAPTOTOP)
end

local function clampToCirclePixels(x, y, maxDist)
    local dist = FixedHypot(x * FRACUNIT, y * FRACUNIT) / FRACUNIT
    if dist > maxDist then
        local angle = R_PointToAngle2(0, 0, x * FRACUNIT, y * FRACUNIT)
        x = FixedMul(cos(angle), maxDist * FRACUNIT) / FRACUNIT
        y = FixedMul(sin(angle), maxDist * FRACUNIT) / FRACUNIT
        return x, y, true
    end
    return x, y, false
end

local function drawObjects(v, user, cx, cy, scale)
    local umo = user.mo
    if not umo then return end

    local radarsize = RADAR_CONFIG.RADAR_SIZE
    local radarWidth = FixedMul(radarsize * FRACUNIT, scale) / FRACUNIT
    local center_pixels = radarWidth / 2
    local unit = FRACUNIT
    local worldRadius = 152 * 48
    local maxDist = center_pixels - RADAR_CONFIG.ICON_OUT_SIZE

    for player in players.iterate do
        local mo = player.mo
        if not mo or mo == umo or player.spectator or not mo.health then
            continue
        end

        if mo.flags2 & MF2_DONTDRAW then
            continue
        end

        local dist = R_PointToDist2(umo.x, umo.y, mo.x, mo.y)
        if dist > RADAR_CONFIG.RADAR_SIGHT then
            continue
        end
        local angle = umo.angle - R_PointToAngle2(umo.x, umo.y, mo.x, mo.y) + ANGLE_270
        local x_pixels = P_ReturnThrustX(nil, angle, dist) / unit * center_pixels / worldRadius
        local y_pixels = P_ReturnThrustY(nil, angle, dist) / unit * center_pixels / worldRadius
        local clamped
        x_pixels, y_pixels, clamped = clampToCirclePixels(x_pixels, y_pixels, maxDist)
        local size = RADAR_CONFIG.ICON_SIZE
        if clamped then size = RADAR_CONFIG.ICON_OUT_SIZE end
        local half = size / 2
        local screenX = cx + x_pixels - half
        local screenY = cy + y_pixels - half

        local color = RADAR_CONFIG.COL_SURVIVOR
        if mo.player and mo.player.ctfteam == 1 then
            color = RADAR_CONFIG.COL_ZOMBIE
        end

        drawSquarePivot(v, screenX, screenY, size, color)
    end
end

local function drawradar(v, user, cam)
    if not radarPatches.background then
        radarPatches.background = v.cachePatch("RBACKG")
        radarPatches.rings = v.cachePatch("RRINGS")
        loadRotatingFrames(v)
    end
    
    local umo = user.mo
    local scale = RADAR_CONFIG.RADAR_SCALE
    local radarsize = RADAR_CONFIG.RADAR_SIZE
    local radarWidth = FixedMul(radarsize * FRACUNIT, scale) / FRACUNIT
    local radarHeight = radarWidth
    local cx = 320 - (radarWidth/2) - RADAR_CONFIG.RADAR_OFFSETX
    local cy = 0 + (radarHeight/2) + RADAR_CONFIG.RADAR_OFFSETY
    
    v.drawScaled(cx * FRACUNIT, cy * FRACUNIT, scale, radarPatches.background, V_SNAPTORIGHT|V_SNAPTOTOP|V_20TRANS)
    v.drawScaled(cx * FRACUNIT, cy * FRACUNIT, scale, radarPatches.rings, V_SNAPTORIGHT|V_SNAPTOTOP)
    
    if cam and cam.angle then
        drawRotatingParts(v, cx, cy, scale, umo.angle)
    end
    drawObjects(v, user, cx, cy, scale)
end

local function hudstuff(v, user, cam)
    if not multiplayer or maptol&TOL_NIGHTS
    or (gametype == GT_HIDEANDSEEK and user.pflags&PF_TAGIT)
    or gametype ~= GT_ZESCAPE then
        return
    end
    
    local umo = user.mo
    if not umo then return end
    
    drawradar(v, user, cam)
end

hud.add(hudstuff, "game")