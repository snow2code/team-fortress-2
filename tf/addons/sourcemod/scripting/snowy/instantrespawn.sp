
ConVar g_cvarInstantRespawn;
bool canRespawn = true;

public InstantRespawn_RoundStart()
{
    canRespawn = true
}

public InstantRespawn_RoundEnd()
{
    canRespawn = false
}

public InstantRespawn_Start()
{
	if (FindConVar("sm_instantrespawn"))
	{
		g_cvarInstantRespawn = FindConVar("sm_instantrespawn");
	} else {
    	g_cvarInstantRespawn = CreateConVar("sm_instantrespawn", "1", "Enable or disable instant respawn", FCVAR_NONE); // FCVAR_NOTIFY);
	}
}

public bool IsInstantRespawnEnabled()
{
    if (g_cvarInstantRespawn != null)
    {
        return g_cvarInstantRespawn.BoolValue;
    }

    return false;
}


// Real Code Below
public Action:OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (canRespawn)
    {
	    RequestFrame(Respawn, GetClientSerial(client));
    }
}

public Respawn(any:serial)
{
	new client = GetClientFromSerial(serial);
	if(client != 0)
	{
        new team = GetClientTeam(client);
        if(!IsPlayerAlive(client) && team != 1)
        {
            CreateTimer(0.1, Timer_RespawnPlayer, client);
            // CreateTimer(5.5, Timer_RespawnPlayer, client);
        }
	}
}

public Action Timer_RespawnPlayer(Handle timer, any client)
{
    if (IsInstantRespawnEnabled())
    {
        if (!IsPlayerAlive(client))
        {
            if (canRespawn)
            {
                TF2_RespawnPlayer(client);
            }
        }
    }
    
    return Plugin_Handled;
}

