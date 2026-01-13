// #pragma semicolon 1

new bool:g_fiammo[MAXPLAYERS+1];

// Commands
public Action:Command_InfAmmo(int client, int args)
{
	// Check args first
	if ( args < 1 )
	{
		// Admin menu
		// if ( args == 0 && client > 0)
		// {
			
		// }

		Snowy_ReplyToCommand(client, "sm_infammo <player>")
		return Plugin_Handled;
	}

	new String:fiatarget[MAX_NAME_LENGTH], String:target_name[MAX_TARGET_LENGTH],target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	GetCmdArg(1, fiatarget, sizeof(fiatarget));
	// GetCmdArg(2, str_fiaswitch, sizeof(str_fiaswitch));

	if ( ( target_count = ProcessTargetString(fiatarget, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml) ) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}


	for( new i = 0; i < target_count; i++ )
	{
		if ( g_fiammo[target_list[i]] == false)
		{
			g_fiammo[target_list[i]] = true;
		} else {
			g_fiammo[target_list[i]] = false;
		}
		SendMessageToClient(target_list[i], "%N has given you infinite ammo (Reserve ammo.)", client);
		Snowy_ReplyToCommand(client, "Gave %N infinite ammo (Reserve ammo.)", target_list[i]);
	}
// 		if(fiaswitch) 
// 		{
// 			g_fiammo[target_list[i]] = true;
// 		}
// 		else
// 		{
// 			g_fiammo[target_list[i]] = false;
// 			if(IsClientInGame(target_list[i]) && IsPlayerAlive(target_list[i]))
// 			{
// 				new health = GetClientHealth(target_list[i]);
// 				SetEntProp(target_list[i], Prop_Send, "m_iRevengeCrits", 0);
// 				TF2_RegeneratePlayer(target_list[i]);
// 				SetEntityHealth(target_list[i], health);
// 			}
// 		}
// 		if(GetConVarBool(hLog)) LogAction(client, target_list[i], "\"%L\" Set Infinite Ammo for  \"%L\" to (%i)", client, target_list[i], fiaswitch);
// 	}

// 	if(GetConVarBool(hChat))
// 	{
// 		if(fiaswitch) ShowActivity2(client, "\x07FFA500[SM]\x01 ","Enabled Infinite Ammo for %s", target_name);
// 		else ShowActivity2(client, "\x07FFA500[SM]\x01 ","Disabled Infinite Ammo for %s", target_name);
// 	}

	return Plugin_Handled;
}

public InfiniteAmmo_Start()
{
	// LoadTranslations("common.phrases");

	RegAdminCmd("sm_infammo", Command_InfAmmo, ADMFLAG_CHEATS, "Give Infinite Ammo to a user.")
}

public OGF_InfAmmo()
{
	for ( new i = 1; i <= MaxClients; i++ )
	{
		if ( ( IsClientInGame(i) && IsPlayerAlive(i) ) && ( g_fiammo[i] ))
		{
			new weapon = GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon");
			new TFClassType:playerclass = TF2_GetPlayerClass(i);
			new String:weaponClass[256];
			GetEntityClassname(weapon, weaponClass, sizeof(weaponClass));
			
			// if( !IsValidEntity(weapon) ) continue;
			int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");

			// Ignore melees. I think their ammoType is -1...
			if ( ammoType != -1)
			{
				int currentReserve = GetEntProp(i, Prop_Send, "m_iAmmo", _, ammoType);
				int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
				int maxReserve = currentReserve;
				bool found = false;
				
				// PrintToChatAll("%s %s %i", weaponClass, weapon, weaponindex);

				// Do it by id first cuz fuck me.

				// Soldier
				if ( weaponindex == 237 )
				{
					found = true;
					maxReserve = 60;
				}

				if ( found == false )
				{
					if ( StrEqual(weaponClass, "tf_weapon_pistol", false) )
					{
						found = true;
						if ( playerclass == TFClass_Engineer ) {
							maxReserve = 200;
						} else {
							maxReserve = 36;
						}

					// Scout
					} else if ( StrEqual(weaponClass, "tf_weapon_scattergun", false) ) {
						found = true;
						maxReserve = 32;
					} else if ( StrEqual(weaponClass, "tf_weapon_pistol_scout", false) ) {
						found = true;
						maxReserve = 36;

					// Soldier
					} else if ( StrEqual(weaponClass, "tf_weapon_rocketlauncher", false) ) {
						found = true;
						maxReserve = 20;
					} else if ( StrEqual(weaponClass, "tf_weapon_shotgun_soldier", false) ) {
						found = true;
						maxReserve = 32;

					// Pyro
					} else if ( StrEqual(weaponClass, "tf_weapon_flamethrower", false) ) {
						found = true;
						maxReserve = 200;
					} else if ( StrEqual(weaponClass, "tf_weapon_rocketlauncher_fireball", false) ) {
						found = true;
						maxReserve = 40;
					} else if ( StrEqual(weaponClass, "tf_weapon_shotgun_pyro", false) ) {
						found = true;
						maxReserve = 32;

					// Demoman
					} else if ( StrEqual(weaponClass, "tf_weapon_grenadelauncher", false) ) {
						found = true;
						maxReserve = 16;
					} else if ( StrEqual(weaponClass, "tf_weapon_pipebomblauncher", false) ) {
						found = true;
						maxReserve = 24;

					// Heavy
					} else if ( StrEqual(weaponClass, "tf_weapon_minigun", false) ) {
						found = true;
						maxReserve = 200;
					} else if ( StrEqual(weaponClass, "tf_weapon_shotgun_hwg", false) ) {
						found = true;
						maxReserve = 32;

					// Engineer
					} else if ( StrEqual(weaponClass, "tf_weapon_shotgun_primary", false) ) {
						// Ignore WidowMaker and The Pomson
						if ( weaponindex == 527 || weaponindex == 528)
						{
							/*
								Ignore:
								WidowMaker
								The Pomson
							*/
						} else {
							found = true;
							maxReserve = 32;
						}

					// Medic
					} else if ( StrEqual(weaponClass, "tf_weapon_syringegun_medic", false) ) {
						found = true;
						maxReserve = 150;
					} else if ( StrEqual(weaponClass, "tf_weapon_crossbow", false) ) {
						found = true;
						maxReserve = 38;

					// Sniper
					} else if ( StrEqual(weaponClass, "tf_weapon_sniperrifle", false) ) {
						found = true;
						maxReserve = 25;
					} else if ( StrEqual(weaponClass, "tf_weapon_compound_bow", false) ) {
						found = true;
						maxReserve = 12;
					} else if ( StrEqual(weaponClass, "tf_weapon_smg", false) ) {
						found = true;
						maxReserve = 75;

					// Spy
					} else if ( StrEqual(weaponClass, "tf_weapon_revolver", false) ) {
						found = true;
						maxReserve = 24;

					// } else if ( StrEqual(weaponClass, "", false) ) {
					}
				}
				
				// Final
				if ( found )
				{
					if ( currentReserve == maxReserve )
					{
						// Nothing
					} else {
						SetEntProp(i, Prop_Send, "m_iAmmo", maxReserve, _, ammoType);
						// DataPack pack = new DataPack();
						// pack.WriteCell(i);
						// pack.WriteCell(ammoType);
						// pack.WriteCell(maxReserve);

						// CreateTimer(0.2, Timer_SetAmmo, pack, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
}

// public Action Timer_SetAmmo(Handle timer, DataPack pack)
// {
// 	pack.Reset();

// 	int client = pack.ReadCell();
// 	int ammoType = pack.ReadCell();
// 	int maxReserve = pack.ReadCell();

// 	delete pack;

// 	PrintToChatAll("Run SetAmmo");
// 	if ( IsClientInGame(client) && IsPlayerAlive(client) )
// 	{
// 		SetEntProp(client, Prop_Send, "m_iAmmo", maxReserve, _, ammoType);
// 	}

// 	return Plugin_Stop;
// }

public OCPIS_InfAmmo(client)
{
	// if(GetConVarBool(hAll))
	// {
	// 	g_fiammo[client] = true;
	// } else {
		// g_fiammo[client] = false;
	// }
}

public OCDP_InfAmmo(client)
{
	// g_fiammo[client] = false;
}
