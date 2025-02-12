// Custom Resources available.
new Array:gPathEntModelsCT;
new Array:gPathEntSoundCT	[E_SOUNDS];
new Array:gPathEntSpritesCT	[E_SPRITES];
new Array:gPathEntModelsTR;
new Array:gPathEntSoundTR	[E_SOUNDS];
new Array:gPathEntSpritesTR	[E_SPRITES];
new Array:gSpritesCT		[E_SPRITES];
new Array:gSpritesTR		[E_SPRITES];
//====================================================
// Load setting for Custom Researces.
//====================================================
/*
new const ENT_DEFAULT_MODELS[]				= "models/v_tripmine.mdl";
new const ENT_DEFAULT_SOUNDS[E_SOUNDS][]	=	
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
new const ENT_DEFAULT_SPRITES[E_SPRITES][]	=
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
enum _:E_SOUNDS
{
	DEPLOY							,
	CHARGE							,
	ACTIVATE						,
	PICKUP							,
	LASER_HIT						,
	SHIELD_HIT						,
	BREAK							,
}

enum _:E_SPRITES
{
	LASER							,
	EXPLOSION						,
	EXPLOSION_WATER					,
	BLAST							,
	SMOKE							,
	BUBBLE							,
	BLOOD_SPLASH					,
	BLOOD_SPRAY						,
};
*/

stock lm_resources_load()
{
	// =================
	// INITIALIZE ARRAY.
	// =================
//	console_print(0, "[LASERMINE] START LOAD RESOURCES");
//	console_print(0, "[LASERMINE] INITIALIZE");
	gPathEntModelsCT = ArrayCreate(MAX_RESOURCE_PATH_LENGTH);
	gPathEntModelsTR = ArrayCreate(MAX_RESOURCE_PATH_LENGTH);
	for(new E_SOUNDS:i = DEPLOY; i < E_SOUNDS; i++)
    {
		gPathEntSoundCT	[i] = ArrayCreate(MAX_RESOURCE_PATH_LENGTH);
		gPathEntSoundTR	[i] = ArrayCreate(MAX_RESOURCE_PATH_LENGTH);
    }
	for(new E_SPRITES:i = LASER; i < E_SPRITES; i++)
	{
		gPathEntSpritesCT	[i] = ArrayCreate(MAX_RESOURCE_PATH_LENGTH);
		gPathEntSpritesTR	[i] = ArrayCreate(MAX_RESOURCE_PATH_LENGTH);
		gSpritesCT[i] = ArrayCreate();
		gSpritesTR[i] = ArrayCreate();
	}

//	console_print(0, "[LASERMINE] JSON PARSE");
	// Open JSON.
	
	new file[64];
	new len = charsmax(file);
	get_localinfo("amxx_configsdir", file, len);
	format(file, len, "%s/%s", file, JSON_FILE);

	new JSON:json = json_parse(file, true, false);
	if (!file_exists(file))
	{
		console_print(0, "[LASERMINE] JSON FILE NOT FOUND => %s", JSON_FILE);
		// console_print(0, "[LASERMINE] INVALID FORMAT");
		console_print(0, "[LASERMINE] LOAD DEFAULTS");
		for (new E_MODELS:i = V_WPN; i < E_MODELS; i++)
    	{
	        load_default_models(i, CS_TEAM_CT);
	        load_default_models(i, CS_TEAM_T);
		}

		for (new E_SOUNDS:i = DEPLOY; i < E_SOUNDS; i++)
    	{
	        load_default_sounds(i, CS_TEAM_CT);
	        load_default_sounds(i, CS_TEAM_T);
		}

		for (new E_SPRITES:i = LASER; i < E_SPRITES; i++)
		{
			load_default_sprites(i, CS_TEAM_CT);
			load_default_sprites(i, CS_TEAM_T);
		}

		return;
	}

	new szValue[MAX_RESOURCE_PATH_LENGTH];
	new JSON:value_ct;
	new JSON:value_tr;
	new count_ct;
	new count_tr;

	// MODELS.
//	object = json_array_get_value(json, 0);
	for (new E_MODELS:i = V_WPN; i < E_MODELS; i++)
    {
		szValue = "";
		json_object_get_string(json, JSON_KEY_MODELS_CT[_:i], szValue, charsmax(szValue));
		if (strlen(szValue) == 0 || equali(szValue, ""))
			load_default_models(i, CS_TEAM_CT);
		else
			ArrayPushString(gPathEntModelsCT, szValue);

		szValue = "";
		json_object_get_string(json, JSON_KEY_MODELS_TR[_:i], szValue, charsmax(szValue));
		if (strlen(szValue) == 0 || equali(szValue, ""))
			load_default_models(i, CS_TEAM_T);
		else
    		ArrayPushString(gPathEntModelsTR, szValue);
    }

	// SOUNDS.
	for (new E_SOUNDS:i = DEPLOY; i < E_SOUNDS; i++)
	{
		value_ct = json_object_get_value(json, JSON_KEY_SOUNDS_CT[_:i], true);
		value_tr = json_object_get_value(json, JSON_KEY_SOUNDS_TR[_:i], true);
		count_ct = json_array_get_count(value_ct);
		count_tr = json_array_get_count(value_tr);
		if (count_ct > 0)
		{
			for(new n = 0; n < count_ct; n++)
			{
				json_array_get_string(value_ct, n, szValue, charsmax(szValue));
				if (equali(szValue, ""))
					load_default_sounds(i, CS_TEAM_CT);
				else
					ArrayPushString(gPathEntSoundCT[i], szValue);
				// console_print(0, "%s => %s", JSON_KEY_SOUNDS[_:i], szValue);
			}
		}
		else
		{
			load_default_sounds(i, CS_TEAM_CT);
		}

		if (count_tr > 0)
		{
			for(new n = 0; n < count_tr; n++)
			{
				json_array_get_string(value_tr, n, szValue, charsmax(szValue));
				if (equali(szValue, ""))
					load_default_sounds(i, CS_TEAM_T);
				else
					ArrayPushString(gPathEntSoundTR[i], szValue);
				// console_print(0, "%s => %s", JSON_KEY_SOUNDS[_:i], szValue);
			}
		}
		else
		{
			load_default_sounds(i, CS_TEAM_T);
		}

		json_free(value_tr);
		json_free(value_ct);
	}

	// SOUNDS.
	for (new E_SPRITES:i = LASER; i < E_SPRITES; i++)
	{
		value_ct = json_object_get_value(json, JSON_KEY_SPRITES_CT[_:i], true);
		value_tr = json_object_get_value(json, JSON_KEY_SPRITES_TR[_:i], true);
		count_ct = json_array_get_count(value_ct);
		count_tr = json_array_get_count(value_tr);
		if (count_ct > 0)
		{
			for(new n = 0; n < count_ct; n++)
			{
				json_array_get_string(value_ct, n, szValue, charsmax(szValue));
				if (equali(szValue, ""))
					load_default_sprites(i, CS_TEAM_CT);
				else
					ArrayPushString(gPathEntSpritesCT[i], szValue);
				// console_print(0, "%s => %s", JSON_KEY_SPRITES_CT[_:i], szValue);
			}
		}
		else
		{
			load_default_sprites(i, CS_TEAM_CT);
		}

		if (count_tr > 0)
		{
			for(new n = 0; n < count_tr; n++)
			{
				json_array_get_string(value_tr, n, szValue, charsmax(szValue));
				if (equali(szValue, ""))
					load_default_sprites(i, CS_TEAM_T);
				else
					ArrayPushString(gPathEntSpritesTR[i], szValue);
				// console_print(0, "%s => %s", JSON_KEY_SPRITES_CT[_:i], szValue);
			}
		}
		else
		{
			load_default_sprites(i, CS_TEAM_T);
		}
		json_free(value_ct);
		json_free(value_tr);
	}
	json_free(json);
}

stock load_default_models(E_MODELS:i, CsTeams:team)
{
    switch(i)
    {
        case V_WPN: ArrayPushString((team == CS_TEAM_CT) ? gPathEntModelsCT : gPathEntModelsTR, "models/v_tripmine.mdl");
        case P_WPN: ArrayPushString((team == CS_TEAM_CT) ? gPathEntModelsCT : gPathEntModelsTR, "models/p_tripmine.mdl");
        case W_WPN: ArrayPushString((team == CS_TEAM_CT) ? gPathEntModelsCT : gPathEntModelsTR, "models/v_tripmine.mdl");
    }
}

stock load_default_sounds(E_SOUNDS:i, CsTeams:team)
{
	switch(i)
	{
		case DEPLOY:
		{
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSoundCT[i] : gPathEntSoundTR[i], "weapons/mine_deploy.wav");
		}
		case CHARGE:
		{
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSoundCT[i] : gPathEntSoundTR[i], "weapons/mine_charge.wav");
		}
		case ACTIVATE:
		{
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSoundCT[i] : gPathEntSoundTR[i], "weapons/mine_activate.wav");
		}
		case PICKUP:
		{
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSoundCT[i] : gPathEntSoundTR[i], "items/gunpickup2.wav");
		}
		case LASER_HIT:
		{
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSoundCT[i] : gPathEntSoundTR[i], "debris/beamstart9.wav");
		}
		case SHIELD_HIT:
		{
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSoundCT[i] : gPathEntSoundTR[i], "weapons/ric_metal-1.wav");
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSoundCT[i] : gPathEntSoundTR[i], "weapons/ric_metal-2.wav");
		}
		case BREAK:
		{
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSoundCT[i] : gPathEntSoundTR[i], "debris/bustglass1.wav");
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSoundCT[i] : gPathEntSoundTR[i], "debris/bustglass2.wav");
		}
	}
}

stock load_default_sprites(E_SPRITES:i, CsTeams:team)
{
	switch(i)
	{
		case LASER:
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSpritesCT[i] : gPathEntSpritesTR[i], "sprites/laserbeam.spr");
		case EXPLOSION_1:
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSpritesCT[i] : gPathEntSpritesTR[i], "sprites/fexplo.spr");
		case EXPLOSION_2:
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSpritesCT[i] : gPathEntSpritesTR[i], "sprites/eexplo.spr");
		case EXPLOSION_WATER:
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSpritesCT[i] : gPathEntSpritesTR[i], "sprites/WXplo1.spr");
		case BLAST:	
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSpritesCT[i] : gPathEntSpritesTR[i], "sprites/blast.spr");
		case SMOKE:
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSpritesCT[i] : gPathEntSpritesTR[i], "sprites/steam1.spr");
		case BUBBLE:
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSpritesCT[i] : gPathEntSpritesTR[i], "sprites/bubble.spr");
		case BLOOD_SPLASH:
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSpritesCT[i] : gPathEntSpritesTR[i], "sprites/blood.spr");
		case BLOOD_SPRAY:
			ArrayPushString((team == CS_TEAM_CT) ? gPathEntSpritesCT[i] : gPathEntSpritesTR[i], "sprites/bloodspray.spr");
	}
}

stock lm_resources_precache()
{
	new szValue[MAX_RESOURCE_PATH_LENGTH];

	// MODELS.
	for (new E_MODELS:i = V_WPN; i < E_MODELS; i++)
	{
		szValue = "";
		ArrayGetString(gPathEntModelsCT, _:i, szValue, charsmax(szValue));
		precache_model(szValue);
		szValue = "";
		ArrayGetString(gPathEntModelsTR, _:i, szValue, charsmax(szValue));
		precache_model(szValue);
	}

	// SOUNDS.
	for (new E_SOUNDS:i = DEPLOY; i < E_SOUNDS; i++)
	{
		for(new n = 0; n < ArraySize(gPathEntSoundCT[i]); n++)
		{
			szValue = "";
			ArrayGetString(gPathEntSoundCT[i], n, szValue, charsmax(szValue));
			precache_sound(szValue);
		}
		for(new n = 0; n < ArraySize(gPathEntSoundTR[i]); n++)
		{
			szValue = "";
			ArrayGetString(gPathEntSoundTR[i], n, szValue, charsmax(szValue));
			precache_sound(szValue);
		}
	}

	// SPRITES.
	for (new E_SPRITES:i = LASER; i < E_SPRITES; i++)
	{
		for(new n = 0; n < ArraySize(gPathEntSpritesCT[i]); n++)
		{
			szValue = "";
			ArrayGetString(gPathEntSpritesCT[i], n, szValue, charsmax(szValue));
			ArrayPushCell(gSpritesCT[i], precache_model(szValue));
		}
		for(new n = 0; n < ArraySize(gPathEntSpritesTR[i]); n++)
		{
			szValue = "";
			ArrayGetString(gPathEntSpritesTR[i], n, szValue, charsmax(szValue));
			ArrayPushCell(gSpritesTR[i], precache_model(szValue));
		}
	}

}

stock lm_resources_release()
{
    // =================
	// INITIALIZE ARRAY.
	// =================
	ArrayDestroy(gPathEntModelsCT);
	ArrayDestroy(gPathEntModelsTR);
	for(new E_SOUNDS:i = DEPLOY; i < E_SOUNDS; i++)
    {
		ArrayDestroy(gPathEntSoundCT[i]);
		ArrayDestroy(gPathEntSoundTR[i]);
    }
	for(new E_SPRITES:i = LASER; i < E_SPRITES; i++)
    {
		ArrayDestroy(gPathEntSpritesCT[i]);
		ArrayDestroy(gPathEntSpritesTR[i]);
    }
}


stock lm_get_models(const E_MODELS:model, const CsTeams:team, szValue[], const szLength) 
{
	ArrayGetString((team == CS_TEAM_CT) ? gPathEntModelsCT : gPathEntModelsTR, _:model, szValue, szLength);
}

stock lm_get_sounds(const E_SOUNDS:sound, const CsTeams:team, szValue[], const szLength) 
{
	ArrayGetString((team == CS_TEAM_CT) ? gPathEntSoundCT[sound] : gPathEntSoundTR[sound], random_num(0, ArraySize((team == CS_TEAM_CT) ? gPathEntSoundCT[sound] : gPathEntSoundTR[sound]) - 1), szValue, szLength);
}

stock lm_get_sprites_cell(const E_SPRITES:sprite, const CsTeams:team)
{
	return ArrayGetCell((team == CS_TEAM_CT) ? gSpritesCT[sprite] : gSpritesTR[sprite], random_num(0, ArraySize((team == CS_TEAM_CT) ? gSpritesCT[sprite] : gSpritesTR[sprite]) - 1));
}

stock lm_get_sprites_path(const E_SPRITES:sprite, const CsTeams:team, szValue[], const szLength)
{
	ArrayGetString((team == CS_TEAM_CT) ? gPathEntSpritesCT[sprite] : gPathEntSpritesTR[sprite], random_num(0, ArraySize((team == CS_TEAM_CT) ? gPathEntSpritesCT[sprite] : gPathEntSpritesTR[sprite]) - 1), szValue, szLength);
}