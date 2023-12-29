//////////////////////////
//		Iw5 Survival	//
//Created By: Soliderror//
//  Do Not Edit And Use	//
// Unless Told Othewise //
//////////////////////////
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\bots\_bot_utility;
#include maps\mp\gametypes\_class;
/* 
TODO:  
Rename script _survival_round_logic

Create new script for player stuff

Notes:
Create or port challanges(not prioirity)

First spawn class is kinda broke in private match, still has perks.

*/

main()
{	
	setDvar("scr_game_playerwaittime", 0);
	setDvar("scr_game_graceperiod", 0);
	setDvar("scr_game_allowkillcam", 0);
	setDvar("bots_main_kickBotsAtEnd",true);
	setdvar("ui_show_perks", 0);
	setDvar( "g_gametype", "survival" );
	level._effect["c4_explosion"] = loadfx( "explosions/grenadeExp_metal" );
	precacherumble( "grenade_rumble" );
}

init()
{
	//jugg caches
	precachemodel( "mp_fullbody_ally_juggernaut" );
    precachemodel( "viewhands_juggernaut_ally" );
    precachemodel( "mp_fullbody_opforce_juggernaut");
    precachemodel( "viewhands_juggernaut_opforce");
	
	preCacheShader("hud_weaponbar_line");
	preCacheShader("hud_icon_self_revive");
	preCacheShader("specialty_bulletaccuracy");
	preCacheShader("specialty_fastreload");
	preCacheShader("specialty_steadyaim");
	preCacheShader("specialty_stalker");
	preCacheShader("specialty_quickdraw");
	
	level.callbackPlayerDamageStub  = level.callbackPlayerDamage;
    level.callbackPlayerDamage      = ::callbackPlayerDamageHook;
	level.tjugg_loadouts["allies"]["loadoutJuggernaut"] = 0;
	level.fix_carry_over = 0; //this is needed for carry over fix
	SetDvar("ui_allow_classchange", 0);
	SetDvar("ui_allow_teamchange", 0);
	
	level.tbk = 0; //total bots killed
	level.bot_watch = 0; //bots killed in a round
	level.kill_val = 8; //default to start
	level.b_t = 0; //was used in a old round concept, unused now

	//main bot watching and spawning
	level.botsLeftToSpawn = 0;
	level.currentBotCount = 0;
	//heli spawning
	level.currentHeliCount = 0;//used for heli monitoring since they are not bots //to end round when they all dead along with bot dead check
	level.heliLeftToSpawn = 0;
	//bomber spawing
	level.currentBomberBotsCout = 0;
	level.suicideBomberBotsLeftToSpawn = 0;
	//other ai type spawing
	//light
	level.currentLightTroopsBotsCount = 0;
	level.lightTroopsBotsLeftToSpawn = 0;
	//medium
	level.currentMediumTroopsBotsCount = 0;
	level.mediumTroopsBotsLeftToSpawn = 0;
	//heavy
	level.currentHeavyTroopsBotsCount = 0;
	level.heavyTroopsBotsLeftToSpawn = 0;
	//commando
	level.currentCommandoTroopsBotsCount = 0;
	level.commandoTroopsBotsLeftToSpawn = 0;
	//heavy commando
	level.currentHeavyCommandoTroopsBotsCount = 0;
	level.heavyCommandoTroopsBotsLeftToSpawn = 0;
	//add claymore and chem troops when code is added
	//Juggernauts
	level.juggBotsLeftToSpawn = 0;
	level.currentJuggBotsCount =0;
	//Riot Juggernauts
	level.juggRiotBotsLeftToSpawn = 0;
	level.currentJuggRiotBotsCount =0;

	level.wave = 1; //sets round to 0 at first so 1st round can start. 
	level.wave_plus = 0; //this is for tracking waves after 40
	level.inter_time = 30; //intermisson time over all (make a dvar later)
	level.dead_players = 0;
    level.current_real_players = 0;

	level.waveStarted = false;
	level.intermissionStarted = false;

	setDvar("bots_main_kickBotsAtEnd",true);
	setDvar("bots_manage_fill_spec",0); //no extra bots can spawn at all that arnt suppose to
	setDvar("scr_war_timelimit",0); //unlim time
	setDvar("scr_war_scorelimit",0); //no score lim
	setDvar("sv_cheats", 1); //dev
	setdvar("g_teamicon_axis", "iw5_cardicon_russian_black");
    setdvar("g_teamicon_allies", "iw5_cardicon_delta_multi");
	setdvar("g_TeamName_Allies", "^2survivors " );
    setdvar("g_TeamName_Axis", "^1Invaders" );

	level thread updateRealPlayerCount();
	level thread updateRealPlayerAliveCount();

	level thread onPlayerConnect();

	level thread loop_startRound();
	level thread loop_startIntermission();


	level thread fix_carry_over();//swifty:  do we need this could just kick all bot before we end the game
	//thread test_hud_swity_forrounds();
	//shouldnt have any extra bots???
}
loop_startRound()
{
	level endon("game_ended");//prob change to custom end end game notify

	while (!level.current_real_players)
	    wait 0.5;

	wait 2;//give connecting players chance to spawn

	allClientsPrint("FIRST INTERMISSION");
	level.intermissionStarted = true;
	intermission_hud();
	level.fix_carry_over = 1;
	level.intermissionStarted = false;
	level notify("survival_round_start");//first round
	level.waveStarted = true;
	thread survival_msg_hud("hostiles_inbound");
	//spawnBotsWrapper(getBotsForWave(), getSuicideBombersForWave(), getJuggsForWave());//
	//bots for wave is total bots   includes all bots types
	//special bots types will spawn first to decrent special bot types
	
	//spawnBotsWrapper(8, 8, 0, 0, 0, 0, 0, 0); //light troops only
	bot_type_handler();
	
	allClientsPrint("WAVE 1 STARTED!");
	thread waittillAllBotsDead();//called when each round starts
	thread watchPlayers();//ends game if all players die or left game //called when first round starts and runs till end game
	//allClientsPrint("ALL FUNCS RAN OVER");

	for (;;)
	{
		level waittill("survival_round_start");//will trigger for second round onwards
		level.waveStarted = true;
		printLn("survival_round_start " + level.wave);
		thread survival_msg_hud("hostiles_inbound");
		//hostiles inbound hud//
		//
		//check what wave type we have //normal bot wave//heli wave//jugg wave//mixed wave//
		//prob dont need to do this if i have shit set up right ^^^^^
		//figure out somthing to increase bots same as stock survival
		//or just add list of how many bots per round somewhere
		//spawnBotsWrapper(getBotsForWave(), getSuicideBombersForWave(), getJuggsForWave());//
		
		//spawnBotsWrapper((level.botsForWave + 8), 0, 0);
		bot_type_handler();
		
		level.heliLeftToSpawn = 0;//getHelisForRound();//map and round specific
		//spawnHelis();
		thread waittillAllBotsDead();

	}
}
loop_startIntermission()
{
	for(;;) 
	{
		level waittill("survival_intermission_start");
		level.waveStarted = false;
		level.intermissionStarted = true;
		printLn("survival_intermission_start all bots/helis dead starting intermission");
		thread survival_msg_hud("wave_cleared");
		//combot performance hid wait 2 thread //add to player connect func wait wave start
		//update intermission hud to be like survival with skip option
		//if we dont thread code should carry on once intermission_hud is done so no wait needed
		intermission_hud();
		level notify("survival_intermission_end");
		level.intermissionStarted = false;
		level.wave++;
		level notify("survival_round_start");
	}
}
//watches for when all players leave and restarts map 
// or if current_real_players is greater than 0 and deadplayers == real players
watchPlayers()//called when first round starts
{
	for (;;)
	{
		wait 0.1;
		if (!level.current_real_players)//all players left during round
		{
			//printLn("watchPlayers() all players left");

			level notify("survival_game_end");
			//end game //just restart game
			map_restart(false);
			return;
		}
		if (level.current_real_players > 0 && level.dead_players == level.current_real_players)//all players died
		{
			//printLn("watchPlayers() all players died");
			level notify("survival_game_end");
			//score summary hud
			//end game
			level maps\mp\gametypes\_gamelogic::endgame("axis");
			
			
			return;
		}
	}
}

waittillAllBotsDead()
{
	allClientsPrint("waittillAllBotsDead Ran");
	
	for (;;)
	{
		wait 0.1;
		if (!level.currentBotCount && !level.botsLeftToSpawn && !level.currentHeliCount && !level.heliLeftToSpawn)
		{
			level notify("survival_round_end");

	        level notify("survival_intermission_start");
			allClientsPrint("NEXT WAVE NOTIFY RAN");
			return;
		}
	}
}
//test botslefttospawn botcount 
test_hud_swity_forrounds()
{
	self.dev_hud = [];
	hud = createServerFontString( "objective", 1.2 );
	hud setPoint( "LEFT", "LEFT", 0, -100 );//-100  
	hud.string = "currentBotCount: " + level.currentBotCount + "\nbotsLeftToSpawn: " + level.botsLeftToSpawn + "\ncurrentHeliCount: "+ level.currentHeliCount + "\nheliLeftToSpawn: " + level.heliLeftToSpawn;
	hud setText(hud.string);
	hud = self.dev_hud["1"];

    hud2 = createServerFontString( "objective", 1.2 );
    hud2 setPoint( "TOPRIGHT", "TOPRIGHT", 0, -130 );//-30
	hud2.label = &"Connected Players: ";
    hud2 setValue(level.current_real_players);
	hud2 = self.dev_hud["2"];

    hud3 = createServerFontString( "objective", 1.2 );
    hud3 setPoint( "TOPRIGHT", "TOPRIGHT", 0, -15 );//-15
	hud3.label = &"Dead Players: ";
    hud3 setValue(level.dead_players);
	hud3 = self.dev_hud["3"];

	for (;;)
	{
		wait 0.1;
		newstring = "currentBotCount: " + level.currentBotCount + "\nbotsLeftToSpawn: " + level.botsLeftToSpawn + "\ncurrentHeliCount: "+ level.currentHeliCount + "\nheliLeftToSpawn: " + level.heliLeftToSpawn;
		if (newstring != hud.string)
		{
			hud.string = newstring;
			hud setText(newstring);
		}
		hud2 setValue(level.current_real_players);
		hud3 setValue(level.dead_players);

	}
}
onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		
		if ( player is_bot() )
		{
			//add bot funcs here if needed (can use this to scan rounds and apply juggs)
		}
		else//player funcs
		{
			//add stock survival spawn from sky
			//black out screen
			//once spawned tp them to sky above proper spawn do the anim spawn from sky << in onPlayerSpawn
			//then remove fade out the black screen
			player thread onPlayerSpawn();
		}
		wait 0.5;
	}
}

//makes you spawn with five seven, and gives last stand as well as skipping the choose class menu and choose team menu.
onPlayerSpawn() //Credit to ZECxR3ap3r for edits
{
    //set wep
	//here is executed on connect
    spawnweapon = "iw5_usp45_mp";//iw5_usp45_mp
    class_name = "class0";
    self.pers["team"] = "allies";
	self.team = "allies";
	self [[level.allies]]();
	self [[level.class]]("class0");	//allies_recipe1 this is the class to use on the server set in the dsr
	//self notify( "menuresponse", "team_marinesopfor", "allies" );
	//self notify("menuresponse", "changeclass",  "class0" ); //allies_recipe1
    self.initial_spawn = 0;
	self thread playerWaittillDeath();
	self thread playerWaittillKilledBot();
	///////////
    while(1)
	{
        self waittill("spawned_player");
        if(self.initial_spawn == 0)
		{
            self.initial_spawn = 1;
            // Reaper : Everything that needs to be loaded only once
            self thread wave_hud();
            self thread score_hud();
			//self thread survival_hud(); //disabled for now until shader is rotated and in place
			self iprintlnbold( "IW5 SURVIVAL BY SOLIDERROR" );
			new_points = 500;
			self.score = new_points;
			self.pers["score"] = new_points;
        }
        // Reaper : everything after here loads everytime the player spawns
        wait 1; //who tf added this
		//give grenades and flash bangs
		self giveLoadoutForMap();
    }
}

playerWaittillDeath()
{
	self endon("disconnect");
	for (;;)
	{
		self waittill("death");
			self notify( "menuresponse", "team_marinesopfor", "spectator" );
			level waittill("survival_intermission_start");
			self notify( "menuresponse", "team_marinesopfor", "allies" );
			self notify("menuresponse", "changeclass",  "class0" );
	}
}
playerWaittillKilledBot()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("killed_enemy");//killed_enemy //killed_player
		self.pers["cur_kill_streak_for_nuke"] = 0;//dont want player to have a moab
	}
}
fix_carry_over()
{
	if(level.fix_carry_over == 0)
	{
		while(1)
		{
			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];
				if ( player is_bot() )
				{
					bot = player getEntityNumber();
					kick( bot );
					level.currentBotCount--;
				}
				if(level.fix_carry_over == 1)
				{
					return;
				}
			}
			wait 0.05;
		}
	}
}

updateRealPlayerCount()
{
    while(1)
    {
        wait 0.05;
        if(level.players.size == 0)
            continue;

        playerCount = 0;
        for (i = 0; i < level.players.size; i++)
            if (!level.players[i] is_bot())
                playerCount++;

        level.current_real_players = playerCount;
    }
}
updateRealPlayerAliveCount()
{
    while(1)
    {
        wait 0.05;
        if(level.players.size == 0)
            continue;

        playerCount = 0;
        for (i = 0; i < level.players.size; i++)
            if (!level.players[i] is_bot() && !isAlive(level.players[i]))
                playerCount++;

        level.dead_players = playerCount;
    }
}


bot_type_handler()
{
	wave = 0;
	
	if(level.wave >= 41) //this is a resetter for rounds without messing with level.wave at all.
	{
		if(level.wave_plus == 41)
		{
			level.wave_plus = 0;
		}
		level.wave_plus++;
		wave = level.wave_plus;
	}
	else
	{
		wave = level.wave;
	}
	//The first switch case is "easy"
	//spawnBotsWrapper(botsCount, lightCount, mediumCount, heavyCount, commandoCount, heavyCommandoCount, suicideBomberCount, juggCount,juggRiotCount)
	switch(wave)
	{
		case 1:
			spawnBotsWrapper(10,10,0,0,0,0,0,0,0);
			//testing wrapper
			//spawnBotsWrapper(2,0,0,0,0,0,0,1,1);
		break;
		
		case 2:
			spawnBotsWrapper(12,12,0,0,0,0,0,0,0);
		break;
		
		case 3:
			spawnBotsWrapper(14,14,0,0,0,0,0,0,0); //spawnBotsWrapper needs dogs (2)
		break;
		
		case 4:
			spawnBotsWrapper(10,0,10,0,0,0,0,0,0);
		break;
			
		case 5:
			spawnBotsWrapper(12,0,12,0,0,0,0,0,0);
		break;
			
		case 6:
			spawnBotsWrapper(12,0,12,0,0,0,0,0,0); // this should be 2 helis, 12 is filler
		break;
			
		case 7:
			spawnBotsWrapper(15,0,12,0,0,0,3,0,0);
		break;
			
		case 8:
			spawnBotsWrapper(17,0,12,0,0,0,5,0,0);
		break;
			
		case 9:
			spawnBotsWrapper(17,0,12,0,0,0,5,0,0); //bombers should be 3 and then 2 dogs
		break;
			
		case 10:
			spawnBotsWrapper(1,0,0,0,0,0,0,1,0); //should be 1 jugg
		break;
			
		case 11:
			spawnBotsWrapper(10,0,0,10,0,0,0,0,0);
		break;
			
		case 12:
			spawnBotsWrapper(12,0,0,12,0,0,0,0,0);
		break;
			
		case 13:
			spawnBotsWrapper(16,0,0,12,0,0,4,0,0);
		break;
			
		case 14:
			spawnBotsWrapper(18,0,0,12,0,0,6,0,0); //should be 4 bombers 2 dogs
		break;
			
		case 15:
			spawnBotsWrapper(2,0,0,0,0,0,0,2,0); //should be 2 juggs
		break;
			
		case 16:
			spawnBotsWrapper(10,0,0,0,10,0,0,0,0);
		break;
			
		case 17:
			spawnBotsWrapper(12,0,0,0,12,0,0,0,0);
		break;
			
		case 18:
			spawnBotsWrapper(17,0,0,0,12,0,5,0,0);
		break;
			
		case 19:
			spawnBotsWrapper(20,0,0,0,12,0,8,0,0); //should be 8 heavy 2 dogs
		break;
			
		case 20:
			spawnBotsWrapper(3,0,0,0,0,0,0,3,0); //should be 3 juggs
		break;
			
		case 21:
			spawnBotsWrapper(11,0,0,0,0,11,0,0,0);
		break;
			
		case 22:
			spawnBotsWrapper(17,0,0,0,0,17,0,0,0); //should be 11 heavy commando, and then 6 claymore specs
		break;
			
		case 23:
			spawnBotsWrapper(17,0,0,0,0,10,7,0,0); //add 1 heli
		break;
			
		case 24:
			spawnBotsWrapper(18,0,0,0,0,10,8,0,0); //add 1 heli
		break;
			
		case 25:
			spawnBotsWrapper(23,0,0,0,0,15,8,0,0); //add 1 heli , should be 10 heavy commando 5 claymore specs
		break;
			
		case 26:
			spawnBotsWrapper(23,0,0,0,0,12,8,2,1); //needs 2 amored juggs, 1 riot jugg, suicide dogs ,14 ai in total
		break;
			
		case 27:
			spawnBotsWrapper(23,0,0,0,0,15,8,0,0); //add 1 heli and claymore specs, 18 ai in total
		break;
			
		case 28:
			spawnBotsWrapper(23,0,0,0,0,15,8,0,0); //add 1 heli, suicide bogs, claymore specs, 19 ai total
		break;
			
		case 29:
			spawnBotsWrapper(23,0,0,0,0,15,8,0,0); //add 1 heli, suicide bogs, claymore specs, 23 ai total
		break;
			
		case 30:
			spawnBotsWrapper(23,0,0,0,0,12,8,2,1); //should be 2 armored juggs, 1 riot jugg, suicide dogs and heavy commando, 15 ai total
		break;
			
		case 31:
			spawnBotsWrapper(23,0,0,0,0,12,11,0,0); //add 1 heli, claymore specs no sus bombers, 18 ai toatl
		break;
			
		case 32:
			spawnBotsWrapper(23,0,0,0,0,12,11,0,0); //add 1 heli, c4 dogs, claymore specs, 19 ai total
		break;
			
		case 33:
			spawnBotsWrapper(23,0,0,0,0,12,11,0,0); //okay just go here, im not listing all this shit (https://www.ign.com/wikis/call-of-duty-modern-warfare-3/Survival_Enemy_List_and_Spawn_Times)
		break;
			
		case 34:
			spawnBotsWrapper(23,0,0,0,0,12,11,0,0); //from here down is all my random shit go stuff
		break;
			
		case 35:
			spawnBotsWrapper(30,0,0,0,7,10,10,2,1);
		break;
			
		case 36:
			spawnBotsWrapper(30,0,0,0,7,12,11,0,0);
		break;
			
		case 37:
			spawnBotsWrapper(30,0,0,0,7,12,11,0,0);
		break;
			
		case 38:
			spawnBotsWrapper(30,0,0,0,7,12,11,0,0);
		break;
			
		case 39:
			spawnBotsWrapper(30,0,0,0,7,12,11,0,0);
		break;
			
		case 40:
			spawnBotsWrapper(30,0,0,0,7,10,10,2,1);
		break;
	}
	
}


spawnBotsWrapper(botsCount, lightCount, mediumCount, heavyCount, commandoCount, heavyCommandoCount, suicideBomberCount, juggCount,juggRiotCount)
{
	level.botsForWave = botsCount;//used for next round to calc bots needed
	level.botsLeftToSpawn = botsCount;//normal bots == botsLeftToSpawn - (suicideBomberCount + juggCount) SOlID EDIT (I am using this for all bots but helis)
	level.lightTroopsBotsLeftToSpawn = lightCount;
	level.mediumTroopsBotsLeftToSpawn = mediumCount;
	level.heavyTroopsBotsLeftToSpawn = heavyCount;
	level.commandoTroopsBotsLeftToSpawn = commandoCount;
	level.heavyCommandoTroopsBotsLeftToSpawn = heavyCommandoCount;
	level.suicideBomberBotsLeftToSpawn = suicideBomberCount;//used when bot spawn to make them correct enemy type
	level.juggBotsLeftToSpawn = juggCount;//used when bot spawn to make them correct enemy type
	level.juggRiotBotsLeftToSpawn = juggRiotCount;
	spawnBots();
}
//this will need to be edited to add juggs later on
spawnBots()//for initial spawning until cap is reached then spawning is done in watchBotDeath when we need more
{
	//prob increase to 14 bots max so we can have 4 players at once
	//need to force team and spawn??
	//bot where getting stuck in spectator i think because of team cap
	if (level.botsForWave < 14)//first round rn we have 8 bots but cap per team is 9
	{
		setDvar("bots_manage_add", level.botsForWave);//
		return;
	}
	setdvar( "bots_manage_add", 14 );

	//setdvar( "surival_add_normal", 8 );
	//setdvar( "surival_add_jugg", 8 );

}

spawnHelis()//for initial spawning until cap is reached then spawning is done in watchHeliDeath when we need more
{
	//TODO 
	//while (level.heliLeftToSpawn > 0 && level.currentHeliCoun < 4)//3 helis max or what ever vehicle limit is
	//{
		//spawn heli //setup pathing //setup attacking
		//level.currentHeliCount++; 
		//heli watchHeliDeath();//new helis will be spawned here if needed
		//decrement count when heli is destroyed
	//}
}

create_bomber() //works mostly
{
	self thread wait_till_near();
	self thread bomber_shot();
	self thread bomber_near();
}

bomber_near()
{
	self waittill("BOOM");
	wait 1.0;
	self explode();
	self suicide();
}

bomber_shot()
{
	self waittill("damage",attacker);
	//level._effect["c4_light_blink"] = loadfx( "misc/light_c4_blink" ); //use this for blining on vests on model
	//playfxontag( common_scripts\utility::getfx( "c4_light_blink" ), self, "tag_fx" );
	wait 3.0;
	if(!attacker is_bot() && isAlive(self))
	{
		self explode();
		self suicide();
	}
}

explode()
{
	dam_rad = 750;
	radiusdamage( self.origin, dam_rad, dam_rad, dam_rad );
	explosionfx(self.origin);
}

wait_till_near()
{
	while(1)
	{
		wait 0.05;
		
		for (i = 0; i < level.players.size; i++)
		{
			if (!level.players[i] is_bot() && isAlive(level.players[i]))
			{
				player = level.players[i];
				
				if(distance(self.origin, player.origin) <= 100)
				{
					self notify("BOOM");
					return;
				}
			}
		}
	}
	
}

explosionfx(var_0)
{
	
    level thread common_scripts\utility::play_sound_in_space( "grenade_explode_concrete", self.origin ); 
    playfx( level._effect["c4_explosion"], var_0 ); //change this to c4 fx
	playrumbleonposition( "grenade_rumble", var_0 );
    earthquake( 0.4, 0.75, var_0, 512 );
}

callbackPlayerDamageHook(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{

    
    if( sMeansOfDeath == "MOD_TRIGGER_HURT" || sMeansOfDeath == "MOD_SUICIDE" )
	{}
	if (isDefined(eAttacker))
		if(eAttacker is_bot())
		{
			if(level.wave < 4)
			{
				iDamage = int(iDamage / 6);
			}
			else
				iDamage = int(iDamage / 3);
		}
		else if(!eAttacker is_bot())
		{
			if(level.wave < 4)
			{
				iDamage = int(iDamage * 2);
			}
			else
				iDamage = int(iDamage / 1);
		}
		else
			iDamage = int(iDamage / 1);


    [[level.callbackPlayerDamageStub]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

giveLoadoutForMap()
{
	
	switch (getDvar("mapname"))
	{
	    case "mp_dome":
		self _clearPerks();
		self maps\mp\killstreaks\_killstreaks::clearKillstreaks();//this removes killsteaks if i have any
		//thought it would stop me getting killstreaks
		self takeallweapons();
		//self setviewmodel("viewhands_delta");
		//self setModel("mp_body_delta_elite_smg_b");
        self giveWeapon("iw5_usp45_mp");
        self setspawnweapon("iw5_usp45_mp");
		self givemaxAmmo("iw5_usp45_mp");
		self surv_givePerk("specialty_finalstand");
		//self giveArmor();
		    break;
		default:
		self _clearPerks();
		self maps\mp\killstreaks\_killstreaks::clearKillstreaks();//this removes killsteaks if i have any
		//thought it would stop me getting killstreaks
		self takeallweapons();
		//self setviewmodel("viewhands_delta");
		//self setModel("mp_body_delta_elite_smg_b");
        self giveWeapon("iw5_usp45_mp");
        self setspawnweapon("iw5_usp45_mp");
		self givemaxAmmo("iw5_usp45_mp");
		self surv_givePerk("specialty_finalstand");
		//self giveArmor();
			break;
	}
}

/* 
HUDS
*/

//wave hud
//wave hud
wave_hud()
{   
	self endon( "disconnect" );
	level endon("game_ended");

    self.hud_wave = self createServerFontString( "hudbig", 0.7 );// "Objective", 1.3 
    self.hud_wave setPoint( "LEFT", "LEFT", 9.5, -125 );
	self.hud_wave.hidewheninmenu = true;
	self.hud_wave.label = &"Wave ";//TODO: make text font same as survival
	self.hud_wave setValue(level.wave);
	self.hud_wave.wave = 0;
	while(1)
	{
		wait 0.05;
		if (self.hud_wave.wave != level.wave)
		{
			self.hud_wave.wave = level.wave;
			self.hud_wave setValue(level.wave);
		}
	}
	
}

//points to buy stuff (move to bottem) make self, cords may need change 
score_hud()//might wanna change how we update this
{
	self endon( "disconnect" );
	level endon("game_ended");

    self.hud_score = self createFontString( "hudbig", 1 );///hudbig      objective 1.5
    self.hud_score setPoint( "LEFT", "LEFT", 0, 220 ); //-115 old
	self.hud_score.hidewheninmenu = true;
	self.hud_score.label = &"$ ";
	self.hud_score setValue(self.score);
	self.hud_score.score = 0;
	while(1)
	{
		wait 0.05;
		if (self.hud_score.score != self.score)
		{
			self.hud_score.score = self.score;
			self.hud_score setValue(self.score);
		}
	}
}

survival_hud() //test sur hud
{
	self endon( "disconnect" );
	level endon("game_ended");

    self.hud_sur = self createIconHud( "hud_weaponbar_line", "LEFT", "LEFT", 0, 202, 160, 40, (1,1,1), 1, 1, true);
	
}

surv_givePerk(perk)
{
	switch (perk)
	{
	    case "specialty_finalstand":
            self maps\mp\_utility::giveperk( "specialty_finalstand", 0 );
	        self thread perk_hud("specialty_finalstand");
		    break;
	    case "specialty_quickdraw":
            self maps\mp\_utility::giveperk( "specialty_quickdraw", 0 );
	        self thread perk_hud("specialty_quickdraw");
		    break;
	    case "specialty_fastreload":
            self maps\mp\_utility::giveperk( "specialty_fastreload", 0 );
	        self thread perk_hud("specialty_fastreload");
		    break;
	    case "specialty_stalker":
            self maps\mp\_utility::giveperk( "specialty_stalker", 0 );
	        self thread perk_hud("specialty_stalker");
		    break;
		case "specialty_bulletaccuracy":
            self maps\mp\_utility::giveperk( "specialty_bulletaccuracy", 0 );
	        self thread perk_hud("specialty_bulletaccuracy");
		    break;
		case "specialty_longersprint":
            self maps\mp\_utility::giveperk( "specialty_longersprint", 0 );
	        self thread perk_hud("V");
		    break;
		default:
		    //no valid perk found
		    break;
	}
}
giveArmor()
{
	armorHud = self createIcon("black", 24, 24);
	armorHud setPoint("CENTER", "CENTER", 0, 202);
	armorHud.alpha = 1;	
    armorHud.hideWhenInMenu = true;
	self.armor = 250;
	//destroy when armor is 0
	self thread destroyOnDeath(armorHud);
	self thread destroyOnDisconnect(armorHud);
}
givePerkCarepackage(perk)//TODO
{

}

perk_hud(perk)
{
	self endon( "disconnect" );
	level endon("game_ended");

	if ( !IsDefined( self.perk_hud ) )
	{
		self.perk_hud = [];
	}

	shader = "";
	switch(perk)
	{
		case"specialty_finalstand":
			shader = "hud_icon_self_revive";
		break;
		case"specialty_quickdraw":
			shader = "specialty_quickdraw";
		break;
		case"specialty_fastreload":
			shader = "specialty_fastreload";
		break;
		case"specialty_bulletaccuracy":
			shader = "specialty_steadyaim";
		break;
		case"specialty_stalker":
			shader = "specialty_stalker";
		break;
		case"specialty_longersprint":
			shader = "specialty_longersprint";
		break;
		
	}
	
	hudIcon = self createIcon(shader, 24, 24);
	align = "CENTER";
	relative = "CENTER";
	hudIcon.align = align;
    hudIcon.relative = relative;
    hudIcon.width = 24;
    hudIcon.height = 24;    
	hudIcon.alpha = 1;	
    hudIcon.hideWhenInMenu = true;
	hudIcon.hidden = false;//this is used in showElem() and hideElem() in maps\mp\gametypes\_hud_util
    hudIcon.archived = false;
    hudIcon.sort = 1;
    hudIcon setPoint(align, relative, self.perk_hud.size * 30, 202); //y202
	hudIcon setParent(level.uiParent);
	
    self.perk_hud[ perk ] = hudIcon;
	
	self thread destroyOnDeath(hudIcon);
	self thread destroyOnDisconnect(hudIcon);
}

vest_hud()
{
	self endon( "disconnect" );
	level endon("game_ended");


	shader = "specialty_armor";
		
	
	hudIcon = self createIcon(shader, 24, 24);
	align = "CENTER";
	relative = "CENTER";
	hudIcon.align = align;
    hudIcon.relative = relative;
    hudIcon.width = 24;
    hudIcon.height = 24;    
	hudIcon.alpha = 1;	
    hudIcon.hideWhenInMenu = true;
	hudIcon.hidden = false;//this is used in showElem() and hideElem() in maps\mp\gametypes\_hud_util
    hudIcon.archived = false;
    hudIcon.sort = 1;
    hudIcon setPoint(align, relative, 0, 202); //y202
	hudIcon setParent(level.uiParent);
	
	self thread destroyOnDeath(hudIcon);
	self thread destroyOnDisconnect(hudIcon);
	
}

createIconHud(shader, align, relative, x, y, width, height, color, alpha, sort, isClient)
{
	if(isClient) hudIcon = self createIcon(shader, width, height);
	else hudIcon = createServerIcon(shader, width, height);
	
	hudIcon.align = align;
    hudIcon.relative = relative;
    hudIcon.width = width;
    hudIcon.height = height;    
	hudIcon.alpha = alpha;
	//hudIcon.color = color;	
    hudIcon.hideWhenInMenu = true;
	hudIcon.hidden = false;
    hudIcon.archived = false;	
    hudIcon.sort = sort;    
    hudIcon setPoint(align, relative, x, y);
	hudIcon setParent(level.uiParent);
    return hudIcon;
}

//cleaner
intermission_hud()// > intermission_hud_plus_logic
{
	level endon("game_ended");
	wait 5;//as soon as last kill this is triggered
	//want to wait before starting countdown like survival
	level.votesToSkip = 0;
	level.vote_intermissionDone = false;
	level.currentIntermissionTime = level.inter_time;
	foreach(player in level.players)
	{
		if (!player is_bot())
		    player thread intermission_hud_player();
			//if level.vote_intermissionDone == false
			//add to onplayerconnect
			//before centerScreenCountdown()
			
	}
	while(1)
	{
		wait 1;
		level.currentIntermissionTime--;

		if (level.votesToSkip == level.current_real_players)
		{
			level.vote_intermissionDone = true;
	        foreach(player in level.players)
	        {
		        if (!player is_bot() && isDefined(player.intermissionHud))
				{
					player notify("intermission_hud_voting_done");
					player.intermissionHud thread hudFadeDestroy(2, 0);
				}
	        }
			centerScreenCountdown(5);
			return;
		}
		
		//hud_inter SetText("Press ^3{+melee_zoom}^7 to ready up " + inter_time);
		
		if(level.currentIntermissionTime == 0)//hud will say 1
		{
			level.vote_intermissionDone = true;
	        foreach(player in level.players)
	        {
		        if (!player is_bot() && isDefined(player.intermissionHud))
				{
					level.started = 1;
					player notify("intermission_hud_voting_done");
		            player.intermissionHud thread hudFadeDestroy(2, 0);
				}
	        }
			centerScreenCountdown(5);
			return;
		}
	}
}

intermission_hud_player()
{
	self endon("disconnect");
	self endon("intermission_hud_voting_done");
    self.intermissionHud = createFontString("hudbig", 0.7);
    self.intermissionHud setPoint("RIGHT", "RIGHT", 0, -125);
	self.intermissionHud.alpha = 0;
	self.intermissionHud _setText("Press ^3[{+melee_zoom}]^7 to ready up: " + level.currentIntermissionTime);
	self thread destroyOnDeath(self.intermissionHud);
	self thread destroyOnDisconnect(self.intermissionHud);
	self.voted = false;
	self thread removeVoteOnDisconnect();
	self.intermissionHud fadeOverTime(1);
	self.intermissionHud.alpha = 1;
	for(;;)
	{
		wait 0.1;
		
		if (self meleeButtonPressed())
		{
			level.votesToSkip++;
			//use this to remove vote if player disconnected
			self.voted = true;
			if (level.current_real_players == 1)
			{
				self.intermissionHud destroy();
				return;
			}
			else if (level.current_real_players == 2)
			{
				self.intermissionHud _setText("Waiting on other player: " + level.currentIntermissionTime);
				//if another player joins still wanna update this
				continue;
			}
			else if (level.current_real_players > 2)
			{
				self.intermissionHud _setText("Waiting on other players: " + level.currentIntermissionTime);
				//if another player joins still wanna update this
				continue;
			}
			
		}
		
		if(!self.voted == true) //fix for hud text
		{
			self.intermissionHud _setText("Press ^3[{+melee_zoom}]^7 to ready up: " + level.currentIntermissionTime);
		}
		
		//self.intermissionHud _setText("Press ^3[{+melee_zoom}]^7 to ready up: " + level.currentIntermissionTime);
	}
}

removeVoteOnDisconnect()
{
	self endon("intermission_hud_voting_done");
	self endon("death");
	hasVoted = self.voted;
	for (;;)
	{
		wait 0.1;
		//if player is not defined they disconnected
		if (!isDefined(self))
		{
			if (hasVoted)
			    level.votesToSkip--;

			return;
		}
		hasVoted = self.voted;
	}
}

centerScreenCountdown(timer)
{
    hud = createServerFontString("hudbig", 1);
    hud setPoint("CENTER", "CENTER", 0, 0);
	hud maps\mp\gametypes\_hud::fontPulseInit();
	snd = spawn( "script_origin", (0,0,0) );
	snd hide();
	for (i = timer; i > 0; i--)
	{
		hud thread maps\mp\gametypes\_hud::fontPulse(level);
		hud setValue(i);
		if (i <= 5)
			snd playSound( "ui_mp_timer_countdown" );

		wait 1;
	}
	hud destroy();
	snd delete();
}

survival_msg_hud(msg)
{
	color = undefined;
	glowColor = undefined;
	glowAlpha = undefined;
	if (msg == "wave_cleared")
	{
		msg = "Wave " + level.wave + " Cleared!";
		color = (1, 1, 1);
		glowColor = (0.2, 0.3, 0.7);
		glowAlpha = 1;
	}
	else if (msg == "hostiles_inbound")
	{
	    msg = "Hostiles inbound";
		color = (1, 1, 1);
		glowColor = (0.2, 0.3, 0.7);
		glowAlpha = 1;
	}
	else if (msg == "hostiles_inbound_bombers")
	{
	    msg = "Hostile bombers inbound";
		color = (1, 1, 1);
		glowColor = (0.2, 0.3, 0.7);
		glowAlpha = 1;
	}

	hud = createServerFontString("hudbig", 2);
	hud setPoint("CENTER", "CENTER", 100, -50);
	hud.color = color;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.hideWhenInMenu = true;
	hud.alpha = 0;
	hud setText(msg);
	hud fadeOverTime(0.1);
	hud.alpha = 1;
	hud moveOverTime(0.1);
	hud.y = -190;
	hud.x = 0;
	hud changeFontScaleOverTime(0.1);
	hud.fontScale = 1;
	wait 4;
	hud fadeOverTime(0.1);
	hud.alpha = 0;
	hud changeFontScaleOverTime(0.1);
	hud.fontScale = 3; 
	wait 0.3;
	hud destroy();
}

destroyOnDeath(hud)
{
	self endon("disconnect");
	self waittill("death");
	if (isDefined(hud))
	    hud destroy();
}

destroyOnDisconnect(hud)
{
	self endon ( "death" );
	self waittill ( "disconnect" );
	if (isDefined(hud))
	    hud destroy();
}

_setText(text)
{
	if (!isDefined(self)) return;

	if (!isDefined(self.text) || self.text != text)
	{
		self.text = text;
		self setText(text);
	}
}

hudFadeDestroy(time, alpha)
{
	self fadeOverTime(time);
	self.alpha = alpha;
	wait time;
	if (isDefined(self))
	    self destroy();
}

kill_leftovers()
{
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( player is_bot() )
		{
			player suicide();
		}
	}
}

kick_leftovers()
{
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( player is_bot() )
		{
			bot = player getEntityNumber();
			kick( bot );
		}
	}
}

//music
//mus = "so_survival_regular_music";


/*
//ai caches
	precachemodel( "body_delta_elite_assault_aa" );
	precachemodel( "body_africa_militia_smg_a" );
	precachemodel( "body_africa_militia_smg_b" );
	precachemodel( "body_africa_militia_smg_c" );
	precachemodel( "body_chemwar_russian_assault_b" );
	precachemodel( "body_chemwar_russian_assault_bb" );
	precachemodel( "body_chemwar_russian_assault_c" );
	precachemodel( "body_chemwar_russian_assault_cc" );
	precachemodel( "body_chemwar_russian_assault_d" );
	precachemodel( "body_chemwar_russian_assault_dd" );
	precachemodel( "body_chemwar_russian_assault_e" );
	precachemodel( "body_chemwar_russian_assault_ee" );
	precachemodel( "body_complete_sp_juggernaut" );
	precachemodel( "body_delta_elite_assault_aa" );
	precachemodel( "body_delta_elite_assault_ab" );
	precachemodel( "body_delta_elite_assault_ba" );
	precachemodel( "body_delta_elite_assault_bb" );
	precachemodel( "body_gign_paris_assault" );
	precachemodel( "body_gign_paris_smg" );
	precachemodel( "body_russian_military_assault_a_black" );
	precachemodel( "body_russian_military_assault_b_woodland" );
	precachemodel( "body_russian_military_smg_a_airborne" );
	precachemodel( "body_russian_naval_assault_c" );
	precachemodel( "body_russian_naval_assault_d" );
	precachemodel( "body_russian_naval_assault_f" );
	precachemodel( "body_russian_naval_assault_ff" );
	precachemodel( "body_so_juggernaut_blue" );
	precachemodel( "fullbody_chemwar_russian_assault_a" );
	precachemodel( "fullbody_chemwar_russian_assault_aa" );
	precachemodel( "fullbody_juggernaut_explosive_so" );
	precachemodel( "fullbody_juggernaut_novisor_b" );
	precachemodel( "fx_bullet_chain" );
	precachemodel( "fx_bullet_chain_blur" );
	precachemodel( "hat_africa_militia_a" );
	precachemodel( "hat_africa_militia_b" );
	precachemodel( "hat_africa_militia_c" );
	precachemodel( "hat_africa_null" );
	precachemodel( "hat_so_juggernaut_blue" );
	precachemodel( "head_africa_militia_a_hat" );
	precachemodel( "head_africa_militia_b_hat" );
	precachemodel( "head_africa_militia_c_hat" );
	precachemodel( "head_africa_militia_d" );
	precachemodel( "head_chemwar_russian_a" );
	precachemodel( "head_chemwar_russian_d" );
	precachemodel( "head_chemwar_russian_e" );
	precachemodel( "head_delta_elite_a" );
	precachemodel( "head_delta_elite_b" );
	precachemodel( "head_delta_elite_c" );
	precachemodel( "head_delta_elite_d" );
	precachemodel( "head_gign_a" );
	precachemodel( "head_gign_b" );
	precachemodel( "head_gign_c" );
	precachemodel( "head_gign_d" );
	precachemodel( "head_opforce_arab_c" );
	precachemodel( "head_russian_military_a" );
	precachemodel( "head_russian_military_bb" );
	precachemodel( "head_russian_military_c" );
	precachemodel( "head_russian_military_cc" );
	precachemodel( "head_russian_military_dd_black" );
	precachemodel( "head_russian_military_d_black" );
	precachemodel( "head_russian_military_e_black" );
	precachemodel( "head_russian_military_f_black" );
	precachemodel( "head_russian_naval_a" );
	precachemodel( "head_russian_naval_b" );
	precachemodel( "head_russian_naval_c" );
	precachemodel( "head_so_juggernaut_blue_hat" );
	precachemodel( "ims_scorpion_explosive1" );
	precachemodel( "mp_body_delta_elite_assault_bb" );
	//DOG
	precachemodel( "german_sheperd_dog" );
	//ADD_ONS
	precachemodel( "gas_canisters_backpack" );
*/