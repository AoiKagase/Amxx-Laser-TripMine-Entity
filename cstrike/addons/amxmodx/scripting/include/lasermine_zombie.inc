// =====================================
//	Laser/Tripmine Entity Zombie Mod Logic
//
// 	by Aoi.Kagase
//
// =====================================

#if defined _lasermine_zombie_included
	#endinput
#endif
#define _lasermine_zombie_included

#if defined BIOHAZARD_SUPPORT
#include <biohazard>

#define PLUGIN 					"Lasermine for BIOHAZARD"

#define CHAT_TAG 				"[Biohazard]"
#define CVAR_TAG				"bh_ltm"
#define CVAR_CFG				"bh_ltm_cvars.cfg"

register_zombie()
{
	gCvar[CVAR_NOROUND]			= register_cvar(fmt("%s%s", CVAR_TAG, "_check_started_round"),	"1"			);	// Check Started Round.

#if AMXX_VERSION_NUM > 183
	AutoExecConfig(true, "plugin-lasermine_bh");
#endif
}
#endif

#if defined ZP_SUPPORT

#include <zp50_items>
#include <zp50_gamemodes>
#include <zp50_colorchat>
#include <zp50_ammopacks>

#define PLUGIN 					"[ZP]Laser/Tripmine Entity"
#define CHAT_TAG 				"[ZP][LM]"
#define CVAR_TAG				"zp_ltm"
#define CVAR_CFG				"zp_ltm_cvars.cfg"

new ITEM_NAME[][]	= {"LaserMines", "TripMines", "Claymores"};
new gZpWeaponId;

register_zombie()
{
	new wmode 						= gCvar[CVAR_MODE];
	new cost						= gCvar[CVAR_COST];
	gZpWeaponId						= zp_items_register(ITEM_NAME[wmode], cost);
#if AMXX_VERSION_NUM > 183
	AutoExecConfig(true, "plugin-lasermine_zp");
#endif
}

// public plugin_natives()
// {
// 	register_native("zp_give_lm", "LaserMine_Native");
// }

// public LaserMine_Native(iPlugin, iParams)
// {
// 	new id = get_param(1);
// 	if (!lm_is_user_alive(id))
// 		return;

// 	lm_set_user_have_mine(id, int:get_param(2));
// }

public zp_fw_core_infect_post(id, attacker)
{
	if (!gCvar[CVAR_ENABLE])
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

	if (gamemode == -2)
	{
		zp_colored_print(id, "This is not available right now...");
		return ZP_ITEM_NOT_AVAILABLE;
	}

	zp_items_menu_text_add(fmt("[%d/%d]", lm_get_user_have_mine(id), gCvar[CVAR_MAX_HAVE]));

	if (lm_get_user_have_mine(id) >= int:gCvar[CVAR_MAX_HAVE])
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

zp_mines_breaked(attacker, victim)
{
	if (lm_get_user_health(victim) <= 0)
	{
		new szName[MAX_NAME_LENGTH];
		new addpoint = gCvar[CVAR_FRAG_MONEY];
		get_user_name(attacker, szName, charsmax(szName));
		zp_ammopacks_set(attacker, zp_ammopacks_get(attacker) + addpoint);
		zp_colored_print(0, "^4%s ^1earned^4 %i points ^1for destorying a lasermine !", szName, addpoint);
	}
}
#endif