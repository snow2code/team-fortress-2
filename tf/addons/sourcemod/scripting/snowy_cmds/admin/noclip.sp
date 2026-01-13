void PerformNoclip(int client, int target)
{
	MoveType movetype = GetEntityMoveType(target);

	if (movetype != MOVETYPE_NOCLIP)
	{
		SetEntityMoveType(target, MOVETYPE_NOCLIP);
	}
	else
	{
		SetEntityMoveType(target, MOVETYPE_WALK);
	}
	
	LogAction(client, target, "\"%L\" toggled noclip on \"%L\"", client, target);
}

public void AdminMenu_Noclip(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Noclip player", param);
	} else if (action == TopMenuAction_SelectOption) {
		DisplayNoclipMenu(param);
	}
}

void DisplayNoclipMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Noclip);
	
	char title[100];
	Format(title, sizeof(title), "%T:", "Noclip player", client);
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	AddTargetsToMenu(menu, client, true, true);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Noclip(Menu menu, MenuAction action, int param1, int param2)
{
	if ( action == MenuAction_End )
	{
		delete menu;
	} else if ( action == MenuAction_Cancel ) {
		if ( param2 == MenuCancel_ExitBack && hTopMenu )
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	} else if ( action == MenuAction_Select ) {
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ( ( target = GetClientOfUserId(userid) ) == 0 )
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available");
		} else if ( !CanUserTarget(param1, target))  {
			PrintToChat(param1, "[SM] %t", "Unable to target");
		} else {
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			
			PerformNoclip(param1, target);
			ShowActivity2(param1, "[SM] ", "%t", "Toggled noclip on target", "_s", name);
		}
		
		/* Re-draw the menu if they're still valid */
		if (IsClientInGame(param1) && !IsClientInKickQueue(param1))
		{
			DisplayNoclipMenu(param1);
		}
	}

	return 0;
}

public Action Command_Noclip(int client, int args)
{
	if ( args < 1 )
	{
		// ReplyToCommand(client, "[SM] Usage: sm_noclip <#userid|name>");
		if ( client == 0 )
		{
			Snowy_ReplyToCommand(client, "Usage: sm_noclip <#userid|name>");
		} else {
			Snowy_ReplyToCommand(client, "Open menu");
		}
		return Plugin_Handled;
	}

	char arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (int i = 0; i < target_count; i++)
	{
		PerformNoclip(client, target_list[i]);
	}
	
	if ( g_displayNoclipUsed.BoolValue == true )
	{
		SendMessageToAll("Toggle noclip on %s", target_name);
	}

	// if (tn_is_ml)
	// {
	// 	ShowActivity2(client, "[SM] ", "%t", "Toggled noclip on target", target_name);
	// }
	// else
	// {
	// 	ShowActivity2(client, "[SM] ", "%t", "Toggled noclip on target", "_s", target_name);
	// }
	
	return Plugin_Handled;
}
