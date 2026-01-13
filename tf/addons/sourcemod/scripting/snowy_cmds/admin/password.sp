public Action Command_Password(int client, int args)
{
    char full[256];
    GetCmdArgString(full, sizeof(full));

    if ( args < 1 )
    {
        Snowy_ReplyToCommand(client, "Usage: password <password|no password>");
    } else {
        if ( StrEqual(full, "no password", false) ) // case-insensitive, so "No Password" also works
        {
            SendMessageToAll("%s %N removed the server password.", CHAT_PREFIX, client);

            // Build a command to clear the password
            ServerCommand("sv_password \"\"");
        } else {
            SendMessageToAll("%s %N applied a server password.", CHAT_PREFIX, client);

            // Build a proper command setting the password
            char cmd[300];
            Format(cmd, sizeof(cmd), "sv_password \"%s\"", full);
            ServerCommand("%s", cmd);
        }
    }

    return Plugin_Handled;
}
