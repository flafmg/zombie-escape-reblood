local ZE = RV_ZESCAPE
local CV = RV_ZESCAPE.Console

local STATUS_CONFIG = {
    HUD_X = 160,
    HUD_Y = 1,
    
    ZOMBIE_WIDTH = 18,
    CLOCK_WIDTH = 42,
    SURVIVOR_WIDTH = 18,
    BAR_HEIGHT = 9,
    
    DIAGONAL_OFFSET = 3,
    
    ZOMBIE_COLOR = 33,
    ZOMBIE_BG = 40,
    SURVIVOR_COLOR = 149,
    SURVIVOR_BG = 156,
    CLOCK_COLOR = 28,
    CLOCK_BG = 24, 
    
    SHADOW_COLOR = 16,
    CLOCK_SIZE = 9,
    CLOCK_BORDER_COLOR = 83,
    CLOCK_FILL_COLOR = 0,
    CLOCK_HAND_COLOR = 16,
    
    TIMER_WARNING_THRESHOLD = 30,
    TIMER_CRITICAL_THRESHOLD = 10,
    FLASH_SPEED = 8,
    
    HAND_ANIMATION_SPEED = 4,
}


local clockTime = {
    hours = 12,
    minutes = 30
}

local function drawDiagonalBarSection(v, x, y, width, height, color, bgColor, drawShadow)
    local diagOffset = STATUS_CONFIG.DIAGONAL_OFFSET
    
    for i = 0, height - 1 do
        local segmentY = y + i
        local segmentDiagX = (i * diagOffset) / height
        
        if drawShadow then
            v.drawFill(x + segmentDiagX + 1, segmentY + 1, width, 1, STATUS_CONFIG.SHADOW_COLOR|V_SNAPTOTOP|V_50TRANS)
        end
        
        v.drawFill(x + segmentDiagX, segmentY, width, 1, bgColor|V_SNAPTOTOP|V_90TRANS)
        v.drawFill(x + segmentDiagX, segmentY, width, 1, color|V_SNAPTOTOP)
    end
end

local function drawClock(v, centerX, centerY)
    local size = STATUS_CONFIG.CLOCK_SIZE
    local radius = (size - 1) / 2
    local cx = centerX + radius
    local cy = centerY + radius

    for dy = 0, size - 1 do
        for dx = 0, size - 1 do
            local distX = dx - radius
            local distY = dy - radius
            local distSq = distX * distX + distY * distY
            local dist = FixedSqrt(distSq * FRACUNIT) / FRACUNIT
            
            if dist <= radius then
                if dist > radius - 1 then
                    v.drawFill(centerX + dx, centerY + dy, 1, 1, STATUS_CONFIG.CLOCK_BORDER_COLOR|V_SNAPTOTOP)
                else
                    v.drawFill(centerX + dx, centerY + dy, 1, 1, STATUS_CONFIG.CLOCK_FILL_COLOR|V_SNAPTOTOP)
                end
            end
        end
    end
    
    v.drawFill(cx, cy, 1, 1, STATUS_CONFIG.CLOCK_HAND_COLOR|V_SNAPTOTOP)
    
    local minuteAngle = ANGLE_270
    local minuteLen = 3
    for i = 1, minuteLen do
        local mx = cx + FixedMul(cos(minuteAngle), i * FRACUNIT) / FRACUNIT
        local my = cy + FixedMul(sin(minuteAngle), i * FRACUNIT) / FRACUNIT
        v.drawFill(mx, my, 1, 1, STATUS_CONFIG.CLOCK_HAND_COLOR|V_SNAPTOTOP)
    end
    
    local hourAngle = 0
    local hourLen = 2
    for i = 1, hourLen do
        local hx = cx + FixedMul(cos(hourAngle), i * FRACUNIT) / FRACUNIT
        local hy = cy + FixedMul(sin(hourAngle), i * FRACUNIT) / FRACUNIT
        v.drawFill(hx, hy, 1, 1, STATUS_CONFIG.CLOCK_HAND_COLOR|V_SNAPTOTOP)
    end
end

local function getTimerColorMap(timeLeft)
    if timeLeft < STATUS_CONFIG.TIMER_CRITICAL_THRESHOLD * TICRATE then
        if (leveltime / STATUS_CONFIG.FLASH_SPEED) % 2 < 1 then
            return V_REDMAP
        else
            return 0
        end
    elseif timeLeft < STATUS_CONFIG.TIMER_WARNING_THRESHOLD * TICRATE then
        if (leveltime / STATUS_CONFIG.FLASH_SPEED) % 2 < 1 then
            return V_YELLOWMAP
        else
            return 0
        end
    end
    return 0
end

local function G_TicsToMTIME(tics)
    local minutes = tostring(G_TicsToMinutes(tics))
    local seconds = tostring(G_TicsToSeconds(tics))
    if minutes:len() < 2 then
        minutes = "0"..$
    end
    if seconds:len() < 2 then
        seconds = "0"..$
    end
    return minutes..":"..seconds
end

//game sttus hud
hud.add(function(v, player, camera)
    local hudtype = CV.hudtype.value
    if gametype ~= GT_ZESCAPE then return end
    if not (player.mo and player.mo.valid) then return end
    if hudtype ~= 2 then return end
    
    local zombies = ZE.zombcount
    local survivors = ZE.survcount
    local basetime = CV.survtime
    local isWaiting = leveltime < CV.waittime

    local totalWidth = STATUS_CONFIG.ZOMBIE_WIDTH + STATUS_CONFIG.CLOCK_WIDTH + STATUS_CONFIG.SURVIVOR_WIDTH
    local startX = STATUS_CONFIG.HUD_X - totalWidth / 2
    
    local diagOffset = STATUS_CONFIG.DIAGONAL_OFFSET
    for i = 0, STATUS_CONFIG.BAR_HEIGHT - 1 do
        local segmentY = STATUS_CONFIG.HUD_Y + i
        local segmentDiagX = (i * diagOffset) / STATUS_CONFIG.BAR_HEIGHT
        v.drawFill(startX + segmentDiagX + 1, segmentY + 1, totalWidth, 1, STATUS_CONFIG.SHADOW_COLOR|V_SNAPTOTOP|V_50TRANS)
    end
    
    local currentX = startX
    
    //zombie
    drawDiagonalBarSection(
        v,
        currentX,
        STATUS_CONFIG.HUD_Y,
        STATUS_CONFIG.ZOMBIE_WIDTH,
        STATUS_CONFIG.BAR_HEIGHT,
        STATUS_CONFIG.ZOMBIE_COLOR,
        STATUS_CONFIG.ZOMBIE_BG,
        false
    )
    
    local zombieText = tostring(zombies)
    local zombieTextWidth = v.stringWidth(zombieText, 0, "thin")
    local zombieTextX = currentX + (STATUS_CONFIG.ZOMBIE_WIDTH - zombieTextWidth) / 2
    local zombieTextY = STATUS_CONFIG.HUD_Y - 1 + (STATUS_CONFIG.BAR_HEIGHT - 5) / 2
    v.drawString(zombieTextX, zombieTextY, zombieText, V_SNAPTOTOP, "thin")
    
    currentX = currentX + STATUS_CONFIG.ZOMBIE_WIDTH
    
    //timer
    drawDiagonalBarSection(
        v,
        currentX,
        STATUS_CONFIG.HUD_Y,
        STATUS_CONFIG.CLOCK_WIDTH,
        STATUS_CONFIG.BAR_HEIGHT,
        STATUS_CONFIG.CLOCK_COLOR,
        STATUS_CONFIG.CLOCK_BG,
        false
    )
    local clockX = currentX + 4
    local clockY = STATUS_CONFIG.HUD_Y
    drawClock(v, clockX, clockY)
    
    local timeText = ""
    local timeColor = V_SNAPTOTOP
    
    if isWaiting then
        timeText = G_TicsToMTIME(CV.waittime - leveltime)
    else
        timeText = G_TicsToMTIME(basetime)
        timeColor = getTimerColorMap(basetime)|V_SNAPTOTOP
    end
    
    local timerX = currentX + 16
    local timerY = STATUS_CONFIG.HUD_Y - 1 + (STATUS_CONFIG.BAR_HEIGHT - 5) / 2
    v.drawString(timerX, timerY, timeText, timeColor, "thin")
    currentX = currentX + STATUS_CONFIG.CLOCK_WIDTH
    
    // survivor 
    drawDiagonalBarSection(
        v,
        currentX,
        STATUS_CONFIG.HUD_Y,
        STATUS_CONFIG.SURVIVOR_WIDTH,
        STATUS_CONFIG.BAR_HEIGHT,
        STATUS_CONFIG.SURVIVOR_COLOR,
        STATUS_CONFIG.SURVIVOR_BG,
        false
    )
    
    local survivorText = tostring(survivors)
    local survivorTextWidth = v.stringWidth(survivorText, 0, "thin")
    local survivorTextX = currentX + (STATUS_CONFIG.SURVIVOR_WIDTH - survivorTextWidth) / 2
    local survivorTextY = STATUS_CONFIG.HUD_Y - 1 + (STATUS_CONFIG.BAR_HEIGHT - 5) / 2
    v.drawString(survivorTextX, survivorTextY, survivorText, V_SNAPTOTOP, "thin")
    
end, "game")