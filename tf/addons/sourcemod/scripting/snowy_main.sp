#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <dhooks>
// #include <tf2attributes>

ConVar g_cvarwhitelistenabled;

#include <snowy/main>
#include <snowy/whitelist>

#include "snowy/whitelist.sp" // You first.
#include "snowy/explosive_arrows.sp"
#include "snowy/instantrespawn.sp"

#define JOINSOUND       "buttons/blip1.wav"

public Plugin myinfo = 
{
	name = "Snowy's Plugin",
	author = "snow2code",
	description = "Nothin",
	version = "0.1.0",      // SOURCEMOD_VERSION
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	PrecacheSound(JOINSOUND);

    Arrows_Start();
    InstantRespawn_Start();

    // Events
    HookEvent("player_connect", OnPlayerConnect, EventHookMode_Pre);
    HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
    HookEvent("player_team", OnPlayerTeam, EventHookMode_Pre);
	HookEvent("player_death", OnPlayerDeath);

	HookEvent("teamplay_round_start", RoundStart, EventHookMode_Post);
	HookEvent("teamplay_round_win", RoundEnd, EventHookMode_Post);

	HookUserMessage(GetUserMessageId("VoiceSubtitle"), VoiceHook, true); 

    // CVars
    g_cvarwhitelistenabled = CreateConVar("sm_whitelist_enabled", "1", "Enable or disable the Whitelist", FCVAR_NOTIFY);

    CheckPlayersWhitelisted(); // This is in snowy/whitelist.sp
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	new String:Game[32];
	GetGameFolderName(Game, sizeof(Game));
	
    if ( !StrEqual(Game, "tf") )
	{
		Format(error, err_max, "This plugin only works for Team Fortress 2");
		return APLRes_Failure;
	}
	
    return APLRes_Success;
}

public RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    InstantRespawn_RoundStart()
    // Ammo_RoundStart()
}

public RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    InstantRespawn_RoundEnd()
    // Ammo_RoundEnd()
}

public void OnClientPutInServer(int client)
{
    /*
    char name[256];
    GetClientName(client, name, sizeof(name));

    SendMessageToAll("I'm %s, I fucking love %s", name, "fish");
    */

	char name[64];
	GetClientName(client, name, sizeof(name));

    if ( !IsFakeClient(client) )
    {
        if ( IsClientWhitelisted(client) )
        {
            char message[256];
            GetJoinMessage(client, message, sizeof(message));

            SendMessageToAll("%s", message)

            EmitSoundToAll(JOINSOUND); // Play the sound, heh
        }
    }

    // if( !IsFakeClient(client) )
    // {
    //     SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitch);
    // }
}

public Action:OnPlayerConnect(Handle:event, const String:name[], bool:dontBroadcast)
{
    SetEventBroadcast(event, true);

    return Plugin_Handled;
}

public Action:OnPlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
    SetEventBroadcast(event, true);
    
    return Plugin_Continue;
}

public Action:OnPlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
    SetEventBroadcast(event, true);
    
    return Plugin_Continue;
}

public Action:VoiceHook(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	return Plugin_Handled;
}