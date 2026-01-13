
bool IsClientAllowedToChangeCvar(int client, const char[] cvarname)
{
	ConVar hndl = FindConVar(cvarname);

	bool allowed = false;
	int client_flags = client == 0 ? ADMFLAG_ROOT : GetUserFlagBits(client);
	
	if (client_flags & ADMFLAG_ROOT)
	{
		allowed = true;
	}
	else
	{
		if (hndl.Flags & FCVAR_PROTECTED)
		{
			allowed = ((client_flags & ADMFLAG_PASSWORD) == ADMFLAG_PASSWORD);
		}
		else if (StrEqual(cvarname, "sv_cheats"))
		{
			allowed = ((client_flags & ADMFLAG_CHEATS) == ADMFLAG_CHEATS);
		}
		else if (!IsVarProtected(cvarname))
		{
			allowed = true;
		}
	}

	return allowed;
}

void ProtectVar(const char[] cvar)
{
	g_ProtectedVars.SetValue(cvar, 1);
}

bool IsVarProtected(const char[] cvar)
{
	int dummy_value;
	return g_ProtectedVars.GetValue(cvar, dummy_value);
}


public Action Command_Cvar(int client, int args)
{
	if (args < 1)
	{
		if (client == 0)
		{
			ReplyToCommand(client, "[SM] Usage: sm_cvar <cvar|protect> [value]");
		}
		else
		{
			ReplyToCommand(client, "[SM] Usage: sm_cvar <cvar> [value]");
		}
		return Plugin_Handled;
	}

	char cvarname[64];
	GetCmdArg(1, cvarname, sizeof(cvarname));
	
	if (client == 0 && StrEqual(cvarname, "protect"))
	{
		if (args < 2)
		{
			ReplyToCommand(client, "[SM] Usage: sm_cvar <protect> <cvar>");
			return Plugin_Handled;
		}
		GetCmdArg(2, cvarname, sizeof(cvarname));
		ProtectVar(cvarname);
		ReplyToCommand(client, "[SM] %t", "Cvar is now protected", cvarname);
		return Plugin_Handled;
	}

	ConVar hndl = FindConVar(cvarname);
	if (hndl == null)
	{
		ReplyToCommand(client, "[SM] %t", "Unable to find cvar", cvarname);
		return Plugin_Handled;
	}

	if (!IsClientAllowedToChangeCvar(client, cvarname))
	{
		ReplyToCommand(client, "[SM] %t", "No access to cvar");
		return Plugin_Handled;
	}

	char value[255];
	if (args < 2)
	{
		hndl.GetString(value, sizeof(value));

		ReplyToCommand(client, "[SM] %t", "Value of cvar", cvarname, value);
		return Plugin_Handled;
	}

	GetCmdArg(2, value, sizeof(value));
	
	// The server passes the values of these directly into ServerCommand, following exec. Sanitize.
	if (StrEqual(cvarname, "servercfgfile", false) || StrEqual(cvarname, "lservercfgfile", false))
	{
		int pos = StrContains(value, ";", true);
		if (pos != -1)
		{
			value[pos] = '\0';
		}
	}

	if ((hndl.Flags & FCVAR_PROTECTED) != FCVAR_PROTECTED)
	{
		ShowActivity2(client, "[SM] ", "%t", "Cvar changed", cvarname, value);
	}
	else
	{
		ReplyToCommand(client, "[SM] %t", "Cvar changed", cvarname, value);
	}

	LogAction(client, -1, "\"%L\" changed cvar (cvar \"%s\") (value \"%s\")", client, cvarname, value);

	hndl.SetString(value, true);

	return Plugin_Handled;
}

public Action Command_ResetCvar(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_resetcvar <cvar>");

		return Plugin_Handled;
	}

	char cvarname[64];
	GetCmdArg(1, cvarname, sizeof(cvarname));
	
	ConVar hndl = FindConVar(cvarname);
	if (hndl == null)
	{
		ReplyToCommand(client, "[SM] %t", "Unable to find cvar", cvarname);
		return Plugin_Handled;
	}
	
	if (!IsClientAllowedToChangeCvar(client, cvarname))
	{
		ReplyToCommand(client, "[SM] %t", "No access to cvar");
		return Plugin_Handled;
	}

	hndl.RestoreDefault();

	char value[255];
	hndl.GetString(value, sizeof(value));

	if ((hndl.Flags & FCVAR_PROTECTED) != FCVAR_PROTECTED)
	{
		ShowActivity2(client, "[SM] ", "%t", "Cvar changed", cvarname, value);
	}
	else
	{
		ReplyToCommand(client, "[SM] %t", "Cvar changed", cvarname, value);
	}

	LogAction(client, -1, "\"%L\" reset cvar (cvar \"%s\") (value \"%s\")", client, cvarname, value);

	return Plugin_Handled;
}

