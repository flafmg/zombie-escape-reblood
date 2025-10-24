local ZE = RV_ZESCAPE
local CV = ZE.Console

--zombie stats doesnt really need much info
--flexible
ZE.ZombieStats = {
	["ZM_NORMAL"] = {
		normalspeed = 20*FRACUNIT,
		jumpfactor = 22 * FRACUNIT / 19,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		startHealth = 200,
		maxHealth = 200,
	},
} -- [Theres a difference between this and ZE.AddZombie, never EVER add anything to ZombieStats.] --



ZE.AddZombie("Alpha", {
	skincolor = SKINCOLOR_ALPHAZOMBIE,
	normalspeed = 18*FRACUNIT,
	jumpfactor = 24 * FRACUNIT / 19,
	charability = CA_NONE,
	charability2 = CA2_NONE,
	startHealth = 500,
	maxHealth = 500,
	scale = 11*FRACUNIT/10,	
	schm = 40, --servercount health multiplier
	effect = "alpha",
},true)

ZE.AddZombie("Fast", {
	skincolor = SKINCOLOR_MOSS,
	normalspeed = 35*FRACUNIT,
	jumpfactor = 18 * FRACUNIT / 19,
	charability = CA_NONE,
	charability2 = CA2_NONE,
	startHealth = 50,
	maxHealth = 50,
	schm = 25,
	effect = "zoom",
},true)

ZE.AddZombie("Tank", {
	skincolor = SKINCOLOR_SEAFOAM,
	normalspeed = 5*FRACUNIT,
	jumpfactor = 18 * FRACUNIT / 19,
	charability = CA_NONE,
	charability2 = CA2_NONE,
	startHealth = 2500,
	maxHealth = 2500,
	scale = 20*FRACUNIT/10,
	schm = 150,
}, true)

ZE.AddZombie("Tiny", {
	skincolor = SKINCOLOR_CERULEAN,
	normalspeed = 60*FRACUNIT,
	jumpfactor = 18 * FRACUNIT / 19,
	charability = CA_NONE,
	charability2 = CA2_NONE,
	startHealth = 25,
	maxHealth = 25,
	scale = 6*FRACUNIT/10,
	schm = 10,
},true)

// Was gonna be luigi zombie.
ZE.AddZombie("Jisk", {
	skincolor = SKINCOLOR_FOREST,
	normalspeed = 65*FRACUNIT,
	jumpfactor = 18 * FRACUNIT / 19,
	charability = CA_NONE,
	charability2 = CA2_NONE,
	startHealth = 300,
	maxHealth = 400,
	schm = 10,
},true)


ZE.CharacterStats = {
	["defaultconfig"] = {
		normalspeed = 22 * FRACUNIT,
		runspeed = 100 * FRACUNIT,
		jumpfactor = 17 * FRACUNIT / 19,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		startHealth = 100,
		maxHealth = 100,
		staminacost = 15,
		staminarun = 16*FRACUNIT,
		staminanormal = 27*FRACUNIT,
    },
	["sonic"] = {
		normalspeed = 24 * FRACUNIT,
		runspeed = 100 * FRACUNIT,
		jumpfactor = 17 * FRACUNIT / 19,
		charability = CA_JUMPTHOK,
		charability2 = CA2_NONE,
		actionspd = 9 * FRACUNIT,
		startHealth = 115,
		maxHealth = 130,
		staminacost = 17,
		staminarun = 16*FRACUNIT,
		staminanormal = 29*FRACUNIT,
	},
	["tails"] = {
		normalspeed = 21 * FRACUNIT,
		runspeed = 100 * FRACUNIT,
		jumpfactor = 17 * FRACUNIT / 19,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		startHealth = 95,
		maxHealth = 125,
		staminacost = 15,
		staminarun = 16*FRACUNIT,
		staminanormal = 28*FRACUNIT,
    },
    ["knuckles"] = {
        normalspeed = 16 * FRACUNIT,
        runspeed = 100 * FRACUNIT,
        jumpfactor = 17 * FRACUNIT / 19,
        charability = CA_NONE,
        charability2 = CA2_NONE,
		startHealth = 150,
		maxHealth = 175,
		staminacost = 14,
		staminarun = 16*FRACUNIT,
		staminanormal = 24*FRACUNIT,
    },
    ["amy"] = {
        normalspeed = 24 * FRACUNIT,
        runspeed = 100 * FRACUNIT,
        jumpfactor = 17 * FRACUNIT / 19,
        charability = CA_TWINSPIN,
        charability2 = CA2_MELEE,
		startHealth = 100,
		maxHealth = 150,
		staminacost = 15,
		staminarun = 16*FRACUNIT,
		staminanormal = 28*FRACUNIT,
    },
	["fang"] = {
        normalspeed = 22 * FRACUNIT,
        runspeed = 100 * FRACUNIT,
        jumpfactor = 17 * FRACUNIT / 19,
        charability = CA_BOUNCE,
        charability2 = CA2_GUNSLINGER,
		startHealth = 110,
		maxHealth = 140,
		staminacost = 11,
		staminarun = 16*FRACUNIT,
		staminanormal = 27*FRACUNIT,
		actionspd = 7 * FRACUNIT,
    },
    ["metalsonic"] = {
        normalspeed = 20 * FRACUNIT,
        runspeed = 100 * FRACUNIT,
        jumpfactor = 17 * FRACUNIT / 19,
        charability = CA_NONE,
        charability2 = CA2_NONE,
		startHealth = 125,
		maxHealth = 145,
		staminacost = 13,
		staminarun = 5*FRACUNIT,
		staminanormal = 28*FRACUNIT,
    },
	["dzombie"] = {
	    normalspeed = ZE.ZombieStats["ZM_NORMAL"].normalspeed,
		runspeed = 100*FRACUNIT,
		jumpfactor = ZE.ZombieStats["ZM_NORMAL"].jumpfactor,
		charability = ZE.ZombieStats["ZM_NORMAL"].charability,
		charability2 = ZE.ZombieStats["ZM_NORMAL"].charability2,
		startHealth = ZE.ZombieStats["ZM_NORMAL"].startHealth,
		maxHealth = ZE.ZombieStats["ZM_NORMAL"].maxHealth,
		staminacost = 0,
		staminarun = 16*FRACUNIT,
		staminanormal = 25*FRACUNIT,
	},
	["bob"] = {
		normalspeed = 22 * FRACUNIT,
		runspeed = 100 * FRACUNIT,
		jumpfactor = 17 * FRACUNIT / 19,
		charability = CA_NONE,
		charability2 = CA2_GUNSLINGER,
		startHealth = 115,
		maxHealth = 115,
		staminacost = 11,
		staminarun = 16*FRACUNIT,
		staminanormal = 27*FRACUNIT,
	},
	["revenger"] = {
		normalspeed = 22*FRACUNIT,
		runspeed = 14 * FRACUNIT,
		jumpfactor = 17 * FRACUNIT / 19,
		charability = CA_NONE,
		charability2 = CA2_NONE,
		startHealth = 130,
		maxHealth = 130,
		staminacost = 8,
		staminarun = 16*FRACUNIT,
		staminanormal = 28*FRACUNIT,
	},
	["w"] = {
        normalspeed = 22 * FRACUNIT,
        runspeed = 100 * FRACUNIT,
        jumpfactor = 17 * FRACUNIT / 19,
        charability = CA_AIRDRILL,
        charability2 = CA2_NONE,
        startHealth = 120,
        maxHealth = 120,
        staminacost = 9,
        staminarun = 16*FRACUNIT,
        staminanormal = 26*FRACUNIT,
    }
}

