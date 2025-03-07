//=============================================
//	Plugin Writed by Visual Studio Code.
//=============================================
// Supported BIOHAZARD.
// #define BIOHAZARD_SUPPORT
// #define ZP_SUPPORT

//=====================================
//  INCLUDE AREA
//=====================================
#include <amxmodx>
#include <amxmisc>
#include <amxconst>
#include <cstrike>
#include <csx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <json>
#include <fun>

#define AMXMODX_NOAUTOLOAD
#include <reapi>

//=====================================
//  VERSION CHECK
//=====================================
#if AMXX_VERSION_NUM < 190
	#assert "AMX Mod X v1.9.0 or greater library required!"
#endif

#include <lasermine_util>
#include <lasermine_resources>

#pragma semicolon 1
#pragma tabsize 4

#if !defined BIOHAZARD_SUPPORT && !defined ZP_SUPPORT
	#define PLUGIN 					"Laser/Tripmine Entity"
	#define CHAT_TAG 				"[Lasermine]"
	#define CVAR_TAG				"amx_ltm"
	#define CVAR_CFG				"lasermine/ltm_cvars"
#endif

//=====================================
//  MACRO AREA
//=====================================
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define AUTHOR 						"Aoi.Kagase"
#define VERSION 					"3.41"

//====================================================
//  GLOBAL VARIABLES
//====================================================
new gMsgBarTime;
new gMsgWeaponList;
new gCvar				[E_CVAR_SETTING];
new gCvarPointer		[E_CVAR_SETTING_LIST];
new gEntMine;
new gWeaponId;
new gDeployingMines		[MAX_PLAYERS];

#if AMXX_VERSION_NUM > 183
new Stack:gRecycleMine	[MAX_PLAYERS];
#endif

#if defined BIOHAZARD_SUPPORT || defined ZP_SUPPORT
#pragma semicolon 0
	#include <lasermine_zombie>
#pragma semicolon 1
#endif
#define RELOAD_TIME						0.6
enum E_FORWARD
{
	E_FWD_ONBUY_PRE,
	E_FWD_ONBUY_POST,
	E_FWD_ONPLANT,
	E_FWD_ONPLANTED,
	E_FWD_ONHIT_PRE,
	E_FWD_ONHIT_POST,
	E_FWD_ONPICKUP_PRE,
	E_FWD_ONPICKUP_POST,
}

new g_forward[E_FORWARD];

new g_library;
new g_players[MAX_PLAYERS + 1];

public plugin_forward()
{
	g_forward[E_FWD_ONBUY_PRE]		= CreateMultiForward("LM_OnBuy_Pre",  		ET_STOP, 	FP_CELL, FP_VAL_BYREF, FP_VAL_BYREF);
	g_forward[E_FWD_ONBUY_POST]		= CreateMultiForward("LM_OnBuy_Post", 		ET_IGNORE, 	FP_CELL, FP_CELL, FP_CELL);
	g_forward[E_FWD_ONPLANT]		= CreateMultiForward("LM_OnPlant", 			ET_STOP, 	FP_CELL, FP_VAL_BYREF);
	g_forward[E_FWD_ONPLANTED]		= CreateMultiForward("LM_OnPlanted", 		ET_IGNORE, 	FP_CELL, FP_CELL);
	g_forward[E_FWD_ONHIT_PRE]		= CreateMultiForward("LM_OnHit_Pre", 		ET_STOP, 	FP_CELL, FP_VAL_BYREF, FP_VAL_BYREF, FP_VAL_BYREF);
	g_forward[E_FWD_ONHIT_POST]		= CreateMultiForward("LM_OnHit_Post", 		ET_IGNORE, 	FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	g_forward[E_FWD_ONPICKUP_PRE]	= CreateMultiForward("LM_OnPickup_Pre", 	ET_STOP, 	FP_CELL, FP_CELL);
	g_forward[E_FWD_ONPICKUP_POST]	= CreateMultiForward("LM_OnPickup_Post", 	ET_IGNORE, 	FP_CELL);
}

//====================================================
// Check Module. Section 2.
//====================================================
public module_filter(const module[])
{
	if (equali(module, "reapi"))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}
//====================================================
// Check Module. Section 3.
//====================================================
public native_filter(const name[], index, trap)
{
	if (!trap)
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}
//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Add your code here...
	register_concmd("lm_remove", 	"admin_remove_laser",ADMIN_ACCESSLEVEL, " - <num>"); 
	register_concmd("lm_give", 		"admin_give_laser",  ADMIN_ACCESSLEVEL, " - <num>"); 

	// register_clcmd("+setlaser", 	"lm_progress_deploy");
	// register_clcmd("+setlm", 	"lm_progress_deploy");
	// register_clcmd("-setlaser", 	"lm_progress_stop");
   	// register_clcmd("-setlm", 	"lm_progress_stop");

	register_clcmd("say", 			"lm_say_lasermine");

#if !defined ZP_SUPPORT	
	register_clcmd("buy_lasermine", "lm_buy_lasermine");
#endif
	register_cvars();

	gMsgBarTime	= get_user_msgid("BarTime");
	gMsgWeaponList = get_user_msgid("WeaponList");
	register_message(get_user_msgid("TextMsg"), 	"Message_TextMsg") ;

	// Register Hamsandwich
	RegisterHamPlayer	(Ham_Spawn, 		"NewRound",			1);
	RegisterHamPlayer	(Ham_Item_PreFrame,	"KeepMaxSpeed", 	1);
	RegisterHamPlayer	(Ham_TakeDamage, 	"PlayerKilling",	0);

	RegisterHam			(Ham_Think,			ENT_CLASS_BREAKABLE, "LaserThink",		0);
	RegisterHam			(Ham_TakeDamage,	ENT_CLASS_BREAKABLE, "MinesTakeDamage",	0);
	RegisterHam			(Ham_TakeDamage,	ENT_CLASS_BREAKABLE, "MinesTakeDamaged",1);

	// Register Event
	register_event_ex	("DeathMsg", 		"DeathEvent",		RegisterEvent_Global);
	register_event_ex	("TeamInfo", 		"CheckSpectator",	RegisterEvent_Global);

	// Register Forward.
	register_forward	(FM_CmdStart,		"PlayerCmdStart");
	register_forward	(FM_TraceLine,		"MinesShowInfo", 1);

	// Multi Language Dictionary.
	register_dictionary	("lasermine.txt");

#if AMXX_VERSION_NUM > 183
	for(new i = 0; i < MAX_PLAYERS; i++)
		gRecycleMine[i] = CreateStack(1);
#endif

#if defined ZP_SUPPORT || defined BIOHAZARD_SUPPORT
	register_zombie();
#else
#if AMXX_VERSION_NUM > 183
	AutoExecConfig(true, CVAR_CFG);
#endif
#endif

	create_cvar			("ltm_version", 	VERSION, FCVAR_SERVER|FCVAR_SPONLY);

	// Add Custom weapon id to CSX.
	gWeaponId = custom_weapon_add("Laser Mine", 0, ENT_CLASS_LASER);

	// registered func_breakable
	gEntMine = engfunc(EngFunc_AllocString, ENT_CLASS_BREAKABLE);

	g_library = LibraryExists("reapi", LibType_Library);

/// =======================================================================================
/// START Custom Weapon
/// =======================================================================================
    register_clcmd		("weapons/ltm/weapon_lasermine", 	"SelectLasermine");
    RegisterHam			(Ham_Item_AddToPlayer, 				"weapon_c4", 	"OnAddToPlayerC4",		.Post = true);
	RegisterHam			(Ham_Item_ItemSlot, 				"weapon_c4", 	"OnItemSlotC4");
	RegisterHam			(Ham_Item_Deploy, 					"weapon_c4", 	"OnSetDeployModels",	.Post = true);
	RegisterHam			(Ham_Weapon_PrimaryAttack, 			"weapon_c4", 	"OnPrimaryAttackPre");
	RegisterHam			(Ham_Weapon_PrimaryAttack, 			"weapon_c4", 	"OnPrimaryAttackPost",	.Post = true);
	RegisterHam			(Ham_CS_Item_CanDrop, 				"weapon_c4", 	"OnC4Drop");
//	RegisterHam			(Ham_Weapon_SecondaryAttack,		"weapon_c4", 	"OnSecondaryAttackPre");

	register_event		("CurWeapon", 						"weapon_change", "be", "1=1");
//	register_forward	(FM_SetModel, 						"OnWeaponBoxSetModel", 					._post = true);
	register_forward	(FM_UpdateClientData, 				"OnUpdateClientDataPost", 				._post = true);
/// =======================================================================================
/// END Custom Weapon
/// =======================================================================================

	LoadDecals();
	plugin_forward();
	return PLUGIN_CONTINUE;
}

public register_cvars()
{
	new E_CVAR_SETTING:key;
	// CVar settings.
	for(new E_CVAR_SETTING_LIST:i = CL_ENABLE; i < E_CVAR_SETTING_LIST; i++)
	{
		key = get_cvar_key(i);
		if (i == CL_FRIENDLY_FIRE || i == CL_VIOLENCE_HBLOOD)
			gCvarPointer[i] = get_cvar_pointer(CVAR_CONFIGRATION[i][0]);
		else
			gCvarPointer[i] = create_cvar(fmt("%s%s", CVAR_TAG, CVAR_CONFIGRATION[i][0]), CVAR_CONFIGRATION[i][2], FCVAR_NONE, CVAR_CONFIGRATION[i][1]);
		if (equali(CVAR_CONFIGRATION[i][3], "num")) {
			bind_pcvar_num(gCvarPointer[i], gCvar[key]);
		}
		else if(equali(CVAR_CONFIGRATION[i][3], "float")) {
			bind_pcvar_float(gCvarPointer[i], Float:gCvar[key]);
		}
		else if(equali(CVAR_CONFIGRATION[i][3], "string")) {
			switch(i)
			{
				case CL_CBT: 			bind_pcvar_string(gCvarPointer[CL_CBT], gCvar[CVAR_CBT], charsmax(gCvar[CVAR_CBT]));
				case CL_LASER_COLOR_TR: bind_pcvar_string(gCvarPointer[CL_LASER_COLOR_TR], gCvar[CVAR_LASER_COLOR_TR], charsmax(gCvar[CVAR_LASER_COLOR_TR]));
				case CL_LASER_COLOR_CT: bind_pcvar_string(gCvarPointer[CL_LASER_COLOR_CT], gCvar[CVAR_LASER_COLOR_CT], charsmax(gCvar[CVAR_LASER_COLOR_CT]));
				case CL_MINE_GLOW_TR: 	bind_pcvar_string(gCvarPointer[CL_MINE_GLOW_TR], gCvar[CVAR_MINE_GLOW_TR], charsmax(gCvar[CVAR_MINE_GLOW_TR]));
				case CL_MINE_GLOW_CT: 	bind_pcvar_string(gCvarPointer[CL_MINE_GLOW_CT], gCvar[CVAR_MINE_GLOW_CT], charsmax(gCvar[CVAR_MINE_GLOW_CT]));				
			}
		}
		
		hook_cvar_change(gCvarPointer[i], "cvar_change_callback");
	}	
}

#if AMXX_VERSION_NUM < 190
//====================================================
//  PLUGIN CONFIG (for 1.8.2)
//====================================================
public plugin_cfg()
{
	new file[64];
	new len = charsmax(file);
	get_localinfo("amxx_configsdir", file, len);
	format(file, len, "%s/plugins/%s.cfg", file, CVAR_CFG);

	if(file_exists(file)) 
	{
		server_cmd("exec %s", file);
		server_exec();
	}
}
#endif

//====================================================
//  PLUGIN END
//====================================================
#if AMXX_VERSION_NUM > 183
public plugin_end()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
		DestroyStack(gRecycleMine[i]);

	lm_resources_release();
}

// ====================================================
//  Callback cvar change.
// ====================================================
public cvar_change_callback(pcvar, const old_value[], const new_value[])
{
	new E_CVAR_SETTING:key;
	for(new E_CVAR_SETTING_LIST:i = CL_ENABLE; i < E_CVAR_SETTING_LIST; i++)
	{
		key = get_cvar_key(i);
		if (gCvarPointer[i] == pcvar)
		{
			if (equali(CVAR_CONFIGRATION[i][3], "num"))
				gCvar[key] = str_to_num(new_value);
			else if (equali(CVAR_CONFIGRATION[i][3], "float"))
				gCvar[key] = _:str_to_float(new_value);
			else if (equali(CVAR_CONFIGRATION[i][3], "string"))
			{
				switch(i)
				{
					case CL_CBT: 			copy(gCvar[CVAR_CBT], charsmax(gCvar[CVAR_CBT]), new_value);
					case CL_LASER_COLOR_TR: copy(gCvar[CVAR_LASER_COLOR_TR], charsmax(gCvar[CVAR_LASER_COLOR_TR]), new_value);
					case CL_LASER_COLOR_CT: copy(gCvar[CVAR_LASER_COLOR_CT], charsmax(gCvar[CVAR_LASER_COLOR_CT]), new_value);
					case CL_MINE_GLOW_TR: 	copy(gCvar[CVAR_MINE_GLOW_TR], charsmax(gCvar[CVAR_MINE_GLOW_TR]), new_value);
					case CL_MINE_GLOW_CT: 	copy(gCvar[CVAR_MINE_GLOW_CT], charsmax(gCvar[CVAR_MINE_GLOW_CT]), new_value);				
				}
			}
			console_print(0,"[LM Debug]: Changed Cvar '%s' => '%s' to '%s'", fmt("%s%s", CVAR_TAG, CVAR_CONFIGRATION[i][0]), old_value, new_value);
		}
	}
}
#endif

//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	check_plugin();

	// Load Custom Resources.
	lm_resources_load();
	lm_resources_precache();

	// WEAPON SLOT ENVIRONMENT.
	precache_model("sprites/weapons/ltm/2560/weapon_tripmine_weapon.spr"),
	precache_model("sprites/weapons/ltm/2560/weapon_tripmine_weapon_s.spr"),
	precache_model("sprites/weapons/ltm/2560/weapon_tripmine_ammo.spr"),
	precache_model("sprites/weapons/ltm/1280/weapon_tripmine_weapon.spr"),
	precache_model("sprites/weapons/ltm/1280/weapon_tripmine_weapon_s.spr"),	
	precache_model("sprites/weapons/ltm/1280/weapon_tripmine_weapon.spr"),
	precache_model("sprites/weapons/ltm/640hud3.spr"),
	precache_model("sprites/weapons/ltm/640hud6.spr"),
	precache_model("sprites/weapons/ltm/640hud7.spr"),
	precache_model("sprites/weapons/ltm/320hud1.spr"),
	precache_model("sprites/weapons/ltm/320hud2.spr"),
	precache_generic("sprites/weapons/ltm/weapon_lasermine.txt");
	
	return PLUGIN_CONTINUE;
}

//====================================================
//  Bot Register Ham.
//====================================================
// new g_bots_registered = false;
// public client_authorized( id )
// {
//     if( !g_bots_registered && is_user_bot( id ) )
//     {
//         set_task( 0.1, "register_bots", id );
//     }
// }

// public register_bots( id )
// {
//     if( !g_bots_registered && is_user_connected( id ) )
//     {
//         RegisterHamFromEntity( Ham_TakeDamage, id, "PlayerKilling");
//         g_bots_registered = true;
//     }
// }

//====================================================
// Friendly Fire Method.
//====================================================
bool:is_valid_takedamage(iAttacker, iTarget)
{
	if (gCvar[CVAR_FRIENDLY_FIRE])
		return true;

	new name[MAX_NAME_LENGTH];
	pev(iTarget, pev_classname, name, charsmax(name));

	if (equali(name, ENT_CLASS_LASER))
	{
		if (cs_get_user_team(iAttacker) != lm_get_laser_team(iTarget))
			return true;
	}
	else
	{
		if (cs_get_user_team(iAttacker) != cs_get_user_team(iTarget))
			return true;
	}

	return false;
}

//====================================================
// Round Start Initialize
//====================================================
public NewRound(id)
{
	// Check Plugin Enabled
	if (!gCvar[CVAR_ENABLE])
		return PLUGIN_CONTINUE;

	if (!is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	if (is_user_bot(id))
		return PLUGIN_CONTINUE;

	// alive?
	if (is_user_alive(id) && pev(id, pev_flags) & (FL_CLIENT)) 
	{
		// Delay time reset
		lm_set_user_delay_count(id, get_gametime());

#if AMXX_VERSION_NUM > 183
		// Init Recycle Health.
		ClearStack(gRecycleMine[id]);
#endif
		// Task Delete.
		delete_task(id);

		// Removing already put lasermine.
		lm_remove_all_entity(id, ENT_CLASS_LASER);

		// Round start set ammo.
		set_start_ammo(id);

		// Refresh show ammo.
		show_ammo(id);
	}
	return PLUGIN_CONTINUE;
}

//====================================================
// Keep Max Speed.
//====================================================
public KeepMaxSpeed(id)
{
	if (is_user_alive(id))
	{
		new Float:now_speed = lm_get_user_max_speed(id);
		if (now_speed > 1.0 && now_speed < 300.0)
			lm_save_user_max_speed(id, lm_get_user_max_speed(id));
	}

	return PLUGIN_CONTINUE;
}

//====================================================
// Round Start Set Ammo.
//====================================================
set_start_ammo(id)
{
	// Get CVAR setting.
	new int:stammo = int:gCvar[CVAR_START_HAVE];

	// Zero check.
	if(stammo <= int:0) 
		return;

	// Getting have ammo.
	new int:haveammo = lm_get_user_have_mine(id);

	// Set largest.
	lm_set_user_have_mine(id, (haveammo <= stammo ? stammo : haveammo));

	if (cs_get_user_bpammo(id, CSW_C4) <= 0)
		give_item(id, "weapon_c4");	

	cs_set_user_bpammo(id, CSW_C4, lm_get_user_have_mine(id));

	return;
}

//====================================================
// Death Event / Delete Task.
//====================================================
public DeathEvent()
{
	// new kID = read_data(1); // killer
	new vID = read_data(2); // victim
	// new isHS = read_data(3); // is headshot
	// new wpnName = read_data(4); // wpnName

	// Check Plugin Enabled
	if (!gCvar[CVAR_ENABLE])
		return PLUGIN_CONTINUE;

	// Is Connected?
	if (is_user_connected(vID)) 
		delete_task(vID);

	// Dead Player remove lasermine.
	if (gCvar[CVAR_DEATH_REMOVE])
		lm_remove_all_entity(vID, ENT_CLASS_LASER);

	return PLUGIN_CONTINUE;
}

//====================================================
// Deploy LaserMine Start Progress
//====================================================
public lm_progress_deploy(id)
{
	// Deploying Check.
	if (!check_for_deploy(id))
		return PLUGIN_HANDLED;

	new wait = gCvar[CVAR_LASER_ACTIVATE];
	new iRet;
	ExecuteForward(g_forward[E_FWD_ONPLANT], iRet, id, wait);
	// Set Flag. start progress.
	lm_set_user_deploy_state(id, int:STATE_DEPLOYING);

	new iEnt = gDeployingMines[id] = engfunc(EngFunc_CreateNamedEntity, gEntMine);
	if (pev_valid(iEnt))
	{
		new szValue[MAX_RESOURCE_PATH_LENGTH];
		lm_get_models(W_WPN, cs_get_user_team(id), szValue, charsmax(szValue));
		// set models.
		engfunc(EngFunc_SetModel, iEnt, szValue);
		// set solid.
		set_pev(iEnt, pev_solid, 		SOLID_NOT);
		// set movetype.
		set_pev(iEnt, pev_movetype, 	MOVETYPE_FLY);

		set_pev(iEnt, pev_renderfx, 	kRenderFxHologram);
		set_pev(iEnt, pev_body, 		3);
		set_pev(iEnt, pev_sequence, 	TRIPMINE_WORLD);
		// set model animation.
		set_pev(iEnt, pev_frame,		0);
		set_pev(iEnt, pev_framerate,	0);
		set_pev(iEnt, pev_rendermode,	kRenderTransAdd);
		set_pev(iEnt, pev_renderfx,	 	kRenderFxHologram);
		set_pev(iEnt, pev_renderamt,	255.0);
		set_pev(iEnt, pev_rendercolor,	{255.0,255.0,255.0});

		if (cs_get_user_weapon(id) == CSW_C4)
			set_pdata_float(cs_get_user_weapon_entity(id), 35, 999.0);		
	}

	// if (wait > 0)
	// {
	// 	lm_show_progress(id, wait, gMsgBarTime);
	// }

	// Start Task. Put Lasermine.
	SpawnMine(TASK_PLANT + id);
//	set_task(float(wait), "SpawnMine", (TASK_PLANT + id));

	return PLUGIN_HANDLED;
}

//====================================================
// Removing target put lasermine.
//====================================================
public lm_progress_remove(id)
{
	// Removing Check.
	if (!check_for_remove(id))
		return PLUGIN_HANDLED;

	new wait = gCvar[CVAR_LASER_ACTIVATE];
	if (wait > 0)
		lm_show_progress(id, wait, gMsgBarTime);

	// Set Flag. start progress.
	lm_set_user_deploy_state(id, int:STATE_PICKING);

	// Start Task. Remove Lasermine.
	set_task(float(wait), "RemoveMine", (TASK_RELEASE + id));

	return PLUGIN_HANDLED;
}

//====================================================
// Stopping Progress.
//====================================================
public lm_progress_stop(id)
{
	if (pev_valid(gDeployingMines[id]))
		lm_remove_entity(gDeployingMines[id]);
	gDeployingMines[id] = 0;

	lm_hide_progress(id, gMsgBarTime);
	delete_task(id);

	return PLUGIN_HANDLED;
}

//====================================================
// Task: Spawn Lasermine.
//====================================================
public SpawnMine(id)
{
	// Task Number to uID.
	new uID = id - TASK_PLANT;
	new iRet;
	// is Valid?
	if(!gDeployingMines[uID])
	{
		cp_debug(uID);
		return PLUGIN_HANDLED_MAIN;
	}

	set_spawn_entity_setting(gDeployingMines[uID], uID, ENT_CLASS_LASER);
	ExecuteForward(g_forward[E_FWD_ONPLANTED], iRet, id, gDeployingMines[uID]);
	return 1;
}

//====================================================
// Lasermine Settings.
//====================================================
stock set_spawn_entity_setting(iEnt, uID, classname[])
{
	// Entity Setting.
	// set class name.
	set_pev(iEnt, pev_classname, 		classname);
	// set solid.
	set_pev(iEnt, pev_solid, 			SOLID_NOT);
	set_pev(iEnt, pev_rendermode,		kRenderNormal);
	set_pev(iEnt, pev_renderfx,	 		kRenderFxNone);
	// set take damage.
	set_pev(iEnt, pev_takedamage, 		DAMAGE_YES);
	set_pev(iEnt, pev_dmg, 				100.0);
	// set entity health.
	// if recycle health.
#if AMXX_VERSION_NUM > 183
	if (!IsStackEmpty(gRecycleMine[uID]))
	{
		new Float:health;
		PopStackCell(gRecycleMine[uID], health);
		lm_set_user_health(iEnt, 		health);
	}
	else
	{
//		client_print(uID, print_chat, "[DEBUG] %f", gCvar[CVAR_MINE_HEALTH]);
		set_pev(iEnt, pev_health, gCvar[CVAR_MINE_HEALTH]);
//		client_print(uID, print_chat, "[DEBUG] %f", lm_get_user_health(iEnt));
	}
#else
	lm_set_user_health(iEnt, 			gCvar[CVAR_MINE_HEALTH]);
#endif
	// set mine position
	set_mine_position(uID, iEnt);
	// Reset powoer on delay time.
	new Float:fCurrTime = get_gametime();

	// Save results to be used later.
	set_pev(iEnt, LASERMINE_OWNER, 		uID);
	set_pev(iEnt, LASERMINE_POWERUP,	fCurrTime + 2.5);
	set_pev(iEnt, LASERMINE_STEP, 		POWERUP_THINK);
	set_pev(iEnt, LASERMINE_COUNT,		fCurrTime);
	set_pev(iEnt, LASERMINE_BEAMTHINK,	fCurrTime);
	// think rate. hmmm....
	set_pev(iEnt, pev_nextthink, 		fCurrTime + 0.2 );
	// Power up sound.
	lm_play_sound(iEnt, 				SOUND_POWERUP, lm_get_laser_team(iEnt));
	// Cound up. deployed.
	lm_set_user_mine_deployed(uID, 		lm_get_user_mine_deployed(uID) + int:1);
	// Cound down. have ammo.
	lm_set_user_have_mine(uID, 			lm_get_user_have_mine(uID) - int:1);
	cs_set_user_bpammo(uID, CSW_C4, lm_get_user_have_mine(uID));
	// Set Flag. end progress.
	lm_set_user_deploy_state(uID, 		int:STATE_DEPLOYED);
	gDeployingMines[uID] = 0;

	// Adds a shot event on a custom weapon to the internal stats.
	custom_weapon_shot(gWeaponId, uID);

	// Refresh show ammo.
	show_ammo(uID);
}

//====================================================
// Set Lasermine Position.
//====================================================
set_mine_position(uID, iEnt)
{
	// Vector settings.
	new Float:vOrigin	[3],Float:vViewOfs	[3];
	new	Float:vNewOrigin[3],Float:vNormal	[3];
	new	Float:vTraceEnd	[3],Float:vEntAngles[3];
	new Float:vDecals	[3];

	// get user position.
	pev(uID, pev_origin, vOrigin);
	pev(uID, pev_view_ofs, vViewOfs);

	velocity_by_aim(uID, 128, vTraceEnd);

	xs_vec_add(vOrigin, vViewOfs, vOrigin);  	
	xs_vec_add(vTraceEnd, vOrigin, vTraceEnd);

    // create the trace handle.
	new trace = create_tr2();
	// get wall position to vNewOrigin.
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, IGNORE_MONSTERS, uID, trace);
	{
		new Float:fFraction;
		get_tr2( trace, TR_flFraction, fFraction );
			
		// -- We hit something!
		if ( fFraction < 1.0 )
		{
			// -- Save results to be used later.
			get_tr2( trace, TR_vecEndPos, vTraceEnd );
			get_tr2( trace, TR_vecPlaneNormal, vNormal );
		}
	}
    // free the trace handle.
	free_tr2(trace);

	xs_vec_add( vTraceEnd, vNormal, vDecals);
	xs_vec_mul_scalar( vNormal, 8.0, vNormal );
	xs_vec_add( vTraceEnd, vNormal, vNewOrigin );

	// set size.
	engfunc(EngFunc_SetSize, iEnt, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );
	// set entity position.
	engfunc(EngFunc_SetOrigin, iEnt, vNewOrigin );
	set_pev(iEnt, LASERMINE_DECALS, vDecals);

	// Rotate tripmine.
	vector_to_angle(vNormal, vEntAngles);
	// set angle.
	set_pev(iEnt, pev_angles, vEntAngles);
	// set laserbeam end point position.
	set_laserend_postiion(iEnt, vNormal, vNewOrigin);
}

//====================================================
// Set Laserbeam End Position.
//====================================================
set_laserend_postiion(iEnt, Float:vNormal[3], Float:vNewOrigin[3])
{
	// Calculate laser end origin.
	new Float:vBeamEnd[3];
	new Float:vTracedBeamEnd[3];
	new Float:vTemp[3];
	new Float:range = gCvar[CVAR_LASER_RANGE];

	new Float:fFraction = 0.0;
	new iIgnore;
	new className[MAX_NAME_LENGTH];
	new trace;	

	xs_vec_mul_scalar(vNormal, range, vNormal );
	xs_vec_add( vNewOrigin, vNormal, vBeamEnd );


	// create the trace handle.
	vTracedBeamEnd	= vBeamEnd;
	vTemp 			= vNewOrigin;
	iIgnore 		= -1;

	// Trace line
	while(fFraction < 1.0)
	{
 		trace = create_tr2();
		engfunc(EngFunc_TraceLine, vTemp, vBeamEnd, (IGNORE_MONSTERS | IGNORE_GLASS), iIgnore, trace);
		{
			get_tr2(trace, TR_flFraction, fFraction);
			get_tr2(trace, TR_vecEndPos, vTemp);
			iIgnore = get_tr2(trace, TR_pHit);

			if (gCvar[CVAR_MODE] == MODE_LASERMINE)
			{
				// is valid hit entity?
				if (pev_valid(iIgnore))
				{
					pev(iIgnore, pev_classname, className, charsmax(className));
					if (!equali(className, ENT_CLASS_BREAKABLE))
						break;
				}
				else
					break;
			}
			else
				break;
		}
		free_tr2(trace);
	}
	vTracedBeamEnd = vTemp;		
	// free the trace handle.
	free_tr2(trace);
	set_pev(iEnt, LASERMINE_BEAMENDPOINT1, vTracedBeamEnd);
}

//====================================================
// Task: Remove Lasermine.
//====================================================
public RemoveMine(id)
{
	new target, body;
	new Float:vOrigin[3];
	new Float:tOrigin[3];

	// Task Number to uID.
	new uID = id - TASK_RELEASE;

	// Get target entity.
	get_user_aiming(uID, target, body);

	// is valid target?
	if(!pev_valid(target))
		return;
	
	new iRet;
	ExecuteForward(g_forward[E_FWD_ONPICKUP_PRE], iRet, uID, target);

	// Get Player Vector Origin.
	pev(uID, pev_origin, vOrigin);
	// Get Mine Vector Origin.
	pev(target, pev_origin, tOrigin);

	// Distance Check. far 70.0 (cm?)
	if(get_distance_f(vOrigin, tOrigin) > 128.0)
		return;
	
	new entityName[MAX_NAME_LENGTH];
	lm_get_entity_class_name(target, entityName, charsmax(entityName));

	// Check. is Target Entity Lasermine?
	if(!equali(entityName, ENT_CLASS_LASER))
		return;

	new ownerID = pev(target, LASERMINE_OWNER);

	new PICKUP_MODE:pickup 	= PICKUP_MODE:gCvar[CVAR_ALLOW_PICKUP];
	switch(pickup)
	{
		case DISALLOW_PICKUP:
			return;
		case ONLY_ME:
		{
			// Check. is Owner you?
			if(ownerID != uID)
				return;
		}
		case ALLOW_FRIENDLY:
		{
			// Check. is friendly team?
			if(lm_get_laser_team(target) != cs_get_user_team(uID))
				return;
		}		
	}

	// Recycle Health.
#if AMXX_VERSION_NUM > 183
	new Float:health = lm_get_user_health(target);
	PushStackCell(gRecycleMine[uID], health);
#endif
	// Remove!
	lm_remove_entity(target);

	// Collect for this removed lasermine.
	lm_set_user_have_mine(uID, lm_get_user_have_mine(uID) + int:1);
	if (cs_get_user_bpammo(uID, CSW_C4) > 0)
		// Collect for this removed lasermine.
		cs_set_user_bpammo(uID, CSW_C4, lm_get_user_have_mine(uID));
	else
		give_item(uID, "weapon_c4");	

	if (pev_valid(ownerID))
	{
		// Return to before deploy count.
		lm_set_user_mine_deployed(ownerID, lm_get_user_mine_deployed(ownerID) - int:1);
	}

	// Play sound.
	lm_play_sound(uID, SOUND_PICKUP, cs_get_user_team(ownerID));

	// Set Flag. end progress.
	lm_set_user_deploy_state(uID, int:STATE_DEPLOYED);

	// Refresh show ammo.
	show_ammo(uID);

	ExecuteForward(g_forward[E_FWD_ONPICKUP_POST], iRet, uID);
	return;
}


//====================================================
// Check: Remove Lasermine.
//====================================================
bool:check_for_remove(id)
{
	new int:cvar_ammo		= int:gCvar[CVAR_MAX_HAVE];
	new PICKUP_MODE:pickup 	= PICKUP_MODE:gCvar[CVAR_ALLOW_PICKUP];
	// common check.
	if (check_for_common(id))
		return false;

	// have max ammo? (use buy system.)
	if (gCvar[CVAR_BUY_MODE] != 0)
	if (lm_get_user_have_mine(id) + int:1 > cvar_ammo) 
		return false;

	new target;
	new body;
	new Float:vOrigin[3];
	new Float:tOrigin[3];

	get_user_aiming(id, target, body);

	// is valid target entity?
	if(!pev_valid(target))
		return false;

	// get potision. player and target.
	pev(id, pev_origin, vOrigin);
	pev(target, pev_origin, tOrigin);

	// Distance Check. far 128.0 (cm?)
	if(get_distance_f(vOrigin, tOrigin) > 128.0)
		return false;
	
	new entityName[MAX_NAME_LENGTH];
	lm_get_entity_class_name(target, entityName, charsmax(entityName));

	// is target lasermine?
	if(!equali(entityName, ENT_CLASS_LASER))
		return false;

	switch(pickup)
	{
		case DISALLOW_PICKUP:
		{
			cp_cant_pickup(id);
			return false;
		}
		case ONLY_ME:
		{
			// is owner you?
			if(pev(target, LASERMINE_OWNER) != id)
				return false;
		}
		case ALLOW_FRIENDLY:
		{
			// is team friendly?
			if(lm_get_laser_team(target) != cs_get_user_team(id))
				return false;
		}
	}

	// Allow Enemy.
	return true;
}

//====================================================
// Lasermine Think Event.
//====================================================
public LaserThink(iEnt)
{
	// Check plugin enabled.
	if (!gCvar[CVAR_ENABLE])
		return HAM_IGNORED;

	// is valid this entity?
	if (!pev_valid(iEnt))
		return HAM_IGNORED;

	new entityName[MAX_NAME_LENGTH];
	lm_get_entity_class_name(iEnt, entityName, charsmax(entityName));

	// is this lasermine? no.
	if (!equali(entityName, ENT_CLASS_LASER))
		return HAM_IGNORED;

	static Float:fCurrTime;
	static Float:vEnd[3];
	static TRIPMINE_THINK:step;

	fCurrTime = get_gametime();
	step = TRIPMINE_THINK:pev(iEnt, LASERMINE_STEP);

	// Get Laser line end potision.
	pev(iEnt, LASERMINE_BEAMENDPOINT1, vEnd);
	// Get owner id.
	new iOwner	= pev(iEnt, LASERMINE_OWNER);

	// lasermine state.
	switch(step)
	{
		// Power up.
		case POWERUP_THINK:
		{
			lm_step_powerup(iEnt, fCurrTime);
		}
		case BEAMUP_THINK:
		{
			lm_step_beamup(iEnt, vEnd, fCurrTime);
		}
		// Laser line activated.
		case BEAMBREAK_THINK:
		{
			lm_step_beambreak(iEnt, vEnd, fCurrTime);
		}
		case EXPLOSE_THINK:
		{
			// Stopping sound.
			lm_play_sound(iEnt, SOUND_STOP, cs_get_user_team(iOwner));
			// Effect Explosion.
			lm_step_explosion(iEnt, iOwner);
		}
	}

	return HAM_IGNORED;
}

//====================================================
// Lasermine Power up Step.
//====================================================
lm_step_powerup(iEnt, Float:fCurrTime)
{
	new Float:fPowerupTime;
	pev(iEnt, LASERMINE_POWERUP, fPowerupTime);
	// over power up time.
		
	if (fCurrTime > fPowerupTime)
	{
		// next state.
		set_pev(iEnt, LASERMINE_STEP, BEAMUP_THINK);
		// activate sound.
		lm_play_sound(iEnt, SOUND_ACTIVATE, lm_get_laser_team(iEnt));
	}

	mine_glowing(iEnt);

	// Think time.
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
}

//====================================================
// Lasermine Beam up Step.
//====================================================
lm_step_beamup(iEnt, Float:vEnd[3], Float:fCurrTime)
{
	// solid complete.
	set_pev(iEnt, pev_solid, SOLID_BBOX);
	// drawing laser line.
	if (gCvar[CVAR_LASER_VISIBLE])
	{
		new beam = draw_laserline(iEnt, vEnd);
		set_pev(iEnt, LASERMINE_BEAM, beam);
		if(gCvar[CVAR_REALISTIC_DETAIL])
			lm_draw_spark_for_wall(vEnd);
	}

	// next state.
	set_pev(iEnt, LASERMINE_STEP, BEAMBREAK_THINK);
	// Think time.
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
}

//====================================================
// Lasermine Laser hit Step.
//====================================================
lm_step_beambreak(iEnt, Float:vEnd[3], Float:fCurrTime)
{
	static Array:aTarget;
	static className[MAX_NAME_LENGTH];
	static hPlayer[HIT_PLAYER];
	static iOwner;
	static iTarget;
	static hitGroup;
	static trace;
	static Float:fFraction;
	static Float:vOrigin	[3];
	static Float:vHitPoint	[3];
	static Float:nextTime = 0.0;
	static Float:beamTime = 0.0;

	// Get this mine position.
	pev(iEnt, pev_origin, 			vOrigin);
	pev(iEnt, LASERMINE_COUNT, 		nextTime);
	pev(iEnt, LASERMINE_BEAMTHINK, 	beamTime);
	iOwner = pev(iEnt, LASERMINE_OWNER);

	if (fCurrTime > beamTime)
	{
		// if (gCvar[CVAR_LASER_VISIBLE])
		// 	draw_laserline(iEnt, vEnd);

		set_pev(iEnt, LASERMINE_BEAMTHINK, fCurrTime + random_float(0.1, 0.2));
	}

	if (gCvar[CVAR_LASER_DMG_MODE])
	{
		if (fCurrTime < nextTime)
		{
			// Think time.
			set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
			return false;
		}
	}

	aTarget = ArrayCreate(HIT_PLAYER);

	// create the trace handle.
	trace = create_tr2();

	fFraction	= 0.0;
	iTarget	= iEnt;
	ArrayClear(aTarget);
	vHitPoint = vOrigin;
	set_pev(iEnt, LASERMINE_COUNT, get_gametime());

	// Trace line
	while(fFraction < 1.0)
	{
		// Trace line
		engfunc(EngFunc_TraceLine, vHitPoint, vEnd, DONT_IGNORE_MONSTERS, iTarget, trace);
		{
			get_tr2(trace, TR_flFraction, fFraction);
			get_tr2(trace, TR_vecEndPos, vHitPoint);				
			iTarget		= get_tr2(trace, TR_pHit);
			hitGroup	= get_tr2(trace, TR_iHitgroup);

			if(gCvar[CVAR_REALISTIC_DETAIL]) 
				lm_draw_spark_for_wall(vHitPoint);
		}

		// Something has passed the laser.
		if (fFraction < 1.0)
		{
			// is valid hit entity?
			if (pev_valid(iTarget))
			{
				pev(iTarget, pev_classname, className, charsmax(className));
				if (equali(className, ENT_CLASS_BREAKABLE) || equali(className, ENT_CLASS_LASER))
				{
					hPlayer[I_TARGET] 	= iTarget;
					hPlayer[V_POSITION]	= _:vHitPoint;
					hPlayer[I_HIT_GROUP]= hitGroup;
					ArrayPushArray(aTarget, hPlayer);
					continue;
				}
				#if defined BIOHAZARD_SUPPORT
				if (equali(className, "player_model"))
					iTarget = pev(iTarget, pev_owner);
				#endif
				// is user?
				if (!(pev(iTarget, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)) && !IsPlayer(iTarget))
					continue;

				// is dead?
				if (!is_user_alive(iTarget))
					continue;

				if (g_players[iTarget])
				{
					// Hit friend and No FF.
					if (!is_valid_takedamage(iOwner, iTarget))
						continue;
					// is godmode?
					if (lm_is_user_godmode(iTarget))
						continue;
				}

				hPlayer[I_TARGET] 	= iTarget;
				hPlayer[V_POSITION]	= _:vHitPoint;
				hPlayer[I_HIT_GROUP]= hitGroup;
				ArrayPushArray(aTarget, hPlayer);

				if (hitGroup == HIT_SHIELD && gCvar[CVAR_DIFENCE_SHIELD])
					break;

				// keep target id.
				set_pev(iEnt, pev_enemy, iTarget);
			}
			else
			{
				continue;
			}
		}
	}

	static arraysize;
	arraysize = ArraySize(aTarget);
	if (gCvar[CVAR_MODE] == MODE_TRIPMINE)
	{
		for (new n = 0; n < arraysize; n++)
		{
			ArrayGetArray(aTarget, n, hPlayer);
			if (IsPlayer(hPlayer[I_TARGET]))
			{
				// State change. to Explosing step.
				set_pev(iEnt, LASERMINE_STEP, EXPLOSE_THINK);
				break;
			}
		}					
	}
	else
	{
		static Float:vEndPosition[3];
		for (new n = 0; n < arraysize; n++)
		{
			ArrayGetArray(aTarget, n, hPlayer);
			xs_vec_copy(hPlayer[V_POSITION], vEndPosition);

			if (gCvar[CVAR_LASER_FENCE])
				// Laser reflect.
				lm_fence_laser(hPlayer[I_TARGET]);

			// Laser line damage mode. Once or Second.
			create_laser_damage(iEnt, hPlayer[I_TARGET], hPlayer[I_HIT_GROUP], hPlayer[V_POSITION]);
		}					

		// Laser line damage mode. Once or Second.
		if (gCvar[CVAR_LASER_DMG_MODE] != 0)
		{
			if (arraysize > 0)
				set_pev(iEnt, LASERMINE_COUNT, (nextTime + gCvar[CVAR_LASER_DMG_DPS]));

			// if change target. keep target id.
			if (pev(iEnt, LASERMINE_HITING) != iTarget)
				set_pev(iEnt, LASERMINE_HITING, iTarget);
		}
	}

	// free the trace handle.
	free_tr2(trace);
	ArrayDestroy(aTarget);

	// Get mine health.
	static Float:iHealth;
	iHealth = lm_get_user_health(iEnt);

	// break?
	if (iHealth <= 0.0 || (pev(iEnt, pev_flags) & FL_KILLME))
	{
		// next step explosion.
		set_pev(iEnt, LASERMINE_STEP, EXPLOSE_THINK);
//		client_print(iOwner, print_chat, "[DEBUG] LM EXPLODE. %f", iHealth);
	}
				
	// Think time. random_float = laser line blinking.
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);

	return true;

}

//====================================================
// Lasermine Explosion Step.
//====================================================
lm_step_explosion(iEnt, iOwner)
{
	// Stopping entity to think
	set_pev(iEnt, pev_nextthink, 0.0);

	// Count down. deployed lasermines.
	lm_set_user_mine_deployed(iOwner, lm_get_user_mine_deployed(iOwner) - int:1);

	// Stop laser line.
	lm_stop_laserline(iEnt);

	// effect explosion.
	static Float:fDamageMax;
	static Float:fDamageRadius;
	static Float:vOrigin[3];
	static Float:vDecals[3];
	static CsTeams:team;
	fDamageMax 		= gCvar[CVAR_EXPLODE_DMG];
	fDamageRadius	= gCvar[CVAR_EXPLODE_RADIUS];
	pev(iEnt, pev_origin, vOrigin);
	pev(iEnt, LASERMINE_DECALS, vDecals);
	team = lm_get_laser_team(iEnt);

	if(engfunc(EngFunc_PointContents, vOrigin) != CONTENTS_WATER) 
	{
		new sprExp1 = lm_get_sprites_cell(EXPLOSION_1, team);
		new sprExp2 = lm_get_sprites_cell(EXPLOSION_2, team);
		new sprBlast= lm_get_sprites_cell(BLAST, team);
		new sprSmoke= lm_get_sprites_cell(SMOKE, team);
		lm_create_explosion	(vOrigin, fDamageMax, fDamageRadius, sprExp1, sprExp2, sprBlast);
		lm_create_smoke		(vOrigin, fDamageMax, fDamageRadius, sprSmoke);
	}
	else 
	{
		new sprExpW = lm_get_sprites_cell(EXPLOSION_WATER, team);
		new sprExpB = lm_get_sprites_cell(BUBBLE, team);
		lm_create_water_explosion(vOrigin, fDamageMax, fDamageRadius, sprExpW);
		lm_create_bubbles(vOrigin, fDamageMax * 1.0, fDamageRadius * 1.0, sprExpB);
	}
	lm_create_explosion_decals(vDecals);

	// damage.
	lm_create_explosion_damage(iEnt, iOwner, fDamageMax, fDamageRadius);

	// remove this.
	lm_remove_entity(iEnt);
}

//====================================================
// Drawing Laser line.
//====================================================
draw_laserline(iEnt, const Float:vEndOrigin[3])
{
	new Float:tcolor	[3];
	new sRGB			[13];
	new sColor			[4];
	new sRGBLen 		= charsmax(sRGB);
	new sColorLen		= charsmax(sColor);
	new CsTeams:teamid 	= lm_get_laser_team(iEnt);
	new Float:width 	= gCvar[CVAR_LASER_WIDTH];
	new i = 0, n = 0, iPos = 0;
	// Color mode. 0 = team color.
	if(gCvar[CVAR_LASER_COLOR] == 0)
	{
		switch(teamid)
		{
			case CS_TEAM_T:
				copy(sRGB, sRGBLen, gCvar[CVAR_LASER_COLOR_TR]);
			case CS_TEAM_CT:
				copy(sRGB, sRGBLen, gCvar[CVAR_LASER_COLOR_CT]);
			default:
#if !defined BIOHAZARD_SUPPORT
				formatex(sRGB, sRGBLen, "0,255,0");
#else
				formatex(sRGB, sRGBLen, "255,0,0");
#endif
		}

	}else
	{
		// Green.
		formatex(sRGB, sRGBLen, "0,255,0");
	}

	formatex(sRGB, sRGBLen, "%s%s", sRGB, ",");
	while(n < sizeof(tcolor))
	{
		i = split_string(sRGB[iPos += i], ",", sColor, sColorLen);
		tcolor[n++] = str_to_float(sColor);
	}
	/*
	stock lm_draw_laser(
		const iEnt,
		const Float:vEndOrigin[3], 
		const beam, 
		const framestart	= 0, 
		const framerate		= 0, 
		const life			= 1, 
		const width			= 1, 
		const wave			= 0, 
		const tcolor		[3],
		const bright		= 255,
		const speed			= 255
	)
	*/
	new szValue[MAX_RESOURCE_PATH_LENGTH];
	lm_get_sprites_path(LASER, teamid, szValue, charsmax(szValue));

	return lm_draw_laser(iEnt, vEndOrigin, szValue, 0, 0, width, 0, tcolor, gCvar[CVAR_LASER_BRIGHT], 0.1);
}

//====================================================
// Laser damage
//====================================================
create_laser_damage(iEnt, iTarget, hitGroup, Float:hitPoint[])
{
	// Damage.
	static Float:dmg;	dmg 		= gCvar[CVAR_LASER_DMG];
	static iAttacker;	iAttacker 	= pev(iEnt,LASERMINE_OWNER);
	static CsTeams:team;team 		= lm_get_laser_team(iEnt);

	if (!is_user_alive(iTarget))
		return;

	new iRet;
	ExecuteForward(g_forward[E_FWD_ONHIT_PRE], iRet, iTarget, iAttacker, iEnt, floatround(dmg));

	if (gCvar[CVAR_DIFENCE_SHIELD] && hitGroup == HIT_SHIELD)
	{
		lm_play_sound(iTarget, SOUND_HIT_SHIELD, team);
		lm_draw_spark(hitPoint);
		lm_hit_shield(iTarget, dmg);
	}
	else
	{
		if (IsPlayer(iTarget))
		{
			lm_play_sound(iTarget, SOUND_HIT, team);
			lm_set_user_lasthit(iTarget, hitGroup);
			if (gCvar[CVAR_VIOLENCE_HBLOOD])
			{
				static sprBloodSpray;  sprBloodSpray  = lm_get_sprites_cell(BLOOD_SPRAY, team);
				static sprBloodSplash; sprBloodSplash = lm_get_sprites_cell(BLOOD_SPLASH, team);
				lm_create_hblood(hitPoint, floatround(dmg), sprBloodSpray, sprBloodSplash);
			}

			if (!is_user_bot(iTarget))
			{
				if (g_players[iAttacker] && !g_players[iTarget])
					dmg = 99999999.0;
			}
		}
		// Other target entities.
		ExecuteHamB(Ham_TakeDamage, iTarget, iEnt, iAttacker, dmg, DMG_ENERGYBEAM);
	}
	set_pev(iEnt, LASERMINE_HITING, iTarget);
	ExecuteForward(g_forward[E_FWD_ONHIT_POST], iRet, iTarget, iAttacker, iEnt, floatround(dmg));

	return;
}

//====================================================
// Player killing (Set Money, Score)
//====================================================
public PlayerKilling(iVictim, inflictor, iAttacker, Float:damage, bits)
{
	static entityName[MAX_NAME_LENGTH];
	lm_get_entity_class_name(inflictor, entityName, charsmax(entityName));
	//
	// Refresh Score info.
	//
	if (equali(entityName, ENT_CLASS_LASER) && is_user_alive(iVictim))
	{
		// Triggers a damage event on a custom weapon, adding it to the internal stats.
		// This will also call the client_damage() and client_kill() forwards if applicable.
		// For a list of possible body hitplaces see the HIT_* constants in amxconst.inc
		if (damage > 0.0)
			custom_weapon_dmg(gWeaponId, iAttacker, iVictim, floatround(damage), lm_get_user_lasthit(iVictim));		

		if (lm_get_user_health(iVictim) - damage > 0.0)
			return HAM_IGNORED;

#if !defined ZP_SUPPORT && !defined BIOHAZARD_SUPPORT
		// Get Target Team.
		new CsTeams:aTeam = cs_get_user_team(iAttacker);
		new CsTeams:vTeam = cs_get_user_team(iVictim);

		new score  = (vTeam != aTeam) ? 1 : -1;
#endif

		// Attacker Frag.
		// Add Attacker Frag (Friendly fire is minus).
		// new aDeath	= cs_get_user_deaths(iAttacker);

		// cs_set_user_deaths(iAttacker, aDeath, false);
		// ExecuteHamB(Ham_AddPoints, iAttacker, score, true);

		new tDeath = cs_get_user_deaths(iVictim);

		cs_set_user_deaths(iVictim, tDeath);
//		ExecuteHamB(Ham_AddPoints, iVictim, 0, true);

#if !defined ZP_SUPPORT && !defined BIOHAZARD_SUPPORT
		// Get Money attacker.
		new money  = gCvar[CVAR_FRAG_MONEY] * score;
		cs_set_user_money(iAttacker, cs_get_user_money(iAttacker) + money);
#endif

//		ExecuteHamB(Ham_Killed, iVictim, iAttacker, 0);
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}

#if !defined ZP_SUPPORT
//====================================================
// Buy Lasermine.
//====================================================
public lm_buy_lasermine(id)
{	
	if (check_for_buy(id))
		return PLUGIN_CONTINUE;

	new cost = gCvar[CVAR_COST];
	new amount = 1;
	new iRet;
	ExecuteForward(g_forward[E_FWD_ONBUY_PRE], iRet, id, amount, cost); 
	cost = cs_get_user_money(id) - cost;
	cs_set_user_money(id, cost);
	lm_set_user_have_mine(id, lm_get_user_have_mine(id) + int:amount);

	if (cs_get_user_bpammo(id, CSW_C4) <= 0)
		give_item(id, "weapon_c4");	

	cs_set_user_bpammo(id, CSW_C4, lm_get_user_have_mine(id));

	cp_bought(id);

	lm_play_sound(id, SOUND_PICKUP, cs_get_user_team(id));

	show_ammo(id);
	ExecuteForward(g_forward[E_FWD_ONBUY_POST], iRet, id, amount, cost); 

	return PLUGIN_HANDLED;
}
#endif

//====================================================
// Show ammo.
//====================================================
show_ammo(id)
{ 
	if (gCvar[CVAR_BUY_MODE] != 0)
		client_print(id, print_center, "%L", id, LANG_KEY[STATE_AMMO], lm_get_user_have_mine(id), gCvar[CVAR_MAX_HAVE]);
	else
		client_print(id, print_center, "%L", id, LANG_KEY[STATE_INF]);
} 

//====================================================
// Chat command.
//====================================================
public lm_say_lasermine(id)
{
	if(!gCvar[CVAR_ENABLE])
		return PLUGIN_CONTINUE;

	new said[32];
	read_argv(1, said, charsmax(said));
	
	if (equali(said,"/buy lasermine") || equali(said,"/lm"))
	{
#if defined ZP_SUPPORT
		zp_items_force_buy(id, gZpWeaponId);
#else
		lm_buy_lasermine(id);
#endif
	}

#if !defined ZP_SUPPORT
	else
	if (equali(said, "lasermine") || equali(said, "/lasermine"))
	{
		const SIZE = 1024;
		new msg[SIZE + 1], len = 0;
		len += formatex(msg[len], SIZE - len, "<html><head><style>body{background-color:gray;color:white;} table{border-color:black;}</style></head><body>");
		len += formatex(msg[len], SIZE - len, "<p><b>Laser/TripMine Entity v%s</b></p>", VERSION);
		len += formatex(msg[len], SIZE - len, "<p>You can be setting the mine on the wall.</p>");
		len += formatex(msg[len], SIZE - len, "<p>That laser will give what touched it damage.</p>");
		len += formatex(msg[len], SIZE - len, "<p><b>Commands</b></p>");
		len += formatex(msg[len], SIZE - len, "<table border='1' cellspacing='0' cellpadding='10'>");
		len += formatex(msg[len], SIZE - len, "<tr><td>say</td><td><b>/buy lasermine</b> or <b>/lm</td><td rowspan='2'>buying lasermine</td></tr>");
		len += formatex(msg[len], SIZE - len, "<tr><td>console</td><td><b>buy_lasermine</b></td></tr>");
		len += formatex(msg[len], SIZE - len, "<tr><tr><td rowspan='2'>bind</td><td><b>+setlaser</b></td><td>bind j +setlaser :using j set lasermine on wall.</td></tr>");
		len += formatex(msg[len], SIZE - len, "<tr><td><b>+dellaser</b></td><td>bind k +dellaser :using k remove lasermine.</td></tr>");
		len += formatex(msg[len], SIZE - len, "</table>");
		len += formatex(msg[len], SIZE - len, "</body></html>");
		show_motd(id, msg, "Lasermine Entity help");

		return PLUGIN_HANDLED;

	} else 
	if (containi(said, "laser") != -1) 
	{
		cp_refer(id);
		return PLUGIN_CONTINUE;
	}
#endif
	return PLUGIN_CONTINUE;
}

//====================================================
// Player Cmd Start event.
// Stop movement for mine deploying.
//====================================================
public PlayerCmdStart(id, handle, random_seed)
{
	// Not alive
	if(!is_user_alive(id) || is_user_bot(id))
		return FMRES_IGNORED;

	// Get user old and actual buttons
	static buttons, buttonsChanged, buttonPressed, buttonReleased, iOldButton;
    buttons 		= get_uc(handle, UC_Buttons);
    buttonsChanged 	= get_ent_data(id, "CBasePlayer", "m_afButtonLast") ^ buttons;
    buttonPressed 	= buttonsChanged & buttons;
    buttonReleased 	= buttonsChanged & ~buttons;
	iOldButton 		= get_user_oldbutton(id);

	if (buttonPressed & IN_USE)
	{
		lm_progress_remove(id);
		return FMRES_IGNORED;
	} else if (buttonReleased & IN_USE)
	{
		lm_progress_stop(id);
		return FMRES_IGNORED;
	}

	if (!lm_get_user_have_mine(id))
		return FMRES_IGNORED;

	if (get_user_weapon(id) != CSW_C4) 
		return FMRES_IGNORED;

	static weapon; weapon = cs_get_user_weapon_entity(id);
	new Float:idle = get_ent_data_float(weapon, "CBasePlayerWeapon", "m_flTimeWeaponIdle");
	if (idle <= 0.0 && lm_deploy_status(id) == _:STATE_IDLE)
		UTIL_PlayWeaponAnimation(id, random_num(TRIPMINE_IDLE1, TRIPMINE_ARM1));

	if (buttonPressed & IN_ATTACK2)
	{
		UTIL_PlayWeaponAnimation(id, TRIPMINE_FIDGET);
		set_ent_data_float(weapon, "CBasePlayerWeapon", "m_flTimeWeaponIdle", 2.5);
		return FMRES_IGNORED;
	} else if (buttonReleased & IN_ATTACK2) 
	{
		return FMRES_IGNORED;
	}

	if (buttonPressed & IN_ATTACK)
	{
		if (!(iOldButton & IN_ATTACK) && check_for_deploy(id))
		{
			UTIL_PlayWeaponAnimation(id, TRIPMINE_ARM2);
			// emit_sound(id, CHAN_WEAPON, ENT_SOUNDS[SND_CM_ATTACK], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

			lm_progress_deploy(id);
			lm_deploy_status(id);
			if (cs_get_user_bpammo(id, CSW_C4) <= 0)
				ExecuteHam(Ham_Weapon_RetireWeapon, cs_get_user_weapon_entity(id));
//			else
		}
		return FMRES_IGNORED;

	} else if (buttonReleased & IN_ATTACK) 
	{
		if (iOldButton & IN_ATTACK)
		{
			// emit_sound(id, CHAN_WEAPON, ENT_SOUNDS[SND_CM_DRAW], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			static int:now_state;
			now_state = lm_get_user_deploy_state(id);
			lm_progress_stop(id);
			lm_set_user_deploy_state(id, now_state);
			lm_deploy_status(id);

			if (cs_get_user_bpammo(id, CSW_C4) <= 0)
				ExecuteHam(Ham_Weapon_RetireWeapon, cs_get_user_weapon_entity(id));
	//		else
				// UTIL_PlayWeaponAnimation(id, TRIPMINE_DRAW);
			return FMRES_IGNORED;
		}
	} else if (buttons & IN_ATTACK)
	{
		// if (int:lm_deploy_status(id) == STATE_IDLE)
		// {
		// 	set_uc(handle, UC_Buttons, buttons & ~IN_ATTACK);
		// }
		return FMRES_IGNORED;
	}
	return FMRES_IGNORED;
}

public lm_deploy_status(id)
{
	new stats = lm_get_user_deploy_state(id);
	switch (stats)
	{
		case STATE_IDLE:
		{
			new Float:speed = lm_get_user_max_speed(id);
			set_pdata_float(cs_get_user_weapon_entity(id), 35, 0.0);
			UTIL_PlayWeaponAnimation(id, random_num(TRIPMINE_IDLE1, TRIPMINE_ARM1));
			new bool:now_speed = (speed <= 2.0);
			if (now_speed)
				ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);				
		}
		case STATE_DEPLOYING:
		{
			if (pev_valid(gDeployingMines[id]))
			{
				// Vector settings.
				static	Float:vOrigin[3], Float:vViewOfs[3];
				static	Float:vNewOrigin[3],Float:vNormal[3],
						Float:vTraceEnd[3],Float:vEntAngles[3];

				// Get wall position.
				velocity_by_aim(id, 128, vTraceEnd);
				// get user position.
				pev(id, pev_origin, vOrigin);
				pev(id, pev_view_ofs, vViewOfs);
				xs_vec_add(vOrigin, vViewOfs, vOrigin);  	
				xs_vec_add(vTraceEnd, vOrigin, vTraceEnd);

			    // create the trace handle.
				static trace;
				trace = create_tr2();

				// get wall position to vNewOrigin.
				engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, IGNORE_MONSTERS, id, trace);
				{
					// -- We hit something!
					// -- Save results to be used later.
					get_tr2(trace, TR_vecEndPos, vTraceEnd);
					get_tr2(trace, TR_vecPlaneNormal, vNormal);

					if (xs_vec_distance(vOrigin, vTraceEnd) < 128.0)
					{
						xs_vec_mul_scalar(vNormal, 8.0, vNormal);
						xs_vec_add(vTraceEnd, vNormal, vNewOrigin);
						// set entity position.
						engfunc(EngFunc_SetOrigin, gDeployingMines[id], vNewOrigin);
						// Rotate tripmine.
						vector_to_angle(vNormal, vEntAngles);
						// set angle.
						set_pev(gDeployingMines[id], pev_angles, vEntAngles);
					}
					else
					{
						lm_progress_stop(id);
					}

				}
				// free the trace handle.
				free_tr2(trace);
			}			
			lm_set_user_max_speed(id, 1.0);
		}
		case STATE_PICKING:
		{
			lm_set_user_max_speed(id, 1.0);
		}
		case STATE_DEPLOYED:
		{
			ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
			UTIL_PlayWeaponAnimation(id, TRIPMINE_DRAW);
			lm_set_user_deploy_state(id, STATE_RELOAD);
			set_task_ex(RELOAD_TIME, "Reload", TASK_RELOAD + id);
		}
	}
	return stats;
}

public Reload(taskid)
{
	new id = taskid - TASK_RELOAD;
//	UTIL_PlayWeaponAnimation(id, TRIPMINE_DRAW);

	lm_set_user_deploy_state(id, STATE_IDLE);
}

//====================================================
// Player connected.
//====================================================
public client_putinserver(id)
{
	// check plugin enabled.
	if(!gCvar[CVAR_ENABLE])
		return PLUGIN_CONTINUE;

	// reset deploy count.
	lm_set_user_mine_deployed(id, int:0);
	// reset hove mine.
	lm_set_user_have_mine(id, int:0);

#if AMXX_VERSION_NUM > 183
	// Init Recycle Health.
	ClearStack(gRecycleMine[id]);
#endif
	CheckPlayer(id);

	return PLUGIN_CONTINUE;
}

//====================================================
// Player Disconnect.
//====================================================
/*
	symbol "client_disconnect" is marked as deprecated: Use client_disconnected() instead.
*/
public client_disconnected(id)
{
	// check plugin enabled.
	if(!gCvar[CVAR_ENABLE])
		return PLUGIN_CONTINUE;

	// delete task.
	delete_task(id);
	// remove all lasermine.
	lm_remove_all_entity(id, ENT_CLASS_LASER);

#if AMXX_VERSION_NUM > 183
	// Init Recycle Health.
	ClearStack(gRecycleMine[id]);
#endif

	return PLUGIN_CONTINUE;
}


//====================================================
// Infected player Deploy stop. (BIOHAZARD)
//====================================================
#if defined BIOHAZARD_SUPPORT
public event_infect2(id)
{
	delete_task(id);
	// remove all lasermine.
	lm_remove_all_entity(id, ENT_CLASS_LASER);
	// drop lasermine.
    engclient_cmd(id, "drop", "weapon_c4")
 
    new weapbox, bomb = fm_find_ent_by_class(-1, "weapon_c4")
    if (bomb && (weapbox = pev(bomb, pev_owner)) > get_maxplayers()) {
        dllfunc(DLLFunc_Think, weapbox) // will remove weaponbox + weapon_c4 entity pair
        // remove blinking red bomb mark on the radar
        message_begin(MSG_ALL, get_user_msgid("BombPickup"))
        message_end()
    }
	return PLUGIN_CONTINUE;
}
#endif

//====================================================
// Delete Task.
//====================================================
delete_task(id)
{
	if (task_exists((TASK_PLANT + id)))
		remove_task((TASK_PLANT + id));

	if (task_exists((TASK_RELEASE + id)))
		remove_task((TASK_RELEASE + id));

	lm_set_user_deploy_state(id, STATE_IDLE);

	return;
}


//====================================================
// Check: common.
//====================================================
stock ERROR:check_for_common(id)
{
	new cvar_enable = gCvar[CVAR_ENABLE];
	new cvar_access = gCvar[CVAR_ACCESS_LEVEL];
	new user_flags	= get_user_flags(id) & ADMIN_ACCESSLEVEL;
	new is_alive	= is_user_alive(id);
	//new cvar_mode	= gCvar[CVAR_MODE];

	// Plugin Enabled
	if (!cvar_enable)
		return show_error_message(id, ERROR:E_NOT_ACTIVE);

	// Can Access.
	if (cvar_access != 0 && !user_flags) 
		return show_error_message(id, ERROR:E_NOT_ACCESS);

	// Is this player Alive?
	if (!is_alive) 
		return show_error_message(id, ERROR:E_NOT_ALIVE);

	// Can set Delay time?
	return ERROR:check_for_time(id);
}

//====================================================
// Check: Can use this time.
//====================================================
stock ERROR:check_for_time(id)
{
	new cvar_delay = floatround(gCvar[CVAR_START_DELAY]);

	// gametime - playertime = delay count.
	new nowTime = floatround(get_gametime()) - floatround(lm_get_user_delay_count(id));

	// check.
	if(nowTime >= cvar_delay)
		return ERROR:E_NONE;

	return show_error_message(id, ERROR:E_DELAY_TIME, nowTime);
}

//====================================================
// Check: Can use this Team.
//====================================================
stock bool:check_for_team(id)
{
	new arg[7];
	new CsTeams:team;

	// Get Cvar
	copy(arg, charsmax(arg), gCvar[CVAR_CBT]);

	// Terrorist
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "Z")  || equali(arg, "Zombie"))
#else
	if(equali(arg, "TR") || equali(arg, "T"))
#endif
		team = CS_TEAM_T;
	else
	// Counter-Terrorist
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "H") || equali(arg, "Human"))
#else
	if(equali(arg, "CT"))
#endif
		team = CS_TEAM_CT;
	else
	// All team.
#if defined BIOHAZARD_SUPPORT
	if(equali(arg, "ZH") || equali(arg, "HZ") || equali(arg, "ALL"))
#else
	if(equali(arg, "ALL"))
#endif
		team = CS_TEAM_UNASSIGNED;
	else
		team = CS_TEAM_UNASSIGNED;

	// Cvar setting equal your team? Not.
	if(team != CS_TEAM_UNASSIGNED && team != cs_get_user_team(id))
		return false;

	return true;
}

//====================================================
// Check: Can buy.
//====================================================
stock ERROR:check_for_buy(id)
{
	new int:cvar_buymode= int:gCvar[CVAR_BUY_MODE];
	new int:cvar_maxhave= int:gCvar[CVAR_MAX_HAVE];
	new cvar_cost		= 	  gCvar[CVAR_COST];
	new cvar_buyzone	=	  gCvar[CVAR_BUY_ZONE];

	// Buy mode ON?
	if (cvar_buymode)
	{
		// Can this team buying?
		if (!check_for_team(id))
		{
#if defined ZP_SUPPORT || defined BIOHAZARD_SUPPORT
			return show_error_message(id, ERROR:E_CANT_BUY_TEAM_Z);
#else
			return show_error_message(id, ERROR:E_CANT_BUY_TEAM);
#endif
		}
		// Have Max?
		if (lm_get_user_have_mine(id) >= cvar_maxhave)
			return show_error_message(id, ERROR:E_HAVE_MAX);

		// buyzone area?
		if (cvar_buyzone && !cs_get_user_buyzone(id))
			return show_error_message(id, ERROR:E_NOT_BUYZONE);

		// Have money?
		if (cs_get_user_money(id) < cvar_cost)
			return show_error_message(id, ERROR:E_NO_MONEY);


	} else {
		return show_error_message(id, ERROR:E_CANT_BUY);
	}

	return ERROR:E_NONE;
}

//====================================================
// Check: Max Deploy.
//====================================================
stock ERROR:check_for_max_deploy(id)
{
	new int:cvar_maxhave = int:gCvar[CVAR_MAX_HAVE];
	new int:cvar_teammax = int:gCvar[CVAR_TEAM_MAX];

	// Max deployed per player.
	if (lm_get_user_mine_deployed(id) >= cvar_maxhave)
		return show_error_message(id, ERROR:E_MAXIMUM_DEPLOYED);

	// Max deployed per team.
	new int:team_count = lm_get_team_deployed_count(id);

	if(team_count >= cvar_teammax || team_count >= int:(MAX_LASER_ENTITY / 2))
		return show_error_message(id, ERROR:E_MANY_PPL);

	return ERROR:E_NONE;
}

//====================================================
// Show Chat area Messages
//====================================================
stock ERROR:show_error_message(id, ERROR:err_num, any:param = 0)
{
	switch(ERROR:err_num)
	{
		case E_NOT_ACTIVE:		cp_not_active(id);
		case E_NOT_ACCESS:		cp_not_access(id);
		case E_DONT_HAVE:		cp_dont_have(id);
		case E_CANT_BUY_TEAM:	cp_cant_buy_team(id);
		case E_CANT_BUY_TEAM_Z:	cp_cant_buy_zombie(id);
		case E_CANT_BUY:		cp_cant_buy(id);
		case E_HAVE_MAX:		cp_have_max(id);
		case E_NO_MONEY:		cp_no_money(id);
		case E_MAXIMUM_DEPLOYED:cp_maximum_deployed(id);
		case E_MANY_PPL:		cp_many_ppl(id);
		case E_DELAY_TIME:		cp_delay_time(id, param);
		case E_MUST_WALL:		cp_must_wall(id);
		case E_NOT_IMPLEMENT:	cp_sorry(id);
		case E_NOT_BUYZONE:		cp_buyzone(id);
		case E_NO_ROUND:		cp_noround(id);
	}
	return err_num;
}

//====================================================
// Check: On the wall.
//====================================================
stock ERROR:check_for_onwall(id)
{
	new Float:vTraceEnd[3];
	new Float:vOrigin[3];

	// Get potision.
	pev(id, pev_origin, vOrigin);
	
	// Get wall position.
	velocity_by_aim(id, 128, vTraceEnd);
	xs_vec_add(vTraceEnd, vOrigin, vTraceEnd);

    // create the trace handle.
	new trace = create_tr2();
	new Float:fFraction = 0.0;
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, IGNORE_MONSTERS, id, trace);
	{
    	get_tr2( trace, TR_flFraction, fFraction );
    }
    // free the trace handle.
	free_tr2(trace);

	// We hit something!
	if ( fFraction < 1.0 )
		return ERROR:E_NONE;

	return show_error_message(id, ERROR:E_MUST_WALL);
}

//====================================================
// Check: Round Started
//====================================================
#if defined BIOHAZARD_SUPPORT
stock ERROR:check_round_started(id)
{
	if (gCvar[CVAR_NOROUND])
	{
		if(!game_started())
			return show_error_message(id, ERROR:E_NO_ROUND);
	}
	return ERROR:E_NONE;
}
#endif

//====================================================
// Check: Lasermine Deploy.
//====================================================
stock bool:check_for_deploy(id)
{
	// Check common.
	if (check_for_common(id))
		return false;

#if defined BIOHAZARD_SUPPORT
	// Check Started Round.
	if (check_round_started(id))
		return false;
#endif
	// Have mine? (use buy system)
	if (gCvar[CVAR_BUY_MODE] != 0)
	if (lm_get_user_have_mine(id) <= int:0) 
	{
		show_error_message(id, ERROR:E_DONT_HAVE);
		return false;
	}

	// Max deployed?
	if (check_for_max_deploy(id))
		return false;
	
	// On the wall?
	if (check_for_onwall(id))
		return false;

	// IDLE?
	if (lm_get_user_deploy_state(id) != STATE_IDLE)
		return false;

	return true;
}

//====================================================
// Mine Glowing
//====================================================
stock mine_glowing(iEnt)
{
	new Float:tcolor[3];
	new sRGB	[13];
	new sColor	[4];
	new sRGBLen 	= charsmax(sRGB);
	new sColorLen	= charsmax(sColor);
	new CsTeams:teamid = lm_get_laser_team(iEnt);

	new i = 0, n = 0, iPos = 0;

	// Glow mode.
	if (gCvar[CVAR_MINE_GLOW] != 0)
	{
		// Color setting.
		if (gCvar[CVAR_MINE_GLOW_MODE] == 0)
		{
			// Team color.
			switch (teamid)
			{
				case CS_TEAM_T:
					copy(sRGB, sRGBLen, gCvar[CVAR_MINE_GLOW_TR]);
				case CS_TEAM_CT:
					copy(sRGB, sRGBLen, gCvar[CVAR_MINE_GLOW_CT]);
				default:
					formatex(sRGB, sRGBLen, "0,255,0");
			} 
		}
		else
		{
			formatex(sRGB, sRGBLen, "0,255,0");
		}

		formatex(sRGB, sRGBLen, "%s%s", sRGB, ",");
		while(n < sizeof(tcolor))
		{
			i = split_string(sRGB[iPos += i], ",", sColor, sColorLen);
			tcolor[n++] = float(str_to_num(sColor));
		}
		lm_set_glow_rendering(iEnt, kRenderFxGlowShell, tcolor, kRenderNormal, 5);
	}
}

//====================================================
// ShowInfo Hud Message
//====================================================
public MinesShowInfo(Float:vStart[3], Float:vEnd[3], Conditions, id, iTrace)
{ 
	static iHit, szName[MAX_NAME_LENGTH], iOwner, Float:health;
	static hudMsg[64];
	iHit = get_tr2(iTrace, TR_pHit);

	if (pev_valid(iHit))
	{
		if (lm_is_user_alive(iHit))
		{
			lm_get_entity_class_name(iHit, szName, charsmax(szName));

			if (equali(szName, ENT_CLASS_LASER))
			{
				iOwner = pev(iHit, LASERMINE_OWNER);
				health = lm_get_user_health(iHit);

				get_user_name(iOwner, szName, charsmax(szName));
				formatex(hudMsg, charsmax(hudMsg), "%L", id, LANG_KEY[MINE_HUD], szName, floatround(health), floatround(gCvar[CVAR_MINE_HEALTH]));

				// set_hudmessage(red = 200, green = 100, blue = 0, Float:x = -1.0, Float:y = 0.35, effects = 0, Float:fxtime = 6.0, Float:holdtime = 12.0, Float:fadeintime = 0.1, Float:fadeouttime = 0.2, channel = -1)
				set_hudmessage(50, 100, 150, -1.0, 0.60, 0, 6.0, 0.4, 0.0, 0.0, -1);
				show_hudmessage(id, hudMsg);
			}
		}
    }

	return FMRES_IGNORED;
}

//====================================================
// Blocken Mines.
//====================================================
public MinesTakeDamage(victim, inflictor, attacker, Float:f_Damage, bit_Damage)
{
	new entityName[MAX_NAME_LENGTH];
	lm_get_entity_class_name(victim, entityName, charsmax(entityName));

	// is this lasermine? no.
	if (!equali(entityName, ENT_CLASS_LASER))
		return HAM_IGNORED;

	// We get the ID of the player who put the mine.
	new iOwner = pev(victim, LASERMINE_OWNER);

	switch(gCvar[CVAR_MINE_BROKEN])
	{
		// 0 = mines.
		case 0:
		{
			// If the one who set the mine does not coincide with the one who attacked it, then we stop execution.
			if(iOwner != attacker)
				return HAM_SUPERCEDE;
		}
		// 1 = team.
		case 1:
		{
			// If the team of the one who put the mine and the one who attacked match.
			if(lm_get_laser_team(victim) != cs_get_user_team(attacker))
				return HAM_SUPERCEDE;
		}
		// 2 = Enemy.
		case 2:
		{
			return HAM_IGNORED;
		}
		// 3 = Enemy Only.
		case 3:
		{
			if(iOwner == attacker || lm_get_laser_team(victim) == cs_get_user_team(attacker))
				return HAM_SUPERCEDE;
		}
		default:
		{
			return HAM_IGNORED;
		}
	}
	return HAM_IGNORED;
}

//====================================================
// Mines Take Damaged.
//====================================================
public MinesTakeDamaged(victim, inflictor, attacker, Float:f_Damage, bit_Damage)
{
	new entityName[MAX_NAME_LENGTH];
	lm_get_entity_class_name(victim, entityName, charsmax(entityName));

    // is this lasermine? no.
	if (!equali(entityName, ENT_CLASS_LASER))
		return HAM_IGNORED;

	if (gCvar[CVAR_MINE_GLOW_MODE] == 2)
		IndicatorGlow(victim);

#if defined ZP_SUPPORT
	zp_mines_breaked(attacker, victim);
#endif
    return HAM_IGNORED;
}

//====================================================
// Admin: Remove Player Lasermine
//====================================================
public admin_remove_laser(id, level, cid) 
{ 
	if (!cmd_access(id, level, cid, 2)) 
		return PLUGIN_HANDLED;

	new arg[32];
	read_argv(1, arg, 31);
	
	new player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF);

	if (!player)
		return PLUGIN_HANDLED;

	delete_task(player); 
	lm_remove_all_entity(player, ENT_CLASS_LASER);

	new namea[MAX_NAME_LENGTH],namep[MAX_NAME_LENGTH]; 
	get_user_name(id, namea, charsmax(namea));
	get_user_name(player, namep, charsmax(namep));
	cp_all_remove(0, namea, namep);

	return PLUGIN_HANDLED; 
} 

//====================================================
// Admin: Give Player Lasermine
//====================================================
public admin_give_laser(id, level, cid) 
{ 
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	new arg[32];
	read_argv(1, arg, 31);
	
	new player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF);
	
	if (!player)
		return PLUGIN_HANDLED;

	delete_task(player);
	set_start_ammo(player);

	new namea[MAX_NAME_LENGTH], namep[MAX_NAME_LENGTH]; 
	get_user_name(id, namea, charsmax(namea)); 
	get_user_name(player, namep, charsmax(namep)); 
	cp_gave(0, namea, namep);
	return PLUGIN_HANDLED; 
} 

public CheckSpectator() 
{
	new id, szTeam[2];
	id = read_data(1);
	read_data(2, szTeam, charsmax(szTeam));

	if(lm_get_user_mine_deployed(id) > int:0) 
	{
		if (szTeam[0] == 'U' || szTeam[0] == 'S')
		{
			delete_task(id);
			lm_remove_all_entity(id, ENT_CLASS_LASER);
			new namep[MAX_NAME_LENGTH];
			get_user_name(id, namep, charsmax(namep));
			cp_remove_spec(0, namep);
		} 
     } 
}

public CheckPlayer(id)
{
	g_players[id] = false;
	if (g_library && has_reunion())
		if (_:REU_GetAuthtype(id) == 2 || is_user_bot(id))
			g_players[id] = true;
		else
			g_players[id] = false;
	else
		g_players[id] = true;
}
//====================================================
// Play sound.
//====================================================
stock lm_play_sound(iEnt, iSoundType, CsTeams:team)
{
	new szValue[MAX_RESOURCE_PATH_LENGTH] = "";

	switch (iSoundType)
	{
		case SOUND_POWERUP:
		{
			lm_get_sounds(DEPLOY, team, szValue, charsmax(szValue));
			// log_amx("[LASERMINE] EMIT SOUND => %s", szValue);
			emit_sound(iEnt, CHAN_VOICE, szValue, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			lm_get_sounds(CHARGE, team, szValue, charsmax(szValue));
			// log_amx("[LASERMINE] EMIT SOUND => %s", szValue);
			emit_sound(iEnt, CHAN_BODY , szValue, 0.2, ATTN_NORM, 0, PITCH_NORM);
		}
		case SOUND_ACTIVATE:
		{
			lm_get_sounds(ACTIVATE, team, szValue, charsmax(szValue));
			// log_amx("[LASERMINE] EMIT SOUND => %s", szValue);
			emit_sound(iEnt, CHAN_VOICE, szValue, 0.5, ATTN_NORM, 1, 75);
		}
		case SOUND_STOP:
		{
			// emit_sound(iEnt, CHAN_BODY , "", 0.2, ATTN_NORM, SND_STOP, PITCH_NORM);
			// emit_sound(iEnt, CHAN_VOICE, "", 0.5, ATTN_NORM, SND_STOP, 75);
		}
		case SOUND_PICKUP:
		{
			lm_get_sounds(PICKUP, team, szValue, charsmax(szValue));
			// log_amx("[LASERMINE] EMIT SOUND => %s", szValue);
			emit_sound(iEnt, CHAN_ITEM,	szValue, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		case SOUND_HIT:
		{
			lm_get_sounds(LASER_HIT, team, szValue, charsmax(szValue));
			// log_amx("[LASERMINE] EMIT SOUND => %s", szValue);
			emit_sound(iEnt, CHAN_WEAPON,szValue, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		case SOUND_HIT_SHIELD:
		{
			lm_get_sounds(SHIELD_HIT, team, szValue, charsmax(szValue));
			// log_amx("[LASERMINE] EMIT SOUND => %s", szValue);
			emit_sound(iEnt, CHAN_VOICE, szValue, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
	}
}

stock ClearStack(Stack:handle)
{
	new Float:health;
	while (!IsStackEmpty(handle))
	{
		PopStackCell(handle, health);
	}
}

//====================================================
// Glow for Mine health indicator.
//====================================================
stock IndicatorGlow(iEnt)
{
	new Float:color[3]   = {0.0, 255.0, 0.0};
	new Float:max_health = gCvar[CVAR_MINE_HEALTH];
	new Float:cur_health = lm_get_user_health(iEnt);
	new Float:percent	 = cur_health / max_health;

	// Red
	if (percent <= 0.5)
		color[0] = 255.0;
	else
		color[0] = 255.0 * ((1.0 - percent) * 2.0);

	// Green
	if (percent >= 0.5)
		color[1] = 255.0;
	else
		color[1] = 255.0 * (percent * 2.0);

	lm_set_glow_rendering(iEnt, kRenderFxGlowShell, color, kRenderNormal, 5);
}

public Message_TextMsg(iMsgId, iMsgDest, id)
{
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE;
	
	new szMessage[64];
	get_msg_arg_string(2, szMessage, charsmax(szMessage));
	if (equali(szMessage, "#C4_Plant_At_Bomb_Spot"))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

/// =======================================================================================
/// START Custom Weapon Lasermine
/// =======================================================================================
public OnAddToPlayerC4(const item, const player)
{
    if(pev_valid(item) && is_user_alive(player)) 	// just for safety.
    {
		if (!lm_get_user_have_mine(player))
			return PLUGIN_CONTINUE;

        message_begin( MSG_ONE, gMsgWeaponList, .player = player );
        {
            write_string("weapons/ltm/weapon_lasermine");  	// WeaponName
            write_byte(14);                   		// PrimaryAmmoID
            write_byte(1);                  		// PrimaryAmmoMaxAmount
            write_byte(-1);                   		// SecondaryAmmoID
            write_byte(-1);                   		// SecondaryAmmoMaxAmount
            write_byte(4);                    		// SlotID (0...N)
            write_byte(3);                    		// NumberInSlot (1...N)
            write_byte(CSW_C4); 	        // WeaponID
            write_byte(0);                    		// Flags
        }
        message_end();
    }
	return PLUGIN_CONTINUE;
}

public SelectLasermine(const client) 
{ 
	if (!lm_get_user_have_mine(client))
		return PLUGIN_CONTINUE;	

	if (cs_get_user_weapon(client) != CSW_C4)
	{
		engclient_cmd(client, "weapon_c4"); 
		UTIL_PlayWeaponAnimation(client, TRIPMINE_DRAW);
	}

	return PLUGIN_CONTINUE;	
} 

public OnItemSlotC4(const item)
{
	static client;
	client = get_ent_data_entity(item, "CBasePlayerItem", "m_pPlayer");

	if (is_user_alive(client))
	{
		if (!lm_get_user_have_mine(client))
			return HAM_IGNORED;

	    SetHamReturnInteger(5);
	    return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public OnSetDeployModels(const item)
{
	if(pev_valid(item) != 2)
		return HAM_IGNORED;

	static client; client = get_pdata_cbase(item, 41, 4);
	if(!is_user_alive(client))
		return HAM_IGNORED;
	if (!lm_get_user_have_mine(client))
		return PLUGIN_CONTINUE;
	if(get_pdata_cbase(client, 373) != item)
		return HAM_IGNORED;

	new szValue[MAX_RESOURCE_PATH_LENGTH];
	lm_get_models(V_WPN, cs_get_user_team(client), szValue, charsmax(szValue));
	set_pev(client, pev_viewmodel2, 	szValue);

	lm_get_models(P_WPN, cs_get_user_team(client), szValue, charsmax(szValue));
	set_pev(client, pev_weaponmodel2, 	szValue);
	UTIL_PlayWeaponAnimation(client, TRIPMINE_DRAW);

	// emit_sound(client, CHAN_WEAPON, ENT_SOUNDS[SND_CM_DRAW], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return HAM_IGNORED;
}

public OnC4Drop(const iEntity) 
{
	SetHamReturnInteger(0);
	return HAM_SUPERCEDE;
}

public weapon_change(id)
{
	if (!is_user_alive(id))
		return;
	if (is_user_bot(id))
		return;
	if (!lm_get_user_have_mine(id))
		return;
	new clip, ammo;
	if (cs_get_user_weapon(id, clip, ammo) != CSW_C4)
	{
		lm_progress_stop(id);
		lm_deploy_status(id);
	} else 
	{
		UTIL_PlayWeaponAnimation(id, TRIPMINE_DRAW);
	}
}

public OnPrimaryAttackPre(Weapon)
{
	new client = get_pdata_cbase(Weapon, 41, 4);
	
	if (get_pdata_cbase(client, 373) != Weapon)
		return HAM_IGNORED;

	return HAM_HANDLED;
}

public OnPrimaryAttackPost(Weapon)
{
	new client = get_pdata_cbase(Weapon, 41, 4);
	
	if (get_pdata_cbase(client, 373) != Weapon)
		return HAM_IGNORED;

	if (int:lm_get_user_deploy_state(client) == STATE_DEPLOYING) 
	{
//		UTIL_PlayWeaponAnimation(client, SEQ_SHOOT);
//		emit_sound(client, CHAN_WEAPON, ENT_SOUNDS[SND_CM_ATTACK], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
	set_ent_data_float(Weapon, "CBasePlayerWeapon", "m_flNextPrimaryAttack", 999.9);
	return HAM_HANDLED;
}

public OnUpdateClientDataPost(Player, SendWeapons, CD_Handle)
{
	if (!is_user_alive(Player) || (cs_get_user_weapon(Player) != CSW_C4))
		return FMRES_IGNORED;
	
	if (!lm_get_user_have_mine(Player))
		return FMRES_IGNORED;

	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + RELOAD_TIME);
	return FMRES_HANDLED;
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	if (cs_get_user_weapon(Player) == CSW_C4)
	{
		static weapon; weapon = cs_get_user_weapon_entity(Player);
		set_pev(Player, pev_weaponanim, Sequence);
	
		message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player);
		write_byte(Sequence);
		write_byte(pev(weapon, pev_body));
		message_end();
	}
}

//====================================================
// Native Functions
//====================================================
public plugin_natives()
{
	set_module_filter("module_filter");
	set_native_filter("native_filter");

	register_library("lasermine_natives");

	register_native("LM_Give", 		"_native_lm_give");
	register_native("LM_Set",  		"_native_lm_set");
	register_native("LM_Sub",  		"_native_lm_sub");
	register_native("LM_Get",		"_native_lm_get_have");
	register_native("LM_RemoveAll", "_native_lm_remove_all");
	register_native("IsLM",			"_native_lm_is_lasermine");
	register_native("LM_GetOwner",	"_native_lm_get_owner");
	register_native("LM_GetLaser",	"_native_lm_get_laser");
	
}

//====================================================
// Give lasermine.
//====================================================
public _native_lm_give(iPlugin, iParams)
{
	new id		      = get_param(1);
	new amount		  = get_param(2);
	new bool:uselimit = bool:get_param(3);

	return lm_give_mine(id, amount, uselimit);
}

lm_give_mine(const id, const amount = 1, bool:uselimit = true) 
{
	new have		  = lm_get_user_have_mine(id);
	new cvar_maxhave  = gCvar[CVAR_MAX_HAVE];
	if (uselimit)
	{
		if ((have + amount) <= cvar_maxhave)
			lm_set_user_have_mine(id, int:(have + amount));
		else
			lm_set_user_have_mine(id, int:(cvar_maxhave));
	}
	else
	{
		lm_set_user_have_mine(id, int:(have + amount));
	}

	if (cs_get_user_bpammo(id, CSW_C4) > 0)
		// Collect for this removed lasermine.
		cs_set_user_bpammo(id, CSW_C4, lm_get_user_have_mine(id));
	else
		give_item(id, "weapon_c4");	

	lm_play_sound(id, SOUND_PICKUP, cs_get_user_team(id));
	return lm_get_user_have_mine(id);
}

//====================================================
// Set Count of lasermine ammo.
//====================================================
public _native_lm_set(iPlugin, iParams)
{
	new id		      	= get_param(1);
	new amount		  	= get_param(2);
	new bool:uselimit 	= bool:get_param(3);
	new cvar_maxhave 	= gCvar[CVAR_MAX_HAVE];
	if (uselimit)
	{
		if (amount <= cvar_maxhave)
			lm_set_user_have_mine(id, int:(amount));
		else
			lm_set_user_have_mine(id, int:(cvar_maxhave));
	}
	else
	{
		lm_set_user_have_mine(id, int:(amount));
	}

	if (cs_get_user_bpammo(id, CSW_C4) > 0)
		// Collect for this removed lasermine.
		cs_set_user_bpammo(id, CSW_C4, lm_get_user_have_mine(id));
	else
		give_item(id, "weapon_c4");	

	lm_play_sound(id, SOUND_PICKUP, cs_get_user_team(id));
	return lm_get_user_have_mine(id);
}

//====================================================
// Subtract of lasermine ammo.
//====================================================
public _native_lm_sub(iPlugin, iParams)
{
	new id		      = get_param(1);
	new amount		  = get_param(2);
	new have		  = lm_get_user_have_mine(id);

	if ((have - amount) > 0)
		lm_set_user_have_mine(id, int:(have - amount));
	else
		lm_set_user_have_mine(id, int:0);

	cs_set_user_bpammo(id, CSW_C4, lm_get_user_have_mine(id));
	return lm_get_user_have_mine(id);
}

//====================================================
// Get amount count haveing ammo for lasermine.
//====================================================
public _native_lm_get_have(iPlugin, iParams)
{
	return lm_get_user_have_mine(get_param(1));
}

//====================================================
// Remove all lasermine of the world.
//====================================================
public _native_lm_remove_all(iPlugin, iParams)
{
	new id = get_param(1);
	lm_remove_all_entity(id, ENT_CLASS_LASER);
}

//====================================================
// Is this lasermine?
//====================================================
public _native_lm_is_lasermine(iPlugin, iParams)
{
	new iEnt = get_param(1);
	new name[MAX_NAME_LENGTH];
	pev(iEnt, pev_classname, name, charsmax(name));

	if (equali(name, ENT_CLASS_LASER))
		return true;

	return false;
}

//====================================================
// Get owner id of lasermine.
//====================================================
public _native_lm_get_owner(iPlugin, iParams)
{
	new iEnt = get_param(1);
	return pev(iEnt, LASERMINE_OWNER);
}

//====================================================
// Get Laser entity id of lasermine.
//====================================================
public _native_lm_get_laser(iPlugin, iParams)
{
	new iEnt = get_param(1);
	return pev(iEnt, LASERMINE_BEAM);
}

