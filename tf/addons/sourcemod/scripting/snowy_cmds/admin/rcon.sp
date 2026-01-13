
public Action Command_Rcon(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_rcon <args>");
		return Plugin_Handled;
	}

	char argstring[255];
	GetCmdArgString(argstring, sizeof(argstring));

	LogAction(client, -1, "\"%L\" console command (cmdline \"%s\")", client, argstring);

	if (client == 0) // They will already see the response in the console.
	{
		ServerCommand("%s", argstring);
	}
	else
	{
		char responseBuffer[4096];
		ServerCommandEx(responseBuffer, sizeof(responseBuffer), "%s", argstring);
		if (IsClientConnected(client))
		{
			ReplyToCommand(client, responseBuffer);
		}
	}

	return Plugin_Handled;
}
