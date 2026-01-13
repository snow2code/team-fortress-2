
#define SNOWYWHITELIST_CHAT_PREFIX 	"\x07FFD700[Snowy Whitelist]\x01"
#define SNOWYWHITELIST_CONS_PREFIX 	"[Snowy Whitelist]"

public void OnClientAuthorized(int client, const char[] auth)
{
    // Actual players only
    if ( !IsFakeClient(client) )
    {
        // Check if whilelist is enabled.
        if ( IsWhitelistEnabled() )
        {
            if ( !IsClientWhitelisted(client) )
            {
                Unautorized_Kick(client, auth)
                return;
            }
        }
    }
}

public bool IsWhitelistEnabled()
{
    return g_cvarwhitelistenabled.BoolValue;
}

void CheckPlayersWhitelisted()
{
    for ( int i = 1; i <= MaxClients; i++ )
    {
        // Only clients that are in game.
        if ( IsClientInGame(i) && !IsFakeClient(i) )
        {
            char auth[64];
            GetClientAuthId(i, AuthId_Steam2, auth, sizeof(auth));

            // Not whitelisted
            if ( !IsClientWhitelisted(i) )
            {
                Unautorized_Kick(i, auth);
            }
        }
    }
}

void Unautorized_Kick(int client, const char[] auth)
{
    char profileId[256];
    GetClientAuthId(client, AuthId_SteamID64, profileId, sizeof(profileId));

    Snowy_Log("Unauthorized Connection attempt, auth: '%s', ID '%s'", auth, profileId);

    if ( TranslationPhraseExists("auth_kick") )
    {
        KickClient(client, "%t", "auth_kick");
    } else {
        KickClient(client, "\nYou are not whitelisted.\n\nContact https://steamcommunity.com/id/snow2code if there's a mistake.");
    }

    PrintToChatAll("%s %N was kicked, reason: You are not whitelisted.", SNOWYWHITELIST_CHAT_PREFIX, client)
}