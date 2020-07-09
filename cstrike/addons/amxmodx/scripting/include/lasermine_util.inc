// =====================================
//	Laser/Tripmine Entity functions
//
// 	by Aoi.Kagase
//
// =====================================

#if defined _lasermine_util_included
	#endinput
#endif
#define _lasermine_util_included

#include <lasermine_const>
#include <engine>

new int:gPlayerInt		[MAX_PLAYERS][PLAYER_DATA_INT];
new Float:gPlayerFloat	[MAX_PLAYERS][PLAYER_DATA_FLOAT];
new gDecalIndexExplosion[MAX_EXPLOSION_DECALS]
new gDecalIndexBlood	[MAX_BLOOD_DECALS]
new gNumDecalsExplosion
new gNumDecalsBlood

//====================================================
//  Player Data functions
//====================================================
stock lm_set_user_delay_count		(id, int:value) 	{ gPlayerInt[id][PLAYER_DELAY_COUNT]	= int:value; }
stock lm_set_user_have_mine			(id, int:value) 	{ gPlayerInt[id][PLAYER_HAVE_MINE]		= int:value; }
stock lm_set_user_mine_deployed		(id, int:value)		{ gPlayerInt[id][PLAYER_DEPLOYED]		= int:value; }
stock lm_set_user_deploy_state		(id, int:value)		{ gPlayerInt[id][PLAYER_MINE_SETTING]	= int:value; }
stock lm_set_user_health			(id, Float:health)	{ health > 0 ? set_pev(id, pev_health, health) : user_kill(id, 1); }
stock lm_set_user_frags				(id, int:frags)		{ set_pev(id, pev_frags, frags); }
stock lm_save_user_max_speed		(id, Float:value)	{ gPlayerFloat[id][PLAYER_MAX_SPEED]	= Float:value; }
stock lm_set_user_max_speed			(id, Float:value)	{ engfunc(EngFunc_SetClientMaxspeed, id, value);set_pev(id, pev_maxspeed, value); }

stock int:lm_get_user_delay_count	(id) 				{ return int:gPlayerInt[id][PLAYER_DELAY_COUNT]; }
stock int:lm_get_user_have_mine		(id) 				{ return int:gPlayerInt[id][PLAYER_HAVE_MINE]; }
stock int:lm_get_user_mine_deployed	(id) 				{ return int:gPlayerInt[id][PLAYER_DEPLOYED]; }
stock int:lm_get_user_deploy_state	(id)				{ return int:gPlayerInt[id][PLAYER_MINE_SETTING]; }
stock Float:lm_load_user_max_speed	(id)				{ return Float:gPlayerFloat[id][PLAYER_MAX_SPEED]; }
stock Float:lm_get_user_max_speed	(id)				{ return Float:pev(id, pev_maxspeed); }
stock Float:lm_get_user_health		(id)
{
	new Float:health;
	pev(id, pev_health, health);
	return health;
}
stock lm_get_user_frags				(id)				{ return pev(id, pev_frags);}
stock bool:lm_is_user_godmode		(id) 				{ return (pev(id, pev_takedamage) == DAMAGE_NO); }
stock bool:lm_is_user_alive			(id)				{ return (pev(id,pev_deadflag) == DEAD_NO);}
stock bool:lm_get_user_buyzone		(id)				{ return bool:(get_pdata_int(id, OFFSET_MAPZONE) & PLAYER_IN_BUYZONE);}
stock lm_get_entity_class_name		(id)
{
	new entityName[MAX_NAME_LENGTH];
	pev(id, pev_classname, entityName, charsmax(entityName));
	return entityName;
}

//====================================================
// Glow Rendering
//====================================================
stock lm_set_glow_rendering(iEnt, fx = kRenderFxNone, Float:renderColor[3], render = kRenderNormal, amount = 16)
{
	set_pev(iEnt, pev_renderfx, fx);
	set_pev(iEnt, pev_rendercolor, renderColor);
	set_pev(iEnt, pev_rendermode, render);
	set_pev(iEnt, pev_renderamt, float(amount));

	return 1;
}

//====================================================
// Function: Count to deployed in team.
//====================================================
stock int:lm_get_team_deployed_count(id)
{
	static int:i;
	static int:count;
	static int:num;
	static players[MAX_PLAYERS];
	static team[3] = '^0';

	// Witch your team?
	switch(CsTeams:lm_get_user_team(id))
	{
		case CS_TEAM_CT: team = "CT";
		case CS_TEAM_T : team = "T";
		default:
			return int:0;
	}

	// Get your team member.
	get_players(players, num, "e", team);

	// Count your team deployed lasermine.
	count = int:0;
	for(i = int:0;i < num;i++)
		count += lm_get_user_mine_deployed(players[i]);

	return count;
}

//====================================================
// Show Progress Bar.
//====================================================
stock lm_show_progress(id, int:time, msg)
{
	if (pev_valid(id))
	{
		engfunc(EngFunc_MessageBegin, MSG_ONE, msg, {0,0,0}, id);
		write_short(time);
		message_end();
	}
}

//====================================================
// Hide Progress Bar.
//====================================================
stock lm_hide_progress(id, msg)
{
	if (pev_valid(id))
	{
		engfunc(EngFunc_MessageBegin, MSG_ONE, msg, {0,0,0}, id);
		write_short(0);
		message_end();
	}
}

//====================================================
// Draw Spark
//====================================================
stock lm_draw_spark(const Float:origin[])
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_SPARKS);
	engfunc(EngFunc_WriteCoord, origin[0]);
	engfunc(EngFunc_WriteCoord, origin[1]);
	engfunc(EngFunc_WriteCoord, origin[2]);
	message_end();
}

stock lm_draw_spark_for_wall(const Float:vEndOrigin[3])
{
   	// Sparks
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vEndOrigin, 0);
	write_byte(TE_SPARKS); // TE id
	engfunc(EngFunc_WriteCoord, vEndOrigin[0]); // x
	engfunc(EngFunc_WriteCoord, vEndOrigin[1]); // y
	engfunc(EngFunc_WriteCoord, vEndOrigin[2]); // z
	message_end();
      
	// Effects when cut
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vEndOrigin[0]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[1]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[2] - 10.0);
	write_short(TE_SPARKS);	// sprite index
	write_byte(1);	// scale in 0.1's
	write_byte(30);	// framerate
	write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NOSOUND);	// flags
	message_end();
}

//====================================================
// Gets offset data
//====================================================
stock get_offset_value(id, type)
{
#if defined UL_MONEY_SUPPORT
	if (type == OFFSET_MONEY)
	{
			return cs_get_user_money_ul(id);
	}
#endif
	return get_pdata_int(id, type);	
}

//====================================================
// Sets offset data
//====================================================
stock set_offset_value(id, type, value)
{
#if defined UL_MONEY_SUPPORT
	if (type == OFFSET_MONEY)
	{
		return cs_set_user_money_ul(id, value);
	}
#endif
	set_pdata_int(id, type, value);	
	return;
}

//====================================================
// Flashing Money Hud
//====================================================
stock lm_flash_money_hud(id, value, msg)
{
	if (pev_valid(id))
	{
		// Send Money message to update player's HUD
		engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, msg, {0, 0, 0}, id);
		write_long(value);
		write_byte(1);	// Flash (difference between new and old money)
		message_end();
	}	
}


//====================================================
// Draw Laserline
//====================================================
stock lm_draw_laser(
	const iEnt,
	/* const Float:vOrigin[3],*/ 
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
{
	// Draw Laser line message.
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte(TE_BEAMENTPOINT);
	write_short(iEnt | 0x1000);
	// engfunc(EngFunc_WriteCoord, vOrigin[0]);
	// engfunc(EngFunc_WriteCoord, vOrigin[1]);
	// engfunc(EngFunc_WriteCoord, vOrigin[2]);
	engfunc(EngFunc_WriteCoord, vEndOrigin[0]); //Random
	engfunc(EngFunc_WriteCoord, vEndOrigin[1]); //Random
	engfunc(EngFunc_WriteCoord, vEndOrigin[2]); //Random
	write_short(beam);
	write_byte(framestart);						// framestart
	write_byte(framerate);						// framerate
	write_byte(life);							// Life
	write_byte(width);							// Width
	write_byte(wave);							// wave/noise
	write_byte(tcolor[0]);						// r
	write_byte(tcolor[1]);						// g
	write_byte(tcolor[2]);						// b
	write_byte(bright);							// Brightness.
	write_byte(speed);							// speed
	message_end();
}

//====================================================
// Effect Explosion.
//====================================================
// stock lm_create_explosion(iEnt, boom)
// {
// 	// Stop laser line.
// 	lm_stop_laserline(iEnt);

// 	// Get position.
// 	new Float:vOrigin[3];
// 	pev(iEnt, pev_origin, vOrigin);

// 	// Boooom.
// 	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0);
// 	write_byte(TE_EXPLOSION);
// 	engfunc(EngFunc_WriteCoord, vOrigin[0]);
// 	engfunc(EngFunc_WriteCoord, vOrigin[1]);
// 	engfunc(EngFunc_WriteCoord, vOrigin[2]);
// 	write_short(boom);
// 	write_byte(30);
// 	write_byte(15);
// 	write_byte(0);
// 	message_end();
// }

stock lm_create_explosion(iOrigin[3], const iDamage, const iRadius, sprExplosion1, sprExplosion2, sprBlast) 
{
	new iZPos = (iDamage + ((iRadius * 3) / 2)) / 8

	if(iZPos < 25) {
		iZPos = 25
	}
	else if(iZPos > 500) {
		iZPos = 500
	}

	new iIntensity = (iDamage + ((iRadius * 7) / 4)) / 32

	if(iIntensity < 12) {
		iIntensity = 12
	}
	else if(iIntensity > 128) {
		iIntensity = 128
	}

	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin, 0);
	write_byte(TE_EXPLOSION)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2] + iZPos)
	write_short(sprExplosion1)
	write_byte(iIntensity)
	write_byte(24)
	write_byte(0)
	message_end()

	iZPos /= 6

	if(iZPos < 6) {
		iZPos = 6
	}
	else if(iZPos > 96) {
		iZPos = 96
	}

	iIntensity = (iIntensity * 7) / 4

	if(iIntensity < 24) {
		iIntensity = 24
	}
	else if(iIntensity > 160) {
		iIntensity = 160
	}

	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin, 0);
	write_byte(TE_EXPLOSION)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2] + iZPos)
	write_short(sprExplosion2)
	write_byte(iIntensity)
	write_byte(20)
	write_byte(0)
	message_end()

	iZPos = ((((iDamage * 3) / 2) + iRadius) * 4) / 6

	if(iZPos < 160) {
		iZPos = 160
	}
	else if(iZPos > 960) {
		iZPos = 960
	}

	iIntensity = iRadius / 70

	if(iIntensity < 3) {
		iIntensity = 3
	}
	else if(iIntensity > 10) {
		iIntensity = 10
	}

	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin, 0);
	write_byte(TE_BEAMCYLINDER)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2])
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2] + iZPos)
	write_short(sprBlast)
	write_byte(0)
	write_byte(2)
	write_byte(iIntensity)
	write_byte(255)
	write_byte(0)
	write_byte(255)
	write_byte(255)
	write_byte(165)
	write_byte(128)
	write_byte(0)
	message_end()
}

//====================================================
// Stop Laser line.
//====================================================
stock lm_stop_laserline(iEnt)
{
	// Laser line stop.
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0);
	write_byte(TE_KILLBEAM); //99 = KillBeam
	write_short(iEnt | 0x1000);
	message_end();
}

//====================================================
// Explosion Damage.
//====================================================
stock lm_create_explosion_damage(iEnt, iAttacker, Float:dmgMax, Float:radius)
{
	// Get given parameters
	
	new Float:vOrigin[3];
	pev(iEnt, pev_origin, vOrigin);

	// radius entities.
	new rEnt  = -1;
	new Float:tmpDmg = dmgMax;

	new Float:kickBack = 0.0;
	
	// Needed for doing some nice calculations :P
	new Float:Tabsmin[3], Float:Tabsmax[3];
	new Float:vecSpot[3];
	new Float:Aabsmin[3], Float:Aabsmax[3];
	new Float:vecSee[3];
	new Float:flFraction;
	new Float:vecEndPos[3];
	new Float:distance;
	new Float:origin[3], Float:vecPush[3];
	new Float:invlen;
	new Float:velocity[3];
	new trace;
	new iHit;
	new tClassName[MAX_NAME_LENGTH];
	new iClassName[MAX_NAME_LENGTH];
	// Calculate falloff
	new Float:falloff;
	if (radius > 0.0)
		falloff = dmgMax / radius;
	else
		falloff = 1.0;
	
	iClassName = lm_get_entity_class_name(iEnt);
	// Find monsters and players inside a specifiec radius
	while((rEnt = engfunc(EngFunc_FindEntityInSphere, rEnt, vOrigin, radius)) != 0)
	{
		// is valid entity? no to continue.
		if (!pev_valid(rEnt)) 
			continue;

		tClassName = lm_get_entity_class_name(rEnt);
		if (!equali(tClassName, iClassName))
		{
			// Entity is not a player or monster, ignore it
			if (!(pev(rEnt, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
				continue;
		}

		// is alive?
		if (!lm_is_user_alive(rEnt))
			continue;
		
		// friendly fire
		if (!is_valid_takedamage(iAttacker, rEnt))
			continue;

		// Reset data
		kickBack = 1.0;
		tmpDmg = dmgMax;
		
		// The following calculations are provided by Orangutanz, THANKS!
		// We use absmin and absmax for the most accurate information
		pev(rEnt, pev_absmin, Tabsmin);
		pev(rEnt, pev_absmax, Tabsmax);

		xs_vec_add(Tabsmin, Tabsmax, Tabsmin);
		xs_vec_mul_scalar(Tabsmin, 0.5, vecSpot);
		
		pev(iEnt, pev_absmin, Aabsmin);
		pev(iEnt, pev_absmax, Aabsmax);

		xs_vec_add(Aabsmin, Aabsmax, Aabsmin);
		xs_vec_mul_scalar(Aabsmin, 0.5, vecSee);
		
        // create the trace handle.
		trace = create_tr2();
		engfunc(EngFunc_TraceLine, vecSee, vecSpot, 0, iEnt, trace);
		{
			get_tr2(trace, TR_flFraction, flFraction);
			iHit = get_tr2(trace, TR_pHit);

			// Work out the distance between impact and entity
			get_tr2(trace, TR_vecEndPos, vecEndPos);
		}
        // free the trace handle.
		free_tr2(trace);

		// Explosion can 'see' this entity, so hurt them! (or impact through objects has been enabled xD)
		if (flFraction >= 0.9 || iHit == rEnt)
		{
			distance = get_distance_f(vOrigin, vecEndPos) * falloff;
			tmpDmg -= distance;
			if(tmpDmg < 0.0)
				tmpDmg = 0.0;
			if (!equali(iClassName, tClassName))
			{
				// Kickback Effect
				if(kickBack != 0.0)
				{
					xs_vec_sub(vecSpot, vecSee, origin);
					
					invlen = 1.0 / get_distance_f(vecSpot, vecSee);

					xs_vec_mul_scalar(origin, invlen, vecPush);
					pev(rEnt, pev_velocity, velocity);
					xs_vec_mul_scalar(vecPush, tmpDmg, vecPush);
					xs_vec_mul_scalar(vecPush, kickBack, vecPush);
					xs_vec_add(velocity, vecPush, velocity);
					
					if(tmpDmg < 60.0)
						xs_vec_mul_scalar(velocity, 12.0, velocity);
					else
						xs_vec_mul_scalar(velocity, 4.0, velocity);
					
					if(velocity[0] != 0.0 || velocity[1] != 0.0 || velocity[2] != 0.0)
					{
						// There's some movement todo :)
						set_pev(rEnt, pev_velocity, velocity);
					}
				}
			}
			// Damage Effect, Damage, Killing Logic.
			ExecuteHamB(Ham_TakeDamage, rEnt, iEnt, iAttacker, tmpDmg, DMG_BLAST);
		}
	}
	return;
}

//====================================================
// show status text 
//====================================================
stock lm_show_status_text(id, szText[], msg)
{
	engfunc(EngFunc_MessageBegin, MSG_ONE, msg, {0, 0, 0}, id);
	write_byte(0);
	write_string(szText);
	message_end();	
}

//====================================================
// Hit Shield Effect 
//====================================================
stock lm_hit_shield(id, Float:dmg)
{
	static Float:punchangle[3];
	punchangle[0] = (dmg * random_float(-0.15, 0.15));
	punchangle[2] = (dmg * random_float(-0.15, 0.15));
	if (punchangle[0] < 4.0)
		punchangle[0] = -4.0;
	if (punchangle[2] < -5.0)
		punchangle[2] = -5.0;
	else
		if (punchangle[2] > 5.0)
			punchangle[2] = 5.0;

	set_pev(id, pev_punchangle, punchangle);	
}

//====================================================
// Remove all Entity.
//====================================================
stock lm_remove_all_entity(id, className[])
{
	new iEnt = -1;
	new authid[MAX_AUTHID_LENGTH];
	new steamid[MAX_AUTHID_LENGTH];
	get_user_authid(id, authid, charsmax(authid));

	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", className)))
	{
		if (!pev_valid(iEnt))
			continue;

		if (pev(iEnt, LASERMINE_OWNER) == id)
		{
			pev(iEnt, pev_netname, steamid, charsmax(steamid));
			if (equali(authid, steamid))
			{
				lm_play_sound(iEnt, SOUND_STOP);
				lm_remove_entity(iEnt);
			}
		}
	}
	// reset deploy count.
	lm_set_user_mine_deployed(id, int:0);
}

stock lm_remove_entity(iEnt)
{
	lm_stop_laserline(iEnt);
	engfunc(EngFunc_RemoveEntity, iEnt);
}

stock CsTeams:lm_get_laser_team(iEnt)
{
	return lm_get_user_team(pev(iEnt, LASERMINE_OWNER));
}

//====================================================
// Decals
//====================================================
stock LoadDecals() 
{
	new const szExplosionDecals[MAX_EXPLOSION_DECALS][] = 
	{
		"{scorch1",
		"{scorch2",
		"{scorch3"
	};

	new const szBloodDecals[MAX_BLOOD_DECALS][] = 
	{
		"{blood1",
		"{blood2",
		"{blood3",
		"{blood4",
		"{blood5",
		"{blood6",
		"{blood7",
		"{blood8",
		"{bigblood1",
		"{bigblood2"
	};

	new iDecalIndex, i;

	for(i = 0; i < MAX_EXPLOSION_DECALS; i++) 
	{
		gDecalIndexExplosion[gNumDecalsExplosion++] = 
			((iDecalIndex = engfunc(EngFunc_DecalIndex, szExplosionDecals[i]))	> 0) ? iDecalIndex : 0;
	}

	for(i = 0; i < MAX_BLOOD_DECALS; i++) 
	{
		gDecalIndexBlood[gNumDecalsBlood++] = 
			((iDecalIndex = engfunc(EngFunc_DecalIndex, szBloodDecals[i]))		> 0) ? iDecalIndex : 0;
	}
}

stock lm_create_water_explosion(iOrigin[3], const iDamage, const iRadius, sprExplosionWater) 
{
	new iZPos = (iDamage + ((iRadius * 3) / 2)) / 34;

	if(iZPos < 8)
		iZPos = 8;
	else
	if(iZPos > 128)
		iZPos = 128;

	new iIntensity = (iDamage + ((iRadius * 7) / 4)) / 14;

	if(iIntensity < 32)
		iIntensity = 32;
	else
	if(iIntensity > 164)
		iIntensity = 164;

	message_begin(MSG_PAS, SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + iZPos);
	write_short(sprExplosionWater);
	write_byte(iIntensity);
	write_byte(16);
	write_byte(0);
	message_end();
}

stock lm_create_smoke(iOrigin[3], const iDamage, const iRadius, sprSmoke)
{
	new iZPos = (iDamage + ((iRadius * 3) / 2)) / 22;

	if(iZPos < 8)
		iZPos = 8;
	else
	if(iZPos > 192)
		iZPos = 192;

	new iIntensity = (iDamage + ((iRadius * 7) / 4)) / 11;

	if(iIntensity < 32)
		iIntensity = 32;
	else
	if(iIntensity > 192)
		iIntensity = 192;

	message_begin(MSG_PAS, SVC_TEMPENTITY, iOrigin);
	write_byte(TE_SMOKE);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + iZPos);
	write_short(sprSmoke);
	write_byte(iIntensity);
	write_byte(4);
	message_end();
}

stock lm_create_explosion_decals(iOrigin[3]) 
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_WORLDDECAL);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_byte(gDecalIndexExplosion[random(gNumDecalsExplosion)]);
	message_end();
}

stock lm_create_bubbles(const Float:vOrigin[3], const Float:flDamageMax, const Float:flDamageRadius, sprBubbles) 
{
	new Float:flMaxSize = floatclamp((flDamageMax + (flDamageRadius * 1.5)) / 13.0, 24.0, 164.0);
	new Float:vMins[3], Float:vMaxs[3];
	new Float:vTemp[3];

	vTemp[0] = vTemp[1] = vTemp[2] = flMaxSize;

	xs_vec_sub(vOrigin, vTemp, vMins);
	xs_vec_add(vOrigin, vTemp, vMaxs);

	UTIL_Bubbles(vMins, vMaxs, 80, sprBubbles);
}

stock lm_create_hblood(Float:vOrigin[], iDamageMax, sprBloodSpray, sprBlood)
{
	// new iDecalIndex = g_iBloodDecalIndex[random_num(MAX_BLOOD_DECALS - 2, MAX_BLOOD_DECALS - 1)];
	
	// message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	// write_byte(TE_WORLDDECAL)
	// write_coord(iBloodOrigin[a][0])
	// write_coord(iBloodOrigin[a][1])
	// write_coord(iTraceEndZ[a])
	// write_byte(iDecalIndex)
	// message_end()

	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte(TE_BLOODSPRITE);
	engfunc(EngFunc_WriteCoord, vOrigin[0]);
	engfunc(EngFunc_WriteCoord, vOrigin[1]);
	engfunc(EngFunc_WriteCoord, vOrigin[2] + random_num(-5, 20));
	write_short(sprBloodSpray);
	write_short(sprBlood);
	write_byte(248);
	write_byte(clamp(iDamageMax / 13, 5, 16));
	message_end();
}

stock UTIL_ScreenShake(Float:vOrigin[3], const Float:flAmplitude, const Float:flDuration, const Float:flFrequency, const Float:flRadius) 
{
	new iPlayers[32], iPlayersNum;
	get_players(iPlayers, iPlayersNum, "ac");

	if(iPlayersNum > 0) 
	{
		new iPlayer;
		new iAmplitude;
		new Float:flLocalAmplitude;
		new Float:flDistance;
		new Float:vPlayerOrigin[3];

		new iDuration	= FixedUnsigned16(flDuration, 1<<12);
		new iFrequency	= FixedUnsigned16(flFrequency, 1<<8);

		for(--iPlayersNum; iPlayersNum >= 0; iPlayersNum--) 
		{
			iPlayer = iPlayers[iPlayersNum];

			flLocalAmplitude = 0.0;

			if((pev(iPlayer, EV_INT_flags) & FL_ONGROUND) == 0)
				continue;

			pev(iPlayer, pev_origin, vPlayerOrigin);

			if((flDistance = get_distance_f(vOrigin, vPlayerOrigin)) < flRadius) 
				flLocalAmplitude = flAmplitude * ((flRadius - flDistance) / 100.0);

			if(flLocalAmplitude > 0.0) 
			{
				iAmplitude = FixedUnsigned16(flLocalAmplitude, 1<<12);

				static iMsgIDScreenShake;
				if(iMsgIDScreenShake == 0) 
					iMsgIDScreenShake = get_user_msgid("ScreenShake");

				message_begin(MSG_ONE, iMsgIDScreenShake, _, iPlayer);
				write_short(iAmplitude);
				write_short(iDuration);
				write_short(iFrequency);
				message_end();
			}
		}
	}
}

stock FixedUnsigned16(Float:flValue, iScale) 
{
	new iOutput = floatround(flValue * iScale);

	if(iOutput < 0)
		iOutput = 0;

	if(iOutput > 0xFFFF)
		iOutput = 0xFFFF;

	return iOutput;
}

stock Float:UTIL_WaterLevel(const Float:vCenter[3], Float:vMinZ, Float:vMaxZ) 
{
	new Float:vMiddleUp[3];

	vMiddleUp[0] = vCenter[0];
	vMiddleUp[1] = vCenter[1];
	vMiddleUp[2] = vMinZ;

	if(engfunc(EngFunc_PointContents, vMiddleUp) != CONTENTS_WATER)
		return vMinZ;

	vMiddleUp[2] = vMaxZ;
	if(engfunc(EngFunc_PointContents, vMiddleUp) == CONTENTS_WATER)
		return vMaxZ;

	new Float:flDiff = vMaxZ - vMinZ;

	while(flDiff > 1.0) 
	{
		vMiddleUp[2] = vMinZ + flDiff / 2.0;

		if(engfunc(EngFunc_PointContents, vMiddleUp) == CONTENTS_WATER)
			vMinZ = vMiddleUp[2];
		else
			vMaxZ = vMiddleUp[2];

		flDiff = vMaxZ - vMinZ;
	}

	return vMiddleUp[2];
}

stock UTIL_Bubbles(const Float:vMins[3], const Float:vMaxs[3], const iCount, sprBubble)
{
	new Float:vCenter[3];
	xs_vec_add(vMins, vMaxs, vCenter);
	xs_vec_mul_scalar(vCenter, 0.5, vCenter);

	new Float:flPosition = UTIL_WaterLevel(vCenter, vCenter[2], vCenter[2] + 1024.0) - vMins[2];

	new iCenter[3];
	FVecIVec(vCenter, iCenter);

	message_begin(MSG_PAS, SVC_TEMPENTITY, iCenter);
	write_byte(TE_BUBBLES);
	write_coord(floatround(vMins[0]));
	write_coord(floatround(vMins[1]));
	write_coord(floatround(vMins[2]));
	write_coord(floatround(vMaxs[0]));
	write_coord(floatround(vMaxs[1]));
	write_coord(floatround(vMaxs[2]));
	write_coord(floatround(flPosition));
	write_short(sprBubble);
	write_byte(iCount);
	write_coord(8);
	message_end();
}

#if AMXX_VERSION_NUM < 190
stock fmt(const szString[], any:...)
{
	new result[512];
	vformat(result, charsmax(result), szString, 2);
	return result;
}

stock split_string(const szSource[], const szDelim[], szParsed[], iMaxChars)
{
    new iPos = strfind(szSource, szDelim);
    return (iPos > -1) ? copy(szParsed, min(iPos, iMaxChars), szSource) + strlen(szDelim) : -1;
}

/**
 * Computes the distance between two vectors (points).
 *
 * @param vec1          First vector.
 * @param vec2          Second vector.
 *
 * @return              The distance between two vectors.
 */
stock Float:xs_vec_distance(const Float:vec1[], const Float:vec2[])
{
	return xs_sqrt((vec1[0]-vec2[0]) * (vec1[0]-vec2[0]) +
	               (vec1[1]-vec2[1]) * (vec1[1]-vec2[1]) +
	               (vec1[2]-vec2[2]) * (vec1[2]-vec2[2]));
}
#endif