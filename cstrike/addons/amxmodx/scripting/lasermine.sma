// #pragma semicolon 1
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
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <lasermine_util>

#if defined BIOHAZARD_SUPPORT
	#include <biohazard>
#endif

#if defined ZP_SUPPORT
	#include <zp50_items>
	#include <zp50_gamemodes>
	#include <zp50_colorchat>
	#include <zp50_ammopacks>
#endif

//=====================================
//  VERSION CHECK
//=====================================
#if AMXX_VERSION_NUM < 182
	#assert "AMX Mod X v1.8.2 or greater library required!"
#endif

#if defined BIOHAZARD_SUPPORT
	#define PLUGIN 					"Lasermine for BIOHAZARD"

	#define CHAT_TAG 				"[Biohazard]"
	#define CVAR_TAG				"bh_ltm"
	#define LANG_KEY_NOT_BUY_TEAM	"NOT_BUY_TEAM"
#else
#if defined ZP_SUPPORT
	#define PLUGIN 					"[ZP]Laser/Tripmine Entity"

	#define CHAT_TAG 				"[ZP][LM]"
	#define CVAR_TAG				"zp_ltm"
	#define LANG_KEY_NOT_BUY_TEAM 	"NOT_BUY_TEAMB"
#else
	#define PLUGIN 					"Laser/Tripmine Entity"
	#define CHAT_TAG 				"[Lasermine]"
	#define CVAR_TAG				"amx_ltm"
	#define LANG_KEY_NOT_BUY_TEAM 	"NOT_BUY_TEAM"
#endif
#endif
//=====================================
//  Resource Setting AREA
//=====================================
#define ENT_MODELS					"models/v_tripmine.mdl"
#define ENT_SOUND1					"weapons/mine_deploy.wav"
#define ENT_SOUND2					"weapons/mine_charge.wav"
#define ENT_SOUND3					"weapons/mine_activate.wav"
#define ENT_SOUND4					"items/gunpickup2.wav"
#define ENT_SOUND5					"debris/beamstart9.wav"
#define ENT_SOUND6					"weapons/ric_metal-1.wav"
#define ENT_SOUND7					"weapons/ric_metal-2.wav"
#define ENT_SOUND8					"debris/bustglass1.wav"
#define ENT_SOUND9					"debris/bustglass2.wav"
#define ENT_SPRITE1 				"sprites/laserbeam.spr"
#define ENT_SPRITE2 				"sprites/eexplo.spr"

//=====================================
//  MACRO AREA
//=====================================
//
// String Data.
//
// AUTHOR NAME +ARUKARI- => SandStriker => Aoi.Kagase
#define AUTHOR 						"Aoi.Kagase"
#define VERSION 					"3.12"

//#define STR_MINEDETNATED 			"Your mine has detonated.",
//#define STR_MINEDETNATED2			"detonated your mine.",
//#define STR_CANTDEPLOY			"Your team can't deploying lasermine!"

#define LANG_KEY_REFER				"REFER"
#define LANG_KEY_BOUGHT       		"BOUGHT"
#define LANG_KEY_NO_MONEY     		"NO_MONEY"
#define LANG_KEY_NOT_ACCESS   		"NOT_ACCESS"
#define LANG_KEY_NOT_ACTIVE   		"NOT_ACTIVE"
#define LANG_KEY_NOT_HAVE     		"NOT_HAVE"
#define LANG_KEY_NOT_BUY      		"NOT_BUY"
#define LANG_KEY_NOT_BUYZONE  		"NOT_BUYZONE"
#define LANG_KEY_NOT_PICKUP   		"NOT_PICKUP"
#define LANG_KEY_MAX_DEPLOY   		"MAX_DEPLOY"
#define LANG_KEY_MAX_HAVE     		"MAX_HAVE"
#define LANG_KEY_MAX_PPL      		"MAX_PPL"
#define LANG_KEY_DELAY_SEC    		"DELAY_SEC"
#define LANG_KEY_STATE_AMMO   		"STATE_AMMO"
#define LANG_KEY_STATE_INF    		"STATE_INF"
#define LANG_KEY_PLANT_WALL   		"PLANT_WALL"
#define LANG_KEY_PLANT_GROUND 		"PLANT_GROUND"
#define LANG_KEY_SORRY_IMPL   		"SORRY_IMPL"
#define LANG_KEY_NOROUND			"NO_ROUND"
#define LANG_KEY_ALL_REMOVE			"ALL_REMOVE"
#define LANG_KEY_GIVE_MINE			"GIVE_MINE"
#define LANG_KEY_REMOVE_SPEC		"REMOVE_SPEC"
#define LANG_KEY_MINE_HUD			"MINE_HUD_MSG"

// ADMIN LEVEL
#define ADMIN_ACCESSLEVEL			ADMIN_LEVEL_H

#if defined BIOHAZARD_SUPPORT
	#define CS_TEAM_ZOMBIE			4
#endif

// Put Guage ID
#define TASK_PLANT					15100
#define TASK_RESET					15500
#define TASK_RELEASE				15900

#define MAX_CLAYMORE				40

// Client Print Command Macro.
#define cp_debug(%1)				client_print_color(%1, %1, "^4[Laesrmine Debug] ^1Can't Create Entity")
#define cp_refer(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_REFER,		CHAT_TAG)
#define cp_bought(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_BOUGHT,		CHAT_TAG)
#define	cp_no_money(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NO_MONEY,		CHAT_TAG, get_pcvar_num(gCvar[CVAR_COST]))
#define cp_not_access(%1)			client_print_color(%1, print_team_red, "%L", %1, LANG_KEY_NOT_ACCESS, CHAT_TAG)
#define cp_not_active(%1)			client_print_color(%1, print_team_red, "%L", %1, LANG_KEY_NOT_ACTIVE, CHAT_TAG)
#define cp_dont_have(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_HAVE,		CHAT_TAG)
#define cp_cant_buy(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUY,		CHAT_TAG)
#define cp_buyzone(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUYZONE,	CHAT_TAG)
#define cp_cant_buy_team(%1)		client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_BUY_TEAM,	CHAT_TAG)
#define cp_cant_pickup(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_NOT_PICKUP,	CHAT_TAG)
#define cp_maximum_deployed(%1)		client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_DEPLOY,	CHAT_TAG)
#define cp_have_max(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_HAVE,		CHAT_TAG)
#define cp_many_ppl(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_MAX_PPL,		CHAT_TAG)
#define cp_delay_time(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_DELAY_SEC,	CHAT_TAG, int:get_pcvar_num(gCvar[CVAR_START_DELAY]) - gNowTime)
#define cp_must_wall(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_PLANT_WALL,	CHAT_TAG)
#define cp_must_ground(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY_PLANT_GROUND,	CHAT_TAG)
#define cp_sorry(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_SORRY_IMPL,	CHAT_TAG)
#define cp_noround(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY_NOROUND, 		CHAT_TAG)
#define cp_all_remove(%1,%2,%3)		client_print_color(%1, %1, "%L", %1, LANG_KEY_ALL_REMOVE,	CHAT_TAG, %2, %3)
#define cp_gave(%1,%2,%3)			client_print_color(%1, %1, "%L", %1, LANG_KEY_GIVE_MINE,	CHAT_TAG, %2, %3)
#define cp_remove_spec(%1,%2)		client_print_color(%1, %1, "%L", %1, LANG_KEY_REMOVE_SPEC,	CHAT_TAG, %2)

enum _:HIT_PLAYER
{
	I_TARGET				,
	I_HIT_GROUP				,
	Float:V_POSITION[3]		,
};

//
// CVAR SETTINGS
//
enum CVAR_SETTING
{
	CVAR_ENABLE				= 0,    // Plugin Enable.
	CVAR_ACCESS_LEVEL		,		// Access level for 0 = ADMIN or 1 = ALL.
	CVAR_NOROUND			,		// Check Started Round.
	CVAR_CMD_MODE			,    	// 0 = +USE key, 1 = bind, 2 = each.
	CVAR_MODE				,    	// 0 = Lasermine, 1 = Tripmine.
	CVAR_MAX_HAVE			,    	// Max having ammo.
	CVAR_START_HAVE			,    	// Start having ammo.
	CVAR_FRAG_MONEY         ,    	// Get money per kill.
	CVAR_COST               ,    	// Buy cost.
	CVAR_BUY_ZONE           ,    	// Stay in buy zone can buy.
	CVAR_LASER_DMG          ,    	// Laser hit Damage.
	CVAR_TEAM_MAX           ,    	// Max deployed in team.
	CVAR_EXPLODE_RADIUS     ,   	// Explosion Radius.
	CVAR_EXPLODE_DMG        ,   	// Explosion Damage.
	CVAR_FRIENDLY_FIRE      ,   	// Friendly Fire.
	CVAR_CBT                ,   	// Can buy team. TR/CT/ALL
	CVAR_BUY_MODE           ,   	// Buy mode. 0 = off, 1 = on.
	CVAR_START_DELAY        ,   	// Round start delay time.
	// Laser design.
	CVAR_LASER_VISIBLE      ,   	// Laser line Visiblity. 0 = off, 1 = on.
	CVAR_LASER_BRIGHT       ,   	// Laser line brightness.
	CVAR_LASER_WIDTH		,		// Laser line width.
	CVAR_LASER_COLOR        ,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_COLOR_TR     ,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_COLOR_CT     ,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_DMG_MODE     ,   	// Laser line damage mode. 0 = frame rate dmg, 1 = once dmg, 2 = 1second dmg.
	CVAR_LASER_DMG_DPS      ,   	// Laser line damage mode 2 only, damage/seconds. default 1 (sec)
	CVAR_MINE_HEALTH        ,   	// Lasermine health. (Can break.)
	CVAR_MINE_GLOW          ,   	// Glowing tripmine.
	CVAR_MINE_GLOW_MODE     ,   	// Glowing color mode.
	CVAR_MINE_GLOW_CT     	,   	// Glowing color for CT.
	CVAR_MINE_GLOW_TR    	,   	// Glowing color for T.
	CVAR_MINE_BROKEN		,		// Can Broken Mines. 0 = Mine, 1 = Team, 2 = Enemy.
	CVAR_DEATH_REMOVE		,		// Dead Player Remove Lasermine.
	CVAR_LASER_ACTIVATE		,		// Waiting for put lasermine. (0 = no progress bar.)
	CVAR_LASER_RANGE		,		// Laserbeam range.
	CVAR_ALLOW_PICKUP		,		// allow pickup.
//  CVAR_LASER_THINK        ,   	// Laser line think.
	CVAR_DIFENCE_SHIELD		,		// Shield hit.
	CVAR_REALISTIC_DETAIL	,		// Spark Effect.
	CVAR_CM_WIRE_RANGE		,		// Claymore Wire Range.
	CVAR_CM_WIRE_WIDTH		,		// Claymore Wire Width.
	CVAR_CM_CENTER_PITCH	,		// Claymore Wire Area Center Pitch.
	CVAR_CM_CENTER_YAW		,		// Claymore Wire Area Center Yaw.
	CVAR_CM_LEFT_PITCH		,		// Claymore Wire Area Left Pitch.
	CVAR_CM_LEFT_YAW		,		// Claymore Wire Area Left Yaw.
	CVAR_CM_RIGHT_PITCH		,		// Claymore Wire Area Right Pitch.
	CVAR_CM_RIGHT_YAW		,		// Claymore Wire Area Right Yaw.
	CVAR_CM_TRIAL_FREQ		,		// Claymore Wire trial frequency.
	CVAR_CM_WIRE_COLOR		,
	CVAR_CM_WIRE_COLOR_T	,
	CVAR_CM_WIRE_COLOR_CT	,
};

#if defined ZP_SUPPORT
enum _:GAMEMODE_TAG
{
	GMODE_ARMAGEDDON,
	GMODE_ZTAG,
	GMODE_ASSASIN,
}
#endif
//====================================================
//  GLOBAL VARIABLES
//====================================================
new gCvar[CVAR_SETTING];

new int:gNowTime;
new gMsgBarTime;
new gBeam, gBoom;
new gEntMine;

#if AMXX_VERSION_NUM > 183
new Stack:gRecycleMine	[MAX_PLAYERS];
#endif

new gDeployingMines		[MAX_PLAYERS];

#if defined ZP_SUPPORT
	new ITEM_NAME[][]	= {"LaserMines", "TripMines", "Claymores"};
	new gZpGameMode[GAMEMODE_TAG];
	new gZpWeaponId;
#else
	#if !defined BIOHAZARD_SUPPORT
		new gMsgStatusText;
	#endif
#endif

//====================================================
//  PLUGIN INITIALIZE
//====================================================
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Add your code here...
	register_concmd("lm_remove", 	"admin_remove_laser",ADMIN_ACCESSLEVEL, " - <num>"); 
	register_concmd("lm_give", 		"admin_give_laser",  ADMIN_ACCESSLEVEL, " - <num>"); 

	register_clcmd("+setlaser", 	"lm_progress_deploy");
	register_clcmd("+setlm", 		"lm_progress_deploy");
	register_clcmd("+dellaser", 	"lm_progress_remove");
	register_clcmd("+remlm", 		"lm_progress_remove");
   	register_clcmd("-setlaser", 	"lm_progress_stop");
   	register_clcmd("-setlm", 		"lm_progress_stop");
   	register_clcmd("-dellaser", 	"lm_progress_stop");
   	register_clcmd("-remlm", 		"lm_progress_stop");

	register_clcmd("say", 			"lm_say_lasermine");
#if !defined ZP_SUPPORT	
	register_clcmd("buy_lasermine", "lm_buy_lasermine");
#endif
	// CVar settings.
	// Common.
	gCvar[CVAR_ENABLE]	        = register_cvar(fmt("%s%s", CVAR_TAG, "_enable"),				"1"			);	// 0 = off, 1 = on.
	gCvar[CVAR_ACCESS_LEVEL]   	= register_cvar(fmt("%s%s", CVAR_TAG, "_access"),				"0"			);	// 0 = all, 1 = admin
	gCvar[CVAR_MODE]           	= register_cvar(fmt("%s%s", CVAR_TAG, "_mode"),   				"0"			);	// 0 = lasermine, 1 = tripmine, 2 = claymore wire trap
//	gCvar[CVAR_FRIENDLY_FIRE]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_friendly_fire"),		"0"			);	// Friendly fire. 0 or 1
	gCvar[CVAR_START_DELAY]    	= register_cvar(fmt("%s%s", CVAR_TAG, "_round_delay"),			"5"			);	// Round start delay time.
	gCvar[CVAR_CMD_MODE]	    = register_cvar(fmt("%s%s", CVAR_TAG, "_cmd_mode"),				"1"			);	// 0 is +USE key, 1 is bind, 2 is each.
#if defined BIOHAZARD_SUPPORT
	gCvar[CVAR_NOROUND]			= register_cvar(fmt("%s%s", CVAR_TAG, "_check_started_round"),	"1"			);	// Check Started Round.
#endif
	// Ammo.
	gCvar[CVAR_START_HAVE]	    = register_cvar(fmt("%s%s", CVAR_TAG, "_amount"),				"1"			);	// Round start have ammo count.
	gCvar[CVAR_MAX_HAVE]       	= register_cvar(fmt("%s%s", CVAR_TAG, "_max_amount"),   		"2"			);	// Max having ammo.
	gCvar[CVAR_TEAM_MAX]		= register_cvar(fmt("%s%s", CVAR_TAG, "_team_max"),				"10"		);	// Max deployed in team.

	// Buy system.
	gCvar[CVAR_BUY_MODE]	    = register_cvar(fmt("%s%s", CVAR_TAG, "_buy_mode"),				"1"			);	// 0 = off, 1 = on.
	gCvar[CVAR_CBT]    			= register_cvar(fmt("%s%s", CVAR_TAG, "_buy_team"),				"ALL"		);	// Can buy team. TR / CT / ALL. (BIOHAZARD: Z = Zombie)
	gCvar[CVAR_COST]           	= register_cvar(fmt("%s%s", CVAR_TAG, "_buy_price"),			"2500"		);	// Buy cost.
	gCvar[CVAR_BUY_ZONE]        = register_cvar(fmt("%s%s", CVAR_TAG, "_buy_zone"),				"1"			);	// Stay in buy zone can buy.
	gCvar[CVAR_FRAG_MONEY]     	= register_cvar(fmt("%s%s", CVAR_TAG, "_frag_money"),   		"300"		);	// Get money.

	// Laser design.
	gCvar[CVAR_LASER_VISIBLE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_visible"),		"1"			);	// Laser line visibility.
	gCvar[CVAR_LASER_COLOR]    	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_color_mode"),		"0"			);	// laser line color 0 = team color, 1 = green.
	// Leser beam color for team color mode.
	gCvar[CVAR_LASER_COLOR_TR] 	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_color_t"),		"255,0,0"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_LASER_COLOR_CT] 	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_color_ct"),		"0,0,255"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)

	gCvar[CVAR_LASER_BRIGHT]   	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_brightness"),		"255"		);	// laser line brightness. 0 to 255
	gCvar[CVAR_LASER_WIDTH]   	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_width"),			"2"			);	// laser line width. 0 to 255
	gCvar[CVAR_LASER_DMG]      	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_damage"),			"60.0"		);	// laser hit dmg. Float Value!
	gCvar[CVAR_LASER_DMG_MODE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_damage_mode"),	"0"			);	// Laser line damage mode. 0 = frame dmg, 1 = once dmg, 2 = 1 second dmg.
	gCvar[CVAR_LASER_DMG_DPS]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_dps"),			"1"			);	// laser line damage mode 2 only, damage/seconds. default 1 (sec)
	gCvar[CVAR_LASER_RANGE]		= register_cvar(fmt("%s%s", CVAR_TAG, "_laser_range"),			"8192.0"	);	// Laser beam lange (float range.)

	// Mine design.
	gCvar[CVAR_MINE_HEALTH]    	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_health"),			"500"		);	// Tripmine Health. (Can break.)
	gCvar[CVAR_MINE_GLOW]      	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow"),			"1"			);	// Tripmine glowing. 0 = off, 1 = on.
	gCvar[CVAR_MINE_GLOW_MODE]  = register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_mode"),	"0"			);	// Mine glow coloer 0 = team color, 1 = green, 2 = Health Indicater(green to red).
	gCvar[CVAR_MINE_GLOW_TR]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_t"),	"255,0,0"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_MINE_GLOW_CT]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_glow_color_ct"),	"0,0,255"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)
	gCvar[CVAR_MINE_BROKEN]		= register_cvar(fmt("%s%s", CVAR_TAG, "_mine_broken"),			"0"			);	// Can broken Mines.(0 = mines, 1 = Team, 2 = Enemy)
	gCvar[CVAR_EXPLODE_RADIUS] 	= register_cvar(fmt("%s%s", CVAR_TAG, "_explode_radius"),		"320.0"		);	// Explosion radius.
	gCvar[CVAR_EXPLODE_DMG]		= register_cvar(fmt("%s%s", CVAR_TAG, "_explode_damage"),		"100"		);	// Explosion radius damage.

	// Misc Settings.
	gCvar[CVAR_DEATH_REMOVE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_death_remove"),			"0"			);	// Dead Player remove lasermine. 0 = off, 1 = on.
	gCvar[CVAR_LASER_ACTIVATE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_activate_time"),		"1"			);	// Waiting for put lasermine. (int:seconds. 0 = no progress bar.)
	gCvar[CVAR_ALLOW_PICKUP]	= register_cvar(fmt("%s%s", CVAR_TAG, "_allow_pickup"),			"1"			);	// allow pickup mine. (0 = disable, 1 = it's mine, 2 = allow friendly mine, 3 = allow enemy mine!)
	gCvar[CVAR_DIFENCE_SHIELD]	= register_cvar(fmt("%s%s", CVAR_TAG, "_shield_difence"),		"1"			);	// allow shiled difence.
	gCvar[CVAR_REALISTIC_DETAIL]= register_cvar(fmt("%s%s", CVAR_TAG, "_realistic_detail"), 	"0"			);	// Spark Effect.

	// Claymore Settings. (Color is Laser color)
	gCvar[CVAR_CM_WIRE_RANGE]	= register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_range"),		"300"		);	// wire range.
	gCvar[CVAR_CM_WIRE_WIDTH]	= register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_width"),		"2"			);	// wire width.
	gCvar[CVAR_CM_CENTER_PITCH]	= register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_center_pitch"),	"220,290"	);	// wire area center pitch.
	gCvar[CVAR_CM_CENTER_YAW]	= register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_center_yaw"),	"-25,25"	);	// wire area center yaw.
	gCvar[CVAR_CM_LEFT_PITCH]	= register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_left_pitch"),	"260,290"	);	// wire area left pitch.
	gCvar[CVAR_CM_LEFT_YAW]		= register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_left_yaw"),		"30,60"		);	// wire area left yaw.
	gCvar[CVAR_CM_RIGHT_PITCH]	= register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_right_pitch"),	"260,290"	);	// wire area right pitch.
	gCvar[CVAR_CM_RIGHT_YAW]	= register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_right_yaw"),	"-30,-60"	);	// wire area right yaw.
	gCvar[CVAR_CM_TRIAL_FREQ]	= register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_trial_freq"),	"3"			);	// wire trial frequency.
	gCvar[CVAR_CM_WIRE_COLOR]  	= register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_color_mode"),	"0"			);	// Mine glow coloer 0 = team color, 1 = green.
	gCvar[CVAR_CM_WIRE_COLOR_T] = register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_color_t"),		"20,0,0"	);	// Team-Color for Terrorist. default:red (R,G,B)
	gCvar[CVAR_CM_WIRE_COLOR_CT]= register_cvar(fmt("%s%s", CVAR_TAG, "_cm_wire_color_ct"),		"0,0,20"	);	// Team-Color for Counter-Terrorist. default:blue (R,G,B)
	gCvar[CVAR_FRIENDLY_FIRE]  	= get_cvar_pointer("mp_friendlyfire");											// Friendly fire. 0 or 1

	// Register Hamsandwich
	RegisterHam(Ham_Spawn, 			"player", "NewRound", 		1);
	RegisterHam(Ham_Item_PreFrame,	"player", "KeepMaxSpeed", 	1);
	RegisterHam(Ham_Killed, 		"player", "PlayerKilling", 	0);
	RegisterHam(Ham_Think,			ENT_CLASS_BREAKABLE, "LaserThink");
	RegisterHam(Ham_TakeDamage,		ENT_CLASS_BREAKABLE, "MinesTakeDamage");
	RegisterHam(Ham_TakeDamage,     ENT_CLASS_BREAKABLE, "MinesBreaked", 1);

	// Register Event
	register_event("DeathMsg", "DeathEvent",	"a");
	register_event("TeamInfo", "CheckSpectator","a");


	// Get Message Id
#if !defined ZP_SUPPORT
	#if !defined BIOHAZARD_SUPPORT
		gMsgStatusText 	= get_user_msgid("StatusText");
	#endif
#endif
	gMsgBarTime		= get_user_msgid("BarTime");

	// Register Forward.
	register_forward(FM_PlayerPostThink,"PlayerPostThink");
	register_forward(FM_PlayerPreThink, "PlayerPreThink");
	register_forward(FM_TraceLine,		"MinesShowInfo", 1);

	// Multi Language Dictionary.
	register_dictionary("lasermine.txt");

	register_cvar("ltm_versions", VERSION, FCVAR_SERVER|FCVAR_SPONLY);

#if AMXX_VERSION_NUM > 183
	for(new i = 0; i < MAX_PLAYERS; i++)
		gRecycleMine[i] = CreateStack(1);
#endif

	#if defined ZP_SUPPORT
		new wmode 						= get_pcvar_num(gCvar[CVAR_MODE]);
		new cost						= get_pcvar_num(gCvar[CVAR_COST]);
		gZpWeaponId						= zp_items_register(ITEM_NAME[wmode], cost);
		gZpGameMode[GMODE_ARMAGEDDON]	= zp_gamemodes_get_id("Armageddon Mode");
		gZpGameMode[GMODE_ZTAG] 		= zp_gamemodes_get_id("Zombie Tag Mode");
		gZpGameMode[GMODE_ASSASIN]		= zp_gamemodes_get_id("Assassin Mode");
	#endif

#if AMXX_VERSION_NUM > 183
#if defined BIOHAZARD_SUPPORT
	AutoExecConfig(true, "plugin-lasermine_bh");
#else
#if defined ZP_SUPPORT
	AutoExecConfig(true, "plugin-lasermine_zp");
#else
	AutoExecConfig(true);
#endif
#endif
#endif
	// registered func_breakable
	gEntMine = engfunc(EngFunc_AllocString, ENT_CLASS_BREAKABLE);

	return PLUGIN_CONTINUE;
}
#if defined ZP_SUPPORT
public plugin_natives()
{
	register_native("zp_give_lm", "LaserMine_Native");
}

public LaserMine_Native(iPlugin, iParams)
{
	new id = get_param(1);
	if (!lm_is_user_alive(id))
		return;

	lm_set_user_have_mine(id, int:get_param(2));
}

public zp_fw_core_infect_post(id, attacker)
{
	if (!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	// Is Connected?
	if (is_user_connected(id)) 
		delete_task(id);

	// Dead Player remove lasermine.
	lm_remove_all_entity(id, ENT_CLASS_LASER);

	return PLUGIN_HANDLED
}

public zp_fw_items_select_pre(id, itemid, ignorecost)
{
	if (itemid != gZpWeaponId)
		return ZP_ITEM_AVAILABLE;

	if (zp_core_is_zombie(id))
		return ZP_ITEM_DONT_SHOW;

	new gamemode = zp_gamemodes_get_current();

	if (gamemode == -2
	||	gamemode == gZpGameMode[GMODE_ARMAGEDDON]
	||	gamemode == gZpGameMode[GMODE_ZTAG]
	||	gamemode == gZpGameMode[GMODE_ASSASIN]
	)
	{
		zp_colored_print(id, "This is not available right now...");
		return ZP_ITEM_NOT_AVAILABLE;
	}

	zp_items_menu_text_add(fmt("[%d/%d]", lm_get_user_have_mine(id), get_pcvar_num(gCvar[CVAR_MAX_HAVE])));

	if (lm_get_user_have_mine(id) >= int:get_pcvar_num(gCvar[CVAR_MAX_HAVE]))
	{
		zp_colored_print(id, "You reached the limit..");
		return ZP_ITEM_NOT_AVAILABLE;
	}

	return ZP_ITEM_AVAILABLE;
}

public zp_fw_items_select_post(id, itemid, ignorecost)
{
	if(itemid == gZpWeaponId)
	{
		lm_set_user_have_mine(id, lm_get_user_have_mine(id) + int:1)
		cp_bought(id)
		lm_play_sound(id, SOUND_PICKUP)
	}
}
#endif
#if AMXX_VERSION_NUM < 190
//====================================================
//  PLUGIN CONFIG
//====================================================
public plugin_cfg()
{
	new file[64];
	new len = charsmax(file);
	get_localinfo("amxx_configsdir", file, len);

#if defined BIOHAZARD_SUPPORT
	format(file, len, "%s/bhltm_cvars.cfg", file);
#else
#if defined ZP_SUPPORT
	format(file, len, "%s/zp_ltm_cvars.cfg", file);
#else
	format(file, len, "%s/ltm_cvars.cfg", file);
#endif
#endif
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
}
#endif
//====================================================
//  PLUGIN PRECACHE
//====================================================
public plugin_precache() 
{
	precache_sound(ENT_SOUND1);
	precache_sound(ENT_SOUND2);
	precache_sound(ENT_SOUND3);
	precache_sound(ENT_SOUND4);
	precache_sound(ENT_SOUND5);
	precache_sound(ENT_SOUND6);
	precache_sound(ENT_SOUND7);
	precache_sound(ENT_SOUND8);
	precache_sound(ENT_SOUND9);
	precache_model(ENT_MODELS);
	gBeam = precache_model(ENT_SPRITE1);
	gBoom = precache_model(ENT_SPRITE2);
	
	return PLUGIN_CONTINUE;
}

//====================================================
//  PLUGIN REQUIRE MODULE
//====================================================
/* 
	1.8.3
	symbol "plugin_modules" is marked as deprecated: 
	Module dependency is now automatically handled by the compiler. 
	This forward is no longer called.
*/
/*
public plugin_modules() 
{
	require_module("fakemeta");
	require_module("hamsandwich");
}
*/

//====================================================
//  Bot Register Ham.
//====================================================
new g_bots_registered = false;
public client_authorized( id )
{
    if( !g_bots_registered && is_user_bot( id ) )
    {
        set_task( 0.1, "register_bots", id );
    }
}

public register_bots( id )
{
    if( !g_bots_registered && is_user_connected( id ) )
    {
        RegisterHamFromEntity( Ham_Killed, id, "PlayerKilling");
        g_bots_registered = true;
    }
}

//====================================================
// Friendly Fire Method.
//====================================================
bool:is_valid_takedamage(iAttacker, iTarget)
{
	if (get_pcvar_num(gCvar[CVAR_FRIENDLY_FIRE]))
		return true;

	if (cs_get_user_team(iAttacker) != cs_get_user_team(iTarget))
		return true;

	return false;
}

// bool:is_user_friend(iAttacker, iTarget)
// {
// 	if (get_pcvar_num(gCvar[CVAR_FRIENDLY_FIRE]))
// 	if (cs_get_user_team(iAttacker) == cs_get_user_team(iTarget))
// 		return true;
// 	return false;
// }

//====================================================
// Round Start Initialize
//====================================================
public NewRound(id)
{
	// Check Plugin Enabled
	if (!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	if (!is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	if (is_user_bot(id))
		return PLUGIN_CONTINUE;

	// alive?
	if (lm_is_user_alive(id) && pev(id, pev_flags) & (FL_CLIENT)) 
	{
		// Delay time reset
		lm_set_user_delay_count(id, int:floatround(get_gametime()));

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
	if (lm_is_user_alive(id))
	{
		new Float:now_speed = lm_get_user_max_speed(id);
		if (now_speed > 1.0 && now_speed < 300.0)
			lm_save_user_max_speed(id, lm_get_user_max_speed(id));
	}

	return PLUGIN_CONTINUE;
}

//====================================================
// Round Start Set Ammo.
// Native:_native_set_start_ammo(iPlugin, iParam);
//====================================================
set_start_ammo(id)
{
	// Get CVAR setting.
	new int:stammo = int:get_pcvar_num(gCvar[CVAR_START_HAVE]);

	// Zero check.
	if(stammo <= int:0) 
		return;

	// Getting have ammo.
	new int:haveammo = lm_get_user_have_mine(id);

	// Set largest.
	lm_set_user_have_mine(id, (haveammo <= stammo ? stammo : haveammo));

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
	if (!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	// Is Connected?
	if (is_user_connected(vID)) 
		delete_task(vID);

	// Dead Player remove lasermine.
	if (get_pcvar_num(gCvar[CVAR_DEATH_REMOVE]))
		lm_remove_all_entity(vID, ENT_CLASS_LASER);

	return PLUGIN_CONTINUE;
}

//====================================================
// Put LaserMine Start Progress A
//====================================================
public lm_progress_deploy_main(id)
{
	// Deploying Check.
	if (!check_for_deploy(id))
		return PLUGIN_HANDLED;

	new Float:wait = get_pcvar_float(gCvar[CVAR_LASER_ACTIVATE]);
	// Set Flag. start progress.
	lm_set_user_deploy_state(id, int:STATE_DEPLOYING);

	new iEnt = gDeployingMines[id] = engfunc(EngFunc_CreateNamedEntity, gEntMine);
	if (pev_valid(iEnt))
	{
		// set models.
		engfunc(EngFunc_SetModel, iEnt, ENT_MODELS);
		// set solid.
		set_pev(iEnt, pev_solid, 		SOLID_NOT);
		// set movetype.
		set_pev(iEnt, pev_movetype, 	MOVETYPE_FLY);

		set_pev(iEnt, pev_renderfx, 	kRenderFxHologram);
		set_pev(iEnt, pev_body, 		3);
		set_pev(iEnt, pev_sequence, 	TRIPMINE_WORLD);
		set_pev(iEnt, pev_rendermode,	kRenderTransAdd);
		set_pev(iEnt, pev_renderfx,	 	kRenderFxHologram);
		set_pev(iEnt, pev_renderamt,	255.0);
		set_pev(iEnt, pev_rendercolor,	{255.0,255.0,255.0});
	}

	if (wait > 0)
	{
		lm_show_progress(id, int:floatround(wait), gMsgBarTime);
	}

	// Start Task. Put Lasermine.
	set_task(wait, "SpawnMine", (TASK_PLANT + id));

	return PLUGIN_HANDLED;
}

//====================================================
// Put LaserMine Start Progress B
//====================================================
public lm_progress_deploy(id)
{
	// Mode check. Bind Key Command.
	if(get_pcvar_num(gCvar[CVAR_CMD_MODE]) != 0)
		lm_progress_deploy_main(id);

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

	new Float:wait = get_pcvar_float(gCvar[CVAR_LASER_ACTIVATE]);
	if (wait > 0)
		lm_show_progress(id, int:floatround(wait), gMsgBarTime);

	// Set Flag. start progress.
	lm_set_user_deploy_state(id, int:STATE_PICKING);

	// Start Task. Remove Lasermine.
	set_task(wait, "RemoveMine", (TASK_RELEASE + id));

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
	// is Valid?
	if(!gDeployingMines[uID])
	{
		cp_debug(uID);
		return PLUGIN_HANDLED_MAIN;
	}

	set_spawn_entity_setting(gDeployingMines[uID], uID, ENT_CLASS_LASER);

	return 1;
}

//====================================================
// Lasermine Settings.
//====================================================
stock set_spawn_entity_setting(iEnt, uID, classname[])
{
	// Entity Setting.
	// set class name.
	set_pev(iEnt, pev_classname, classname);

	// set models.
	engfunc(EngFunc_SetModel, iEnt, ENT_MODELS);

	// set solid.
	set_pev(iEnt, pev_solid, SOLID_NOT);

	// set movetype.
	set_pev(iEnt, pev_movetype, MOVETYPE_FLY);

	// set model animation.
	set_pev(iEnt, pev_frame,		0);
	set_pev(iEnt, pev_body, 		3);
	set_pev(iEnt, pev_sequence, 	TRIPMINE_WORLD);
	set_pev(iEnt, pev_framerate,	0);
	set_pev(iEnt, pev_rendermode,	kRenderNormal);
	set_pev(iEnt, pev_renderfx,	 	kRenderFxNone);

	// set take damage.
	set_pev(iEnt, pev_takedamage, DAMAGE_YES);
	set_pev(iEnt, pev_dmg, 100.0);

	// set entity health.
	// if recycle health.
#if AMXX_VERSION_NUM > 183
	if (!IsStackEmpty(gRecycleMine[uID]))
	{
		new Float:health;
		PopStackCell(gRecycleMine[uID], health);
		lm_set_user_health(iEnt, health);
	}
	else
	{
		lm_set_user_health(iEnt, get_pcvar_float(gCvar[CVAR_MINE_HEALTH]));
	}
#else
	lm_set_user_health(iEnt, get_pcvar_float(gCvar[CVAR_MINE_HEALTH]));
#endif
	// set mine position
	set_mine_position(uID, iEnt);

	new authid[MAX_AUTHID_LENGTH];
	get_user_authid(uID, authid, charsmax(authid));
	set_pev(iEnt, pev_netname, authid);
	// Save results to be used later.
	set_pev(iEnt, LASERMINE_OWNER, uID );

	// Reset powoer on delay time.
	new Float:fCurrTime = get_gametime();
	set_pev(iEnt, LASERMINE_POWERUP, fCurrTime + 2.5 );   
	set_pev(iEnt, LASERMINE_STEP, POWERUP_THINK);
	set_pev(iEnt, LASERMINE_COUNT, fCurrTime);
	set_pev(iEnt, LASERMINE_BEAMTHINK, fCurrTime);

	// think rate. hmmm....
	set_pev(iEnt, pev_nextthink, fCurrTime + 0.2 );

	// Power up sound.
	lm_play_sound(iEnt, SOUND_POWERUP);

	// Cound up. deployed.
	lm_set_user_mine_deployed(uID, lm_get_user_mine_deployed(uID) + int:1);
	// Cound down. have ammo.
	lm_set_user_have_mine(uID, lm_get_user_have_mine(uID) - int:1);

	// Refresh show ammo.
	show_ammo(uID);

	// Set Flag. end progress.
	lm_set_user_deploy_state(uID, int:STATE_DEPLOYED);
	gDeployingMines[uID] = 0;
}

//====================================================
// Set Lasermine Position.
//====================================================
set_mine_position(uID, iEnt)
{
	// Vector settings.
	new Float:vOrigin[3];
	new	Float:vNewOrigin[3],Float:vNormal[3],
		Float:vTraceEnd[3],Float:vEntAngles[3];
	new bool:mode_claymore = (get_pcvar_num(gCvar[CVAR_MODE]) == MODE_BF4_CLAYMORE);

	// get user position.
	pev(uID, pev_origin, vOrigin);
	velocity_by_aim(uID, 128, vTraceEnd);
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

	xs_vec_mul_scalar( vNormal, 8.0, vNormal );
	xs_vec_add( vTraceEnd, vNormal, vNewOrigin );

	// set size.
	engfunc(EngFunc_SetSize, iEnt, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } );
	// set entity position.
	engfunc(EngFunc_SetOrigin, iEnt, vNewOrigin );

	// Claymore user Angles.
	if (mode_claymore)
	{
		new Float:pAngles[3], Float:vFwd[3], Float:vRight[3], Float:vUp[3];
		pev(uID, pev_angles, pAngles);
		xs_anglevectors(pAngles, vFwd, vRight, vUp);
		xs_vec_add(vNormal, vFwd, vNormal);
	}

	// Rotate tripmine.
	vector_to_angle(vNormal, vEntAngles);

	// set angle.
	set_pev(iEnt, pev_angles, vEntAngles);

	// set laserbeam end point position.
	set_laserend_postiion(iEnt, vNormal, vNewOrigin, mode_claymore);
}

//====================================================
// Set Laserbeam End Position.
//====================================================
set_laserend_postiion(iEnt, Float:vNormal[3], Float:vNewOrigin[3], bool:claymore)
{
	// Calculate laser end origin.
	new Float:vBeamEnd[3];
	new Float:vTracedBeamEnd[3];
	new Float:range = get_pcvar_float(gCvar[CVAR_LASER_RANGE]);
	new Float:claymoreNormal[3];
	claymoreNormal = vNormal;
	xs_vec_mul_scalar(vNormal, range, vNormal );
	xs_vec_add( vNewOrigin, vNormal, vBeamEnd );

    // create the trace handle.
	new trace = create_tr2();
	// (const float *v1, const float *v2, int fNoMonsters, edict_t *pentToSkip, TraceResult *ptr);
	engfunc(EngFunc_TraceLine, vNewOrigin, vBeamEnd, IGNORE_MONSTERS, -1, trace);
	{
		get_tr2(trace, TR_vecEndPos, vTracedBeamEnd);
	}
    // free the trace handle.
	free_tr2(trace);
	set_pev(iEnt, LASERMINE_BEAMENDPOINT1, vTracedBeamEnd);

	// calucrate claymore wire end point.
	if (claymore)
	{
		set_claymore_endpoint(iEnt, vNewOrigin, claymoreNormal);
		return;
	}
	set_pev(iEnt, LASERMINE_BEAMENDPOINT2, vTracedBeamEnd);
	set_pev(iEnt, LASERMINE_BEAMENDPOINT3, vTracedBeamEnd);
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
		return 1;
	
	// Get Player Vector Origin.
	pev(uID, pev_origin, vOrigin);
	// Get Mine Vector Origin.
	pev(target, pev_origin, tOrigin);

	// Distance Check. far 70.0 (cm?)
	if(get_distance_f(vOrigin, tOrigin) > 70.0)
		return 1;
	
	new entityName[MAX_NAME_LENGTH];
	entityName = lm_get_entity_class_name(target);

	// Check. is Target Entity Lasermine?
	if(!equali(entityName, ENT_CLASS_LASER))
		return 1;

	new ownerID = pev(target, LASERMINE_OWNER);

	new PICKUP_MODE:pickup 	= PICKUP_MODE:get_pcvar_num(gCvar[CVAR_ALLOW_PICKUP]);
	switch(pickup)
	{
		case DISALLOW_PICKUP:
			return 1;
		case ONLY_ME:
		{
			// Check. is Owner you?
			if(ownerID != uID)
				return 1;
		}
		case ALLOW_FRIENDLY:
		{
			// Check. is friendly team?
			if(lm_get_laser_team(target) != cs_get_user_team(uID))
				return 1;
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

	if (pev_valid(ownerID))
	{
		// Return to before deploy count.
		lm_set_user_mine_deployed(ownerID, lm_get_user_mine_deployed(ownerID) - int:1);
	}

	// Play sound.
	lm_play_sound(uID, SOUND_PICKUP);

	// Set Flag. end progress.
	lm_set_user_deploy_state(uID, int:STATE_DEPLOYED);

	// Refresh show ammo.
	show_ammo(uID);

	return 1;
}


//====================================================
// Check: Remove Lasermine.
//====================================================
bool:check_for_remove(id)
{
	new int:cvar_ammo		= int:get_pcvar_num(gCvar[CVAR_MAX_HAVE]);
	new ERROR:error 		= check_for_common(id);
	new PICKUP_MODE:pickup 	= PICKUP_MODE:get_pcvar_num(gCvar[CVAR_ALLOW_PICKUP]);
	// common check.
	if (error)
		return false;

	// have max ammo? (use buy system.)
	if (get_pcvar_num(gCvar[CVAR_BUY_MODE]) != 0)
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
	entityName = lm_get_entity_class_name(target);

	// is target lasermine?
	if(!equali(entityName, ENT_CLASS_LASER))
		return false;

	// Damaged?
	// new Float:health;
	// health = lm_get_user_health(target);
	// if (health < get_pcvar_float(gCvar[CVAR_MINE_HEALTH]))
	// {
	// 	cp_cant_pickup(id);
	// 	return false;
	// }

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
	if (!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return HAM_IGNORED;

	// is valid this entity?
	if (!pev_valid(iEnt))
		return HAM_IGNORED;

	new entityName[MAX_NAME_LENGTH];
	entityName = lm_get_entity_class_name(iEnt);

	// is this lasermine? no.
	if (!equali(entityName, ENT_CLASS_LASER))
		return HAM_IGNORED;

	static Float:fCurrTime;
	static TRIPMINE_THINK:step;
	static loop;
	loop = get_pcvar_num(gCvar[CVAR_MODE]) == MODE_BF4_CLAYMORE ? 3 : 1;

	fCurrTime = get_gametime();
	step = TRIPMINE_THINK:pev(iEnt, LASERMINE_STEP);

	// lasermine state.
	// Power up.
	if (step == TRIPMINE_THINK:POWERUP_THINK)
	{
		new Float:fPowerupTime;
		pev(iEnt, LASERMINE_POWERUP, fPowerupTime);
		// over power up time.
		
		if (fCurrTime > fPowerupTime)
		{
			// next state.
			set_pev(iEnt, LASERMINE_STEP, BEAMUP_THINK);
			// activate sound.
			lm_play_sound(iEnt, SOUND_ACTIVATE);
		}

		mine_glowing(iEnt);

		// Think time.
		set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);

		return HAM_HANDLED;
	}
	static Float:vEnd[3][3]; // Claymore 3 point
	static Float:vOrigin[3];

	// Get this mine position.
	pev(iEnt, pev_origin, vOrigin);
	// Get Laser line end potision.
	pev(iEnt, LASERMINE_BEAMENDPOINT1, vEnd[0]);
	pev(iEnt, LASERMINE_BEAMENDPOINT2, vEnd[1]);
	pev(iEnt, LASERMINE_BEAMENDPOINT3, vEnd[2]);

	if (step == TRIPMINE_THINK:BEAMUP_THINK)
	{
		// solid complete.
		set_pev(iEnt, pev_solid, SOLID_BBOX);

		// drawing laser line.
		if (get_pcvar_num(gCvar[CVAR_LASER_VISIBLE]) )
		{
			for (new i = 0; i < loop; i++)
			{
				draw_laserline(iEnt, vEnd[i]);
				if(get_pcvar_num(gCvar[CVAR_REALISTIC_DETAIL])) 
					lm_draw_spark_for_wall(vEnd[i]);
			}
		}

		// next state.
		set_pev(iEnt, LASERMINE_STEP, BEAMBREAK_THINK);
		// Think time.
		set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
	}
	// Get owner id.
	new iOwner = pev(iEnt, LASERMINE_OWNER);

	// Laser line activated.
	if (step == TRIPMINE_THINK:BEAMBREAK_THINK)
	{
		static Array:aTarget;
		static hPlayer[HIT_PLAYER];
		static iTarget;
		static hitGroup;
		static iIgnoreEnt;
		static trace;
		static Float:fFraction;
		static Float:hitPoint[3];
		static Float:reStartPos[3];
		static Float:nextTime = 0.0;
		static Float:beamTime = 0.0;

		pev(iEnt, LASERMINE_COUNT, nextTime);
		pev(iEnt, LASERMINE_BEAMTHINK, beamTime);
		if (fCurrTime > beamTime)
		{
			for(new i = 0; i < loop; i++)
			{
				// drawing spark.
				if (get_pcvar_num(gCvar[CVAR_LASER_VISIBLE]) )
				{
					draw_laserline(iEnt, vEnd[i]);
					if(get_pcvar_num(gCvar[CVAR_REALISTIC_DETAIL])) 
						lm_draw_spark_for_wall(hitPoint);
				}
			}
			set_pev(iEnt, LASERMINE_BEAMTHINK, fCurrTime + random_float(0.1, 0.2));
		}

		if (get_pcvar_num(gCvar[CVAR_MODE]) == MODE_LASERMINE 
		&&  get_pcvar_num(gCvar[CVAR_LASER_DMG_MODE]) != 0)
		{
			if (fCurrTime < nextTime)
			{
				// Think time.
				// Think time. random_float = laser line blinking.
				set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
				return HAM_HANDLED;
			}
		}
		aTarget = ArrayCreate(sizeof(hPlayer));

		// create the trace handle.
		trace = create_tr2();

		for(new i = 0; i < loop; i++)
		{
			fFraction	= 0.0;
			iIgnoreEnt	= iEnt;
			ArrayClear(aTarget);
			reStartPos = vOrigin;
			set_pev(iEnt, LASERMINE_COUNT, get_gametime());

			// Trace line
			while(fFraction < 1.0)
			{
				// Trace line
				engfunc(EngFunc_TraceLine, reStartPos, vEnd[i], DONT_IGNORE_MONSTERS, iIgnoreEnt, trace);
				{
					get_tr2(trace, TR_flFraction, fFraction);
					iTarget		= get_tr2(trace, TR_pHit);
					hitGroup	= get_tr2(trace, TR_iHitgroup);
					get_tr2(trace, TR_vecEndPos, hitPoint);				
				}

				// Something has passed the laser.
				if (fFraction < 1.0)
				{

					// is valid hit entity?
					if (!pev_valid(iTarget)
					// is user?
					|| !(pev(iTarget, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER))
					// is dead?
					|| !lm_is_user_alive(iTarget)
					// Hit friend and No FF.
					|| !is_valid_takedamage(iOwner, iTarget)
					// is godmode?
					|| lm_is_user_godmode(iTarget)
					)
					{
						reStartPos = hitPoint;
						iIgnoreEnt = iTarget;
						continue;
					}
					hPlayer[I_TARGET] 	= iTarget;
					hPlayer[V_POSITION]	= _:hitPoint;
					hPlayer[I_HIT_GROUP]= hitGroup;
					ArrayPushArray(aTarget, hPlayer);
					if (hitGroup == HIT_SHIELD && get_pcvar_num(gCvar[CVAR_DIFENCE_SHIELD]))
						break;
								
					reStartPos = hitPoint;
					iIgnoreEnt = iTarget;
					// keep target id.
					set_pev(iEnt, pev_enemy, iTarget);
				}
			}

			// Mode. Lasermine / Tripmine / Claymore wire trap.
			switch(get_pcvar_num(gCvar[CVAR_MODE]))
			{
				// Lasermine mode.
				// Laser damage.
				case MODE_LASERMINE:
				{
					for (new n = 0; n < ArraySize(aTarget); n++)
					{
						ArrayGetArray(aTarget, n, hPlayer);
						// Laser line damage mode. Once or Second.
						create_laser_damage(iEnt, hPlayer[I_TARGET], hPlayer[I_HIT_GROUP], hPlayer[V_POSITION]);
					}					
					// Laser line damage mode. Once or Second.
					if (get_pcvar_num(gCvar[CVAR_LASER_DMG_MODE]) != 0)
					{
						if (ArraySize(aTarget) > 0)
							set_pev(iEnt, LASERMINE_COUNT, (nextTime + get_pcvar_float(gCvar[CVAR_LASER_DMG_DPS])));

						// if change target. keep target id.
						if (pev(iEnt, LASERMINE_HITING) != iTarget)
							set_pev(iEnt, LASERMINE_HITING, iTarget);
					}
				}
				// Tripmine mode.
				// Friendly Fire ON or Target is Enemy Team.
				case MODE_TRIPMINE, MODE_BF4_CLAYMORE:
				{
					// State change. to Explosing step.
					set_pev(iEnt, LASERMINE_STEP, EXPLOSE_THINK);
					break;
				}
			}
		}

		// free the trace handle.
		free_tr2(trace);
		ArrayDestroy(aTarget);

		// Get mine health.
		static Float:iHealth;
		iHealth = lm_get_user_health(iEnt);

		// break?
		if (iHealth <= 0 || (pev(iEnt, pev_flags) & FL_KILLME))
		{
			// next step explosion.
			set_pev(iEnt, LASERMINE_STEP, EXPLOSE_THINK);
			set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);
		}
				
		// Think time. random_float = laser line blinking.
		set_pev(iEnt, pev_nextthink, fCurrTime + 0.1);

		return HAM_HANDLED;
	}

	// EXPLODE
	if (TRIPMINE_THINK:step == TRIPMINE_THINK:EXPLOSE_THINK)
	{
		// Stopping entity to think
		set_pev(iEnt, pev_nextthink, 0.0);
		// Stopping sound.
		lm_play_sound(iEnt, SOUND_STOP);

		// Count down. deployed lasermines.
		lm_set_user_mine_deployed(iOwner, lm_get_user_mine_deployed(iOwner) - int:1);

		// effect explosion.
		lm_create_explosion(iEnt, gBoom);
	
		// damage.
		lm_create_explosion_damage(iEnt, iOwner, get_pcvar_float(gCvar[CVAR_EXPLODE_DMG]), get_pcvar_float(gCvar[CVAR_EXPLODE_RADIUS]));

		// remove this.
		lm_remove_entity(iEnt);
		return HAM_HANDLED;
	}

	return HAM_SUPERCEDE;
}

//====================================================
// Blocken Mines.
//====================================================
public MinesTakeDamage(victim, inflictor, attacker, Float:f_Damage, bit_Damage)
{
	new entityName[MAX_NAME_LENGTH];
	entityName = lm_get_entity_class_name(victim);

	// is this lasermine? no.
	if (!equali(entityName, ENT_CLASS_LASER))
		return HAM_IGNORED;

	// We get the ID of the player who put the mine.
	new iOwner = pev(victim, LASERMINE_OWNER);

	switch(get_pcvar_num(gCvar[CVAR_MINE_BROKEN]))
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
			if (get_pcvar_num(gCvar[CVAR_MINE_GLOW_MODE]) == 2)
				IndicateGlow(victim);
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
			if (get_pcvar_num(gCvar[CVAR_MINE_GLOW_MODE]) == 2)
				IndicateGlow(victim);
			return HAM_IGNORED;
		}
	}
	return HAM_IGNORED;
}


//====================================================
// Drawing Laser line.
//====================================================
draw_laserline(iEnt, const Float:vEndOrigin[3])
{
	new tcolor	[3];
	new sRGB	[13];
	new sColor	[4];
	new sRGBLen 	= charsmax(sRGB);
	new sColorLen	= charsmax(sColor);
	new CsTeams:teamid = lm_get_laser_team(iEnt);
	new width 		= get_pcvar_num(gCvar[CVAR_LASER_WIDTH]);
	new i = 0, n = 0, iPos = 0;
	// Color mode. 0 = team color.
	if(get_pcvar_num(gCvar[CVAR_LASER_COLOR]) == 0)
	{
		switch(teamid)
		{
			case CS_TEAM_T:
				get_pcvar_string(gCvar[CVAR_LASER_COLOR_TR], sRGB, sRGBLen);
			case CS_TEAM_CT:
				get_pcvar_string(gCvar[CVAR_LASER_COLOR_CT], sRGB, sRGBLen);
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

	// Test. Claymore color is black wire.
	if (get_pcvar_num(gCvar[CVAR_MODE]) == MODE_BF4_CLAYMORE)
	{
		if (get_pcvar_num(gCvar[CVAR_CM_WIRE_COLOR]) == 0)
		{
		switch(teamid)
		{
			case CS_TEAM_T:
				get_pcvar_string(gCvar[CVAR_CM_WIRE_COLOR_T],  sRGB, sRGBLen);
			case CS_TEAM_CT:
				get_pcvar_string(gCvar[CVAR_CM_WIRE_COLOR_CT], sRGB, sRGBLen);
			default:
				formatex(sRGB, sRGBLen, "20,20,20");
		}

		}
		width = get_pcvar_num(gCvar[CVAR_CM_WIRE_WIDTH]);
	}

	formatex(sRGB, sRGBLen, "%s%s", sRGB, ",");
	while(n < sizeof(tcolor))
	{
		i = split_string(sRGB[iPos += i], ",", sColor, sColorLen);
		tcolor[n++] = str_to_num(sColor);
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
	lm_draw_laser(iEnt, vEndOrigin, gBeam, 0, 0, 2, width, 0, tcolor, get_pcvar_num(gCvar[CVAR_LASER_BRIGHT]), 255);
}

//====================================================
// Laser damage
//====================================================
create_laser_damage(iEnt, iTarget, hitGroup, Float:hitPoint[])
{
	// Damage.
	new Float:dmg 	= get_pcvar_float(gCvar[CVAR_LASER_DMG]);

	new iAttacker = pev(iEnt,LASERMINE_OWNER);
	if (get_pcvar_num(gCvar[CVAR_DIFENCE_SHIELD]) && hitGroup == HIT_SHIELD)
	{
		lm_play_sound(iTarget, SOUND_HIT_SHIELD);

		lm_draw_spark(hitPoint);
		lm_hit_shield(iTarget, dmg);
	}
	else
	{
		lm_play_sound(iTarget, SOUND_HIT);
		lm_set_user_lasthit(iTarget, hitGroup);

		// if (is_user_friend(iAttacker, iTarget))
		// {
		// 	// Hit
		// 	new CsTeams:aTeam = cs_get_user_team(iAttacker);
		// 	cs_set_user_team(iAttacker, int:((aTeam == CS_TEAM_T) ? CS_TEAM_CT : CS_TEAM_T), _, false);
		// 	// Damage Effect, Damage, Killing Logic.
		// 	ExecuteHamB(Ham_TakeDamage, iTarget, iEnt, iAttacker, get_pcvar_float(gCvar[CVAR_LASER_DMG]), DMG_ENERGYBEAM);
		// 	cs_set_user_team(iAttacker, int:aTeam, _, false);
		// }
		// else
		// {
		// Damage Effect, Damage, Killing Logic.
		ExecuteHamB(Ham_TakeDamage, iTarget, iEnt, iAttacker, get_pcvar_float(gCvar[CVAR_LASER_DMG]), DMG_ENERGYBEAM);
		// }
	}
	set_pev(iEnt, LASERMINE_HITING, iTarget);		
	
	// // is target func_breakable?
	// if (equali(entityName, ENT_CLASS_BREAKABLE))
	// {
	// 	ExecuteHamB(Ham_TakeDamage, iTarget, iEnt, iAttacker, get_pcvar_float(gCvar[CVAR_LASER_DMG]));
	// 	// damage it.
	// 	//set_user_health(iTarget, Float:(fm_get_user_health(iTarget) - get_pcvar_float(gCvar[CVAR_LASER_DMG])));
	// }
	return;
}

//====================================================
// Player killing (Set Money, Score)
//====================================================
public PlayerKilling(iVictim, iAttacker)
{
	static entityName[MAX_NAME_LENGTH];
	entityName = lm_get_entity_class_name(iAttacker);
	//
	// Refresh Score info.
	//
	if (equali(entityName, ENT_CLASS_LASER))
	{
		// Get Target Team.
		new CsTeams:aTeam = cs_get_user_team(iAttacker);
		new CsTeams:vTeam = cs_get_user_team(iVictim);

		new score  = (vTeam != aTeam) ? 1 : -1;

		// Attacker Frag.
		// Add Attacker Frag (Friendly fire is minus).
		new aFrag	= lm_get_user_frags(iAttacker) + score;
		new aDeath	= cs_get_user_deaths(iAttacker);

		lm_set_user_deaths(iAttacker, aDeath);
		ExecuteHamB(Ham_AddPoints, iAttacker, aFrag - lm_get_user_frags(iAttacker), true);

		new tDeath = lm_get_user_deaths(iVictim);

		lm_set_user_deaths(iVictim, tDeath);
		ExecuteHamB(Ham_AddPoints, iVictim, 0, true);

		#if !defined ZP_SUPPORT
			#if !defined BIOHAZARD_SUPPORT
				// Get Money attacker.
				new money  = (vTeam != aTeam) ? get_pcvar_num(gCvar[CVAR_FRAG_MONEY]) : (get_pcvar_num(gCvar[CVAR_FRAG_MONEY]) * -1);
				cs_set_user_money(iAttacker, cs_get_user_money(iAttacker) + money);
			#endif
		#endif
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
	new ERROR:error = check_for_buy(id);
	if( error )
	{
		show_error_message(id, error);
		return PLUGIN_CONTINUE;
	}

	new cost = get_pcvar_num(gCvar[CVAR_COST]);
	cs_set_user_money(id, cs_get_user_money(id) - cost);

	lm_set_user_have_mine(id, lm_get_user_have_mine(id) + int:1);

	cp_bought(id);

	lm_play_sound(id, SOUND_PICKUP);

	show_ammo(id);

	return PLUGIN_HANDLED;
}
#endif
//====================================================
// Show ammo.
//====================================================
show_ammo(id)
{ 
#if defined ZP_SUPPORT
	client_print(id, print_center, "[%i/%i]", lm_get_user_have_mine(id), get_pcvar_num(gCvar[CVAR_MAX_HAVE]));
#else
#if defined BIOHAZARD_SUPPORT
	client_print(id, print_center, "[%i/%i]", lm_get_user_have_mine(id), get_pcvar_num(gCvar[CVAR_MAX_HAVE]));
#else
	new ammo[51];
	if (get_pcvar_num(gCvar[CVAR_BUY_MODE]) != 0)
		formatex(ammo, charsmax(ammo), "%L", id, LANG_KEY_STATE_AMMO, lm_get_user_have_mine(id), get_pcvar_num(gCvar[CVAR_MAX_HAVE]));
	else
		formatex(ammo, charsmax(ammo), "%L", id, LANG_KEY_STATE_INF);

	if (pev_valid(id))
		lm_show_status_text(id, ammo, gMsgStatusText);
#endif
#endif
} 

//====================================================
// Chat command.
//====================================================
public lm_say_lasermine(id)
{
	if(!get_pcvar_num(gCvar[CVAR_ENABLE]))
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
#if !defined ZP_SUPPORT
	} else 
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
#endif
	}
	return PLUGIN_CONTINUE;
}

//====================================================
// Player post think event.
// Stop movement for mine deploying.
//====================================================
public PlayerPostThink(id) 
{
	if ((pev(id, pev_weapons) & (1 << CSW_C4)) && (pev(id, pev_oldbuttons) & IN_ATTACK))
		return FMRES_IGNORED;

	switch (lm_get_user_deploy_state(id))
	{
		case STATE_IDLE:
		{
			new bool:now_speed = (lm_get_user_max_speed(id) <= 1.0);
			if (now_speed)
				ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
		}
		case STATE_DEPLOYING:
		{
			if (pev_valid(gDeployingMines[id]))
			{
				// Vector settings.
				static	Float:vOrigin[3];
				static	Float:vNewOrigin[3],Float:vNormal[3],
						Float:vTraceEnd[3],Float:vEntAngles[3];

				// Get wall position.
				velocity_by_aim(id, 128, vTraceEnd);
				// get user position.
				pev(id, pev_origin, vOrigin);
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
			lm_set_user_deploy_state(id, STATE_IDLE);
		}
	}

	return FMRES_IGNORED;
}

//====================================================
// Player pre think event.
//====================================================
public PlayerPreThink(id)
{
	if (!lm_is_user_alive(id)			// isDead?
		|| is_user_bot(id) 				// is bot?
		|| lm_get_user_deploy_state(id) != STATE_IDLE	 // deploying?
		|| get_pcvar_num(gCvar[CVAR_CMD_MODE]) == 1) // +setlaser use?
		return FMRES_IGNORED;

	// [USE] Key.
	if(pev(id, pev_button ) & IN_USE && !(pev(id, pev_oldbuttons ) & IN_USE ))
		lm_progress_deploy_main(id);			// deploying.

	return FMRES_IGNORED;
}

//====================================================
// Player connected.
//====================================================
public client_putinserver(id)
{
	// check plugin enabled.
	if(!get_pcvar_num(gCvar[CVAR_ENABLE]))
		return PLUGIN_CONTINUE;

	// reset deploy count.
	lm_set_user_mine_deployed(id, int:0);
	// reset hove mine.
	lm_set_user_have_mine(id, int:0);

#if AMXX_VERSION_NUM > 183
	// Init Recycle Health.
	ClearStack(gRecycleMine[id]);
#endif

	return PLUGIN_CONTINUE;
}

//====================================================
// Player Disconnect.
//====================================================
/*
	symbol "client_disconnect" is marked as deprecated: Use client_disconnected() instead.
*/
#if AMXX_VERSION_NUM > 183
public client_disconnected(id)
#else
public client_disconnect(id)
#endif
{
	// check plugin enabled.
	if(!get_pcvar_num(gCvar[CVAR_ENABLE]))
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
	new cvar_enable = get_pcvar_num(gCvar[CVAR_ENABLE]);
	new cvar_access = get_pcvar_num(gCvar[CVAR_ACCESS_LEVEL]);
	new user_flags	= get_user_flags(id) & ADMIN_ACCESSLEVEL;
	new is_alive	= lm_is_user_alive(id);
	//new cvar_mode	= get_pcvar_num(gCvar[CVAR_MODE]);

	// Plugin Enabled
	if (!cvar_enable)
		return ERROR:NOT_ACTIVE;

	// Can Access.
	if (cvar_access != 0 && !user_flags) 
		return ERROR:NOT_ACCESS;

	// Is this player Alive?
	if (!is_alive) 
		return ERROR:NOT_ALIVE;

	// claymore.
	//if (cvar_mode == MODE_BF4_CLAYMORE)
	// 	return ERROR:NOT_IMPLEMENT;

	// Can set Delay time?
	return ERROR:check_for_time(id);
}

//====================================================
// Check: Can use this time.
//====================================================
stock ERROR:check_for_time(id)
{
	new int:cvar_delay = int:get_pcvar_num(gCvar[CVAR_START_DELAY]);

	// gametime - playertime = delay count.
	gNowTime = int:floatround(get_gametime()) - lm_get_user_delay_count(id);

	// check.
	if(gNowTime >= cvar_delay)
		return ERROR:NONE;

	return ERROR:DELAY_TIME;
}

//====================================================
// Check: Can use this Team.
//====================================================
stock bool:check_for_team(id)
{
	new arg[4];
	new CsTeams:team;

	// Get Cvar
	get_pcvar_string(gCvar[CVAR_CBT], arg, charsmax(arg));

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
	new int:cvar_buymode= int:get_pcvar_num(gCvar[CVAR_BUY_MODE]);
	new int:cvar_maxhave= int:get_pcvar_num(gCvar[CVAR_MAX_HAVE]);
	new cvar_cost		= 	  get_pcvar_num(gCvar[CVAR_COST]);
	new cvar_buyzone	=	  get_pcvar_num(gCvar[CVAR_BUY_ZONE]);

	// Buy mode ON?
	if (cvar_buymode)
	{
		// Can this team buying?
		if (!check_for_team(id))
			return ERROR:CANT_BUY_TEAM;

		// Have Max?
		if (lm_get_user_have_mine(id) >= cvar_maxhave)
			return ERROR:HAVE_MAX;

		// buyzone area?
		if (cvar_buyzone && !cs_get_user_buyzone(id))
			return ERROR:NOT_BUYZONE;

		// Have money?
		if (lm_get_user_money(id) < cvar_cost)
			return ERROR:NO_MONEY;


	} else {
		return ERROR:CANT_BUY;
	}

	return ERROR:NONE;
}

//====================================================
// Check: Max Deploy.
//====================================================
stock ERROR:check_for_max_deploy(id)
{
	new int:cvar_maxhave = int:get_pcvar_num(gCvar[CVAR_MAX_HAVE]);
	new int:cvar_teammax = int:get_pcvar_num(gCvar[CVAR_TEAM_MAX]);
	new cvar_mode = get_pcvar_num(gCvar[CVAR_MODE]);

	// Max deployed per player.
	if (lm_get_user_mine_deployed(id) >= cvar_maxhave)
		return ERROR:MAXIMUM_DEPLOYED;

	// Max deployed per team.
	new int:team_count = lm_get_team_deployed_count(id);
	if (cvar_mode == MODE_BF4_CLAYMORE)
	{
		if(team_count >= cvar_teammax || team_count >= int:(MAX_CLAYMORE / 2))
			return ERROR:MANY_PPL;
	}
	else
	{
		if(team_count >= cvar_teammax || team_count >= int:(MAX_LASER_ENTITY / 2))
			return ERROR:MANY_PPL;
	}

	return ERROR:NONE;
}

//====================================================
// Show Chat area Messages
//====================================================
stock show_error_message(id, ERROR:err_num)
{
	switch(ERROR:err_num)
	{
		case NOT_ACTIVE:		cp_not_active(id);
		case NOT_ACCESS:		cp_not_access(id);
		case DONT_HAVE:			cp_dont_have(id);
		case CANT_BUY_TEAM:		cp_cant_buy_team(id);
		case CANT_BUY:			cp_cant_buy(id);
		case HAVE_MAX:			cp_have_max(id);
		case NO_MONEY:			cp_no_money(id);
		case MAXIMUM_DEPLOYED:	cp_maximum_deployed(id);
		case MANY_PPL:			cp_many_ppl(id);
		case DELAY_TIME:		cp_delay_time(id);
		case MUST_WALL:			cp_must_wall(id);
		case MUST_GROUND:		cp_must_ground(id);
		case NOT_IMPLEMENT:		cp_sorry(id);
		case NOT_BUYZONE:		cp_buyzone(id);
		case NO_ROUND:			cp_noround(id);
	}
}

//====================================================
// Check: On the wall.
//====================================================
stock ERROR:check_for_onwall(id)
{
	new Float:vTraceEnd[3];
	new Float:vOrigin[3];
	new bool:mode_claymore = (get_pcvar_num(gCvar[CVAR_MODE]) == MODE_BF4_CLAYMORE);

	// Get potision.
	pev(id, pev_origin, vOrigin);
	
	// Get wall position.
	velocity_by_aim(id, 128, vTraceEnd);

	if (mode_claymore)
	{
		// Claymore is ground position.
		vTraceEnd[2] = -128.0;
	}
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
		return ERROR:NONE;

	if (mode_claymore)
		return ERROR:MUST_GROUND;

	return ERROR:MUST_WALL;
}

//====================================================
// Check: Round Started
//====================================================
#if defined BIOHAZARD_SUPPORT
stock ERROR:check_round_started()
{
	if (get_pcvar_num(gCvar[CVAR_NOROUND]))
	{
		if(!game_started())
			return ERROR:NO_ROUND;
	}
	return ERROR:NONE;
}
#endif
//====================================================
// Check: Lasermine Deploy.
//====================================================
stock bool:check_for_deploy(id)
{
	// Check common.
	new ERROR:error = check_for_common(id);
	if (error)
	{
		show_error_message(id, error);
		return false;
	}

#if defined BIOHAZARD_SUPPORT
	// Check Started Round.
	error = check_round_started();
	if(error)
	{
		show_error_message(id, error);
		return false;
	}	
#endif
	// Have mine? (use buy system)
	if (get_pcvar_num(gCvar[CVAR_BUY_MODE]) != 0)
	if (lm_get_user_have_mine(id) <= int:0) 
	{
		show_error_message(id, ERROR:DONT_HAVE);
		return false;
	}

	// Max deployed?
	error = check_for_max_deploy(id);
	if (error) 
	{
		show_error_message(id, error);
		return false;
	}
	
	// On the wall?
	error = check_for_onwall(id);
	if (error) 
	{
		show_error_message(id, error);
		return false;
	}

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
	if (get_pcvar_num(gCvar[CVAR_MINE_GLOW]) != 0)
	{
		// Color setting.
		if (get_pcvar_num(gCvar[CVAR_MINE_GLOW_MODE]) == 0)
		{
			// Team color.
			switch (teamid)
			{
				case CS_TEAM_T:
					get_pcvar_string(gCvar[CVAR_MINE_GLOW_TR], sRGB, sRGBLen);
				case CS_TEAM_CT:
					get_pcvar_string(gCvar[CVAR_MINE_GLOW_CT], sRGB, sRGBLen);
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

Float:get_claymore_wire_endpoint(CVAR_SETTING:cvar)
{
	new i = 0, n = 0, iPos = 0;
	new Float:values[2];
	new sCvarValue	[20];
	new sSplit		[20];

	new sSplitLen		= charsmax(sSplit);

	get_pcvar_string(gCvar[cvar], sCvarValue, charsmax(sCvarValue));

	formatex(sCvarValue, charsmax(sCvarValue), "%s%s", sCvarValue, ",");
	while((i = split_string(sCvarValue[iPos += i], ",", sSplit, sSplitLen)) != -1 && n < sizeof(values))
	{
		values[n++] = str_to_float(sSplit);
	}
	return random_float(values[0], values[1]);
}

//====================================================
// Claymore Wire Endpoint
//====================================================
set_claymore_endpoint(iEnt, Float:vOrigin[3], Float:vNormal[3])
{
	new Float:vAngles	[3];
	new Float:vForward	[3];
	new Float:vResult	[3][3];
	new Float:hitPoint	[3];
	new Float:vTmp		[3];
	new Float:pAngles	[3];
	new Float:vFwd		[3];
	new Float:vRight	[3];
	new Float:vUp		[3];
	new trace = create_tr2();
	new Float:pitch;
	new Float:yaw;
	new Float:range;
	new n = 0;
	new freq = get_pcvar_num(gCvar[CVAR_CM_TRIAL_FREQ]);
	range = get_pcvar_float(gCvar[CVAR_CM_WIRE_RANGE]);
	pev(iEnt, pev_angles, vAngles);

	// roll zero
	pAngles[2] = 0.0;

	for (new i = 0; i < 3; i++)
	{
		hitPoint	= vOrigin;
		vTmp		= vOrigin;
		n = 0;
		while(n < freq)
		{
			while(xs_vec_distance(vOrigin, vTmp) > range || xs_vec_equal(vOrigin, vTmp))
			{
				switch(i)
				{
					// pitch:down 0, back 90, up 180, forward 270(-90)
					// yaw  :left 90, right -90 
					case 0: // center
					{
						pitch 	= get_claymore_wire_endpoint(CVAR_CM_CENTER_PITCH);
						yaw		= get_claymore_wire_endpoint(CVAR_CM_CENTER_YAW);
					}
					case 1: // right
					{
						pitch 	= get_claymore_wire_endpoint(CVAR_CM_RIGHT_PITCH);
						yaw		= get_claymore_wire_endpoint(CVAR_CM_RIGHT_YAW);
					}
					case 2: // left
					{
						pitch 	= get_claymore_wire_endpoint(CVAR_CM_LEFT_PITCH);
						yaw		= get_claymore_wire_endpoint(CVAR_CM_LEFT_YAW);
					}
				}

				pAngles[0] = pitch;
				pAngles[1] = yaw;

				xs_vec_add(pAngles, vAngles, pAngles);
				xs_anglevectors(pAngles, vFwd, vRight, vUp);
			
				xs_vec_mul_scalar(vFwd, range, vFwd);
				// xs_vec_add(vOrigin, vFwd, vForward);
				xs_vec_add(vFwd, vNormal, vForward);
				xs_vec_add(vOrigin, vForward, vForward);

				// Trace line
				engfunc(EngFunc_TraceLine, vOrigin, vForward, IGNORE_MONSTERS, iEnt, trace);
				{
					get_tr2(trace, TR_vecEndPos, vTmp);
				}
			}
			if (xs_vec_distance(vOrigin, vTmp) > xs_vec_distance(vOrigin, hitPoint))
				hitPoint = vTmp;

			n++;
		}
		vResult[i] = hitPoint;
	}

	// free the trace handle.
	free_tr2(trace);

	set_pev(iEnt, LASERMINE_BEAMENDPOINT1, vResult[0]);
	set_pev(iEnt, LASERMINE_BEAMENDPOINT2, vResult[1]);
	set_pev(iEnt, LASERMINE_BEAMENDPOINT3, vResult[2]);
}

//====================================================
// ShowInfo Hud Message
//====================================================
public MinesShowInfo(Float:vStart[3], Float:vEnd[3], Conditions, id, iTrace)
{ 
	static iHit, szName[MAX_NAME_LENGTH], iOwner, health;
	static hudMsg[64];
	static steamid[MAX_AUTHID_LENGTH];
	iHit = get_tr2(iTrace, TR_pHit);
	if (pev_valid(iHit))
	{
		if (lm_is_user_alive(iHit))
		{
			szName = lm_get_entity_class_name(iHit);

			if (equali(szName, ENT_CLASS_LASER))
			{
				iOwner = pev(iHit, LASERMINE_OWNER);
				health = floatround(lm_get_user_health(iHit));
				get_user_name(iOwner, szName, charsmax(szName));
				pev(iHit, pev_netname, steamid, charsmax(steamid));
				formatex(hudMsg, charsmax(hudMsg), "%L ^nSTEAMID:%s", id, LANG_KEY_MINE_HUD, szName, health, get_pcvar_num(gCvar[CVAR_MINE_HEALTH]), steamid);
				//set_hudmessage(red = 200, green = 100, blue = 0, Float:x = -1.0, Float:y = 0.35, effects = 0, Float:fxtime = 6.0, Float:holdtime = 12.0, Float:fadeintime = 0.1, Float:fadeouttime = 0.2, channel = -1)
				set_hudmessage(50, 100, 150, -1.0, 0.60, 0, 6.0, 0.4, 0.0, 0.0, -1);
				show_hudmessage(id, hudMsg);
			}
		}
    }
} 

public MinesBreaked(victim, inflictor, attacker, Float:f_Damage, bit_Damage)
{
	new entityName[MAX_NAME_LENGTH];
	entityName = lm_get_entity_class_name(victim);

    // is this lasermine? no.
	if (!equali(entityName, ENT_CLASS_LASER))
		return HAM_IGNORED;

#if defined ZP_SUPPORT
	if (lm_get_user_health(victim) <= 0)
	{
		new szName[MAX_NAME_LENGTH];
		new addpoint = get_pcvar_num(gCvar[CVAR_FRAG_MONEY]);
		get_user_name(attacker, szName, charsmax(szName));
		zp_ammopacks_set(attacker, zp_ammopacks_get(attacker) + addpoint);
		zp_colored_print(0, "^4%s ^1earned^4 %i points ^1for destorying a lasermine !", szName, addpoint);
	}
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

//====================================================
// Play sound.
//====================================================
stock lm_play_sound(iEnt, iSoundType)
{
	switch (iSoundType)
	{
		case SOUND_POWERUP:
		{
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUND1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			emit_sound(iEnt, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, 0, PITCH_NORM);
		}
		case SOUND_ACTIVATE:
		{
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, 1, 75);
		}
		case SOUND_STOP:
		{
			emit_sound(iEnt, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, SND_STOP, PITCH_NORM);
			emit_sound(iEnt, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, SND_STOP, 75);
		}
		case SOUND_PICKUP:
		{
			emit_sound(iEnt, CHAN_ITEM, ENT_SOUND4, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		case SOUND_HIT:
		{
			emit_sound(iEnt, CHAN_WEAPON, ENT_SOUND5, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		case SOUND_HIT_SHIELD:
		{
			emit_sound(iEnt, CHAN_VOICE, random_num(0, 1) == 1 ? ENT_SOUND6 : ENT_SOUND7, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
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

stock IndicateGlow(iEnt)
{
	new Float:color[3]   = {0.0, 255.0, 0.0}
	new Float:max_health = get_pcvar_float(gCvar[CVAR_MINE_HEALTH]);
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