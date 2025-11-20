local ZE = RV_ZESCAPE
local CV = ZE.Console

ZE.Unlockables = {}

ZE.addUnlockableCharacter = function(char, gamesRequired)
    print("adding unlockable char: "..char.." with "..gamesRequired.." rounds required")
    ZE.Unlockables[char] = {
        char = char,
        games = gamesRequired,
        flag = char .. "pass"
    }
end

ZE.isCharacterUnlocked = function(player, char)
    local unlock = ZE.Unlockables[char]
    if not unlock then return true end
    return player[unlock.flag] == 1
end

ZE.UnlockCharacter = function(player, unlock)
    if player[unlock.flag] ~= 1 then
        chatprint(string.format("\x87\%s unlocked %s for playing %d games!", player.name, unlock.char, player.gamesPlayed))
        S_StartSound(player.mo, sfx_ideya)
        player[unlock.flag] = 1
    end
end

ZE.CheckCharacterAccess = function(player)
    for player in players.iterate do
        if player.mo and player.mo.valid then
            local unlock = ZE.Unlockables[player.mo.skin]
            if unlock and player[unlock.flag] == 0 then
                if IsPlayerAdmin(player) or player == server then return end
                R_SetPlayerSkin(player, ZE.survskinsplay[P_RandomRange(1, #ZE.survskinsplay)])
                chatprintf(player, "\x87\You need atleast " .. unlock.games .. " games played to use this character!", true)
            end
        end
    end
end

ZE.CheckUnlocks = function(player)
    for char, unlock in pairs(ZE.Unlockables) do
        if player.gamesPlayed >= unlock.games then
            ZE.UnlockCharacter(player, unlock)
        end
    end
end

ZE.InsertUnlocked = function(player)
    for char, unlock in pairs(ZE.Unlockables) do
        player[unlock.flag] = $ or 0
    end
    player.gamesPlayed = $ or 0
end
