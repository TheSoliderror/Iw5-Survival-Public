//////////////////////////
//		Iw5 Survival	//
//Created By: Soliderror//
//  Do Not Edit And Use	//
// Unless Told Othewise //
//////////////////////////
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_class;
///////////////
// 	  MAP    //
//    ALL    //
///////////////
init()
{
	preCacheShader("hud_icon_weapons");
	preCacheShader("hud_icon_equipment");
	preCacheShader("hud_icon_support");
	preCacheString(&"SO_SURVIVAL_ARMORY_USE_WEAPON");
	preCacheString(&"SO_SURVIVAL_ARMORY_USE_EQUIPMENT");
	preCacheString(&"SO_SURVIVAL_ARMORY_USE_AIRSUPPORT");
	precachemodel( "com_laptop_close");
	precachemodel( "com_laptop_open");
	switch(getdvar("mapname"))
	{
		case "mp_dome":
			level thread spawnArmory((61, -368, -376), (0, 25, 0), "weapons" );
			level thread spawnArmory((-1481, 1091, -410), (0, -65, 0), "equipment" );	
			level thread spawnArmory((430, 2510, -240), (0, -95, 0), "support" );
		    break;
		case "mp_seatown":
			level thread spawnArmory((-460, 458, 182 ), (0, 90, 0), "weapons" ); 
			level thread spawnArmory((898, 232, 223), (0, 45, 0), "equipment" );
			level thread spawnArmory((65, -1504, 223), (0, 0, 0), "support" );
		    break;
		case "mp_bravo":
			level thread spawnArmory((-1471, -246, 975), (-10, -41, 0), "weapons" ); 
			level thread spawnArmory((51, -344, 970), (0, -1, 0), "equipment" );
			level thread spawnArmory((1331, 1180, 1236), (0, 0, 0), "support" );
		    break;
		case "mp_carbon":
			level thread spawnArmory((-1081, -4048, 3803),(0, 0, 0), "weapons" ); 	
			level thread spawnArmory((-3929, -3123, 3633),(0, 0, 0), "equipment" );	
			level thread spawnArmory((771, -3385, 3964),(0, -72, 0), "support" );
		    break;
		case "mp_interchange":
			level thread spawnArmory((1913, -1649, 95),(0, -40, 0), "weapons" ); 	
			level thread spawnArmory((899, 450, 76),(0, 0, 0), "equipment" );	
			level thread spawnArmory((-364, 541, 83),(0, 41, 0), "support" );
		    break;
		case "mp_paris":
			level thread spawnArmory((1544, 644, -1), (0, 90, 0), "weapons" ); 
			level thread spawnArmory((583, 1947, -15), (0, 93, 6), "equipment" );
			level thread spawnArmory((-790, 60, 72), (0, 0, 0), "support" );
		    break;
		case "mp_village":
			level thread spawnArmory((1256, 452, 301), (0, 111, 0), "weapons" ); 	
			level thread spawnArmory((36, 909, 278), (0, 130, 0), "equipment" );
			level thread spawnArmory((-243, -1459, 210), (0, 0, 0), "support" );
		    break;
		case "mp_nuked":
			level thread spawnArmory((1730, 759, -49), (0, 106, 0), "weapons" ); 
			level thread spawnArmory((-232, 1008, -49), (0, 23, 0), "equipment" );
			level thread spawnArmory((-1085, 479, -44), (0, 69, 0), "support" );
		    break;
	}
	
	//menu replace		
	replaceFunc(maps\mp\gametypes\_quickmessages::quickresponses, ::quickresponses); //weap menu
	replaceFunc(maps\mp\gametypes\_quickmessages::quickstatements, ::quickstatements);
	replaceFunc(maps\mp\gametypes\_quickmessages::quickcommands, ::quickcommands);

    level thread onPlayerConnect();
}

//response funcs
quickresponses(response){}
quickstatements(response){}
quickcommands(response){}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		if (!player maps\mp\bots\_bot_utility::is_bot())
		    //player thread onArmoryResponse();
			player thread onMenuResponse();
	}
}
onArmoryResponse()
{
    level endon("game_ended");
	self endon("disconnect");
    for(;;)
    {
        self waittill("menuresponse", menu, response);
		//printLn("*****************************************");
		//printLn("menu " + menu + "     response " + response);
		//printLn("*****************************************");
		switch (menu)
		{
		    case "quickresponses":
			    self thread weapon_armory(response);
			    break;
		    case "quickcommands":
			    self thread support_armory(response);
			    break;
		    case "quickstatements":
			    self thread equipment_armory(response);
			    break;
		}
	}
}
//amory spawning & main trigger create
spawnArmory(origin, angles, armoryName)
{
	armory = spawn( "script_model", origin );
	armory CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
	armory setModel("com_plasticcase_friendly");
	armory.angles = angles;
	//obj rotateTo(angles, .1);
	lap_angles = angles + (0, 90, 0);
	lap_orgigin = origin + (0, 0, 13);
	armory.laptop = spawn( "script_model", lap_orgigin );
	armory.laptop setModel("com_laptop_close");
	//armory.laptop setModel("com_laptop_open");
	//armory.laptop setModel("body_russian_military_assault_a_black"); //test for model ports
	armory.laptop.angles = lap_angles;

	waittillArmoryUnlock(armoryName);
	armory.laptop setModel("com_laptop_open"); //does not apper?

	armory setCursorHint( "HINT_NOICON" );
	if (armoryName == "weapons")
	    armory setHintString(&"SO_SURVIVAL_ARMORY_USE_WEAPON");
	    //Hold ^3[{+activate}]^7 to use Weapon Armory
	else if (armoryName == "equipment")
	    armory setHintString(&"SO_SURVIVAL_ARMORY_USE_EQUIPMENT");
	    //Hold ^3[{+activate}]^7 to use Equipment Armory
	else if (armoryName == "support")
	    armory setHintString(&"SO_SURVIVAL_ARMORY_USE_AIRSUPPORT");
	    //Hold ^3[{+activate}]^7 to use Air Support Armory
	armory makeUsable();
	//check the usable radius seems very big

	armory.worldIcon = createArmoryWorldIcon(armoryName, origin);
	//say(armoryName + " unlocked  replace with enabled hud");
	//thread armoryEnabledHud(armoryName);
	armory thread onUseArmory(armoryName);
}
createArmoryWorldIcon(armoryName, origin)
{
	shader = "";
	switch(armoryName)
	{
		case "weapons":
			shader = "hud_icon_weapons";
		    break;
		case "equipment":
			shader = "hud_icon_equipment";
		    break;
		case "support":
			shader = "hud_icon_support";
		    break;
	}
	worldIcon = newHudElem();
	worldIcon.x = origin[0];
	worldIcon.y = origin[1];
	worldIcon.z = origin[2];
	worldIcon.alpha = 1; //0.85
	worldIcon setShader( shader, 5,5 );
	worldIcon setWaypoint( true, true, false );
	thread destroyWorldIconOnEndGame(worldIcon);
	return worldIcon;

}
//text 1
//Weapon Armory Enabled!
//Equipment Armory Enabled!
//Air Support Enabled!
//text 2
//Purchase and upgrade weapons.
//Purchase Explosives, Sentries, Armor\n         and more...      
//Call in Predator missiles, Friendly\n          support and Perk air drops.
armoryEnabledHud(armoryName)
{
	icon = "";
	text1 = "";
	text2 = "";
	text3 = "";
	switch(armoryName)
	{
		case "weapons":
		    icon = "hud_icon_weapons";
			text1 = "Weapon Armory Enabled!";
			text2 = "Purchase and upgrade weapons.";
		    break;
		case "equipment":
		    icon = "hud_icon_weapons";
			text1 = "Equipment Armory Enabled!";
			text2 = "Purchase Explosives, Sentries, Armor";
			text3 = "and more...";
		    break;
		case "support":
		    icon = "hud_icon_support";
			text1 = "Air Support Enabled!";
			text2 = "Call in Predator missiles, Friendly";
			text3 = "support and Perk air drops.";
		    break;
	}//35    //27
	bgWhiteFade = createServerIcon("gradient", 300 ,10);
	bgWhiteFade setPoint("RIGHT", "RIGHT", 0, -110);//-200, -90 //something offscreen with right y
    bgWhiteFade.alpha = 0.2;

	bgBlackFade = createServerIcon("gradient", 300 ,20);
	bgBlackFade setPoint("RIGHT", "RIGHT", 0, -95);
	bgBlackFade.alpha = 0.2;
	bgWhiteFade addChild(bgBlackFade);
	
	armoryIcon = createServerIcon(icon, 24 ,24);
	armoryIcon setPoint("RIGHT", "RIGHT", 35, 180);
	bgWhiteFade addChild(armoryIcon);

	hudtext1 = createServerFontString("hudbig", 1);
	hudtext1 setPoint("RIGHT", "RIGHT", 0, 200);
	hudtext1 setText(text1);
	bgWhiteFade addChild(hudtext1);


	hudtext2 = createServerFontString("hudbig", 1);
	hudtext2 setPoint("RIGHT", "RIGHT", 0, 190);
	hudtext2 setText(text2);
	bgWhiteFade addChild(hudtext2);
	if (text3 != "")
	{
	    hudtext3 = createServerFontString("hudbig", 1);
	    hudtext3 setPoint("RIGHT", "RIGHT", 0, 190);
	    hudtext3 setText(text3);
		bgWhiteFade addChild(hudtext3);
	}
	//MOVE IN
	//bgWhiteFade moveOverTime(2);
	//bgWhiteFade.x = 200;//get onscreen pos
	wait 8;
	//MOVE OUT
	//bgWhiteFade moveOverTime(1);
	//bgWhiteFade.x = -150;//get offscreen pos
	wait 1;
	bgWhiteFade destroyElem();
	//hud_icon_weapons

}
waittillArmoryUnlock(armoryName)
{
	level endon("game_ended");
	for (;;)
	{
		level waittill("survival_intermission_start");
	    switch(armoryName)
	    {
		    case "weapons":
			    if (level.wave == 1) return;
		        break;
		    case "equipment":
			    if (level.wave == 2) return;
		        break;
		    case "support":
			    if (level.wave == 3) return;
		        break;
	    }
	}

}
destroyWorldIconOnEndGame(worldIcon)
{
	level waittill("game_ended");

	if (isDefined(worldIcon))
	    worldIcon destroy();
}
onUseArmory(armoryName)
{
	level endon("game_ended");
    for(;;)
	{
        self waittill( "trigger", player );
		if (player maps\mp\bots\_bot_utility::is_bot()) continue;//
		//printLn("onUseArmory(" + armoryName + ") " + player.name);
		//wait 0.2;//
		//continue;//
		if(armoryName == "weapons")
			player openpopupMenu("quickresponses");
		if(armoryName == "equipment")
			player openpopupMenu("quickstatements");
		if(armoryName == "support")
			player openpopupMenu("quickcommands");

	}
}
weapon_armory(response)
{
	if(response != "") //this is for all weapons, fast way.
	{
		self buy_weapon(response);
	}
	
	switch (response)
	{
	    case"ammo":
			cost = 750;
			if(self.score >= cost)
			{
				self givemaxAmmo(self getCurrentWeapon()); //scan wep list to give all ammo
				self take_points(cost);
			}
		break;
		case"acog":
			self add_attachment_p(response);
		break;	
		case"heartbeat":
			self add_attachment_p(response);
		break;	
		case"thermal":
			self add_attachment_p(response);
		break;
	}
}
support_armory(response)
{
	switch (response)
	{
	    case"missle_buy":
					self give_killstreak("predator_missile");
		break;
		case"speed_buy":
			self give_perk("specialty_quickdraw");
		break;	
		case"slight_buy":
			self give_perk("specialty_fastreload");
		break;			
		case"aim_buy":
			self give_perk("specialty_bulletaccuracy");
		break;				
		case"stalk_buy":
			self give_perk("specialty_stalker");
		break;				
		case"xtream_buy":
			self give_perk("specialty_longersprint");
		break;
	}
}
equipment_armory(response)
{
	switch (response)
	{
		case"frag_buy":
			cost = 50;
			if(self.score >= cost)
			{
				self giveWeapon("frag_grenade_mp", 1);
				self take_points(cost);
			}
		break;
					
		case"vest_buy":
			cost = 2000;
			if(self.score >= cost)
			{
				self thread maps\mp\perks\_perkfunctions::givelightarmor();
				self take_points(cost);
			}
		break;
	    case"riot_buy":
			cost = 50;
			if(self.score >= cost)
			{
				self buy_weapon("riotshield_mp");
				self take_points(cost);
			}
		break;
			
		//From here down in the cases things need to be added to the gsc to work
		case"flash_buy": 
			cost = 50;
			if(self.score >= cost)
			{
				self giveWeapon("flash_grenade_mp", 1);
				self take_points(cost);
			}
		break;
					
		case"claymore_buy":
			cost = 50;
			if(self.score >= cost)
			{
				self giveWeapon("claymore_mp", 1);
				self take_points(cost);
			}
		break;
					
		case"revive_buy":
		//prob use force spawn along with a func for this.
			cost = 0;
			if(self.score >= cost)
			{
			self take_points(cost);
			}
	}
}


//menu gsc (solid error, works for now)
onMenuResponse()
{
    level endon("game_ended");
    for(;;)
    {
        self waittill("menuresponse", menu, response);

			switch(response)
			{
			//weap arm only
				case"ammo": //some things will not be added to this and MUST use an if statmnt.
					cost = 750;
					if(self.score >= cost)
					{
					self givemaxAmmo(self getCurrentWeapon());
					self take_points(cost);
					}
				break;
					
				case"acog":
					self add_attachment_p(response);
				break;
					
				case"heartbeat":
					self add_attachment_p(response);
				break;
					
				case"thermal":
					self add_attachment_p(response);
				break;
					
				//air support arm
				case"missle_buy":
					self give_killstreak("predator_missile");
				break;
					
				case"heli_buy":
					self give_killstreak("helicopter");
				break;
					
				case"nuke_buy":
					self give_killstreak("nuke"); //removed
				break;
					
				case"riot_buy":
					cost = 3000;
					if(self.score >= cost)
					{
						self buy_weapon("riotshield_mp");
						self take_points(cost);
					}
				break;
					
				case"frag_buy":
					cost = 750;
					if(self.score >= cost)
					{
						self giveWeapon("frag_grenade_mp", 1);
						self take_points(cost);
					}
				break;
					
				case"vest_buy":
					cost = 2000;
					if(self.score >= cost)
					{
						self thread maps\mp\perks\_perkfunctions::givelightarmor();
						self scripts\_survival_round_util::vest_hud();
						self take_points(cost);
					}
				break;
					
				case"sentry_buy":
					self give_killstreak("sentry");
				break;
					
				case"speed_buy":
					self give_perk("specialty_quickdraw");
				break;
					
				case"slight_buy":
					self give_perk("specialty_fastreload");
				break;
					
				case"aim_buy":
					self give_perk("specialty_bulletaccuracy");
				break;
					
				case"stalk_buy":
					self give_perk("specialty_stalker");
				break;
					
				case"xtream_buy":
					self give_perk("specialty_longersprint");
				break;
					
				//From here down in the cases things need to be added to the gsc to work
				case"flash_buy": 
					cost = 1000;
					if(self.score >= cost)
					{
						//self.grenadeweapon = "fraggrenade"; //change this to flash
						self setoffhandsecondaryclass( "flash" ); //use this ig
						self giveWeapon("flash_grenade_mp", 1); //was flash_grenade_mp
						self take_points(cost);
					}
				break;
					
				case"claymore_buy":
					cost = 1000;
					if(self.score >= cost)
					{
						self giveWeapon("claymore_mp", 1);
						self take_points(cost);
					}
				break;
					
				case"revive_buy":
				//prob use force spawn along with a func for this.
					cost = 0; //4000
					if(self.score >= cost)
					{
						self take_points(cost);
					}
				break;
					
				case"": //use this for C4 (c4_mp)
					
				break;
					
				case"":
					
				break;
					
				case"":
					
				break;
					
				case"":
					
				break;
			}
			
			//weapons, this cannot go into the switch until EVERYTHING else has been added(will be defualt case)
			if(response != "")
			{
				self buy_weapon(response);
			}
    }
}

give_perk(perk)
{
	cost = 0;
	
	if(self maps\mp\_utility::_hasperk(perk))
	{
		return;
	}

	switch(perk)
	{
		case "specialty_quickdraw":
			cost = 3000;
		break;
		
		case "specialty_fastreload":
			cost = 5000;
		break;
		
		case "specialty_bulletaccuracy": //steadyaim, idk if this is the right perk
			cost = 3000;
		break;
		
		case "specialty_stalker":
			cost = 4000;
		break;
		
		case "specialty_longersprint":
			cost = 4000;
		break;
		
	}
	
	if(self.score <= cost)
	{
			//play no money sound
		return;
	}
		
		//self self.pers["gamemodeLoadout"]["killstreak1"] = streak;
		//self GivePerk(perk, 0);
		self scripts\_survival_round_util::surv_givePerk(perk);
		self take_points(cost);
		//self scripts\_survival_round_util::perk_hud(perk);
	
}

give_killstreak(streak)
{
	//if(self.pers["gamemodeLoadout"]["killstreak4"] != "none") //this needs to have a clear killstreak spot 
	//{
		//play no money sound/deny
	//	return;
	//}
	
	cost = 0;
	
	switch(streak)
	{
		case "predator_missile":
			cost = 2500;
			self switch_streak_type("assault");
		break;
		
		case "helicopter": //not in sur
			cost = 500;
			self switch_streak_type("assault");
		break;
		
		case "sentry":
			cost = 3000;
			self switch_streak_type("assault");
		break;
		
		case "nuke": //removed
			cost = 500;
			self switch_streak_type("assault");
		break;
	}
		
	if(self.score <= cost)
	{
		//play no money sound
		return;
	}
		
		//self self.pers["gamemodeLoadout"]["killstreak1"] = streak;
		self maps\mp\killstreaks\_killstreaks::givekillstreak(streak);
		self take_points(cost);
	
}

switch_streak_type(type)
{
	switch(type)
	{
		case "assault":
			self.pers["gamemodeLoadout"]["loadoutStreakType"] = "streaktype_assault";
		break;
		
		case "support":
			self.pers["gamemodeLoadout"]["loadoutStreakType"] = "streaktype_support";
		break;
	}
}

buy_weapon(response)
{
	cost = 0;
	type = "";
	
	switch(response)
	{
		//secondarys
		case "iw5_deserteagle_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_44magnum_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_fnfiveseven_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_mp412_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_p99_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_usp45_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_m9_mp":
		cost = 250;
		type = "secondary";
		break;
		
		//machine handguns
		case "iw5_g18_mp":
		cost = 1500;
		type = "secondary";
		break;
		case "iw5_fmg9_mp":
		cost = 1500;
		type = "secondary";
		break;
		case "iw5_skorpion_mp":
		cost = 1500;
		type = "secondary";
		break;
		case "iw5_mp9_mp":
		cost = 1500;
		type = "secondary";
		break;
		
		//misc
		case "riotshield_mp":
		cost = 5000;
		type = "secondary";
		break;
		
		//primarys
		//AR's
		case "iw5_m4_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_m16_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_acr_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_ak47_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_scar_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_g36c_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_type95_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_mk14_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_fad_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_cm901_mp":
		cost = 3000;
		type = "primary";
		break;
		
		//SMG's
		case "iw5_mp5_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_mp7_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_p90_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_pp90m1_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_ump45_mp":
		cost = 2000;
		type = "primary";
		break;
		
		//LMG's
		case "iw5_sa80_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_m240_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_m60_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_mg36_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_mk46_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_pecheneg_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_m60jugg_mp_camo08":
		cost = 7000;
		type = "primary";
		break;
		
		//Snipers
		case "iw5_as50_mp_as50scope":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_barrett_mp_barrettscope":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_dragunov_mp_dragunovscope":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_l96a1_mp_l96a1scope":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_msr_mp_msrscope":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_rsass_mp_rsassscope":
		cost = 2000;
		type = "primary";
		break;
		
		//shotguns: holly shit you added them
		case "iw5_1887_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_usas12_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_spas12_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_ksg_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_striker_mp":
		cost = 4000;
		type = "primary";
		break;
		case "iw5_aa12_mp":
		cost = 5000;
		type = "primary";
		break;	
		
	}
	
	
	if(type == "secondary") //secondary type
	{
		if(self.score >= cost)
		{
			if(self GetWeaponsListPrimaries()[0] == "none") //this needs testing(buy without weapon type)
			{
				self ReplaceWeapon_s(response);
				self take_points(cost);
			}
			else if(self GetWeaponsListPrimaries()[0] == response) //no buy twice
			{
				//playe sound
				return;
			}
			else{
			self ReplaceWeapon_s(response);
			self take_points(cost);
			}
		}
		else
		{
			self take_points(cost);
			//add sound
		}
	}
	
	//primary type
	if(type == "primary")
	{
		if(self.score >= cost)
		{
			if(self GetWeaponsListPrimaries()[1] == "none") //this needs testing(buy without weapon type)
			{
				self ReplaceWeapon_p(response);
				self take_points(cost);
			}
			else if(self GetWeaponsListPrimaries()[1] == response) //no buy twice
			{
				//play sound
				return;
			}
			else{
				self ReplaceWeapon_p(response);
				self take_points(cost);
			}
		}
		else
		{
			self take_points(cost);
			//add sound
		}
	}
	
}

get_weap_type(weapon)
{
	type = "";
	cost = "";
	switch(weapon)
	{
		//secondarys
		case "iw5_deserteagle_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_44magnum_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_fnfiveseven_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_mp412_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_p99_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_usp45_mp":
		cost = 250;
		type = "secondary";
		break;
		case "iw5_m9_mp":
		cost = 250;
		type = "secondary";
		break;
		
		//machine handguns
		case "iw5_g18_mp":
		cost = 1500;
		type = "secondary";
		break;
		case "iw5_fmg9_mp":
		cost = 1500;
		type = "secondary";
		break;
		case "iw5_skorpion_mp":
		cost = 1500;
		type = "secondary";
		break;
		case "iw5_mp9_mp":
		cost = 1500;
		type = "secondary";
		break;
		
		//misc
		case "riotshield_mp":
		cost = 50;
		type = "secondary";
		break;
		
		//primarys
		//AR's
		case "iw5_m4_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_m16_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_acr_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_ak47_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_scar_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_g36c_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_type95_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_mk14_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_fad_mp":
		cost = 3000;
		type = "primary";
		break;
		case "iw5_cm901_mp":
		cost = 3000;
		type = "primary";
		break;
		
		//SMG's
		case "iw5_mp5_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_mp7_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_p90_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_pp90m1_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_ump45_mp":
		cost = 2000;
		type = "primary";
		break;
		
		//LMG's
		case "iw5_sa80_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_m240_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_m60_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_mg36_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_mk46_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_pecheneg_mp":
		cost = 7000;
		type = "primary";
		break;
		case "iw5_m60jugg_mp_camo08":
		cost = 7000;
		type = "primary";
		break;
		
		//Snipers
		case "iw5_as50_mp_as50scope":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_barrett_mp_barrettscope":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_dragunov_mp_dragunovscope":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_l96a1_mp_l96a1scope":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_msr_mp_msrscope":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_rsass_mp_rsassscope":
		cost = 2000;
		type = "primary";
		break;
		
		//shotguns: holly shit you added them
		case "iw5_1887_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_usas12_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_spas12_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_ksg_mp":
		cost = 2000;
		type = "primary";
		break;
		case "iw5_striker_mp":
		cost = 4000;
		type = "primary";
		break;
		case "iw5_aa12_mp":
		cost = 5000;
		type = "primary";
		break;	
	}
	
	return type;
}

take_points(cost)
{
	if(self.score >= cost)
	{
		points = self.score; 
		new_points = points - cost;
		self.score = new_points;
		self.pers["score"] = new_points;
	}
	else
	{
		self iprintln("You do not have the points");
		//add sound here for no money
		return;
	}
}

give_points(cost)
{
		points = self.score; 
		new_points = points + cost;
		self.score = new_points;
}

//attachment
add_attachment_p(response)
{
	cost = 0;
	attachment = "";
	weapon = self GetWeaponsListPrimaries()[1]; //get weapon type with get_weap_type("weapon");
	type = get_weap_type(weapon); //gets type of weapon
	
	switch(response)
	{
		//survial attachments
		//all primary weap
		case "acog":
			attachment = "acog";
			cost = 1250;
			type_needed = "primary";
			weap_needed = "all_p"; //this is just a holder
		break;
		//red dot 750
		//holo 1000
		
		//launchers (weap spic) 1250
			//m203 - m16, m4
			//gp-25 - ak
			//m320 - acr, cm901,fad,g36c, mk14, scar, type 95
		
		//shotgun under 1500
			//all ARs
		
		
		
		
		case "heartbeat": //not in survival
			attachment = "heartbeat";
			cost = 100; 
		break;
		case "thermal":
			attachment = "thermal"; //not in survival
			cost = 100;
		break;
		//add attachments here
		
	}
	
		if(get_attachments(weapon,"") && self.score >= cost) //has attachment already
		{
			self get_attachments(weapon, "_" + attachment);
			self take_points(cost);
		}
		else if(!get_attachments(weapon,"") && self.score >= cost) //gives first attachment
		//if(self.score >= cost)//this is just 1 attachment for now, but works for 1
		{
			self ReplaceWeapon_p_a(weapon,attachment);
			//BaseWeapon = GetBaseWeaponName(weapon);
			//self ReplaceWeapon_p_a(BaseWeapon,new_attachments);
			self take_points(cost);
		}
		else
		{
			//add sound here
			return;
		}
	
}

//weapon taking (needs to be tested)

ReplaceWeapon_p(new_weapon)
{
    self TakeWeapon(self GetWeaponsListPrimaries()[1]); // take primary weapon, replace with 0 for secondary weapon
    self GiveWeapon(new_weapon);
    self SwitchToWeapon(self GetWeaponsListPrimaries()[1]);
	self givemaxAmmo(self GetWeaponsListPrimaries()[1]);
}

ReplaceWeapon_p_a(new_weapon,attachment)
{
	//add ammo fix
	
    self TakeWeapon(self GetWeaponsListPrimaries()[1]); // take primary weapon, replace with 0 for secondary weapon
    self GiveWeapon(new_weapon + FixReversedAttachments(new_weapon,attachment));
	printLn("New Weapon Name is: " + new_weapon + FixReversedAttachments(new_weapon,attachment));
    self SwitchToWeapon(self GetWeaponsListPrimaries()[1]);
}

ReplaceWeapon_s(new_weapon)
{

    self TakeWeapon(self GetWeaponsListPrimaries()[0]); // take primary weapon, replace with 0 for secondary weapon
    self GiveWeapon(new_weapon);
    self SwitchToWeapon(self GetWeaponsListPrimaries()[0]);
	self givemaxAmmo(self GetWeaponsListPrimaries()[0]);
}

//sound stuff

playSoundOnPlayer( soundAlias, player )
{
	if( !isDefined(player) && isPlayer( self ) )
		player = self;
	
	audioPlayer = spawn( "script_origin", player.origin );
	audioPlayer playSound( soundAlias );
	audioPlayer thread follow( player );
	audioPlayer thread deleteAfterTime( 60 );
}

deleteAfterTime( time )
{
	wait time;
	if( isDefined( self ) )
		self delete();
}

follow( who )
{
	self endon("stopfollowing");
	while(isDefined(self))
	{
		self.origin = who.origin;
		wait .05;
	}
}

//other attachment functions
get_attachments(weapon,attachment2)
{
	attachmentsArray = StrTok(weapon, "_");
	attachment = "";

    if (attachmentsArray.size < 2)
    {
        attachment = attachmentsArray[3];//gets the name of attachment alreay had?
		return true;
    }

	if(!attachment2 == "")
	{
		new_attachments = attachment + attachment2;
		//get ammo here		
		base_weapon = GetBaseWeaponName(weapon);
		self ReplaceWeapon_p_a(base_weapon,new_attachments);
	}
	

}

GetBaseWeaponName(weaponName)
{
    weaponCode = StrTok(weaponName, "_");

    if (weaponCode.size < 3)
    {
        return weaponName;
    }
	
	return weaponCode[0] + "_" + weaponCode[1] + "_" + weaponCode[2]; // Example: iw5_msr_mp
}

//fix ghetto attachment logic (rexit made this)
FixReversedAttachments(weaponName, attachments)
{
    reverse = false;
    attachmentsArray = StrTok(attachments, "_");

    if (attachmentsArray.size < 2)
    {
        return attachments;
    }

    if (GetWeaponClass(weaponName) == "weapon_assault")
    {
        if (attachmentsArray[1] == "heartbeat" && attachmentsArray[0] != "eotech" && attachmentsArray[0] != "acog" && attachmentsArray[0] != "thermal")
        {
            reverse = true;
        }
        else if (attachmentsArray[0] == "thermal" && attachmentsArray[1] != "xmags")
        {
            reverse = true;
        }
        else if (attachmentsArray[0] == "hybrid" && attachmentsArray[1] != "xmags" && attachmentsArray[1] != "silencer")
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_smg")
    {
        if (attachmentsArray[0] == "thermalsmg" && attachmentsArray[1] != "xmags")
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_lmg")
    {
        if (attachmentsArray[1] == "grip" && attachmentsArray[0] != "acog" && attachmentsArray[0] != "eotechlmg")
        {
            reverse = true;
        }
        else if (attachmentsArray[1] == "heartbeat" && attachmentsArray[0] != "eotechlmg" && attachmentsArray[0] != "acog")
        {
            reverse = true;
        }
        else if (attachmentsArray[0] == "thermal" && attachmentsArray[1] != "xmags")
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_sniper")
    {
        if (attachmentsArray[1] == "heartbeat" && (attachmentsArray[0] == "rsassscope" || attachmentsArray[0] == "l96a1scope" || attachmentsArray[0] == "msrscope"))
        {
            reverse = true;
        }
        else if (attachmentsArray[0] == "thermal" && (attachmentsArray[1] != "xmags" || attachmentsArray[1] == "silencer03"))
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_shotgun")
    {
        if (attachmentsArray[1] == "grip" && attachmentsArray[0] != "eotech")
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_machine_pistol")
    {
        if (attachmentsArray[1] == "akimbo")
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_pistol")
    {
        if (attachmentsArray[0] == "tactical" && attachmentsArray[1] == "silencer02")
        {
            reverse = true;
        }
    }

    if (reverse)
    {
        return "_" + attachmentsArray[1] + "_" + attachmentsArray[0];
    }
    else
    {
        return attachments;
    }
}