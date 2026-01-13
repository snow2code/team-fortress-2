
public Action Command_Plugins(int client, int args)
{
	if ( args < 1 )
	{
        // if ( args == 0 )
        // {
        //     // Open admin menu, if the command has one.
        // }
        CommandUsage(client, "sm_plugins [load/unload] [file_name]");
		return Plugin_Handled;
	}

    char type[128];
    char fileName[256];
	GetCmdArg(1, type, sizeof(type));
	GetCmdArg(2, fileName, sizeof(fileName));

    StringToLower(type, type, sizeof(type));

    if ( StrEqual(type, "load", false) || StrEqual(type, "unload", false) )
    {
        char command[256];
        Format(command, sizeof(command), "sm plugins %s %s", type, fileName);

        if ( StrEqual(fileName, "snowy_commands", false) )
        {
            // Cuz your the server, you can unload that.
            if (client == 0 )
            {
                ServerCommand("%s", command);
            } else {
                Snowy_ReplyToCommand(client, "You cannot unload or load that plugin.");
            }
        } else {
            // Client 0 is the server, the server sees everything.
            if ( client == 0 )
            {
                ServerCommand("%s", command);
            } else {
                char responseBuffer[4096];
                ServerCommandEx(responseBuffer, sizeof(responseBuffer), "%s", command);
                
                if ( IsClientConnected(client) )
                {
                    // ReplyToCommand(client, responseBuffer);
                    
                    // Do some silly stuff cuz yes
                    if ( StrContains(responseBuffer, "failed to load: Unable to open file", false) != -1 )
                    {
                        Snowy_ReplyToCommand(client, "Cannot load plugin '%s'. (Did you enter the name correctly?)", fileName);
                    }

                    // Already loaded
                    else if ( StrContains(responseBuffer, "is already loaded", false) != -1 ) {
                        Snowy_ReplyToCommand(client, "The plugin '%s' is already loaded.", fileName);
                    
                    }

                    // Not loaded.
                    else if ( StrContains(responseBuffer, "is not loaded", false) != -1 ) {
                        Snowy_ReplyToCommand(client, "The plugin '%s' is not loaded.", fileName);
                    }

                    // Load
                    else if ( StrContains(responseBuffer, "Loaded plugin", false) != -1 ) {
                        Snowy_ReplyToCommand(client, "The plugin '%s' was loaded successfully, or not. Who knows..", fileName);
                    }

                    // Unload
                    else if ( StrContains(responseBuffer, "will be unloaded on the next frame", false) != -1 ) {
                        Snowy_ReplyToCommand(client, "The plugin '%s' was unloaded.", fileName);
                    // } else if ( StrContains(responseBuffer, "", false) ) {
                    //     Snowy_ReplyToCommand(client "The plugin '%s' ..", fileName);
                    }
                }
            }
        }
    }

    return Plugin_Handled;
}