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
#endif

#define ENT_CLASS_LASER				"lasermine"
#define ENT_CLASS_BREAKABLE			"func_breakable"
#define MAX_LASER_ENTITY			128
#define MAX_EXPLOSION_DECALS 		3
#define MAX_BLOOD_DECALS 			10

// CS Status Data.
#define lm_get_user_deaths(%1)		get_ent_data(%1, "CbasePlayer",	"m_iDeaths")
#define lm_set_user_deaths(%1,%2)	set_ent_data(%1, "CbasePlayer",	"m_iDeaths", %2)
#define lm_set_user_lasthit(%1,%2)	set_ent_data(%1, "CBaseMonster","m_LastHitGroup", %2)

// Lasermine Data Save Area.
#define LASERMINE_OWNER				pev_iuser1
#define LASERMINE_STEP				pev_iuser2
#define LASERMINE_HITING			pev_iuser3
#define LASERMINE_COUNT				pev_fuser1
#define LASERMINE_POWERUP			pev_fuser2
#define LASERMINE_BEAMTHINK			pev_fuser3
#define LASERMINE_BEAMENDPOINT1		pev_vuser1
#define LASERMINE_DECALS			pev_vuser2

#define IsPlayer(%1) 				( 1 <= %1 <= 32 ) 

//====================================================
// ENUM AREA
//====================================================
//
// Tripmine Action Control
//
enum _:TRIPMINE_MODE
{
	MODE_LASERMINE			= 0,
	MODE_TRIPMINE			,
	MODE_BF4_CLAYMORE		,
}
enum _:TRIPMINE_STATE
{
	TRIPMINE_IDLE1			= 0,
	TRIPMINE_IDLE2			,
	TRIPMINE_ARM1			,
	TRIPMINE_ARM2			,
	TRIPMINE_FIDGET			,
	TRIPMINE_HOLSTER		,
	TRIPMINE_DRAW			,
	TRIPMINE_WORLD			,		// Put.
	TRIPMINE_GROUND			,
};

enum _:TRIPMINE_THINK
{
	POWERUP_THINK			= 0,
	BEAMUP_THINK			,
	BEAMBREAK_THINK			,
	EXPLOSE_THINK			,
};

enum _:TRIPMINE_SOUND
{
	SOUND_POWERUP			= 0,
	SOUND_ACTIVATE			,
	SOUND_STOP				,
	SOUND_PICKUP			,
	SOUND_HIT				,
	SOUND_HIT_SHIELD		,
};

enum _:TRIPMINE_DMGMODE
{
	DMGMODE_ALWAYS			= 0,
	DMGMODE_ONCE			,
	DMGMODE_SECONDS			,
};
//
// CHECK ERROR CODE
//
enum _:ERROR
{
	NONE				= 0,
	NOT_ACTIVE			,
	NOT_ACCESS			,
	DONT_HAVE			,
	CANT_BUY_TEAM		,
	CANT_BUY_TEAM_Z		,
	CANT_BUY			,
	HAVE_MAX			,
	NO_MONEY			,
	MAXIMUM_DEPLOYED	,
	MANY_PPL			,
	DELAY_TIME			,
	NOT_ALIVE			,
	MUST_WALL			,
	MUST_GROUND			,
	NOT_IMPLEMENT		,
	NOT_BUYZONE			,
	NO_ROUND			,
};

//
// PLAYER DATA AREA
//
enum int:PLAYER_DATA_INT
{
	PLAYER_DELAY_COUNT		= 0,
	PLAYER_HAVE_MINE		,
	PLAYER_MINE_SETTING		,
	PLAYER_DEPLOYED			,
}

enum Float:PLAYER_DATA_FLOAT
{
	PLAYER_MAX_SPEED		= 0,
}

enum int:PLAYER_DEPLOY_STATE
{
	STATE_IDLE				= 0,
	STATE_DEPLOYING			,
	STATE_PICKING			,
	STATE_DEPLOYED			,
}

enum _:PICKUP_MODE
{
	DISALLOW_PICKUP			= 0,
	ONLY_ME					,
	ALLOW_FRIENDLY			,
	ALLOW_ENEMY				,
}
