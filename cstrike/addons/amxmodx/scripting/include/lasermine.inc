
#if defined _lasermine_natives_included
    #endinput
#endif
#define _lasermine_natives_included
#if AMXX_VERSION_NUM >= 175
	#pragma reqlib lasermine_natives
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib lasermine_natives
	#endif
#else
	#pragma library lasermine_natives
#endif

/**
 * Adds one or more remaining laser mines to the player
 *
 * @param client				Client index to add to
 * @param amount    			Amount of laser mines to add.
 * @param uselimit  			Set to true to use the plugin limitation, false to ignore
 * @return 						new amount of laser mines
 */
native      LM_Give(client, amount = 1, bool:uselimit = true);

/**
 * Sets the player's amount of the remaining laser mines
 *
 * @param client				Client index to set to
 * @param amount 				Amount of laser mines to set. Negative numbers to set to infinity, 0 - to remove all and positive number to set to the amount
 * @param uselimit				Set to true to use the plugin limitation, false to ignore
 * @return 						new amount of laser mines
 */
native 		LM_Set(client, amount, bool:uselimit = true);

/**
 * Subtracts one or more remaining lasermines from the player
 *
 * @param client 				Client index to substract from
 * @param amount 				Amount of laser mines to substract.
 * @return 						new amount of laser mines
 */
native      LM_Sub(client, amount = 1);

/**
 * Returns number of remaining laser mines a player has.
 *
 * @param client 				Client index to get from
 * @return 						number of remaining laser mines.
 */
native      LM_Get(client);

/**
 * Clears the map from the player's laser mines
 *
 * @param client   				Client index to clear
 * @noreturn
 */
native      LM_RemoveAll(client);

/**
 * Checks whether the entity is a lasermine
 *
 * @param entity 				Entity index to check
 * @return 						True if the entity is a lasermine, false otherwise
 */
native bool:IsLM(entity);

/**
 * Gets client index by the lasermine
 *
 * @param entity 				Entity index to get the owner for
 * @return 						Client index or -1 if no client found
 */
native      LM_GetOwner(entity);

/**
 * Gets beam index by the lasermine
 *
 * @param entity 				The lasermine index to get the laser for
 * @return 						Beam index or -1 if no laser found
 */
native      LM_GetLaser(entity);

/**
 * Called when the player is about to buy a laser mine
 *
 * @param client 				Client index of the player who is buying a laser mine
 * @param amount 				The amount of laser mines a player is going to buy. Set by reference
 * @param price 				The laser mine price. Set by reference
 * @return 						Plugin_Changed to apply new values, Plugin_Contninue to allow buy as is and >= Plugin_Handled to block the operation
 */
forward     LM_OnBuy_Pre(client, &amount, &price);


/**
 * Called when a player has bought a laser mine
 *
 * @param client 				Client index of the player who has bought
 * @param amount 				The amount of laser mines have been bought
 * @param sum	 				The sum of money the player cost
 * @noreturn
 */
forward     LM_OnBuy_Post(client, amount, sum);

/**
 * Called when the player is about to plant a laser mine
 *
 * @param client 				Client index of the player
 * @param act_delay 			Activation time. Set by reference
 * @return         				Plugin_Changed to apply new values, Plugin_Contninue to allow the planting as is and >= Plugin_Handled to block the planting
 */
forward     LM_OnPlant(client, &Float:act_delay);

/**
 * Called when the player planted a laser mine
 *
 * @param client 				Client index of the player
 * @param lasermine 			The lasermine index
 * @noreturn
 */
forward     LM_OnPlanted(client, lasermine);

/**
 * Called when the player is about to be hitted by a laser mine
 *
 * @param victim 				Client index of the player who is being hitted
 * @param attacker 				The owner index of the laser mine. Set by reference
 * @param beam 					The beam index which is going to inflict the victim. Set by reference
 * @param lasermine 			The lasermine index which is going to inflict the victim. Set by reference
 * @param damage 				Damage of the hit. Set by reference
 * @return 						Plugin_Changed to apply new values, Plugin_Contninue to allow the hit as is and >= Plugin_Handled to block the hit
 */
forward     LM_OnHit_Pre(victim, &attacker, &lasermine, &damage);


/**
 * Called when the player has been hitted by a laser mine
 *
 * @param victim 				Client index of the player who has been hitted
 * @param attacker 				The owner index of the laser mine
 * @param beam 					The beam index which has inflicted the victim
 * @param lasermine 			The lasermine index which has inflicted the victim
 * @param damage 				Damage of the hit
 * @noreturn
 */
forward     LM_OnHit_Post(victim, attacker, lasermine, damage);

/**
 * Called when the player is about to pickup a lasermine
 *
 * @param client 				Client index of the player who is going to pickup
 * @param lasermine 			Lasermine index which is being picked up
 * @return 						Plugin_Contninue or Plugin_Changed to allow the pickup and Plugin_Handled or Plugin_Stop to block the pickup
 */
forward     LM_OnPickup_Pre(client, lasermine);


/**
 * Called when the player has picked up a lasermine
 *
 * @param client 				Client index of the player who has picked up a lasermine
 * @noreturn
 */
forward     LM_OnPickup_Post(client); 