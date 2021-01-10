// =====================================
//	Laser/Tripmine Entity Const
//
// 	by Aoi.Kagase
//
// =====================================

#if defined _lasermine_const_included
	#endinput
#endif
#define _lasermine_const_included

#if AMXX_VERSION_NUM < 190
#include <cromchat>

#define MAX_PLAYERS					32
#define MAX_NAME_LENGTH				32
#define MAX_AUTHID_LENGTH			64
#define HIT_SHIELD					8
#define Ham_CS_Player_ResetMaxSpeed Ham_Item_PreFrame
#define XTRA_OFS_PLAYER        		5
#define m_LastHitGroup        		75
#define lm_set_user_lasthit(%1,%2)	set_pdata_int(%1, m_LastHitGroup, %2)
#else
#define lm_set_user_lasthit(%1,%2)	set_ent_data(%1, "CBaseMonster","m_LastHitGroup", %2)
#endif

#define ENT_CLASS_LASER				"lasermine"
#define ENT_CLASS_BREAKABLE			"func_breakable"
#define MAX_LASER_ENTITY			128
#define MAX_EXPLOSION_DECALS 		3
#define MAX_BLOOD_DECALS 			10

// CS Status Data.
#define lm_get_user_deaths(%1)		get_ent_data(%1, "CbasePlayer",	"m_iDeaths")
#define lm_set_user_deaths(%1,%2)	set_ent_data(%1, "CbasePlayer",	"m_iDeaths", %2)

// Lasermine Data Save Area.
#define LASERMINE_OWNER				pev_iuser1
#define LASERMINE_STEP				pev_iuser2
#define LASERMINE_HITING			pev_iuser3
#define	LASERMINE_BEAM				pev_iuser4
#define LASERMINE_COUNT				pev_fuser1
#define LASERMINE_POWERUP			pev_fuser2
#define LASERMINE_BEAMTHINK			pev_fuser3
#define LASERMINE_BEAMENDPOINT1		pev_vuser1
#define LASERMINE_DECALS			pev_vuser2

#define IsPlayer(%1) 				( 1 <= %1 <= 32 ) 

#define TASK_PLANT					15100
#define TASK_RESET					15500
#define TASK_RELEASE				15900

//====================================================
// ENUM AREA
//====================================================
//
// Tripmine Action Control
//
enum _:TRIPMINE_MODE
{
	MODE_LASERMINE					= 0,
	MODE_TRIPMINE					,
	MODE_BF4_CLAYMORE				,
}
enum _:TRIPMINE_STATE
{
	TRIPMINE_IDLE1					= 0,
	TRIPMINE_IDLE2					,
	TRIPMINE_ARM1					,
	TRIPMINE_ARM2					,
	TRIPMINE_FIDGET					,
	TRIPMINE_HOLSTER				,
	TRIPMINE_DRAW					,
	TRIPMINE_WORLD					,		// Put.
	TRIPMINE_GROUND					,
};

enum _:TRIPMINE_THINK
{
	POWERUP_THINK					= 0,
	BEAMUP_THINK					,
	BEAMBREAK_THINK					,
	EXPLOSE_THINK					,
};

enum _:TRIPMINE_SOUND
{
	SOUND_POWERUP					= 0,
	SOUND_ACTIVATE					,
	SOUND_STOP						,
	SOUND_PICKUP					,
	SOUND_HIT						,
	SOUND_HIT_SHIELD				,
};

enum _:TRIPMINE_DMGMODE
{
	DMGMODE_ALWAYS					= 0,
	DMGMODE_ONCE					,
	DMGMODE_SECONDS					,
};
//
// CHECK ERROR CODE
//
enum _:ERROR
{
	E_NONE							= 0,
	E_NOT_ACTIVE					,
	E_NOT_ACCESS					,
	E_DONT_HAVE						,
	E_CANT_BUY_TEAM					,
	E_CANT_BUY_TEAM_Z				,
	E_CANT_BUY						,
	E_HAVE_MAX						,
	E_NO_MONEY						,
	E_MAXIMUM_DEPLOYED				,
	E_MANY_PPL						,
	E_DELAY_TIME					,
	E_NOT_ALIVE						,
	E_MUST_WALL						,
	E_MUST_GROUND					,
	E_NOT_IMPLEMENT					,
	E_NOT_BUYZONE					,
	E_NO_ROUND						,
};

//
// PLAYER DATA AREA
//
enum int:PLAYER_DATA_INT
{
	PLAYER_DELAY_COUNT				= 0,
	PLAYER_HAVE_MINE				,
	PLAYER_MINE_SETTING				,
	PLAYER_DEPLOYED					,
}

enum Float:PLAYER_DATA_FLOAT
{
	PLAYER_MAX_SPEED				= 0,
}

enum int:PLAYER_DEPLOY_STATE
{
	STATE_IDLE						= 0,
	STATE_DEPLOYING					,
	STATE_PICKING					,
	STATE_DEPLOYED					,
}

enum _:PICKUP_MODE
{
	DISALLOW_PICKUP					= 0,
	ONLY_ME							,
	ALLOW_FRIENDLY					,
	ALLOW_ENEMY						,
}

enum _:E_SOUNDS
{
	DEPLOY							,
	CHARGE							,
	ACTIVATE						,
	PICKUP							,
	LASER_HIT						,
	SHIELD_HIT1						,
	SHIELD_HIT2						,
	GLASS_1							,
	GLASS_2							,
}

enum _:E_SPRITES
{
	LASER							,
	EXPLOSION_1						,
	EXPLOSION_2						,
	EXPLOSION_WATER					,
	BLAST							,
	SMOKE							,
	BUBBLE							,
	BLOOD_SPLASH					,
	BLOOD_SPRAY						,
};

enum _:E_LANG_KEY
{
	REFER							,
	BOUGHT							,
	NO_MONEY						,
	NOT_ACCESS						,
	NOT_ACTIVE						,
	NOT_HAVE						,
	NOT_BUY							,
	NOT_BUYTEAM						,
	NOT_BUYTEAMB					,
	NOT_BUYZONE						,
	NOT_PICKUP						,
	MAX_DEPLOY						,
	MAX_HAVE						,
	MAX_PPL							,
	DELAY_SEC						,
	STATE_AMMO						,
	STATE_INF						,
	PLANT_WALL						,
	SORRY_IMPL						,
	NOROUND							,
	ALL_REMOVE						,
	GIVE_MINE						,
	REMOVE_SPEC						,
	MINE_HUD						,
}

enum _:HIT_PLAYER
{
	I_TARGET						,
	I_HIT_GROUP						,
	Float:V_POSITION[3]				,
};

//
// CVAR SETTINGS
//
enum E_CVAR_SETTING
{
	CVAR_ENABLE						= 0,    // Plugin Enable.
	CVAR_ACCESS_LEVEL				,		// Access level for 0 = ADMIN or 1 = ALL.
	CVAR_NOROUND					,		// Check Started Round.
	CVAR_MODE						,    	// 0 = Lasermine, 1 = Tripmine.
	CVAR_MAX_HAVE					,    	// Max having ammo.
	CVAR_START_HAVE					,    	// Start having ammo.
	CVAR_FRAG_MONEY     		    ,    	// Get money per kill.
	CVAR_COST               		,    	// Buy cost.
	CVAR_BUY_ZONE           		,    	// Stay in buy zone can buy.
	Float:CVAR_LASER_DMG         	,    	// Laser hit Damage.
	CVAR_TEAM_MAX           		,    	// Max deployed in team.
	Float:CVAR_EXPLODE_RADIUS    	,   	// Explosion Radius.
	Float:CVAR_EXPLODE_DMG     		,   	// Explosion Damage.
	CVAR_FRIENDLY_FIRE      		,   	// Friendly Fire.
	CVAR_VIOLENCE_HBLOOD			,		// Violence High blood
	CVAR_CBT				[4]		,   	// Can buy team. TR/CT/ALL
	CVAR_BUY_MODE           		,   	// Buy mode. 0 = off, 1 = on.
	Float:CVAR_START_DELAY       	,   	// Round start delay time.
	// Laser design.
	CVAR_LASER_VISIBLE      		,   	// Laser line Visiblity. 0 = off, 1 = on.
	Float:CVAR_LASER_BRIGHT    		,   	// Laser line brightness.
	Float:CVAR_LASER_WIDTH			,		// Laser line width.
	CVAR_LASER_COLOR        		,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_COLOR_TR     [13]	,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_COLOR_CT     [13]	,   	// Laser line color. 0 = team color, 1 = green
	CVAR_LASER_DMG_MODE     		,   	// Laser line damage mode. 0 = frame rate dmg, 1 = once dmg, 2 = 1second dmg.
	Float:CVAR_LASER_DMG_DPS      	,   	// Laser line damage mode 2 only, damage/seconds. default 1 (sec)
	Float:CVAR_MINE_HEALTH     		,   	// Lasermine health. (Can break.)
	CVAR_MINE_GLOW          		,   	// Glowing tripmine.
	CVAR_MINE_GLOW_MODE     		,   	// Glowing color mode.
	CVAR_MINE_GLOW_CT     	[13]	,   	// Glowing color for CT.
	CVAR_MINE_GLOW_TR    	[13]	,   	// Glowing color for T.
	CVAR_MINE_BROKEN				,		// Can Broken Mines. 0 = Mine, 1 = Team, 2 = Enemy.
	CVAR_DEATH_REMOVE				,		// Dead Player Remove Lasermine.
	Float:CVAR_LASER_ACTIVATE		,		// Waiting for put lasermine. (0 = no progress bar.)
	Float:CVAR_LASER_RANGE			,		// Laserbeam range.
	CVAR_ALLOW_PICKUP				,		// allow pickup.
	CVAR_DIFENCE_SHIELD				,		// Shield hit.
	CVAR_REALISTIC_DETAIL			,		// Spark Effect.
};

// ADMIN LEVEL
#define ADMIN_ACCESSLEVEL			ADMIN_LEVEL_H
// Client Print Command Macro.
#define cp_debug(%1)				client_print_color(%1, %1, "^4[Laesrmine Debug] ^1Can't Create Entity")
#define cp_refer(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY[REFER],		CHAT_TAG)
#define cp_bought(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY[BOUGHT],		CHAT_TAG)
#define	cp_no_money(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY[NO_MONEY],	CHAT_TAG, gCvar[CVAR_COST])
#define cp_not_access(%1)			client_print_color(%1, print_team_red, "%L", %1, LANG_KEY[NOT_ACCESS], CHAT_TAG)
#define cp_not_active(%1)			client_print_color(%1, print_team_red, "%L", %1, LANG_KEY[NOT_ACTIVE], CHAT_TAG)
#define cp_dont_have(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY[NOT_HAVE],	CHAT_TAG)
#define cp_cant_buy(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY[NOT_BUY],		CHAT_TAG)
#define cp_buyzone(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY[NOT_BUYZONE],	CHAT_TAG)
#define cp_cant_buy_team(%1)		client_print_color(%1, %1, "%L", %1, LANG_KEY[NOT_BUYTEAM], CHAT_TAG)
#define cp_cant_buy_zombie(%1)		client_print_color(%1, %1, "%L", %1, LANG_KEY[NOT_BUYTEAMB],CHAT_TAG)
#define cp_cant_pickup(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY[NOT_PICKUP],	CHAT_TAG)
#define cp_maximum_deployed(%1)		client_print_color(%1, %1, "%L", %1, LANG_KEY[MAX_DEPLOY],	CHAT_TAG)
#define cp_have_max(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY[MAX_HAVE],	CHAT_TAG)
#define cp_many_ppl(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY[MAX_PPL],		CHAT_TAG)
#define cp_delay_time(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY[DELAY_SEC],	CHAT_TAG, gCvar[CVAR_START_DELAY] - gNowTime)
#define cp_must_wall(%1)			client_print_color(%1, %1, "%L", %1, LANG_KEY[PLANT_WALL],	CHAT_TAG)
#define cp_sorry(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY[SORRY_IMPL],	CHAT_TAG)
#define cp_noround(%1)				client_print_color(%1, %1, "%L", %1, LANG_KEY[NOROUND], 	CHAT_TAG)
#define cp_all_remove(%1,%2,%3)		client_print_color(%1, %1, "%L", %1, LANG_KEY[ALL_REMOVE],	CHAT_TAG, %2, %3)
#define cp_gave(%1,%2,%3)			client_print_color(%1, %1, "%L", %1, LANG_KEY[GIVE_MINE],	CHAT_TAG, %2, %3)
#define cp_remove_spec(%1,%2)		client_print_color(%1, %1, "%L", %1, LANG_KEY[REMOVE_SPEC],	CHAT_TAG, %2)

//=====================================
//  Resource Setting AREA
//=====================================
new const ENT_MODELS[]		=		"models/v_tripmine.mdl";
new const ENT_SOUNDS[][]	=	
{
									"weapons/mine_deploy.wav"	,		// 0: DEPLOY
									"weapons/mine_charge.wav"	,		// 1: CHARGE
									"weapons/mine_activate.wav"	,		// 2: ACTIVATE
									"items/gunpickup2.wav"		,		// 3: PICKUP
									"debris/beamstart9.wav"		,		// 4: LASER HIT
									"weapons/ric_metal-1.wav"	,		// 5: SHIELD HIT
									"weapons/ric_metal-2.wav"	,		// 6: SHIELD HIT
									"debris/bustglass1.wav"		,		// 7: GLASS
									"debris/bustglass2.wav"				// 8: GLASS
};
new const ENT_SPRITES[][]	=
{
									"sprites/laserbeam.spr"		,		// 0: LASER
									"sprites/fexplo.spr"		,		// 1: EXPLOSION
									"sprites/eexplo.spr"		,		// 2: EXPLOSION
									"sprites/WXplo1.spr"		,		// 3: WATER EXPLOSION
									"sprites/blast.spr"			,		// 4: BLAST
									"sprites/steam1.spr"		,		// 5: SMOKE
									"sprites/bubble.spr"		,		// 6: BUBBLE
									"sprites/blood.spr"			,		// 7: BLOOD SPLASH
									"sprites/bloodspray.spr"			// 8: BLOOD SPRAY
};
new const LANG_KEY[][]		=
{
									"REFER"						,
									"BOUGHT"					,
									"NO_MONEY"					,
									"NOT_ACCESS"				,
									"NOT_ACTIVE"				,
									"NOT_HAVE"					,
									"NOT_BUY"					,
									"NOT_BUY_TEAM"				,
									"NOT_BUY_TEAMB"				,
									"NOT_BUYZONE"				,
									"NOT_PICKUP"				,
									"MAX_DEPLOY"				,
									"MAX_HAVE"					,
									"MAX_PPL"					,
									"DELAY_SEC"					,
									"STATE_AMMO"				,
									"STATE_INF"					,
									"PLANT_WALL"				,
									"SORRY_IMPL"				,
									"NO_ROUND"					,
									"ALL_REMOVE"				,
									"GIVE_MINE"					,
									"REMOVE_SPEC"				,
									"MINE_HUD_MSG"				
};
