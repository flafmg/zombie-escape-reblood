local ZE = RV_ZESCAPE
local CV = RV_ZESCAPE.Console

// guess what? this is the configuration for the stats hud lol :p
local HUD_CONFIG = {
    BAR_WIDTH = 65,
    BAR_HEIGHT = 8,
    BAR_SPACING = 4,
    BAR_X = 8,
    BAR_Y_HEALTH = 183,
    BAR_Y_STAMINA = 171,
    DIAGONAL_OFFSET = 3,
    
    HEALTH_COLOR = 96,
    HEALTH_LOW_COLOR = 32,
    HEALTH_LOW_FLASH = 120,
    HEALTH_BG = 24,
    HEALTH_SHADOW = 16,
    
    STAMINA_COLOR = 146,
    STAMINA_LOW_COLOR = 32,
    STAMINA_LOW_FLASH = 120,
    STAMINA_BG = 24,
    STAMINA_SHADOW = 16,
    
    HEALTH_LOW_THRESHOLD = 25,
    STAMINA_LOW_THRESHOLD = 15,
    
    SHAKE_INTENSITY_X = 1,
    SHAKE_INTENSITY_Y = 0,
    FLASH_SPEED = 8,
    
    RINGS_Y = 159,
    RINGS_X = 8,
    RINGS_ICON_SCALE = FU/2,
    
    TEXT_OFFSET_X = 3,
    TEXT_OFFSET_Y = 1,
}

local function isHealthLow(health, maxHealth)
    return health <= HUD_CONFIG.HEALTH_LOW_THRESHOLD
end
local function isStaminaLow(stamina)
    return stamina < (HUD_CONFIG.STAMINA_LOW_THRESHOLD * TICRATE)
end

local function getFlashColor(normalColor, lowColor, flashColor)
    if (leveltime / HUD_CONFIG.FLASH_SPEED) % 2 < 1 then
        return lowColor
    else
        return flashColor
    end
end



local function getShakeOffset()
    local shakeX = 0
    local shakeY = 0
    
    if leveltime % 4 < 2 then
        shakeX = HUD_CONFIG.SHAKE_INTENSITY_X
        shakeY = HUD_CONFIG.SHAKE_INTENSITY_Y
    else
        shakeX = -HUD_CONFIG.SHAKE_INTENSITY_X
        shakeY = -HUD_CONFIG.SHAKE_INTENSITY_Y
    end
    
    return shakeX, shakeY
end


local function drawDiagonalBarOptimized(v, x, y, width, height, fillPercent, color, bgColor, shadowColor, shakeX, shakeY)
    local fillWidth = (width * fillPercent) / 100
    
    local diagOffset = HUD_CONFIG.DIAGONAL_OFFSET

    local segments = height
    for i = 0, segments - 1 do
        local segmentY = y + i + shakeY
        local segmentDiagX = (i * diagOffset) / height
        
        v.drawFill(x + segmentDiagX + shakeX + 1, segmentY + 1, width, 1, shadowColor|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_50TRANS) //outline
        v.drawFill(x + segmentDiagX + shakeX, segmentY, width, 1,bgColor|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM) //bkg
        if fillWidth > 0 then
            v.drawFill(x + segmentDiagX + shakeX, segmentY, fillWidth, 1, color|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM) //fill
        end
    end
end

//stat ring
hud.add(function(v, player, camera)
    local hudtype = CV.hudtype.value
    if (gametype ~= GT_ZESCAPE) then return end
    if not (player.mo and player.mo.valid) then return end
    if not (player.mo.health and player.mo.health > 0) then return end
    if hudtype ~= 2 then return end
    if(player.rings <= 0) then return end
    
    local x = HUD_CONFIG.RINGS_X
    local y = HUD_CONFIG.RINGS_Y

    local ringPatch = v.cachePatch("MRING")

    v.drawScaled(x * FRACUNIT, y * FRACUNIT, HUD_CONFIG.RINGS_ICON_SCALE, ringPatch, V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
    v.drawString(x + 10, y + 1, max(0, player.rings),  V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_YELLOWMAP, "thin")
end, "game")

//stat helth
hud.add(function(v, player, camera)
    local hudtype = CV.hudtype.value
    if (gametype ~= GT_ZESCAPE) then return end
    if not (player.mo and player.mo.valid) then return end
    if not (player.mo.health and player.mo.health > 0 and player.mo.maxHealth) then return end
    
    //i dont know why this exists but im keeping it
    if hudtype == 1 then
        v.drawString(0, 183, "\x85\+", V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
        v.drawString(8, 183, max(0, player.mo.health), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM, "left")
        return
    end
    
    if hudtype == 2 then
        local health = max(0, player.mo.health)
        local maxHealth = max(1, player.mo.maxHealth)
        local healthPercent = (health * 100) / maxHealth
        
        local isLow = isHealthLow(health, maxHealth)
        local barColor = HUD_CONFIG.HEALTH_COLOR
        
        if isLow then
            barColor = getFlashColor(HUD_CONFIG.HEALTH_COLOR, HUD_CONFIG.HEALTH_LOW_COLOR, HUD_CONFIG.HEALTH_LOW_FLASH)
        end
        
        local shakeX = 0
        local shakeY = 0
        if isLow then
            shakeX, shakeY = getShakeOffset()
        end
        
        drawDiagonalBarOptimized(
            v,
            HUD_CONFIG.BAR_X,
            HUD_CONFIG.BAR_Y_HEALTH,
            HUD_CONFIG.BAR_WIDTH,
            HUD_CONFIG.BAR_HEIGHT,
            healthPercent,
            barColor,
            HUD_CONFIG.HEALTH_BG,
            HUD_CONFIG.HEALTH_SHADOW,
            shakeX,
            shakeY
        )

        local textX = HUD_CONFIG.BAR_X + HUD_CONFIG.TEXT_OFFSET_X
        local textY = HUD_CONFIG.BAR_Y_HEALTH + HUD_CONFIG.TEXT_OFFSET_Y
        v.drawString(textX, textY, health .. "/" .. maxHealth, V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM, "thin")
    end
end, "game")

//stat stamina
hud.add(function(v, player)
    local hudtype = CV.hudtype.value
    if not (player.ctfteam == 2) then return end
    if (gametype ~= GT_ZESCAPE) then return end
    if not (player.mo and player.mo.valid) then return end
    
    //i dont know why this exists but im keeping it
    if hudtype == 1 then
        local staminaSec = max(0, player.stamina / TICRATE)
        if player.stamina < 25 * TICRATE then
            v.drawString(33, 183, "\x85\S", V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
            v.drawString(42, 183, staminaSec, V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM, "left")
        else
            v.drawString(33, 183, "\x84\S", V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
            v.drawString(42, 183, staminaSec, V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM, "left")
        end
        return
    end
    
    if hudtype == 2 then
        local maxStamina = 100 * TICRATE
        local stamina = max(0, min(player.stamina, maxStamina))
        local staminaPercent = (stamina * 100) / maxStamina
        
        local isLow = isStaminaLow(stamina)
        local barColor = HUD_CONFIG.STAMINA_COLOR
        
        if isLow then
            barColor = getFlashColor(HUD_CONFIG.STAMINA_COLOR, HUD_CONFIG.STAMINA_LOW_COLOR, HUD_CONFIG.STAMINA_LOW_FLASH)
        end
        
        local shakeX = 0
        local shakeY = 0
        if isLow then
            shakeX, shakeY = getShakeOffset()
        end
        
        drawDiagonalBarOptimized(
            v,
            HUD_CONFIG.BAR_X,
            HUD_CONFIG.BAR_Y_STAMINA,
            HUD_CONFIG.BAR_WIDTH,
            HUD_CONFIG.BAR_HEIGHT,
            staminaPercent,
            barColor,
            HUD_CONFIG.STAMINA_BG,
            HUD_CONFIG.STAMINA_SHADOW,
            shakeX,
            shakeY
        )
        
        local textX = HUD_CONFIG.BAR_X + HUD_CONFIG.TEXT_OFFSET_X
        local textY = HUD_CONFIG.BAR_Y_STAMINA + HUD_CONFIG.TEXT_OFFSET_Y
        v.drawString(textX, textY, staminaPercent .. "%", V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM, "thin")
    end
end, "game")