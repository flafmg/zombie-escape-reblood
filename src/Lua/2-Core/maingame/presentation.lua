local ZE = RV_ZESCAPE

local PRESENT_CONFIG = {
    DELAY_AFTER_CHAR_SELECT = 2 * TICRATE,
    NOTIF_DELAY = 6 * TICRATE, 
    PRESENT_DELAY = 2 * TICRATE,  
}

local playerTimers = {}
local playerseenbasic = {}
local characterDescriptions = {}

local defaultPresentation = {
    {type="info", message="Welcome to \nZombie Escape!"},
    {type="hint", message="{yellow}C1 {white}to run\nconsumes {blue}stamina"},
    {type="hint", message="{yellow}Fire Normal {white}to reload"},
    {type="hint", message="{yellow}Fire {white}to attack"}
}

local function sendNotification(player, type, message)
    ZE.player_notify(player, type, message)
end

local function processQueue(player)
    local data = playerTimers[player]
    if not data or #data.queue == 0 then return end
    
    local item = table.remove(data.queue, 1)
    sendNotification(player, item.type, item.message)
    
    if #data.queue > 0 then
        data.timer = PRESENT_CONFIG.NOTIF_DELAY
    end
end

local function queueNotifications(player, notifs)
    if not playerTimers[player] then
        playerTimers[player] = {queue = {}, timer = 0}
    end
    for _, notif in ipairs(notifs) do
        table.insert(playerTimers[player].queue, notif)
    end
    if playerTimers[player].timer == 0 and #playerTimers[player].queue > 0 then
        playerTimers[player].timer = 1 
    end
end

ZE.addCharacterDescription = function(skinname, notifications)
    characterDescriptions[skinname] = notifications
end

ZE.setDefaultPresentation = function(notifications)
    defaultPresentation = notifications
end

ZE.basicpresentation = function(player)
    queueNotifications(player, defaultPresentation)
end

ZE.charpresentation = function(player)
    local notifs = {}
    
    if player.ctfteam == 2 then
        if player.mo and player.mo.valid then
            local skinname = player.mo.skin
            if characterDescriptions[skinname] then
                notifs = characterDescriptions[skinname]
            end
        end
    elseif player.ctfteam == 1 then
        if player.ztype == "ZM_ALPHA" then
            table.insert(notifs, {type="hint", message="As Alpha Zombie:\n{yellow}C1 {white}to rage\nCooldown shown"})
        elseif player.ztype then
            table.insert(notifs, {type="hint", message="As "..ZE.Ztypes[player.ztype].name.." Zombie\n{red}seek fresh meat"})
        else
            table.insert(notifs, {type="hint", message="As Zombie\n{red}seek fresh meat"})
        end
    end
    
    queueNotifications(player, notifs)
end

ZE.presentation = function(player) 
    if not playerseenbasic[player] then
        ZE.basicpresentation(player)
        playerseenbasic[player] = true
    end
    ZE.charpresentation(player)
end

ZE.schedulePresentation = function(player)
    if not playerTimers[player] then
        playerTimers[player] = {queue = {}, timer = PRESENT_CONFIG.DELAY_AFTER_CHAR_SELECT}
    else
        playerTimers[player].timer = PRESENT_CONFIG.DELAY_AFTER_CHAR_SELECT
    end
    playerTimers[player].onTimerEnd = function() ZE.presentation(player) end
end

addHook("ThinkFrame", function()
    for player in players.iterate do
        local data = playerTimers[player]
        if data and data.timer > 0 then
            data.timer = $ - 1
            if data.timer == 0 then
                if data.onTimerEnd then
                    data.onTimerEnd()
                    data.onTimerEnd = nil
                else
                    processQueue(player)
                end
            end
        end
    end
end)

ZE.addCharacterDescription("amy", {
    {type="hint", message="As {rosy}Amy{white}:\n{yellow}Spin {white}to attack or heal"},
    {type="hint", message="As {rosy}Amy{white}:\n{yellow}TF {white}for heal burst\nCost: "..tostring(ZE.PropCosts["HealBurst"])}
})

ZE.addCharacterDescription("tails", {
    {type="hint", message="As {orange}Tails{white}:\n{yellow}TF {white}to spawn wood fence\nCost: "..tostring(ZE.PropCosts["Wood"])}
})

ZE.addCharacterDescription("metalsonic", {
    {type="hint", message="As {blue}Metal Sonic{white}:\n{yellow}TF {white}to place land mines\nCost: "..tostring(ZE.PropCosts["LandMine"])}
})

ZE.addCharacterDescription("fang", {
    {type="hint", message="As {purple}Fang{white}:\n{yellow}Spin {white}to attack"}
})

ZE.addCharacterDescription("scarf", {
    {type="hint", message="As Scraf{white}:\n{yellow}Spin {white}for melee\n{yellow}Hold Spin {white}for fireball"}
})

ZE.addCharacterDescription("sonic", {
    {type="hint", message="As {blue}sonic{white}:\n{yellow}jump {white}twice for thok"}
})