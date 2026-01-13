new bool:g_bThirdPersonEnabled[MAXPLAYERS+1] = {false, ...};

public void OPS_TPFP(Handle:event, const String:name[])
{
	new userid = GetEventInt(event, "userid");
	if (g_bThirdPersonEnabled[GetClientOfUserId(userid)])
	{
		CreateTimer(0.2, SetViewOnSpawn, userid);
	}
}

public Action:SetViewOnSpawn(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	
    if ( client != 0 )	//Checked g_bThirdPersonEnabled in hook callback, dont need to do it here~
	{
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}
}

public void OCD_TPFP(client)
{
	g_bThirdPersonEnabled[client] = false;
}


public Action:Command_ThirdPerson(client, args)
{
	if ( client != 0 )
	{
		if( !IsPlayerAlive(client) )
		{
			PrintToChat(client, "%s Thirdperson view will be enabled when you spawn.", CHAT_PREFIX);
		} else {
			PrintToChat(client, "%s You have enabled now 'ThirdPerson' mode. To disable it, write !fp in chat", CHAT_PREFIX);
		}

		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
		g_bThirdPersonEnabled[client] = true;
	} else {
		ReplyToCommand(client, "%s Command is in-game only", CONS_PREFIX);
	}

	return Plugin_Handled;
}

public Action:Command_FirstPerson(client, args)
{
	if ( client != 0 )
	{
		// if(!IsPlayerAlive(client))
			PrintToChat(client, "%s Thirdperson view disabled.", CHAT_PREFIX);

		SetVariantInt(0);
		AcceptEntityInput(client, "SetForcedTauntCam");
		g_bThirdPersonEnabled[client] = false;
	} else {
		ReplyToCommand(client, "%s Command is in-game only", CONS_PREFIX);
	}

	return Plugin_Handled;
}