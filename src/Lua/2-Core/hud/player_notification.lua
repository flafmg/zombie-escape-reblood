local ZE = RV_ZESCAPE
local CV = RV_ZESCAPE.Console

local NOTIF_CONFIG = {
    OFFSET_X = 10,
    OFFSET_Y = 10,
    STACK_SPACING = 26,
    
    WIDTH = 120,
    HEIGHT = 24,
    
    DEFAULT_BG_COLOR = 24,
    DEFAULT_SHADOW_COLOR = 16,
    DIAGONAL_OFFSET = 3,
    
    DEFAULT_TEXT_PADDING = 6,
    LINE_HEIGHT = 8,
    
    FADE_IN_TIME = 15,
    DISPLAY_TIME = 5 * TICRATE,
    FADE_OUT_TIME = 15,
    
    SLIDE_DISTANCE = 40,
    
    ICON_OFFSET_X = 12,
}

local NOTIF_TYPES = {
    info = {
        patch = "INFO",
        scale = (5 * FRACUNIT) / 4,
        bg_color = 139,
        shadow_color = 28,
        text_padding = 16
    },
    hint = {
        patch = "HINT",
        scale = (5 * FRACUNIT) / 4,
        bg_color = 169,
        shadow_color = 28,
        text_padding = 20
    },
    warn = {
        patch = "WARN",
        scale = (5 * FRACUNIT) / 4,
        bg_color = 71,
        shadow_color = 28,
        text_padding = 18
    },
    defend = {
        patch = "DEFEND",
        scale = (5 * FRACUNIT) / 4,
        bg_color = 110,
        shadow_color = 28,
        text_padding = 26
    },
    none = {
        patch = "none",
        scale = 0,
        bg_color = 24,
        shadow_color = 28,
        text_padding = 6
    }
}

local COLOR_CODES = {
    white = "\x80",
    magenta = "\x81",
    yellow = "\x82",
    green = "\x83",
    blue = "\x84",
    red = "\x85",
    gray = "\x86",
    orange = "\x87",
    sky = "\x88",
    purple = "\x89",
    aqua = "\x8A",
    peridot = "\x8B",
    azure = "\x8C",
    brown = "\x8D",
    rosy = "\x8E",
    inverted = "\x8F"
}

local activeNotifications = {}

local function drawDiagonalBox(v, x, y, width, height, bgColor, shadowColor, trans)
    local diagOffset = NOTIF_CONFIG.DIAGONAL_OFFSET
    
    for i = 0, height - 1 do
        local segmentY = y + i
        local segmentDiagX = (i * diagOffset) / height
        
        v.drawFill(x + segmentDiagX + 1, segmentY + 1, width, 1, shadowColor|V_SNAPTORIGHT|V_SNAPTOBOTTOM|trans)
        v.drawFill(x + segmentDiagX, segmentY, width, 1, bgColor|V_SNAPTORIGHT|V_SNAPTOBOTTOM|trans)
    end
end

local function getTransparency(elapsed, totalDuration)
    local fadeInTime = NOTIF_CONFIG.FADE_IN_TIME
    local fadeOutTime = NOTIF_CONFIG.FADE_OUT_TIME
    local fadeOutStart = totalDuration - fadeOutTime
    
    if elapsed < fadeInTime then
        local progress = elapsed * 10 / fadeInTime
        if progress < 1 then return V_90TRANS
        elseif progress < 2 then return V_80TRANS
        elseif progress < 4 then return V_70TRANS
        elseif progress < 6 then return V_60TRANS
        elseif progress < 8 then return V_50TRANS
        else return 0
        end
    elseif elapsed > fadeOutStart then
        local fadeProgress = (elapsed - fadeOutStart) * 10 / fadeOutTime
        if fadeProgress > 9 then return V_90TRANS
        elseif fadeProgress > 8 then return V_80TRANS
        elseif fadeProgress > 6 then return V_70TRANS
        elseif fadeProgress > 4 then return V_60TRANS
        elseif fadeProgress > 2 then return V_50TRANS
        else return 0
        end
    else
        return 0
    end
end

local function getSlideOffset(elapsed, totalDuration)
    local fadeInTime = NOTIF_CONFIG.FADE_IN_TIME
    local fadeOutTime = NOTIF_CONFIG.FADE_OUT_TIME
    local fadeOutStart = totalDuration - fadeOutTime
    
    if elapsed < fadeInTime then
        local progress = (elapsed * FRACUNIT) / fadeInTime
        return NOTIF_CONFIG.SLIDE_DISTANCE - FixedMul(NOTIF_CONFIG.SLIDE_DISTANCE * FRACUNIT, progress) / FRACUNIT
    elseif elapsed > fadeOutStart then
        local fadeProgress = ((elapsed - fadeOutStart) * FRACUNIT) / fadeOutTime
        return FixedMul(NOTIF_CONFIG.SLIDE_DISTANCE * FRACUNIT, fadeProgress) / FRACUNIT
    else
        return 0
    end
end

local function processColorCodes(text)
    local processed = text
    for colorName, colorCode in pairs(COLOR_CODES) do
        processed = processed:gsub("{"..colorName.."}", colorCode)
    end
    return processed
end

local function splitLines(text)
    local lines = {}
    local processed = text:gsub("\\n", "\n")
    for line in processed:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    if #lines == 0 then
        table.insert(lines, processed)
    end
    return lines
end

local function addNotification(player, type, message)
    if not activeNotifications[player] then
        activeNotifications[player] = {}
    end
    table.insert(activeNotifications[player], {
        type = type,
        message = message,
        startTime = leveltime
    })
end

ZE.player_notify = function(player, type, message)
    addNotification(player, type, message)
end

ZE.notify_all = function(type, message)
    for player in players.iterate do
        ZE.player_notify(player, type, message)
    end
end

hud.add(function(v, player)
    if gametype ~= GT_ZESCAPE then return end
    local notifs = activeNotifications[player]
    if not notifs or not notifs[1] then return end
    
    local totalDuration = NOTIF_CONFIG.FADE_IN_TIME + NOTIF_CONFIG.DISPLAY_TIME + NOTIF_CONFIG.FADE_OUT_TIME
    
    for index = #notifs, 1, -1 do
        local notif = notifs[index]
        local elapsed = leveltime - notif.startTime
        
        if elapsed > totalDuration then
            table.remove(notifs, index)
        else
            local stackOffset = (index - 1) * NOTIF_CONFIG.STACK_SPACING
            local slideOffset = getSlideOffset(elapsed, totalDuration)
            local x = 320 - NOTIF_CONFIG.WIDTH - NOTIF_CONFIG.OFFSET_X
            local y = 200 - NOTIF_CONFIG.HEIGHT - NOTIF_CONFIG.OFFSET_Y + slideOffset - stackOffset
            
            local trans = getTransparency(elapsed, totalDuration)
            
            local bgColor = NOTIF_CONFIG.DEFAULT_BG_COLOR
            local shadowColor = NOTIF_CONFIG.DEFAULT_SHADOW_COLOR
            local textPadding = NOTIF_CONFIG.DEFAULT_TEXT_PADDING
            
            if notif.type and NOTIF_TYPES[notif.type] then
                local typeData = NOTIF_TYPES[notif.type]
                bgColor = typeData.bg_color or bgColor
                shadowColor = typeData.shadow_color or shadowColor
                textPadding = typeData.text_padding or textPadding
            end
            
            drawDiagonalBox(
                v,
                x,
                y,
                NOTIF_CONFIG.WIDTH,
                NOTIF_CONFIG.HEIGHT,
                bgColor,
                shadowColor,
                trans
            )
            
            local textX = x + textPadding
            
            if notif.type and NOTIF_TYPES[notif.type] then
                local typeData = NOTIF_TYPES[notif.type]
                local patchName = typeData.patch
                
                if v.patchExists(patchName) then
                    local patch = v.cachePatch(patchName)
                    
                    local iconX = x + NOTIF_CONFIG.ICON_OFFSET_X
                    local iconY = y + NOTIF_CONFIG.HEIGHT / 2
                    
                    v.drawScaled(
                        iconX * FRACUNIT,
                        iconY * FRACUNIT,
                        typeData.scale,
                        patch,
                        V_SNAPTORIGHT|V_SNAPTOBOTTOM|trans
                    )
                end
            end
            
            local processedMessage = processColorCodes(notif.message)
            local lines = splitLines(processedMessage)
            local totalTextHeight = #lines * NOTIF_CONFIG.LINE_HEIGHT
            local textStartY = y + (NOTIF_CONFIG.HEIGHT - totalTextHeight) / 2
            
            for i, line in ipairs(lines) do
                local lineY = textStartY + (i - 1) * NOTIF_CONFIG.LINE_HEIGHT
                v.drawString(
                    textX,
                    lineY,
                    line,
                    V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|trans,
                    "thin"
                )
            end
        end
    end
end, "game")