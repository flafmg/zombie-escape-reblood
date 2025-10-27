local ZE = RV_ZESCAPE
local CV = RV_ZESCAPE.Console


hud.add(function(v, player, camera)
	if gametype == GT_ZESCAPE
		if ZE.teamWin != 0 and player.ctfteam != 0 and CV.savedendtic != 0
		    local time = TICRATE*2
			local ese = ease.inoutquad(( (FU) / (time) )*(CV.timeafterwin), 0, 16)
			local ese2 = ease.inoutquad(( (FU) / (time) )*(CV.timeafterwin), -50, 50)
			
			local function DoAnim(teamwin)
				local patches = {"ZOMBWIN", "SURVWIN"}
				if CV.timeafterwin < time then
					v.fadeScreen(0xFF00, ese)
					v.draw(160,ese2,v.cachePatch(patches[teamwin]), V_PERPLAYER|V_SNAPTOBOTTOM)
				else
					v.fadeScreen(0xFF00, 16)
					v.draw(160,50,v.cachePatch(patches[teamwin]), V_PERPLAYER|V_SNAPTOBOTTOM)
				end
				if CV.showendscore.value == 1
					if CV.timeafterwin == TICRATE*2 then
						S_StartSound(nil,sfx_dmst,player)
					end
					if CV.timeafterwin > TICRATE*2 then
						local score = player.score
						v.drawString(160,130, "Score: " + score , V_PERPLAYER, "center") --127+yo
					end
				end
				if CV.winWait < 10*TICRATE then
					v.drawString(160,140, "Intermission in: " + CV.winWait/TICRATE , V_PERPLAYER|V_REDMAP|V_50TRANS, "center") --127+yo
				end
			end
		
			if player.ctfteam == ZE.teamWin
				if ZE.teamWin == 1
					DoAnim(1)
				else
					DoAnim(1)
				end
			else
				if ZE.teamWin == 2
					DoAnim(2)
				else
					DoAnim(2)
				end
			end
		end
		
		
		if ZE.alpha_attack == 1 and ZE.alpha_attack_show < 15*FRACUNIT and ZE.alpha_attack_doneshow == false then
			v.draw(160,50,v.cachePatch("ALPHATT"), V_PERPLAYER|V_SNAPTOBOTTOM|V_50TRANS)
		end
		
		if ZE.secretshowtime then
			v.draw(160,50,v.cachePatch("SECRETZE"), V_PERPLAYER|V_SNAPTOBOTTOM|V_50TRANS)
		end
	end
end, "game")

hud.add(function(v, player)
	if (gametype ~= GT_ZESCAPE) return end
end)
